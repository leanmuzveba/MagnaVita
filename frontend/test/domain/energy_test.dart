import 'package:flutter_test/flutter_test.dart';
import 'package:life_fasting/domain/body.dart';
import 'package:life_fasting/domain/energy.dart';
import 'package:life_fasting/domain/settings.dart';
import 'package:life_fasting/state/providers.dart';

import '../helpers.dart';

void main() {
  test('steps above the baseline count; the watch replaces them', () {
    expect(stepKcal(1500, 80), 0);
    expect(stepKcal(12000, 80), 400); // 10 000 × 0.0005 × 80
    expect(const DayMovement(loggedKcal: 100, steps: 12000).activeKcal(80), 500);
    expect(const DayMovement(loggedKcal: 100, watchKcal: 300, steps: 12000).activeKcal(80), 400);
    expect(const DayMovement(watchKcal: 0, steps: 12000).activeKcal(80), 400, reason: 'watch linked, nothing synced');
  });

  test('maintenance: measured after 7 days, else the chosen level, else unknown', () {
    final week = List.filled(7, const DayMovement(loggedKcal: 400));
    final m = energyFrom(resting: 1600, weightKg: 70, days: week, chosen: ActivityLevel.sedentary)!;
    expect(m.measured, isTrue);
    expect(m.maintenance, 1600 * 1.2 + 400);
    expect(m.level, ActivityLevel.light); // 2320 / 1600 = 1.45
    final c = energyFrom(resting: 1600, weightKg: 70, days: week.take(6).toList(), chosen: ActivityLevel.moderate)!;
    expect(c.measured, isFalse);
    expect(c.maintenance, 1600 * 1.55);
    expect(energyFrom(resting: 1600, weightKg: 70, days: const []), isNull);
    expect(ActivityLevel.nearest(1.0), ActivityLevel.sedentary);
    expect(ActivityLevel.nearest(2.4), ActivityLevel.veryActive);
  });

  test('calorie target: pace, safe minimum, gain cap, at goal', () {
    const man = Energy(resting: 1855, maintenance: 2875, level: ActivityLevel.moderate, measured: false);
    var t = calorieTarget(energy: man, sex: Sex.male, currentKg: 90, goal: const WeightGoal(goalKg: 80));
    expect(t.direction, WeightDirection.lose);
    expect(t.kcal, 2875 - 550);
    expect(t.weeklyKg, closeTo(-0.5, 1e-9));
    expect(t.limited, isFalse);
    // 1 kg a week would mean 1775 kcal, under his resting energy (1855).
    t = calorieTarget(energy: man, sex: Sex.male, currentKg: 90, goal: const WeightGoal(goalKg: 80, paceKg: 1));
    expect(t.kcal, 1855);
    expect(t.limited, isTrue);
    expect(t.weeklyKg, closeTo(-(2875 - 1855) * 7 / 7700, 1e-9));
    // A small, sedentary woman: never below 1200 or her resting energy.
    const woman = Energy(resting: 1150, maintenance: 1380, level: ActivityLevel.sedentary, measured: false);
    t = calorieTarget(energy: woman, sex: Sex.female, currentKg: 60, goal: const WeightGoal(goalKg: 55));
    expect(t.kcal, 1200);
    expect(t.limited, isTrue);
    // Gaining is capped at 0.5 kg a week.
    t = calorieTarget(energy: man, sex: Sex.male, currentKg: 70, goal: const WeightGoal(goalKg: 75, paceKg: 1));
    expect(t.direction, WeightDirection.gain);
    expect(t.kcal, 2875 + 550);
    // Within half a kilo: at goal.
    t = calorieTarget(energy: man, sex: Sex.male, currentKg: 80.3, goal: const WeightGoal(goalKg: 80));
    expect(t.direction, WeightDirection.maintain);
    expect(t.kcal, 2875);
    expect(minGoalKg(180).toStringAsFixed(1), '59.9');
  });

  test('forecast: resting energy follows the weight; holds at the goal', () {
    const man = Energy(resting: 1855, maintenance: 2875, level: ActivityLevel.moderate, measured: false);
    final today = DateTime(2026, 11, 10);
    Forecast run(WeightGoal? goal) => forecast(
      startKg: 90,
      heightCm: 180,
      age: 35,
      sex: Sex.male,
      energy: man,
      intake: 2325,
      source: IntakeSource.target,
      today: today,
      goal: goal,
    );
    final f = run(const WeightGoal(goalKg: 80));
    expect(f.weeklyKg, hasLength(13));
    expect(f.weeklyKg.first, 90);
    expect(f.weeklyKg.last, closeTo(84.47, 0.01)); // a little slower than 0.5 kg a week
    for (var i = 1; i < f.weeklyKg.length; i++) {
      expect(f.weeklyKg[i], lessThan(f.weeklyKg[i - 1]));
    }
    expect(f.reachesGoal, isNull);
    final near = run(const WeightGoal(goalKg: 88));
    expect(near.reachesGoal, isNotNull);
    expect(near.reachesGoal!.isAfter(today), isTrue);
    expect(near.weeklyKg.last, 88);
    expect(near.weeklyKg.where((w) => w < 88), isEmpty, reason: 'never projects past the goal');
  });

  test('diary intake needs 7 logged days', () {
    expect(diaryIntake(List.filled(6, 2000)), isNull);
    expect(diaryIntake([...List.filled(6, 2000), 2700]), 2100);
  });

  test('past days: phone step totals since setup give a measured level', () async {
    final clock = FakeClock(DateTime(2026, 11, 10, 9));
    final db = await openTestDb();
    final c = await testContainer(db, clock);
    final repo = c.read(settingsRepositoryProvider);
    await repo.save(AppSettings(eligibility: AgeEligibility.adult, memberSince: DateTime(2026, 11, 1, 20).toUtc()));
    for (var d = 2; d <= 9; d++) {
      await repo.setValue('steps.phone.2026-11-0$d', '12000');
    }
    await repo.setValue('steps.phone.2026-11-01', '30000'); // the setup day itself isn't complete
    await c.read(bodyActionsProvider).saveProfile(const BodyProfile(heightCm: 180, birthYear: 1991, sex: Sex.male));
    await c.read(bodyActionsProvider).addWeighIn(WeighIn(at: clock.now.toUtc(), weightKg: 80));
    c.invalidate(settingsProvider);
    final e = (await c.read(energyProvider.future))!;
    expect(e.measured, isTrue);
    expect(e.days, 8);
    expect(e.activeKcal, 400);
    expect(e.resting, 1755); // 10·80 + 6.25·180 − 5·35 + 5
    expect(e.maintenance, 1755 * 1.2 + 400);
  });
}
