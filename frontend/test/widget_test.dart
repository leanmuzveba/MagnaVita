import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_fasting/data/update_checker.dart';
import 'package:life_fasting/domain/settings.dart';
import 'package:life_fasting/features/food/barcode_scanner_screen.dart';
import 'package:life_fasting/features/food/meal_photo_screen.dart';
import 'package:life_fasting/main.dart';
import 'package:life_fasting/state/providers.dart';

import 'helpers.dart';

late StreamController<DateTime> _ticks;
late FakeNotifications notifications;

/// Canned TheMealDB responses; tests never use the network.
late FakeRecipeApi recipeApi;

/// Canned Open Food Facts products, and the code the fake scanner returns.
late FakeFoodFactsApi foodFacts;
String? scannedBarcode;

/// Fake Gemini replies; null = no API key configured.
FakeMealPhotoApi? mealPhoto;

/// Fake hardware step counter (permission + readings).
late FakeStepCounter steps;

/// Fake Health Connect (watch data).
late FakeHealthSource watch;

/// What the release page reports (null = no newer version).
AppRelease? latestRelease;

/// The file the fake picker hands to Restore (null = cancelled).
Uint8List? backupFile;

/// Boots the real app on an in-memory database with a fake clock.

late FakeAccountService accounts;

/// [accountChosen]: the account step is already done (used without one).
Future<FakeClock> pumpApp(
  WidgetTester tester, {
  AgeEligibility eligibility = AgeEligibility.adult,
  bool accountChosen = true,
}) async {
  await loadAppFonts();
  final clock = FakeClock(DateTime(2026, 10, 4, 7, 24, 36));
  final db = await openTestDb();
  _ticks = StreamController<DateTime>.broadcast();
  notifications = FakeNotifications();
  recipeApi = FakeRecipeApi();
  foodFacts = FakeFoodFactsApi();
  scannedBarcode = null;
  mealPhoto = FakeMealPhotoApi();
  steps = FakeStepCounter();
  watch = FakeHealthSource();
  latestRelease = null;
  backupFile = null;
  accounts = FakeAccountService();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock.call),
      notificationServiceProvider.overrideWithValue(notifications),
      recipeApiProvider.overrideWithValue(recipeApi),
      foodFactsApiProvider.overrideWithValue(foodFacts),
      barcodeScannerProvider.overrideWithValue((_) async => scannedBarcode),
      mealPhotoApiProvider.overrideWith((ref) async => mealPhoto),
      stepCounterProvider.overrideWithValue(steps),
      healthSourceProvider.overrideWithValue(watch),
      updateCheckerProvider.overrideWithValue(FakeUpdateChecker(() => latestRelease)),
      mealPhotoPickerProvider.overrideWithValue((_) async => onePixelPng),
      backupPickerProvider.overrideWithValue(() async => backupFile),
      accountServiceProvider.overrideWithValue(accounts),
      // Test-driven ticks instead of a real periodic timer.
      nowProvider.overrideWith((ref) async* {
        yield clock();
        yield* _ticks.stream;
      }),
    ],
  );
  await container
      .read(settingsRepositoryProvider)
      .save(AppSettings(eligibility: eligibility, onboardingComplete: eligibility != AgeEligibility.unknown));
  if (accountChosen) await container.read(settingsRepositoryProvider).setFlag('account.local', true);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const LifeFastingApp()));
  await tester.pumpAndSettle();
  addTearDown(() async {
    container.dispose();
    unawaited(_ticks.close());
    await db.close();
  });
  return clock;
}

Future<void> tick(WidgetTester tester, FakeClock clock, Duration d) async {
  clock.advance(d);
  _ticks.add(clock());
  await tester.pumpAndSettle();
}

/// Opens the full timer from the home "Hours fasted" row.
Future<void> openTimer(WidgetTester tester) async {
  ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).removeCurrentSnackBar();
  await tester.pumpAndSettle();
  await tester.tap(find.bySemanticsLabel(RegExp(r'^Hours fasted')));
  await tester.pumpAndSettle();
}

