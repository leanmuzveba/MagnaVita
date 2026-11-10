import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_fasting/core/widgets/ruva_kit.dart';
import 'package:life_fasting/domain/activity.dart';
import 'package:life_fasting/domain/body.dart';
import 'package:life_fasting/domain/food.dart';
import 'package:life_fasting/domain/goals.dart';
import 'package:life_fasting/domain/plan.dart';
import 'package:life_fasting/state/providers.dart';

import '../widget_test.dart' show pumpApp;

Future<void> Function(ProviderContainer) _goals(UserGoals g, {bool body = false}) => (c) async {
  await c.read(settingsRepositoryProvider).setValue('goals', jsonEncode(g.toJson()));
  if (body) {
    await c.read(bodyActionsProvider).saveProfile(const BodyProfile(heightCm: 180, birthYear: 1991, sex: Sex.male));
    await c.read(bodyActionsProvider).addWeighIn(WeighIn(at: DateTime.utc(2026, 10, 3), weightKg: 90));
    await c.read(settingsRepositoryProvider).setValue('energy.level', 'moderate');
    await c.read(settingsRepositoryProvider).setValue('goal.weight', '{"goalKg":80,"paceKg":0.5}');
  }
};

Future<void> _openActivity(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 1800);
  await tester.tap(find.bySemanticsLabel('Activity').last);
  await tester.pumpAndSettle();
}

double _top(WidgetTester tester, String text) => tester.getTopLeft(find.text(text).first).dy;

void main() {
  testWidgets('lose weight: the day’s calories against your target come first', (tester) async {
    await pumpApp(tester, before: _goals(const UserGoals(main: MainGoal.loseWeight), body: true));
    final c = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    await c
        .read(foodRepositoryProvider)
        .insert(
          FoodEntry(
            day: DateTime(2026, 10, 4),
            meal: Meal.breakfast,
            loggedAt: DateTime.utc(2026, 10, 4, 6),
            name: 'Oats',
            grams: 100,
            nutrients: const {Nutrient.energy: 400},
          ),
        );
    c.invalidate(diaryDayProvider);
    await _openActivity(tester);
    expect(find.text('Today, toward your goal weight'), findsOneWidget);
    expect(find.text('400 kcal'), findsOneWidget);
    expect(find.text('of 2,325'), findsOneWidget);
    expect(find.text('About 1,925 kcal left today'), findsOneWidget);
    expect(_top(tester, 'Today, toward your goal weight'), lessThan(_top(tester, 'Strength workout')));
  });

  testWidgets('lose weight without a target: a way to set one up', (tester) async {
    await pumpApp(tester, before: _goals(const UserGoals(main: MainGoal.loseWeight)));
    await _openActivity(tester);
    expect(find.text('Get a daily calorie target in Profile'), findsOneWidget);
  });

  testWidgets('build muscle: training first, then workouts this week, streak and protein', (tester) async {
    await pumpApp(tester, before: _goals(const UserGoals(main: MainGoal.buildMuscle, trainingDays: 4), body: true));
    await _openActivity(tester);
    expect(find.text('Building muscle'), findsOneWidget);
    expect(find.text('0 of 4'), findsOneWidget);
    expect(find.text('of about 144 g'), findsOneWidget); // 90 kg × 1.6
    expect(_top(tester, 'Strength workout'), lessThan(_top(tester, 'Building muscle')));
  });

  testWidgets('get fitter: active minutes this week toward 150, logging before the gym', (tester) async {
    await pumpApp(
      tester,
      before: (c) async {
        await _goals(const UserGoals(main: MainGoal.getFitter))(c);
        await c
            .read(activityActionsProvider)
            .save(
              ActivityEntry(
                type: ActivityType.run,
                startedAt: DateTime.utc(2026, 10, 3, 7),
                minutes: 40,
                createdAt: DateTime.utc(2026, 10, 3),
                updatedAt: DateTime.utc(2026, 10, 3),
              ),
            );
      },
    );
    await _openActivity(tester);
    expect(find.text('Getting fitter'), findsOneWidget);
    // Sunday 4 Oct: the week began Monday 28 Sep, so Saturday's 40 minutes count.
    expect(find.text('40 of 150'), findsOneWidget);
    expect(find.textContaining('110 more active minutes'), findsOneWidget);
    expect(_top(tester, 'Getting fitter'), lessThan(_top(tester, 'Strength workout')));
  });

  testWidgets('fasting habits or no goal: no goal card', (tester) async {
    await pumpApp(tester, before: _goals(const UserGoals(main: MainGoal.fasting)));
    await _openActivity(tester);
    expect(find.text('YOUR GOAL'), findsNothing);
  });

  testWidgets('a new plan starts from your setup answers', (tester) async {
    await pumpApp(
      tester,
      before: _goals(
        const UserGoals(
          main: MainGoal.loseWeight,
          trainingDays: 5,
          level: PlanLevel.intermediate,
          equipment: PlanEquipment.bodyweight,
        ),
      ),
    );
    await _openActivity(tester);
    await tester.tap(find.text('Make a workout plan'));
    await tester.pumpAndSettle();
    bool chosen(String label) =>
        tester.widget<RuvaChip>(find.ancestor(of: find.text(label), matching: find.byType(RuvaChip))).selected;
    expect(chosen('Lose fat'), isTrue);
    expect(chosen('5 days'), isTrue);
    expect(chosen('Intermediate'), isTrue);
    expect(chosen('No equipment'), isTrue);
  });
}
