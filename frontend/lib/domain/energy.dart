import 'dart:math' as math;

import 'activity.dart' show bmr;
import 'body.dart';

/// Resting energy (BMR, Mifflin-St Jeor) in kcal a day for an adult with
/// height, age, sex and a weight; null when something is missing or under 18.
double? restingEnergy(BodyProfile profile, double? weightKg, DateTime today) {
  final age = profile.ageOn(today);
  final h = profile.heightCm;
  final sex = profile.sex;
  if (weightKg == null || h == null || sex == null || age == null || age < 18) return null;
  return bmr(weightKg: weightKg, heightCm: h, age: age, sex: sex);
}

/// The usual activity multipliers on resting energy.
enum ActivityLevel {
  sedentary(1.2),
  light(1.375),
  moderate(1.55),
  active(1.725),
  veryActive(1.9);

  const ActivityLevel(this.factor);
  final double factor;

  /// The level whose multiplier is closest to [factor].
  static ActivityLevel nearest(double factor) =>
      values.reduce((a, b) => (a.factor - factor).abs() <= (b.factor - factor).abs() ? a : b);
}

/// Steps a sedentary day already includes (moving around the house).
const baselineSteps = 2000;

/// Days of records needed before the measured level replaces the one you chose.
const minMeasuredDays = 7;

/// How far back the measured level looks.
const measuredWindowDays = 28;

/// Energy for walking: about 0.5 kcal per kg per 1000 steps above the baseline
/// (resting energy excluded, like activity calories).
double stepKcal(int steps, double weightKg) => math.max(0, steps - baselineSteps) * 0.0005 * weightKg;

/// One past day's movement: calories from activities you logged, what the
/// watch counted (which already includes walking) and steps.
class DayMovement {
  const DayMovement({this.loggedKcal = 0, this.watchKcal, this.steps});
  final double loggedKcal;
  final double? watchKcal;
  final int? steps;

  /// Active calories for the day; steps count only when the watch didn't.
  double activeKcal(double weightKg) => loggedKcal + switch (watchKcal) {
    final w? when w > 0 => w,
    _ => steps == null ? 0 : stepKcal(steps!, weightKg),
  };
}

/// Calories a day: resting energy, your activity level and where it came from.
class Energy {
  const Energy({
    required this.resting,
    required this.maintenance,
    required this.level,
    required this.measured,
    this.days = 0,
    this.activeKcal = 0,
  });

  final double resting;

  /// Calories a day that keep your weight steady (TDEE).
  final double maintenance;
  final ActivityLevel level;

  /// True when worked out from your records, false when it's the level you chose.
  final bool measured;
  final int days;

  /// Average active calories a day over [days].
  final double activeKcal;
}

/// Maintenance calories from at least [minMeasuredDays] of records (resting ×
/// 1.2 for daily life, plus your average active calories), else from the level
/// you chose; null when neither is known.
Energy? energyFrom({
  required double resting,
  required double weightKg,
  required List<DayMovement> days,
  ActivityLevel? chosen,
}) {
  if (days.length >= minMeasuredDays) {
    final active = days.fold(0.0, (s, d) => s + d.activeKcal(weightKg)) / days.length;
    final maintenance = resting * ActivityLevel.sedentary.factor + active;
    return Energy(
      resting: resting,
      maintenance: maintenance,
      level: ActivityLevel.nearest(maintenance / resting),
      measured: true,
      days: days.length,
      activeKcal: active,
    );
  }
  if (chosen == null) return null;
  return Energy(resting: resting, maintenance: resting * chosen.factor, level: chosen, measured: false);
}

/// Energy in a kilogram of body weight (the usual rule of thumb).
const kcalPerKg = 7700.0;

/// Paces you can pick, in kg a week. Gaining is capped at 0.5 kg.
const paceOptionsKg = [0.25, 0.5, 0.75, 1.0];
const maxGainPaceKg = 0.5;

/// The lowest daily target MagnaVita suggests: your resting energy, and never
/// under 1200 kcal (women) or 1500 kcal (men).
double calorieFloor(double resting, Sex sex) => math.max(resting, sex == Sex.female ? 1200 : 1500);

/// The lowest goal weight allowed: BMI 18.5 at [heightCm].
double minGoalKg(double heightCm) => healthyRange(heightCm).low;

enum WeightDirection { lose, maintain, gain }

/// Within half a kilo of the goal counts as there.
WeightDirection directionFor(double currentKg, double goalKg) => (goalKg - currentKg).abs() < 0.5
    ? WeightDirection.maintain
    : goalKg < currentKg
    ? WeightDirection.lose
    : WeightDirection.gain;

