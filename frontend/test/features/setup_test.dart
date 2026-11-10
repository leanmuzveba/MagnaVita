import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_fasting/domain/body.dart';
import 'package:life_fasting/domain/energy.dart';
import 'package:life_fasting/domain/goals.dart';
import 'package:life_fasting/domain/plan.dart';
import 'package:life_fasting/domain/settings.dart';
import 'package:life_fasting/state/providers.dart';

import '../widget_test.dart' show accounts, pumpApp;

Future<void> _fill(WidgetTester tester, Map<String, String> fields) async {
  for (final MapEntry(key: label, value: text) in fields.entries) {
    final field = find.descendant(
      of: find.ancestor(of: find.text(label.toUpperCase()), matching: find.byType(Column)).first,
      matching: find.byType(TextField),
    );
    await tester.enterText(field, text);
  }
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

void main() {
  testWidgets('setup: every answer is saved, then the app opens', (tester) async {
    await pumpApp(tester, setupDone: false);
    tester.view.physicalSize = const Size(390, 1400);
    expect(find.text('About you'), findsOneWidget);
    expect(find.text('STEP 1 OF 7'), findsOneWidget);

    await _fill(tester, {'Name': 'Rudo', 'Year of birth': '1991', 'Height (cm)': '180'});
    await _tap(tester, 'Male');
    await _tap(tester, 'Next');
    expect(find.text('Your weight today'), findsOneWidget);
    await _fill(tester, {'Weight (kg)': '90'});
    await _tap(tester, 'Next');

    await _tap(tester, 'Lose weight');
    await _fill(tester, {'Goal weight (kg)': '50'});
    await _tap(tester, 'Next');
    expect(find.text('0.25 kg a week'), findsOneWidget);
    expect(find.textContaining('The lowest goal MagnaVita sets is 59.9 kg', skipOffstage: false), findsOneWidget);
    await _fill(tester, {'Goal weight (kg)': '80'});
    await _tap(tester, 'Next');

    await _tap(tester, 'Moderately active');
    await _tap(tester, 'Next');
    await _tap(tester, '3 meals');
    await _tap(tester, 'Next');
    await _tap(tester, '4 days');
    await _tap(tester, 'Beginner');
    await _tap(tester, 'Dumbbells at home');
    await _tap(tester, 'Next');
    await _tap(tester, 'Vegetarian');
    await _tap(tester, 'Peanuts');
    await _tap(tester, 'Finish');

    expect(find.text('About you'), findsNothing);
    final c = _container(tester);
    final body = await c.read(bodyProfileProvider.future);
    expect((body.heightCm, body.birthYear, body.sex), (180, 1991, Sex.male));
    expect((await c.read(weighInsProvider.future)).single.weightKg, 90);
    final goal = (await c.read(weightGoalProvider.future))!;
    expect((goal.goalKg, goal.paceKg), (80, 0.5));
    expect(await c.read(chosenActivityLevelProvider.future), ActivityLevel.moderate);
    final goals = await c.read(userGoalsProvider.future);
    expect(goals.main, MainGoal.loseWeight);
    expect(goals.mealsPerDay, 3);
    expect(goals.trainingDays, 4);
    expect(goals.level, PlanLevel.beginner);
    expect(goals.equipment, PlanEquipment.dumbbells);
    final s = await c.read(settingsProvider.future);
    expect(s.userName, 'Rudo');
    expect(s.diet, DietPreference.vegetarian);
    expect(s.allergies, {Allergen.peanuts});
    expect((await c.read(calorieTargetProvider.future))!.kcal, closeTo(1855 * 1.55 - 550, 1e-6));
    expect(await c.read(setupDoneProvider.future), isTrue);
  });

  testWidgets('setup: an under-18 birth year is refused; skip keeps what is valid', (tester) async {
    await pumpApp(tester, setupDone: false);
    tester.view.physicalSize = const Size(390, 1400);
    await _fill(tester, {'Year of birth': '2015'});
    await _tap(tester, 'Next');
    expect(find.textContaining('goals are for people 18 and over'), findsOneWidget);
    await _fill(tester, {'Name': 'Tari'});
    await _tap(tester, 'Skip for now');
    expect(find.text('About you'), findsNothing);
    final c = _container(tester);
    expect((await c.read(settingsProvider.future)).userName, 'Tari');
    expect((await c.read(bodyProfileProvider.future)).birthYear, isNull);
  });

  testWidgets('existing install: setup opens once, filled in from what is saved', (tester) async {
    await pumpApp(
      tester,
      setupDone: false,
      before: (c) async {
        await c.read(settingsProvider.notifier).change((s) => s.copyWith(userName: 'Lean'));
        await c.read(bodyActionsProvider).saveProfile(const BodyProfile(heightCm: 172, birthYear: 1990, sex: Sex.female));
        await c.read(bodyActionsProvider).addWeighIn(WeighIn(at: DateTime.utc(2026, 10, 1), weightKg: 68));
      },
    );
    tester.view.physicalSize = const Size(390, 1400);
    expect(find.widgetWithText(TextField, 'Lean'), findsOneWidget);
    expect(find.widgetWithText(TextField, '1990'), findsOneWidget);
    expect(find.widgetWithText(TextField, '172'), findsOneWidget);
    await _tap(tester, 'Next');
    expect(find.widgetWithText(TextField, '68'), findsOneWidget);
    await _tap(tester, 'Skip for now');
    final c = _container(tester);
    expect(await c.read(weighInsProvider.future), hasLength(1), reason: 'an unchanged weight adds no weigh-in');
  });

  testWidgets('signed in: setup answers are saved to the account', (tester) async {
    await pumpApp(tester, accountChosen: false, setupDone: false);
    tester.view.physicalSize = const Size(390, 1400);
    await _tap(tester, 'Already have an account? Sign in');
    await _fill(tester, {'Email': 'ann@example.com', 'Password': 'correct horse'});
    await _tap(tester, 'Sign in');
    expect(find.text('About you'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Ann'), findsOneWidget, reason: 'name from the account');
    await _fill(tester, {'Height (cm)': '165'});
    await _tap(tester, 'Female');
    await _tap(tester, 'Next');
    await _tap(tester, 'Next');
    await _tap(tester, 'Get fitter');
    await _tap(tester, 'Skip for now');
    await tester.pumpAndSettle();
    final p = accounts.profile!;
    expect(p['display_name'], 'Ann');
    expect(p['height_cm'], 165);
    expect(p['sex'], 'female');
    expect(p['main_goal'], 'getFitter');
    expect(p['setup_done'], isTrue);
  });

  testWidgets('new phone: signing in brings the saved setup back and skips the questions', (tester) async {
    await pumpApp(tester, accountChosen: false, setupDone: false);
    accounts.profile = {
      'display_name': 'Ann',
      'sex': 'female',
      'birth_year': 1990,
      'height_cm': 168,
      'weight_kg': 70,
      'main_goal': 'loseWeight',
      'goal_weight_kg': 64,
      'pace_kg': 0.25,
      'activity_level': 'light',
      'meals_per_day': 2,
      'training_days': 3,
      'experience': 'intermediate',
      'equipment': 'gym',
      'diet': 'pescatarian',
      'allergies': ['sesame'],
      'units': 'metric',
      'setup_done': true,
    };
    await _tap(tester, 'Already have an account? Sign in');
    await _fill(tester, {'Email': 'ann@example.com', 'Password': 'correct horse'});
    await _tap(tester, 'Sign in');
    expect(find.text('About you'), findsNothing);
    final c = _container(tester);
    expect((await c.read(bodyProfileProvider.future)).heightCm, 168);
    expect((await c.read(weighInsProvider.future)).single.weightKg, 70);
    expect((await c.read(weightGoalProvider.future))!.paceKg, 0.25);
    expect(await c.read(chosenActivityLevelProvider.future), ActivityLevel.light);
    expect((await c.read(userGoalsProvider.future)).mealsPerDay, 2);
    expect((await c.read(settingsProvider.future)).allergies, {Allergen.sesame});
  });
}
