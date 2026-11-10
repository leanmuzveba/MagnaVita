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
