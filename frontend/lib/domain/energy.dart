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