/// A goal weight and how fast to get there.
class WeightGoal {
  const WeightGoal({required this.goalKg, this.paceKg = 0.5});
  final double goalKg;
  final double paceKg; // per week

  Map<String, Object> toJson() => {'goalKg': goalKg, 'paceKg': paceKg};

  static WeightGoal? fromJson(Map<String, dynamic>? j) => j == null
      ? null
      : WeightGoal(goalKg: (j['goalKg'] as num).toDouble(), paceKg: (j['paceKg'] as num).toDouble());
}

/// Daily calories for a goal, and the pace they actually give.
class CalorieTarget {
  const CalorieTarget({required this.direction, required this.kcal, required this.weeklyKg, this.limited = false});
  final WeightDirection direction;
  final double kcal;

  /// Expected change a week at [kcal] (negative = losing).
  final double weeklyKg;

  /// True when the safe minimum stopped the target going lower.
  final bool limited;
}

CalorieTarget calorieTarget({required Energy energy, required Sex sex, required double currentKg, required WeightGoal goal}) {
  final direction = directionFor(currentKg, goal.goalKg);
  final m = energy.maintenance;
  switch (direction) {
    case WeightDirection.maintain:
      return CalorieTarget(direction: direction, kcal: m, weeklyKg: 0);
    case WeightDirection.gain:
      final pace = math.min(goal.paceKg, maxGainPaceKg);
      return CalorieTarget(direction: direction, kcal: m + pace * kcalPerKg / 7, weeklyKg: pace);
    case WeightDirection.lose:
      final floor = calorieFloor(energy.resting, sex);
      final wanted = m - goal.paceKg * kcalPerKg / 7;
      final kcal = math.max(wanted, floor);
      return CalorieTarget(
        direction: direction,
        kcal: kcal,
        weeklyKg: -math.max(0, m - kcal) * 7 / kcalPerKg,
        limited: wanted < floor,
      );
  }
}

/// What you eat comes from the diary when at least [minIntakeDays] of the last
/// [intakeWindowDays] days have food logged.
const minIntakeDays = 7, intakeWindowDays = 14;

/// Weeks the forecast looks ahead.
const forecastWeeks = 12;

enum IntakeSource { diary, target, maintenance }

/// Projected weight: one point a week from now, and when the goal is reached.
class Forecast {
  const Forecast({required this.weeklyKg, required this.intake, required this.source, this.reachesGoal});

  /// [0] is today's weight, then one value per week.
  final List<double> weeklyKg;
  final double intake;
  final IntakeSource source;
  final DateTime? reachesGoal;
}

/// Day-by-day projection eating [intake] kcal a day: resting energy is
/// recalculated as weight changes, activity stays as it is now. Once the goal
/// is reached the line holds there (you'd move to maintenance calories).
Forecast forecast({
  required double startKg,
  required double heightCm,
  required int age,
  required Sex sex,
  required Energy energy,
  required double intake,
  required IntakeSource source,
  required DateTime today,
  WeightGoal? goal,
  int weeks = forecastWeeks,
}) {
  double burn(double w) {
    final r = bmr(weightKg: w, heightCm: heightCm, age: age, sex: sex);
    return energy.measured ? r * ActivityLevel.sedentary.factor + energy.activeKcal : r * energy.level.factor;
  }

  final direction = goal == null ? null : directionFor(startKg, goal.goalKg);
  var w = startKg;
  DateTime? reached;
  final points = [startKg];
  for (var day = 1; day <= weeks * 7; day++) {
    if (reached == null) {
      w -= (burn(w) - intake) / kcalPerKg;
      final hit = switch (direction) {
        WeightDirection.lose => w <= goal!.goalKg,
        WeightDirection.gain => w >= goal!.goalKg,
        _ => false,
      };
      if (hit) {
        reached = DateTime(today.year, today.month, today.day + day);
        w = goal!.goalKg;
      }
    }
    if (day % 7 == 0) points.add(w);
  }
  return Forecast(weeklyKg: points, intake: intake, source: source, reachesGoal: reached);
}

/// Average calories a day from the diary (days with food logged), or null
/// when fewer than [minIntakeDays] have any.
double? diaryIntake(List<double> loggedDayTotals) => loggedDayTotals.length < minIntakeDays
    ? null
    : loggedDayTotals.reduce((a, b) => a + b) / loggedDayTotals.length;
