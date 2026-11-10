import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_fasting/domain/body.dart';
import 'package:life_fasting/domain/energy.dart';
import 'package:life_fasting/state/providers.dart';

import '../widget_test.dart' show pumpApp;

WeighIn _w(double kg, {double? waist, double? neck, double? hip}) =>
    WeighIn(at: DateTime.utc(2026, 10, 1), weightKg: kg, waistCm: waist, neckCm: neck, hipCm: hip);

Future<void> _openProfile(WidgetTester tester) async {
  await pumpApp(tester);
  tester.view.physicalSize = const Size(390, 3000);
  await tester.tap(find.bySemanticsLabel('Profile').last);
  await tester.pumpAndSettle();
  await tester.tap(find.bySemanticsLabel(RegExp('Add your name')));
  await tester.pumpAndSettle();
}

void main() {
  test('BMI, adult bands, healthy range and distance to it', () {
    expect(bmi(80, 180).toStringAsFixed(1), '24.7');
    expect(bmiBand(24.7, adult: true), BmiBand.healthy);
    expect(bmiBand(31, adult: true), BmiBand.obese);
    expect(bmiBand(31, adult: false), isNull);
    final r = healthyRange(180);
    expect(r.low.toStringAsFixed(1), '59.9');
    expect(r.high.toStringAsFixed(1), '80.7');
    expect(toHealthyRange(90, 180).toStringAsFixed(1), '-9.3');
    expect(toHealthyRange(55, 180).toStringAsFixed(1), '4.9');
    expect(toHealthyRange(70, 180), 0);
  });

  test('resting energy: adults with every detail only', () {
    final today = DateTime(2026, 10, 4);
    const p = BodyProfile(heightCm: 165, birthYear: 1996, sex: Sex.female);
    expect(restingEnergy(p, 60, today)!.round(), 1320); // 600 + 1031.25 − 150 − 161
    expect(restingEnergy(p, null, today), isNull);
    expect(restingEnergy(const BodyProfile(heightCm: 165, birthYear: 1996), 60, today), isNull);
    expect(restingEnergy(const BodyProfile(heightCm: 165, birthYear: 2011, sex: Sex.female), 50, today), isNull);
  });

  test('body fat: tape method preferred, BMI fallback, adults with sex only', () {
    final tape = bodyFat(sex: Sex.male, age: 30, heightCm: 178, latest: _w(80, waist: 90, neck: 38))!;
    expect(tape.method, BodyFatMethod.tape);
    expect(tape.percent.toStringAsFixed(1), '20.1');
    final rough = bodyFat(sex: Sex.male, age: 30, heightCm: 200, latest: _w(100))!;
    expect(rough.method, BodyFatMethod.bmi);
    expect(rough.percent.toStringAsFixed(1), '20.7');
    // A woman's tape estimate needs hips; without them it falls back to BMI.
    expect(
      bodyFat(sex: Sex.female, age: 30, heightCm: 165, latest: _w(60, waist: 75, neck: 32))!.method,
      BodyFatMethod.bmi,
    );
    expect(bodyFat(sex: null, age: 30, heightCm: 178, latest: _w(80)), isNull);
    expect(bodyFat(sex: Sex.male, age: 16, heightCm: 178, latest: _w(80)), isNull);
  });

  testWidgets('profile: enter stats → BMI, distance to range, body fat; history editable', (tester) async {
    await _openProfile(tester);
    expect(find.text('Add your height and weight to see your BMI and healthy weight range.'), findsOneWidget);
    expect(find.text('Add your height, weight, age and sex to see your resting energy.'), findsOneWidget);

    await tester.tap(find.text('Update stats'));
    await tester.pumpAndSettle();
    final f = find.byType(TextField);
    await tester.enterText(f.at(0), '90'); // weight kg
    await tester.enterText(f.at(1), '180'); // height cm
    await tester.enterText(f.at(2), '35'); // age
    await tester.tap(find.text('Male'));
    await tester.pumpAndSettle();
    await tester.enterText(f.at(3), '95'); // waist
    await tester.enterText(f.at(4), '40'); // neck
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('27.8'), findsOneWidget);
    expect(find.text('Above the healthy range'), findsOneWidget);
    expect(find.text('Healthy range for your height: 59.9 kg – 80.7 kg'), findsOneWidget);
    expect(find.text('To reach it: lose about 9.3 kg'), findsOneWidget);
    expect(find.text('From your tape measurements (US Navy method) · about ±3%'), findsOneWidget);
    expect(find.bySemanticsLabel('Age: 35 years'), findsOneWidget);
    // BMR = 10·90 + 6.25·180 − 5·35 + 5
    expect(find.text('1,855 kcal a day'), findsOneWidget);
    // No records yet: pick a level → calories to keep your weight steady.
    expect(find.text('Calories to keep your weight steady'.toUpperCase()), findsNothing);
    await tester.tap(find.text('Moderately active'));
    await tester.pumpAndSettle();
    expect(find.text('2,875 kcal a day'), findsOneWidget); // 1855 × 1.55
    expect(find.textContaining('The level you chose.'), findsOneWidget);

    // Goal: below BMI 18.5 is refused; 80 kg at 0.5 kg a week → 2875 − 550.
    await tester.tap(find.text('Set a goal weight'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '50');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('The lowest goal MagnaVita sets is 59.9 kg'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '80');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.text('80 kg at 0.5 kg a week'), findsOneWidget);
    expect(find.text('Eat about 2,325 kcal a day to lose about 0.5 kg a week'), findsOneWidget);

    // History: delete the weigh-in → back to "add your weight".
    await tester.tap(find.byTooltip(RegExp('^90 kg on ')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No weigh-ins yet.'), findsOneWidget);
  });

  testWidgets('under 18: BMI shown without adult categories or weight targets', (tester) async {
    await _openProfile(tester);
    final c = ProviderScope.containerOf(tester.element(find.text('Your profile')));
    await c.read(bodyActionsProvider).saveProfile(const BodyProfile(heightCm: 165, birthYear: 2011, sex: Sex.female));
    await c.read(bodyActionsProvider).addWeighIn(_w(50));
    await tester.pumpAndSettle();
    expect(find.text('18.4'), findsOneWidget);
    expect(find.textContaining('don’t apply under 18'), findsOneWidget);
    expect(find.textContaining('To reach it'), findsNothing);
    expect(find.text('Resting energy (BMR)'), findsNothing);
    expect(find.text('Below the healthy range'), findsNothing);
  });

  testWidgets('weight tracking can be turned off', (tester) async {
    await _openProfile(tester);
    await tester.tap(find.text('Track my weight'));
    await tester.pumpAndSettle();
    expect(find.text('Weight tracking is off.'), findsOneWidget);
    expect(find.text('Weight history'.toUpperCase()), findsNothing);
  });
}