/// Centre + menu → [option] (e.g. "Start fast", "Drink water").
Future<void> quickAdd(WidgetTester tester, String option) async {
  await tester.tap(find.byTooltip('Quick add'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows the greeting, steps and today’s numbers', (tester) async {
    await pumpApp(tester);
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('SUNDAY · 4 OCT'), findsOneWidget);
    expect(find.text('Today’s steps'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Calories eaten: 0 kcal')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Hours fasted: —\. Not fasting')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Water: 0 ml\. of ')), findsOneWidget);
  });

  testWidgets('timer page keeps the ring, pop-up cards and target link', (tester) async {
    await pumpApp(tester);
    await openTimer(tester);
    expect(find.text('READY WHEN YOU ARE'), findsOneWidget);
    expect(find.text('TARGET'), findsNothing, reason: 'cards live in the pop-up');
    await tester.tap(find.text('00:00:00'));
    await tester.pumpAndSettle();
    expect(find.text('TARGET'), findsOneWidget);
    expect(find.text('16 hours'), findsOneWidget);
    expect(find.text('IF STARTED NOW'), findsOneWidget);
    expect(find.text('11:24 PM'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Change target'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Good morning'), findsOneWidget);
  });

  testWidgets('start from + → running → end saves to history', (tester) async {
    final clock = await pumpApp(tester);
    await quickAdd(tester, 'Start fast');
    expect(find.text('Fast started — the timer is running.'), findsOneWidget);
    await tick(tester, clock, const Duration(hours: 12, minutes: 24));
    expect(find.bySemanticsLabel('Hours fasted: 12 h 24 m. Target 16 h · 78%'), findsOneWidget);

    await openTimer(tester);
    expect(find.text('Sunday 4 October · Session in progress'), findsOneWidget);
    await tester.tap(find.text('12:24:00'));
    await tester.pumpAndSettle();
    expect(find.text('FAST STARTED'), findsOneWidget);
    expect(find.text('PLANNED END'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('End fast').last);
    await tester.pumpAndSettle();
    expect(find.text('End this session?'), findsOneWidget);
    expect(find.textContaining('Recorded so far: 12 h 24 m', findRichText: true), findsOneWidget);
    await tester.tap(find.text('End session'));
    await tester.pumpAndSettle();
    expect(find.text('Start fast'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
  });

  testWidgets('End fast from + asks for confirmation', (tester) async {
    final clock = await pumpApp(tester);
    await quickAdd(tester, 'Start fast');
    await tick(tester, clock, const Duration(hours: 2));
    await quickAdd(tester, 'End fast');
    expect(find.text('End this session?'), findsOneWidget);
    await tester.tap(find.text('End session'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'^Hours fasted: —')), findsOneWidget);
  });

  testWidgets('target reached keeps counting and never asks to continue', (tester) async {
    final clock = await pumpApp(tester);
    await quickAdd(tester, 'Start fast');
    await tick(tester, clock, const Duration(hours: 17));
    expect(find.bySemanticsLabel(RegExp(r'^Hours fasted: 17 h 0 m')), findsOneWidget);
    await openTimer(tester);
    expect(find.text('TARGET REACHED'), findsOneWidget);
    expect(find.text('17:00:00'), findsOneWidget);
  });

  testWidgets('milestone sheet shows the uncertainty disclaimer', (tester) async {
    await pumpApp(tester);
    await openTimer(tester);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Ketosis may begin')));
    await tester.pumpAndSettle();
    expect(find.text('Roughly 12–18 hours (estimate)'), findsOneWidget);
    expect(find.textContaining('cannot measure ketones'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Roughly 12–18 hours (estimate)'), findsNothing);
  });

  testWidgets('edit start time sheet previews the resolved start', (tester) async {
    await pumpApp(tester);
    await quickAdd(tester, 'Start fast');
    await openTimer(tester);
    await tester.tap(find.text('Edit start time'));
    await tester.pumpAndSettle();
    expect(find.text('STARTED AT'), findsOneWidget);
    expect(find.text('Will start Sun 4 Oct at 7:24 AM.'), findsOneWidget);
    expect(find.text('Sun 4 Oct, 7:24 AM'), findsOneWidget); // date and time, any day
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('STARTED AT'), findsNothing);
  });

  testWidgets('bottom nav: Home · Activity · (+) · Nutrition · Profile; History lives in Profile', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Activity').last);
    await tester.pumpAndSettle();
    expect(find.text('Today’s steps'), findsNothing);
    expect(find.text('Log an activity'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('All'), findsOneWidget); // History's filter chips
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Nutrition').last);
    await tester.pumpAndSettle();
    expect(find.text('Food Diary'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Today’s steps'), findsOneWidget);
  });

  testWidgets('+ menu: water adds a glass, food opens Nutrition, weigh-in opens Profile', (tester) async {
    await pumpApp(tester);
    await quickAdd(tester, 'Drink water');
    expect(find.text('Added 250 ml · 250 ml today'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Water: 250 ml')), findsOneWidget);
    await quickAdd(tester, 'Log food');
    expect(find.text('Food Diary'), findsOneWidget);
    await quickAdd(tester, 'Weigh in');
    expect(find.text('Weigh-in'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '72.5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Weight: 72.5 kg'), findsOneWidget);
  });

  testWidgets('steps: ask for permission, then count from the sensor', (tester) async {
    await pumpApp(tester);
    steps.allowed = false;
    final c = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    c.invalidate(todayStepsProvider);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Count my steps'));
    await tester.pumpAndSettle();
    steps.readingsController.add(5000); // since boot: starts the day's count
    await tester.pumpAndSettle();
    steps.readingsController.add(8240);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Today’s steps: 3,240, 32% of goal'), findsOneWidget);

    // Change the goal: 10,000 → 8,000.
    await tester.tap(find.text('Goal 10,000'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byTooltip('Less'));
      await tester.pump();
    }
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Goal 8,000'), findsOneWidget);
    expect(find.bySemanticsLabel('Today’s steps: 3,240, 41% of goal'), findsOneWidget);
  });

  testWidgets('steps: type in what your watch shows; the phone keeps adding, a later sync takes over', (tester) async {
    await pumpApp(tester);
    tester.view.physicalSize = const Size(390, 1600);
    final c = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    steps.readingsController.add(5000);
    await tester.pumpAndSettle();
    steps.readingsController.add(8000); // phone: 3,000 today
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Today’s steps: 3,000, 30% of goal'), findsOneWidget);

    await tester.tap(find.text('Edit steps'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '9800');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Today’s steps: 9,800, 98% of goal'), findsOneWidget);
    expect(find.textContaining('· edited'), findsOneWidget);

    steps.readingsController.add(8200); // 200 more on the phone
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Today’s steps: 10,000, 100% of goal'), findsOneWidget);
    final today = DateTime(2026, 10, 4);
    expect((await tester.runAsync(() => c.read(dayStatsProvider(today).future)))!.steps, 10000); // the export too

    // The watch syncs past it: its own count is used again.
    await c.read(settingsRepositoryProvider).setFlag('watch.linked', true);
    watch
      ..granted = true
      ..stepCount = 12000;
    c.read(watchActionsProvider).refresh();
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Today’s steps: 12,000, 100% of goal'), findsOneWidget);
    expect(find.textContaining('· watch'), findsOneWidget);

    await tester.tap(find.text('Edit steps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go back to the automatic count'));
    await tester.pumpAndSettle();
    expect(await c.read(manualStepsProvider(today).future), isNull);
  });

  testWidgets('Home offers an update when a newer build is published', (tester) async {
    await pumpApp(tester);
    expect(find.text('New version available'), findsNothing);
    latestRelease = const AppRelease(
      build: 999,
      apkUrl: 'https://example.com/ruva-999.apk',
      version: '1.2.999',
      notes: 'Watch fixes',
    );
    final c = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    c.invalidate(availableUpdateProvider);
    await tester.pumpAndSettle();
    expect(find.text('New version available · 1.2.999'), findsOneWidget);
    expect(find.text('Watch fixes'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
  });
}
