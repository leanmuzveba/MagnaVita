import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../data/account.dart';
import '../data/activity_repository.dart';
import '../data/backup.dart';
import '../data/body_repository.dart';
import '../data/food_facts_api.dart';
import '../data/food_repository.dart';
import '../data/health_source.dart';
import '../data/hydration_repository.dart';
import '../data/meal_photo_api.dart';
import '../data/kitchen_repository.dart';
import '../data/notification_service.dart';
import '../data/recipe_repository.dart';
import '../data/review_repository.dart';
import '../data/session_repository.dart';
import '../data/settings_repository.dart';
import '../data/step_counter.dart';
import '../data/update_checker.dart';
import '../domain/activity.dart';
import '../domain/body.dart';
import '../domain/energy.dart';
import '../domain/fasting_session.dart';
import '../domain/goals.dart';
import '../domain/fasting_timer.dart';
import '../domain/food.dart';
import '../domain/history.dart';
import '../domain/hydration.dart';
import '../domain/kitchen.dart';
import '../domain/kitchen_review.dart';
import '../domain/meal_estimate.dart';
import '../domain/plan.dart';
import '../domain/recipe.dart';
import '../domain/settings.dart';
import '../domain/steps.dart';
import '../domain/workout.dart';

/// Opened in main() and injected with an override.
final databaseProvider = Provider<Database>((ref) => throw UnimplementedError('override databaseProvider'));

final sessionRepositoryProvider = Provider((ref) => SessionRepository(ref.watch(databaseProvider)));
final settingsRepositoryProvider = Provider((ref) => SettingsRepository(ref.watch(databaseProvider)));

/// Current instant. Overridden in tests for a fixed clock.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Ticks once a second. The displayed time is recomputed from stored
/// timestamps on every tick, so pausing (app in background) never drifts.
final nowProvider = StreamProvider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  final controller = StreamController<DateTime>();
  controller.add(clock());
  final timer = Timer.periodic(const Duration(seconds: 1), (_) => controller.add(clock()));
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    final s = await repo.load();
    if (s.memberSince != null) return s;
    // First run (or first run of a version that tracks it): remember the date.
    final stamped = s.copyWith(memberSince: ref.read(clockProvider)().toUtc());
    await repo.save(stamped);
    return stamped;
  }

  Future<void> save(AppSettings next) async {
    await ref.read(settingsRepositoryProvider).save(next);
    state = AsyncData(next);
    unawaited(ref.read(accountActionsProvider).push());
  }

  Future<void> change(AppSettings Function(AppSettings) edit) async => save(edit(await future));
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Thrown when an action is blocked by the safety rules (FR-12).
class NotEligibleError extends StateError {
  NotEligibleError() : super('Fasting sessions are only available to confirmed adults.');
}

class ActiveSessionNotifier extends AsyncNotifier<FastingSession?> {
  @override
  Future<FastingSession?> build() => ref.watch(sessionRepositoryProvider).active();

  SessionRepository get _repo => ref.read(sessionRepositoryProvider);
  DateTime _now() => ref.read(clockProvider)().toUtc();

  Future<void> start() async {
    final settings = await ref.read(settingsProvider.future);
    if (!settings.canFast) throw NotEligibleError();
    if (await future != null) return;
    final now = _now();
    final s = await _repo.insert(
      FastingSession(startedAt: now, targetMinutes: settings.targetMinutes, createdAt: now, updatedAt: now),
    );
    state = AsyncData(s);
    ref.invalidate(historyProvider);
    await syncNotifications(ref);
  }

  /// Ends the session and returns it as saved.
  Future<FastingSession?> end() async {
    final s = await future;
    if (s == null) return null;
    final now = _now();
    // Guard against a device clock that moved behind the start time.
    final endAt = now.isAfter(s.startedAt) ? now : s.startedAt.add(const Duration(seconds: 1));
    final ended = s.copyWith(endedAt: () => endAt, updatedAt: now);
    await _repo.update(ended);
    state = const AsyncData(null);
    ref.invalidate(historyProvider);
    await syncNotifications(ref);
    return ended;
  }

  /// Returns a validation error, or null when saved.
  Future<SessionTimeError?> editStart(DateTime startedAt) async {
    final s = await future;
    if (s == null) return null;
    final now = _now();
    final error = validateSessionTimes(
      start: startedAt,
      now: now,
      id: s.id,
      others: await ref.read(sessionRepositoryProvider).all(),
    );
    if (error != null) return error;
    final edited = s.copyWith(startedAt: startedAt.toUtc(), updatedAt: now);
    await _repo.update(edited);
    state = AsyncData(edited);
    ref.invalidate(historyProvider);
    await syncNotifications(ref);
    return null;
  }
}

final activeSessionProvider = AsyncNotifierProvider<ActiveSessionNotifier, FastingSession?>(ActiveSessionNotifier.new);

/// All sessions, newest first.
final historyProvider = FutureProvider<List<FastingSession>>((ref) => ref.watch(sessionRepositoryProvider).all());

/// Derived timer state for the Home screen; null until data has loaded.
final timerSnapshotProvider = Provider.family<TimerSnapshot?, double>((ref, gapFraction) {
  final session = ref.watch(activeSessionProvider).value;
  final settings = ref.watch(settingsProvider).value;
  final now = ref.watch(nowProvider).value;
  if (settings == null || now == null || ref.watch(activeSessionProvider).isLoading) return null;
  return TimerSnapshot.compute(
    session: session,
    idleTargetMinutes: settings.targetMinutes,
    now: now,
    gapFraction: gapFraction,
  );
});

/// Edit / delete any saved session from History (FR-08, FR-09).
class SessionActions {
  SessionActions(this._ref);
  final Ref _ref;

  /// Returns a validation error, or null when saved.
  Future<SessionTimeError?> save(FastingSession edited) async {
    final now = _ref.read(clockProvider)().toUtc();
    final error = validateSessionTimes(
      start: edited.startedAt,
      end: edited.endedAt,
      now: now,
      id: edited.id,
      others: await _ref.read(sessionRepositoryProvider).all(),
    );
    if (error != null) return error;
    await _ref.read(sessionRepositoryProvider).update(edited.copyWith(updatedAt: now));
    await _refresh();
    return null;
  }

  Future<void> delete(FastingSession s) async {
    await _ref.read(sessionRepositoryProvider).delete(s.id!);
    await _refresh();
  }

  Future<void> _refresh() async {
    _ref.invalidate(historyProvider);
    _ref.invalidate(activeSessionProvider);
    await syncNotifications(_ref);
  }

  /// "Delete all data": sessions, settings, preferences and scheduled reminders.
  Future<void> deleteEverything() async {
    await _ref.read(sessionRepositoryProvider).deleteAll();
    await _ref.read(hydrationRepositoryProvider).deleteAll();
    await _ref.read(activityRepositoryProvider).deleteAll();
    await _ref.read(kitchenRepositoryProvider).deleteAll();
    await _ref.read(reviewRepositoryProvider).deleteAll();
    await _ref.read(foodRepositoryProvider).deleteAll();
    await _ref.read(bodyRepositoryProvider).deleteAll();
    await _ref.read(recipeRepositoryProvider).deleteAll();
    await _ref.read(myRecipeRepositoryProvider).deleteAll();
    await _ref.read(settingsRepositoryProvider).clear();
    await _ref.read(notificationServiceProvider).cancelAll();
    _reloadAll();
  }

  /// The backup file's bytes, to save somewhere safe.
  Future<Uint8List> backup() => Backup.create(_ref.read(databaseProvider));

  /// Replaces this phone's data with a backup; false when the file isn't one.
  Future<bool> restore(Uint8List bytes) async {
    if (!await Backup.restore(_ref.read(databaseProvider), bytes)) return false;
    _reloadAll();
    syncNotifications(_ref);
    return true;
  }

  /// Every screen re-reads the database.
  void _reloadAll() {
    _ref.invalidate(historyProvider);
    _ref.invalidate(activeSessionProvider);
    _ref.invalidate(hydrationDayProvider);
    _ref.invalidate(activityDayProvider);
    _ref.invalidate(recentActivitiesProvider);
    _ref.invalidate(kitchenProvider);
    _ref.invalidate(shoppingListProvider);
    _ref.invalidate(diaryDayProvider);
    _ref.invalidate(customFoodsProvider);
    _ref.invalidate(recentFoodsProvider);
    _ref.invalidate(savedFoodsProvider);
    _ref.invalidate(bodyProfileProvider);
    _ref.invalidate(weighInsProvider);
    _ref.invalidate(savedRecipesProvider);
    _ref.invalidate(lastCookedProvider);
    _ref.invalidate(myRecipesProvider);
    _ref.invalidate(recipeSuggestionsProvider);
    _ref.invalidate(notificationPrefsProvider);
    _ref.invalidate(settingsProvider);
    _ref.invalidate(stepGoalProvider);
    _ref.invalidate(daySummariesProvider);
    _ref.invalidate(dayStatsProvider);
    _ref.invalidate(watchStatusProvider);
    _ref.invalidate(workoutProvider);
    _ref.invalidate(planProvider);
    _ref.invalidate(restSecondsProvider);
  }
}

final sessionActionsProvider = Provider(SessionActions.new);

/// Picks a backup file to restore; null when cancelled (tests swap it).
final backupPickerProvider = Provider<Future<Uint8List?> Function()>(
  (ref) =>
      () async => (await FilePicker.pickFile())?.readAsBytes(),
);

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationPrefsNotifier extends AsyncNotifier<List<NotificationPreference>> {
  @override
  Future<List<NotificationPreference>> build() => ref.watch(settingsRepositoryProvider).notificationPrefs();

  /// Saves a preference. Turning one on asks the OS for permission first;
  /// returns false (and keeps it off) if permission is refused.
  Future<bool> set(NotificationPreference p) async {
    if (p.enabled && !await ref.read(notificationServiceProvider).requestPermission()) return false;
    await ref.read(settingsRepositoryProvider).saveNotificationPref(p);
    final all = [for (final x in await future) x.type == p.type ? p : x];
    state = AsyncData(all);
    await ref
        .read(settingsProvider.notifier)
        .change((s) => s.copyWith(notificationsEnabled: all.any((x) => x.enabled)));
    await syncNotifications(ref);
    return true;
  }
}

final notificationPrefsProvider = AsyncNotifierProvider<NotificationPrefsNotifier, List<NotificationPreference>>(
  NotificationPrefsNotifier.new,
);

/// Idempotently (re)schedules exactly the notifications the user has enabled.
/// Called after every session change and on app launch.
Future<void> syncNotifications(Ref ref) async {
  // Everything read before the first await: callers don't wait, so the ref may be gone by then.
  final svc = ref.read(notificationServiceProvider);
  final repo = ref.read(settingsRepositoryProvider);
  final sessions = ref.read(sessionRepositoryProvider);
  final settings = await ref.read(settingsProvider.future);
  final prefs = {for (final p in await repo.notificationPrefs()) p.type: p};
  final active = await sessions.active();
  final allowed = settings.canFast; // Never notify under-18 or unconfirmed users.

  final target = prefs[NotificationType.targetReached];
  if (allowed && active != null && (target?.enabled ?? false)) {
    await svc.scheduleTargetReached(active.plannedEnd);
  } else {
    await svc.cancel(NotificationService.targetReachedId);
  }

  // Water reminders are general wellness, not fasting: allowed for everyone who opted in.
  if (prefs[NotificationType.waterReminder]?.enabled ?? false) {
    await svc.scheduleWaterReminders();
  } else {
    await svc.cancelWaterReminders();
  }

  if (prefs[NotificationType.monthlyReview]?.enabled ?? false) {
    await svc.scheduleMonthlyReview();
  } else {
    await svc.cancel(NotificationService.monthlyReviewId);
  }

  // Training-day reminders, from your workout plan (general fitness, so for everyone).
  final planJson = await repo.value(PlanNotifier.key);
  final plan = planJson == null ? null : WorkoutPlan.fromJson(jsonDecode(planJson) as Map<String, dynamic>);
  if (plan?.remindAt case final at?) {
    await svc.scheduleWorkoutReminders(plan!.weekdays, at ~/ 60, at % 60);
  } else {
    await svc.cancelWorkoutReminders();
  }

  final daily = prefs[NotificationType.dailyReminder];
  if (allowed && daily != null && daily.enabled && daily.hour != null && daily.minute != null) {
    await svc.scheduleDailyReminder(daily.hour!, daily.minute!);
  } else {
    await svc.cancel(NotificationService.dailyReminderId);
  }
}

final launchSyncProvider = FutureProvider<void>((ref) async {
  try {
    await syncNotifications(ref);
  } catch (e) {
    debugPrint('Notification sync failed: $e'); // Never block the app on reminders.
  }
});

// --- Hydration (PRD v1.2 §9) ------------------------------------------------

final hydrationRepositoryProvider = Provider((ref) => HydrationRepository(ref.watch(databaseProvider)));

/// Local calendar day (midnight) containing [t].
DateTime localDay(DateTime t) {
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// Water entries for one local day, oldest first. Key: local midnight.
final hydrationDayProvider = FutureProvider.family<List<HydrationEntry>, DateTime>((ref, day) {
  final next = DateTime(day.year, day.month, day.day + 1);
  return ref.watch(hydrationRepositoryProvider).between(day, next);
});

class HydrationActions {
  HydrationActions(this._ref);
  final Ref _ref;

  HydrationRepository get _repo => _ref.read(hydrationRepositoryProvider);
  DateTime _now() => _ref.read(clockProvider)().toUtc();

  /// Logs [amountMl] at [at] (default: now). Rejects non-positive or future amounts.
  Future<void> add(double amountMl, {DateTime? at}) async {
    final now = _now();
    final when = (at ?? now).toUtc();
    if (amountMl <= 0 || when.isAfter(now)) return;
    await _repo.insert(HydrationEntry(amountMl: amountMl, loggedAt: when, createdAt: now, updatedAt: now));
    _ref.invalidate(hydrationDayProvider);
    _ref.invalidate(daySummariesProvider);
  }

  Future<void> update(HydrationEntry e) async {
    if (e.amountMl <= 0) return;
    await _repo.update(e.copyWith(updatedAt: _now()));
    _ref.invalidate(hydrationDayProvider);
    _ref.invalidate(daySummariesProvider);
  }

  Future<void> delete(HydrationEntry e) async {
    await _repo.delete(e.id!);
    _ref.invalidate(hydrationDayProvider);
    _ref.invalidate(daySummariesProvider);
  }
}

final hydrationActionsProvider = Provider(HydrationActions.new);

// --- Activity (PRD v1.2 §8) -------------------------------------------------

final activityRepositoryProvider = Provider((ref) => ActivityRepository(ref.watch(databaseProvider)));

/// Activities that started on one local day (key: local midnight), newest first.
final activityDayProvider = FutureProvider.family<List<ActivityEntry>, DateTime>((ref, day) {
  final next = DateTime(day.year, day.month, day.day + 1);
  return ref.watch(activityRepositoryProvider).between(day, next);
});

/// Latest activities, newest first.
final recentActivitiesProvider = FutureProvider((ref) => ref.watch(activityRepositoryProvider).recent());

class ActivityActions {
  ActivityActions(this._ref);
  final Ref _ref;

  ActivityRepository get _repo => _ref.read(activityRepositoryProvider);
  DateTime _now() => _ref.read(clockProvider)().toUtc();

  void _refresh() {
    _ref.invalidate(activityDayProvider);
    _ref.invalidate(recentActivitiesProvider);
    _ref.invalidate(daySummariesProvider);
  }

  /// Returns false (and saves nothing) for an out-of-range duration or a future start.
  Future<bool> save(ActivityEntry e) async {
    final now = _now();
    if (e.minutes < minActivityMinutes || e.minutes > maxActivityMinutes || e.startedAt.isAfter(now)) return false;
    final notes = e.notes.trim();
    if (e.id == null) {
      await _repo.insert(e.copyWith(notes: notes));
    } else {
      await _repo.update(e.copyWith(notes: notes, updatedAt: now));
    }
    _refresh();
    return true;
  }

  Future<void> delete(ActivityEntry e) async {
    await _repo.delete(e);
    _refresh();
  }
}

final activityActionsProvider = Provider(ActivityActions.new);

// --- Strength workouts --------------------------------------------------------

/// The bundled exercise library, A–Z.
final exerciseLibraryProvider = FutureProvider<List<LibraryExercise>>((ref) async {
  final list = jsonDecode(await rootBundle.loadString('assets/exercises/exercises.json')) as List;
  return [for (final j in list) LibraryExercise.fromJson(j as Map<String, dynamic>)]
    ..sort((a, b) => a.name.compareTo(b.name));
});

/// Every strength session you've logged, newest first.
final strengthSessionsProvider = FutureProvider<List<ActivityEntry>>((ref) async {
  ref.watch(recentActivitiesProvider); // recompute when activities change
  final all = await ref.watch(activityRepositoryProvider).all();
  return [
    for (final a in all.reversed)
      if (a.exercises.isNotEmpty) a,
  ];
});

/// Every exercise you've logged, by [exerciseKey], newest session first.
final exerciseHistoryProvider = FutureProvider<Map<String, List<(DateTime, Exercise)>>>((ref) async {
  final history = <String, List<(DateTime, Exercise)>>{};
  for (final a in await ref.watch(strengthSessionsProvider.future)) {
    for (final x in a.exercises) {
      (history[exerciseKey(x)] ??= []).add((a.startedAt, x));
    }
  }
  return history;
});

/// Rest between sets, in seconds (you change it from the rest timer).
final restSecondsProvider = FutureProvider<int>(
  (ref) async =>
      int.tryParse(await ref.watch(settingsRepositoryProvider).value('workout.rest') ?? '') ?? defaultRestSeconds,
);

/// The strength workout in progress (null = none), saved after every change.
class WorkoutNotifier extends AsyncNotifier<Workout?> {
  static const _key = 'workout.current';

  @override
  Future<Workout?> build() async {
    final json = await ref.watch(settingsRepositoryProvider).value(_key);
    return json == null ? null : Workout.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  DateTime _now() => ref.read(clockProvider)().toUtc();

  Future<void> _set(Workout? w) async {
    state = AsyncData(w);
    await ref.read(settingsRepositoryProvider).setValue(_key, w == null ? null : jsonEncode(w.toJson()));
  }

  Future<void> _edit(Workout Function(Workout) change) async {
    final w = await future;
    if (w != null) await _set(change(w));
  }

  Future<void> _editSets(int i, List<SetLog> Function(List<SetLog>) change) => _edit(
    (w) => w.copyWith(exercises: [...w.exercises]..[i] = w.exercises[i].withLog(change([...w.exercises[i].log]))),
  );

  Future<void> start() async {
    if (await future != null) return;
    await _set(Workout(startedAt: _now()));
    unawaited(ref.read(notificationServiceProvider).requestPermission()); // for the rest timer
  }

  /// Starts day [day] of your plan: its exercises and sets, at last time's weights.
  Future<void> startPlanned(int day) async {
    if (await future != null) return;
    final plan = await ref.read(planProvider.future);
    if (plan == null) return;
    final history = await ref.read(exerciseHistoryProvider.future);
    await ref.read(settingsRepositoryProvider).setValue('workout.rest', '${plan.rest}');
    ref.invalidate(restSecondsProvider);
    await _set(
      Workout(
        startedAt: _now(),
        planDay: day,
        exercises: [
          for (final x in plan.days[day].exercises)
            x.withLog([
              for (final s in x.log)
                s.copyWith(kg: () => history[exerciseKey(x)]?.first.$2.log.lastOrNull?.kg, done: false),
            ]),
        ],
      ),
    );
    unawaited(ref.read(notificationServiceProvider).requestPermission());
  }

  /// Adds an exercise, starting from what you did last time (or 3 × 10).
  Future<void> addExercise(String name, {String? libraryId}) async {
    final fresh = Exercise.logged(name, const [], libraryId: libraryId);
    final last = (await ref.read(exerciseHistoryProvider.future))[exerciseKey(fresh)]?.first.$2;
    final log = [for (final s in last?.log ?? List.filled(3, const SetLog())) s.copyWith(done: false)];
    await _edit((w) => w.copyWith(exercises: [...w.exercises, fresh.withLog(log)]));
  }

  Future<void> removeExercise(int i) => _edit((w) => w.copyWith(exercises: [...w.exercises]..removeAt(i)));

  Future<void> updateSet(int i, int j, SetLog s) => _editSets(i, (log) => log..[j] = s);

  Future<void> addSet(int i) =>
      _editSets(i, (log) => log..add((log.lastOrNull ?? const SetLog()).copyWith(done: false)));

  Future<void> removeSet(int i, int j) => _editSets(i, (log) => log..removeAt(j));

  /// Ticks a set on or off; ticking one on starts the rest timer.
  Future<void> toggleDone(int i, int j) async {
    final w = await future;
    if (w == null) return;
    final done = !w.exercises[i].log[j].done;
    await _editSets(i, (log) => log..[j] = log[j].copyWith(done: done));
    if (done) await _rest(await ref.read(restSecondsProvider.future));
  }

  Future<void> _rest(int seconds) async {
    final until = _now().add(Duration(seconds: seconds));
    await _edit((w) => w.copyWith(restUntil: () => until));
    await ref.read(notificationServiceProvider).scheduleRestOver(until);
  }

  /// Longer or shorter rest: for this rest and the ones after it.
  Future<void> adjustRest(int deltaSeconds) async {
    final seconds = ((await ref.read(restSecondsProvider.future)) + deltaSeconds).clamp(minRestSeconds, maxRestSeconds);
    await ref.read(settingsRepositoryProvider).setValue('workout.rest', '$seconds');
    ref.invalidate(restSecondsProvider);
    final until = (await future)?.restUntil;
    if (until != null && until.isAfter(_now())) {
      final next = until.add(Duration(seconds: deltaSeconds));
      await _edit((w) => w.copyWith(restUntil: () => next));
      await ref.read(notificationServiceProvider).scheduleRestOver(next);
    }
  }

  Future<void> skipRest() async {
    await ref.read(notificationServiceProvider).cancel(NotificationService.restOverId);
    await _edit((w) => w.copyWith(restUntil: () => null));
  }

  /// Saves what you did as a strength activity; null when nothing was ticked.
  Future<ActivityEntry?> finish() async {
    final w = await future;
    if (w == null || w.completed.isEmpty) return null;
    final now = _now();
    final minutes = now.difference(w.startedAt).inMinutes.clamp(minActivityMinutes, maxActivityMinutes);
    final weighIns = await ref.read(weighInsProvider.future);
    final kg = (await ref.read(bodyProfileProvider.future)).trackWeight ? weighIns.lastOrNull?.weightKg : null;
    final entry = ActivityEntry(
      type: ActivityType.strength,
      startedAt: w.startedAt,
      minutes: minutes,
      kcal: kg == null ? null : activityKcal(ActivityType.strength, null, minutes, kg),
      exercises: w.completed,
      createdAt: now,
      updatedAt: now,
    );
    if (!await ref.read(activityActionsProvider).save(entry)) return null;
    if (w.planDay case final day?) await ref.read(planProvider.notifier).done(day);
    await discard();
    return entry;
  }

  Future<void> discard() async {
    await ref.read(notificationServiceProvider).cancel(NotificationService.restOverId);
    await _set(null);
  }
}

final workoutProvider = AsyncNotifierProvider<WorkoutNotifier, Workout?>(WorkoutNotifier.new);

/// Your weekly workout plan (null = none yet).
class PlanNotifier extends AsyncNotifier<WorkoutPlan?> {
  static const key = 'workout.plan';

  @override
  Future<WorkoutPlan?> build() async {
    final json = await ref.watch(settingsRepositoryProvider).value(key);
    return json == null ? null : WorkoutPlan.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> _set(WorkoutPlan? p) async {
    final before = state.value;
    state = AsyncData(p);
    await ref.read(settingsRepositoryProvider).setValue(key, p == null ? null : jsonEncode(p.toJson()));
    if (before?.remindAt != p?.remindAt || before?.weekdays != p?.weekdays) await syncNotifications(ref);
  }

  /// Trains on [weekday] (1 = Monday) or not; keeps at least one day.
  Future<void> toggleWeekday(int weekday) async {
    final p = await future;
    if (p == null) return;
    final days = p.weekdays.contains(weekday) ? [...p.weekdays.where((w) => w != weekday)] : [...p.weekdays, weekday]
      ..sort();
    if (days.isNotEmpty) await _set(p.copyWith(weekdays: days));
  }

  /// Reminds you on training days at [minutes] after midnight (null = off);
  /// false when the phone won't allow notifications.
  Future<bool> setReminder(int? minutes) async {
    final p = await future;
    if (p == null) return false;
    if (minutes != null && !await ref.read(notificationServiceProvider).requestPermission()) return false;
    await _set(p.copyWith(remindAt: () => minutes));
    return true;
  }

  Future<void> create({
    required PlanGoal goal,
    required int daysPerWeek,
    required PlanLevel level,
    required PlanEquipment equipment,
  }) async {
    // Usually loaded already (the setup screen shows it); waiting on it costs a frame.
    final List<LibraryExercise> library =
        ref.read(exerciseLibraryProvider).value ?? await ref.read(exerciseLibraryProvider.future);
    final fresh = buildPlan(library, goal: goal, daysPerWeek: daysPerWeek, level: level, equipment: equipment);
    final old = await future; // a new plan keeps your reminder, and your days when there are as many
    await _set(
      old == null
          ? fresh
          : fresh.copyWith(
              weekdays: old.weekdays.length == daysPerWeek ? old.weekdays : null,
              remindAt: () => old.remindAt,
            ),
    );
  }

  Future<void> _editDay(int day, List<Exercise> Function(List<Exercise>) change) async {
    final p = await future;
    if (p == null) return;
    await _set(p.copyWith(days: [...p.days]..[day] = PlanDay(p.days[day].focus, change([...p.days[day].exercises]))));
  }

  /// Swaps exercise [i] of [day] for [x], keeping its sets and reps.
  Future<void> swap(int day, int i, LibraryExercise x) =>
      _editDay(day, (list) => list..[i] = Exercise.logged(x.name, list[i].log, libraryId: x.id));

  Future<void> setSetsReps(int day, int i, int sets, int reps) =>
      _editDay(day, (list) => list..[i] = Exercise(list[i].name, sets: sets, reps: reps, libraryId: list[i].libraryId));

  Future<void> remove(int day, int i) => _editDay(day, (list) => list..removeAt(i));

  /// You finished [day]: the next one is up.
  Future<void> done(int day) async {
    final p = await future;
    if (p != null) await _set(p.copyWith(next: (day + 1) % p.days.length));
  }

  Future<void> delete() => _set(null);
}

final planProvider = AsyncNotifierProvider<PlanNotifier, WorkoutPlan?>(PlanNotifier.new);

// --- History (PRD v1.2 §10) -------------------------------------------------

/// Per-day summaries of everything recorded in [range] (local days, end exclusive).
final daySummariesProvider = FutureProvider.family<Map<DateTime, DaySummary>, (DateTime, DateTime)>((ref, range) async {
  final (from, to) = range;
  final sessions = await ref.watch(historyProvider.future);
  final water = await ref.watch(hydrationRepositoryProvider).between(from, to);
  final activities = await ref.watch(activityRepositoryProvider).between(from, to);
  final fromUtc = from.toUtc(), toUtc = to.toUtc();
  return summariseByDay(
    sessions: sessions.where((s) => !s.startedAt.isBefore(fromUtc) && s.startedAt.isBefore(toUtc)),
    water: water,
    activities: activities,
  );
});

// --- My Kitchen (PRD v1.2 §4) ----------------------------------------------

final kitchenRepositoryProvider = Provider((ref) => KitchenRepository(ref.watch(databaseProvider)));

/// Ingredients currently in the kitchen, A–Z.
final kitchenProvider = FutureProvider((ref) => ref.watch(kitchenRepositoryProvider).active());

class KitchenActions {
  KitchenActions(this._ref);
  final Ref _ref;

  KitchenRepository get _repo => _ref.read(kitchenRepositoryProvider);
  DateTime _now() => _ref.read(clockProvider)().toUtc();

  /// Adds or updates; returns the validation problem, or null when saved.
  Future<IngredientError?> save(Ingredient i) async {
    final error = validateIngredient(i);
    if (error != null) return error;
    if (i.id == null) {
      await _repo.insert(i);
    } else {
      await _repo.update(i.copyWith(updatedAt: _now()));
    }
    _ref.invalidate(kitchenProvider);
    return null;
  }

  /// Used up: leaves the kitchen but stays in history.
  Future<void> markFinished(Ingredient i) => _setStatus(i, IngredientStatus.finished);

  /// Spoiled/removed in a review: leaves the kitchen but stays in history.
  Future<void> discard(Ingredient i) => _setStatus(i, IngredientStatus.discarded);

  Future<void> _setStatus(Ingredient i, IngredientStatus status) async {
    final now = _now();
    await _repo.update(i.copyWith(status: status, statusAt: () => now, updatedAt: now));
    _ref.invalidate(kitchenProvider);
  }

  /// Removes the record entirely (user's explicit choice only).
  Future<void> delete(Ingredient i) async {
    await _repo.delete(i.id!);
    _ref.invalidate(kitchenProvider);
  }
}

final kitchenActionsProvider = Provider(KitchenActions.new);

// --- Monthly kitchen review + shopping list (PRD v1.2 §6) -------------------

final reviewRepositoryProvider = Provider((ref) => ReviewRepository(ref.watch(databaseProvider)));

final shoppingListProvider = FutureProvider((ref) => ref.watch(reviewRepositoryProvider).shoppingList());

/// Applies each review decision straight away (nothing is lost if the review
/// is interrupted) and records it against the review.
class ReviewActions {
  ReviewActions(this._ref);
  final Ref _ref;

  ReviewRepository get _repo => _ref.read(reviewRepositoryProvider);
  KitchenActions get _kitchen => _ref.read(kitchenActionsProvider);
  DateTime _now() => _ref.read(clockProvider)().toUtc();

  Future<int> start() => _repo.startReview(_now());

  /// Still have it: quantity updated (or unchanged).
  Future<void> keep(int reviewId, Ingredient i, double quantity) async {
    await _kitchen.save(i.copyWith(quantity: quantity));
    await _repo.addChange(reviewId, _change(i, ReviewAction.kept, quantity));
  }

  Future<void> usedUp(int reviewId, Ingredient i, {bool addToList = true}) async {
    await _kitchen.markFinished(i);
    await _repo.addChange(reviewId, _change(i, ReviewAction.usedUp, null));
    if (addToList) await addToShoppingList(i.name);
  }

  Future<void> spoiled(int reviewId, Ingredient i, {bool addToList = true}) async {
    await _kitchen.discard(i);
    await _repo.addChange(reviewId, _change(i, ReviewAction.spoiled, null));
    if (addToList) await addToShoppingList(i.name);
  }

  Future<void> complete(int reviewId) => _repo.completeReview(reviewId, _now());

  ReviewChange _change(Ingredient i, ReviewAction a, double? newQ) => ReviewChange(
    ingredientId: i.id!,
    name: i.name,
    action: a,
    oldQuantity: i.quantity,
    newQuantity: newQ,
    unit: i.unit,
  );

  Future<bool> addToShoppingList(String name, {String note = ''}) async {
    final added = await _repo.addToShoppingList(name, _now(), note: note);
    _ref.invalidate(shoppingListProvider);
    return added;
  }

  Future<void> setChecked(ShoppingItem s, bool checked) async {
    await _repo.setChecked(s.id!, checked);
    _ref.invalidate(shoppingListProvider);
  }

  Future<void> remove(ShoppingItem s) async {
    await _repo.removeShoppingItem(s.id!);
    _ref.invalidate(shoppingListProvider);
  }

  Future<void> clearChecked() async {
    await _repo.clearChecked();
    _ref.invalidate(shoppingListProvider);
  }
}

final reviewActionsProvider = Provider(ReviewActions.new);

// --- Food diary (PRD v1.2 §3) ---------------------------------------------------

final foodRepositoryProvider = Provider((ref) => FoodRepository(ref.watch(databaseProvider)));
final foodFactsApiProvider = Provider((ref) => FoodFactsApi());

/// USDA FoodData Central SR Legacy, bundled (public domain); loaded once.
final usdaFoodsProvider = FutureProvider<List<Food>>((ref) async {
  final data = await rootBundle.load('assets/foods/usda_sr_legacy.tsv');
  final text = utf8.decode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  return [
    for (final line in text.split('\n'))
      if (line.isNotEmpty) Food.fromUsdaLine(line),
  ];
});

final customFoodsProvider = FutureProvider((ref) => ref.watch(foodRepositoryProvider).customFoods());

/// Everything searchable: your own foods first, then USDA.
final foodCatalogueProvider = FutureProvider<List<Food>>(
  (ref) async => [...await ref.watch(customFoodsProvider.future), ...await ref.watch(usdaFoodsProvider.future)],
);

/// Diary entries for one local date (key: local midnight), in time order.
final diaryDayProvider = FutureProvider.family<List<FoodEntry>, DateTime>(
  (ref, day) => ref.watch(foodRepositoryProvider).forDay(day),
);

/// Foods you've logged before matching a search (for one-tap re-logging).
final loggedBeforeProvider = FutureProvider.family<List<FoodEntry>, String>(
  (ref, query) => ref.watch(foodRepositoryProvider).loggedBefore(query),
);

final recentFoodsProvider = FutureProvider((ref) => ref.watch(foodRepositoryProvider).recent());
final savedFoodsProvider = FutureProvider((ref) => ref.watch(foodRepositoryProvider).saved());

class FoodActions {
  FoodActions(this._ref);
  final Ref _ref;

  FoodRepository get _repo => _ref.read(foodRepositoryProvider);
  DateTime _now() => _ref.read(clockProvider)().toUtc();

  void _changed() {
    _ref.invalidate(diaryDayProvider);
    _ref.invalidate(recentFoodsProvider);
    _ref.invalidate(loggedBeforeProvider);
  }

  /// Logs [grams] of [food] to [meal] on local date [day] at local time [at].
  Future<FoodEntry?> log(
    Food food,
    double grams, {
    required Meal meal,
    required DateTime at,
    String portion = '',
  }) async {
    if (grams <= 0) return null;
    final local = at.toLocal();
    final e = await _repo.insert(
      FoodEntry(
        day: DateTime(local.year, local.month, local.day),
        meal: meal,
        loggedAt: at.toUtc(),
        name: food.name,
        foodKey: food.key,
        grams: grams,
        portion: portion,
        unit: food.unit,
        nutrients: scaleNutrients(food.per100g, grams),
      ),
    );
    _changed();
    return e;
  }

  Future<void> update(FoodEntry e) async {
    if ((e.grams ?? 1) <= 0) return;
    await _repo.update(e);
    _changed();
  }

  Future<void> delete(FoodEntry e) async {
    await _repo.delete(e.id!);
    _changed();
  }

  /// Copies entries as they are (amounts, nutrition, meal, time) to [day].
  Future<void> copyTo(Iterable<FoodEntry> entries, DateTime day) async {
    for (final e in entries) {
      await _repo.insert(e.copyToDay(day));
    }
    _changed();
  }

  Future<void> setSaved(Food food, bool saved, {double grams = 100, String portion = ''}) async {
    if (saved) {
      await _repo.save((key: food.key, name: food.name, grams: grams, portion: portion, at: _now()));
    } else {
      await _repo.unsave(food.key);
    }
    _ref.invalidate(savedFoodsProvider);
  }

  Future<Food> createCustom(Food food) async {
    final f = await _repo.addCustomFood(food, _now());
    _ref.invalidate(customFoodsProvider);
    return f;
  }

  /// Logs the reviewed items from a meal photo as separate entries, marked
  /// with [label] so they read as estimates in the diary.
  Future<void> logEstimate(
    Iterable<EstimatedItem> items, {
    required Meal meal,
    required DateTime at,
    required String label,
  }) async {
    final local = at.toLocal();
    for (final i in items) {
      if (i.grams <= 0 || i.name.trim().isEmpty) continue;
      await _repo.insert(
        FoodEntry(
          day: DateTime(local.year, local.month, local.day),
          meal: meal,
          loggedAt: at.toUtc(),
          name: i.name.trim(),
          grams: i.grams,
          portion: label,
          nutrients: i.nutrients,
        ),
      );
    }
    _changed();
  }

  /// Finds a packaged food: first among foods you scanned or created, then
  /// Open Food Facts (saved locally so it works offline next time). Null when
  /// unknown; throws when offline and not saved.
  Future<Food?> lookupBarcode(String barcode, {required String servingLabel, required String packLabel}) async {
    final local = await _repo.byBarcode(barcode);
    if (local != null) return local;
    final product = await _ref.read(foodFactsApiProvider).product(barcode);
    final food = product == null
        ? null
        : foodFromOpenFoodFacts(barcode, product, servingLabel: servingLabel, packLabel: packLabel);
    return food == null ? null : createCustom(food);
  }
}

final foodActionsProvider = Provider(FoodActions.new);

// --- Smart Recipe Planner (PRD v1.2 §5) -------------------------------------------

final recipeApiProvider = Provider((ref) => RecipeApi());
final recipeRepositoryProvider = Provider(
  (ref) => RecipeRepository(ref.watch(databaseProvider), ref.watch(recipeApiProvider), ref.watch(clockProvider)),
);

final recipeProvider = FutureProvider.family<Recipe?, String>(
  (ref, id) => ref.watch(recipeRepositoryProvider).byId(id),
);
final myRecipeRepositoryProvider = Provider(
  (ref) => MyRecipeRepository(ref.watch(databaseProvider), ref.watch(clockProvider)),
);
final myRecipesProvider = FutureProvider((ref) => ref.watch(myRecipeRepositoryProvider).all());

final savedRecipesProvider = FutureProvider((ref) => ref.watch(recipeRepositoryProvider).savedIds());
final lastCookedProvider = FutureProvider((ref) => ref.watch(recipeRepositoryProvider).lastCooked());

/// How many kitchen items are looked up, and how many recipes are opened.
const _maxQueries = 8, _maxCandidates = 16;

/// What you can make: recipes that use your kitchen items (expiring first),
/// minus anything with a recorded allergen; ranked by fewest missing.
/// Diet filtering is left to the screen so it can be switched.
final recipeSuggestionsProvider = FutureProvider<List<RecipeMatch>>((ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  final kitchen = await ref.watch(kitchenProvider.future);
  final allergies = (await ref.watch(settingsProvider.future)).allergies;
  final t = ref.read(clockProvider)().toLocal();
  final today = DateTime(t.year, t.month, t.day);

  final usable = kitchen.where((i) => !i.isExpired(today)).toList()
    ..sort((a, b) => (a.daysToExpiry(today) ?? 9999).compareTo(b.daysToExpiry(today) ?? 9999));
  final hits = <String, int>{};
  for (final item in usable.take(_maxQueries)) {
    var ids = await repo.idsWith(item.name);
    final words = item.name.trim().split(RegExp(r'\s+'));
    if (ids.isEmpty && words.length > 1) ids = await repo.idsWith(words.last);
    for (final id in ids) {
      hits[id] = (hits[id] ?? 0) + 1;
    }
  }
  final ids = (hits.keys.toList()..sort((a, b) => hits[b]!.compareTo(hits[a]!))).take(_maxCandidates);
  final recipes = await Future.wait(ids.map(repo.byId));
  return rankMatches([
    for (final r in recipes)
      if (r != null && allergensIn(r).intersection(allergies).isEmpty) RecipeMatch(r, kitchen, today),
  ]);
});

/// Recipes by name, matched against the kitchen; recorded allergens excluded.
final recipeSearchProvider = FutureProvider.family<List<RecipeMatch>, String>((ref, query) async {
  final recipes = await ref.watch(recipeRepositoryProvider).search(query);
  final kitchen = await ref.watch(kitchenProvider.future);
  final allergies = (await ref.watch(settingsProvider.future)).allergies;
  final t = ref.read(clockProvider)().toLocal();
  return rankMatches([
    for (final r in recipes)
      if (allergensIn(r).intersection(allergies).isEmpty) RecipeMatch(r, kitchen, DateTime(t.year, t.month, t.day)),
  ]);
});

class RecipeActions {
  RecipeActions(this._ref);
  final Ref _ref;

  RecipeRepository get _repo => _ref.read(recipeRepositoryProvider);

  Future<void> setSaved(Recipe r, bool saved) async {
    await _repo.setSaved(r, saved);
    _ref.invalidate(savedRecipesProvider);
  }

  /// Saves your own recipe; returns its id.
  Future<String> saveMine(Recipe r) async {
    final id = await _ref.read(myRecipeRepositoryProvider).save(r);
    _ref.invalidate(myRecipesProvider);
    return id;
  }

  Future<void> deleteMine(Recipe r) async {
    await _ref.read(myRecipeRepositoryProvider).delete(r.id);
    await _repo.setSaved(r, false);
    _ref.invalidate(myRecipesProvider);
    _ref.invalidate(savedRecipesProvider);
  }

  Future<void> markCooked(Recipe r, double batch) async {
    await _repo.markCooked(r, batch);
    _ref.invalidate(lastCookedProvider);
  }

  /// Logs one serving to the diary. Returns false when this recipe is
  /// already logged for that meal and day (no duplicates).
  Future<bool> logToDiary(Recipe r, Meal meal, DateTime at, {required String servingLabel}) async {
    final food = _ref.read(foodRepositoryProvider);
    final local = at.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    if (await food.isLogged('recipe:${r.id}', day, meal)) return false;
    await food.insert(
      FoodEntry(
        day: day,
        meal: meal,
        loggedAt: at.toUtc(),
        name: r.name,
        foodKey: 'recipe:${r.id}',
        portion: servingLabel,
        nutrients: r.nutrients, // per serving for your recipes; TheMealDB has none
      ),
    );
    _ref.invalidate(diaryDayProvider);
    return true;
  }

  /// Adds missing ingredients to the shopping list; returns how many were new.
  Future<int> addToShoppingList(Iterable<RecipeIngredient> items) async {
    var added = 0;
    for (final i in items) {
      if (await _ref.read(reviewActionsProvider).addToShoppingList(i.name)) added++;
    }
    return added;
  }
}

final recipeActionsProvider = Provider(RecipeActions.new);

// --- Meal photo estimates (PRD v1.2 §3, optional; reviewed before saving) ------

/// Built into the app at build time (--dart-define-from-file=secrets.json);
/// never committed.
const _builtInGeminiKey = String.fromEnvironment('GEMINI_API_KEY');

/// Which Gemini key is used: yours from Settings, else the built-in one.
final geminiKeyProvider = FutureProvider<({String key, bool own})?>((ref) async {
  final own = await ref.watch(settingsRepositoryProvider).apiKey('gemini');
  if (own != null && own.isNotEmpty) return (key: own, own: true);
  return _builtInGeminiKey.isEmpty ? null : (key: _builtInGeminiKey, own: false);
});

/// Null when no key is available.
final mealPhotoApiProvider = FutureProvider<MealPhotoApi?>((ref) async {
  final k = await ref.watch(geminiKeyProvider.future);
  return k == null ? null : MealPhotoApi(k.key);
});

// --- Personal measurements (PRD v1.2 §7) -------------------------------------------

final bodyRepositoryProvider = Provider((ref) => BodyRepository(ref.watch(databaseProvider)));
final bodyProfileProvider = FutureProvider((ref) => ref.watch(bodyRepositoryProvider).profile());
final weighInsProvider = FutureProvider((ref) => ref.watch(bodyRepositoryProvider).weighIns());

class BodyActions {
  BodyActions(this._ref);
  final Ref _ref;

  BodyRepository get _repo => _ref.read(bodyRepositoryProvider);

  Future<void> saveProfile(BodyProfile p) async {
    await _repo.saveProfile(p);
    _ref.invalidate(bodyProfileProvider);
    unawaited(_ref.read(accountActionsProvider).push());
  }

  Future<void> addWeighIn(WeighIn w) async {
    if (w.weightKg <= 0) return;
    await _repo.addWeighIn(w);
    _ref.invalidate(weighInsProvider);
    unawaited(_ref.read(accountActionsProvider).push());
  }

  Future<void> updateWeighIn(WeighIn w) async {
    if (w.weightKg <= 0) return;
    await _repo.updateWeighIn(w);
    _ref.invalidate(weighInsProvider);
  }

  Future<void> deleteWeighIn(WeighIn w) async {
    await _repo.deleteWeighIn(w.id!);
    _ref.invalidate(weighInsProvider);
  }
}

final bodyActionsProvider = Provider(BodyActions.new);

// --- Steps (home page) ---------------------------------------------------------------

final stepCounterProvider = Provider((ref) => StepCounter());

/// Today's steps, or why they can't be shown.
class StepsState {
  const StepsState({this.steps = 0, this.needsPermission = false, this.unavailable = false});
  final int steps;
  final bool needsPermission;
  final bool unavailable;
}

/// Daily steps goal (you can change it on the home steps card).
final stepGoalProvider = FutureProvider<int>(
  (ref) async =>
      ((await ref.watch(settingsRepositoryProvider).stepGoal()) ?? dailyStepGoal).clamp(minStepGoal, maxStepGoal),
);

final todayStepsProvider = StreamProvider<StepsState>((ref) async* {
  final counter = ref.watch(stepCounterProvider);
  final repo = ref.watch(settingsRepositoryProvider);
  DateTime now() => ref.read(clockProvider)().toLocal();
  if (!await counter.granted()) {
    yield const StepsState(needsPermission: true);
    return;
  }
  var book = StepBook.fromJson(await repo.stepBook());
  yield StepsState(steps: stepsToday(book, now()));
  var saved = book?.last ?? -1;
  try {
    await for (final reading in counter.readings()) {
      final day = book?.day;
      final before = book;
      book = recordSteps(book, reading, now());
      // A new day: keep the finished day's total (for activity level and exports).
      if (before != null && book.day != day) await repo.setValue('steps.phone.${before.day}', '${before.today}');
      // Save on a new day, after a reboot, or every 50 steps.
      if (book.day != day || reading < saved || reading - saved >= 50) {
        await repo.saveStepBook(book.toJson());
        saved = reading;
      }
      yield StepsState(steps: book.today);
    }
  } catch (_) {
    yield const StepsState(unavailable: true);
  }
});

// --- Watch via Health Connect (read-only) -------------------------------------------

final healthSourceProvider = Provider((ref) => HealthSource());

enum WatchStatus { off, unavailable, needsPermission, linked }

/// Whether you've connected your watch (opt-in) and MagnaVita can still read it.
final watchStatusProvider = FutureProvider<WatchStatus>((ref) async {
  final linked = await ref.watch(settingsRepositoryProvider).flag('watch.linked');
  final hc = ref.watch(healthSourceProvider);
  try {
    if (!await hc.available()) return WatchStatus.unavailable;
    if (!linked) return WatchStatus.off;
    return await hc.connected() ? WatchStatus.linked : WatchStatus.needsPermission;
  } catch (_) {
    return WatchStatus.unavailable;
  }
});

/// Today's calories burned from your watch: null when not connected, 0 when
/// connected but nothing has synced yet (so the row still shows).
final watchCaloriesTodayProvider = FutureProvider<double?>((ref) async {
  if (await ref.watch(watchStatusProvider.future) != WatchStatus.linked) return null;
  final now = ref.read(clockProvider)().toLocal();
  try {
    return await ref.watch(healthSourceProvider).caloriesBurned(DateTime(now.year, now.month, now.day), now) ?? 0;
  } catch (_) {
    return 0;
  }
});

/// What each health app wrote today (troubleshooting in Settings → Watch).
final watchBreakdownProvider = FutureProvider<List<SourceTotals>>((ref) async {
  if (await ref.watch(watchStatusProvider.future) != WatchStatus.linked) return const [];
  final now = ref.read(clockProvider)().toLocal();
  try {
    return await ref.watch(healthSourceProvider).breakdown(DateTime(now.year, now.month, now.day), now);
  } catch (_) {
    return const [];
  }
});

/// Today's steps from your watch (full day), or null when not connected.
final watchStepsTodayProvider = FutureProvider<int?>((ref) async {
  if (await ref.watch(watchStatusProvider.future) != WatchStatus.linked) return null;
  final now = ref.read(clockProvider)().toLocal();
  try {
    return await ref.watch(healthSourceProvider).steps(DateTime(now.year, now.month, now.day), now);
  } catch (_) {
    return null;
  }
});

/// Steps you entered yourself for a local day (key: local midnight), or null.
final manualStepsProvider = FutureProvider.family<ManualSteps?, DateTime>((ref, day) async {
  final json = await ref.watch(settingsRepositoryProvider).value('steps.manual.${stepDayKey(day)}');
  return json == null ? null : ManualSteps.fromJson(jsonDecode(json) as Map<String, dynamic>);
});

/// Saves (or with null, clears) your own step count for [day].
Future<void> setManualSteps(WidgetRef ref, DateTime day, int? steps) async {
  final phone = ref.read(todayStepsProvider).value;
  final phoneAt = phone == null || phone.unavailable || phone.needsPermission ? null : phone.steps;
  await ref
      .read(settingsRepositoryProvider)
      .setValue(
        'steps.manual.${stepDayKey(day)}',
        steps == null ? null : jsonEncode(ManualSteps(steps, phoneAt: phoneAt).toJson()),
      );
  ref.invalidate(manualStepsProvider(day));
  ref.invalidate(dayStatsProvider(day));
}

/// When the watch's steps last reached Health Connect today, or null.
final watchStepsSyncedProvider = FutureProvider<DateTime?>((ref) async {
  if (await ref.watch(watchStatusProvider.future) != WatchStatus.linked) return null;
  final now = ref.read(clockProvider)().toLocal();
  try {
    return await ref.watch(healthSourceProvider).lastStepsAt(DateTime(now.year, now.month, now.day), now);
  } catch (_) {
    return null;
  }
});

/// One day's movement, for the shareable stats image.
class DayStats {
  const DayStats({this.steps, this.km, this.kcal = 0, this.watchKcal, this.activeMinutes = 0});
  final int? steps; // null when unknown (no watch, phone or own figure for the day)
  final double? km;
  final double kcal; // watch + activities you logged
  final double? watchKcal; // the watch's part of [kcal]; null when not connected
  final int activeMinutes; // the watch's active time, else minutes you logged
}

/// Stats for any local day (key: local midnight). Past days need the watch
/// for steps and distance; the phone's step counter only knows today.
final dayStatsProvider = FutureProvider.family<DayStats, DateTime>((ref, day) async {
  final now = ref.read(clockProvider)().toLocal();
  final end = DateTime(day.year, day.month, day.day + 1);
  final to = end.isAfter(now) ? now : end;
  final activities = await ref.watch(activityDayProvider(day).future);
  var kcal = activities.where((a) => !a.fromWatch).fold(0.0, (s, a) => s + (a.kcal ?? 0));
  int? steps, active;
  double? watchKcal;
  if (await ref.watch(watchStatusProvider.future) == WatchStatus.linked) {
    final hc = ref.watch(healthSourceProvider);
    try {
      steps = await hc.steps(day, to);
      watchKcal = await hc.caloriesBurned(day, to) ?? 0;
      kcal += watchKcal;
      active = await hc.activeMinutes(day, to);
    } catch (_) {}
  }
  final manual = await ref.watch(manualStepsProvider(day).future);
  if (day == DateTime(now.year, now.month, now.day)) {
    // Same as the home card: the highest of watch, phone and your own figure.
    final phone = ref.read(todayStepsProvider).value?.steps;
    if (phone != null || manual != null || steps != null) {
      steps = shownSteps(watch: steps, phone: phone, manual: manual).$1;
    }
  } else {
    // Past days: the phone's total for the day (kept since November 2026) or your own figure.
    final phone = int.tryParse(await ref.watch(settingsRepositoryProvider).value('steps.phone.${stepDayKey(day)}') ?? '');
    for (final s in [phone, manual?.steps]) {
      if (s != null && s > (steps ?? -1)) steps = s;
    }
  }
  // From steps, exactly like the home card: the watch app's distance records
  // cover only part of the day's walking.
  final km = steps == null ? null : stepsToKm(steps, heightCm: (await ref.watch(bodyProfileProvider.future)).heightCm);
  return DayStats(steps: steps, km: km, kcal: kcal, watchKcal: watchKcal, activeMinutes: active ?? totalMinutes(activities));
});

// --- Energy: maintenance calories from your records (profile) ------------------------

/// Complete past days with something recorded (activities, watch or steps),
/// from the day after you started using MagnaVita, up to the last 28.
final pastMovementProvider = FutureProvider<List<DayMovement>>((ref) async {
  final now = ref.read(clockProvider)().toLocal();
  final today = DateTime(now.year, now.month, now.day);
  var first = DateTime(today.year, today.month, today.day - measuredWindowDays);
  final since = (await ref.watch(settingsProvider.future)).memberSince?.toLocal();
  if (since != null) {
    final next = DateTime(since.year, since.month, since.day + 1);
    if (next.isAfter(first)) first = next;
  }
  return [
    for (var d = first; d.isBefore(today); d = DateTime(d.year, d.month, d.day + 1))
      if (await ref.watch(dayStatsProvider(d).future) case final s when s.kcal > 0 || s.steps != null)
        DayMovement(loggedKcal: s.kcal - (s.watchKcal ?? 0), watchKcal: s.watchKcal, steps: s.steps),
  ];
});

/// The activity level you chose (used until there are enough records).
final chosenActivityLevelProvider = FutureProvider<ActivityLevel?>(
  (ref) async => ActivityLevel.values.asNameMap()[await ref.watch(settingsRepositoryProvider).value('energy.level')],
);

Future<void> setChosenActivityLevel(WidgetRef ref, ActivityLevel level) async {
  await ref.read(settingsRepositoryProvider).setValue('energy.level', level.name);
  ref.invalidate(chosenActivityLevelProvider);
  unawaited(ref.read(accountActionsProvider).push());
}

/// Resting energy and maintenance calories from your latest weigh-in; null
/// for under-18s, without the needed details, or with weight tracking off.
final energyProvider = FutureProvider<Energy?>((ref) async {
  final profile = await ref.watch(bodyProfileProvider.future);
  final weighIns = await ref.watch(weighInsProvider.future);
  if (!profile.trackWeight || weighIns.isEmpty) return null;
  final kg = weighIns.last.weightKg;
  final resting = restingEnergy(profile, kg, ref.read(clockProvider)().toLocal());
  if (resting == null) return null;
  return energyFrom(
    resting: resting,
    weightKg: kg,
    days: await ref.watch(pastMovementProvider.future),
    chosen: await ref.watch(chosenActivityLevelProvider.future),
  );
});

/// Your goal weight and pace, or null.
final weightGoalProvider = FutureProvider<WeightGoal?>((ref) async {
  final json = await ref.watch(settingsRepositoryProvider).value('goal.weight');
  return json == null ? null : WeightGoal.fromJson(jsonDecode(json) as Map<String, dynamic>);
});

Future<void> setWeightGoal(WidgetRef ref, WeightGoal? goal) async {
  await ref.read(settingsRepositoryProvider).setValue('goal.weight', goal == null ? null : jsonEncode(goal.toJson()));
  ref.invalidate(weightGoalProvider);
  unawaited(ref.read(accountActionsProvider).push());
}

// --- Setup answers -------------------------------------------------------------------

/// Your goal, meals per day and training from setup.
final userGoalsProvider = FutureProvider<UserGoals>((ref) async {
  final json = await ref.watch(settingsRepositoryProvider).value('goals');
  return json == null ? const UserGoals() : UserGoals.fromJson(jsonDecode(json) as Map<String, dynamic>);
});

Future<void> setUserGoals(WidgetRef ref, UserGoals goals) async {
  await ref.read(settingsRepositoryProvider).setValue('goals', jsonEncode(goals.toJson()));
  ref.invalidate(userGoalsProvider);
}

/// Calories a day to aim for: your goal's target, or maintenance when your
/// goal is to stay where you are; null otherwise.
final dailyCaloriesProvider = FutureProvider<double?>((ref) async {
  final target = await ref.watch(calorieTargetProvider.future);
  if (target != null) return target.kcal;
  final main = (await ref.watch(userGoalsProvider.future)).main;
  return main == MainGoal.maintain || main == MainGoal.loseWeight
      ? (await ref.watch(energyProvider.future))?.maintenance
      : null;
});

/// Setup has been finished (or skipped) on this phone.
final setupDoneProvider = FutureProvider<bool>((ref) => ref.watch(settingsRepositoryProvider).flag('setup.done'));

Future<void> setSetupDone(WidgetRef ref) async {
  await ref.read(settingsRepositoryProvider).setFlag('setup.done', true);
  ref.invalidate(setupDoneProvider);
  await ref.read(accountActionsProvider).push();
}

/// Daily calories for your goal; null without a goal or maintenance calories.
final calorieTargetProvider = FutureProvider<CalorieTarget?>((ref) async {
  final energy = await ref.watch(energyProvider.future);
  final goal = await ref.watch(weightGoalProvider.future);
  final sex = (await ref.watch(bodyProfileProvider.future)).sex;
  final weighIns = await ref.watch(weighInsProvider.future);
  if (energy == null || goal == null || sex == null || weighIns.isEmpty) return null;
  return calorieTarget(energy: energy, sex: sex, currentKg: weighIns.last.weightKg, goal: goal);
});

/// Your weight over the next 12 weeks, eating what your diary shows (or your
/// target, or maintenance) with your current activity; null without energy.
final forecastProvider = FutureProvider<Forecast?>((ref) async {
  final energy = await ref.watch(energyProvider.future);
  if (energy == null) return null;
  final profile = await ref.watch(bodyProfileProvider.future);
  final weighIns = await ref.watch(weighInsProvider.future);
  final goal = await ref.watch(weightGoalProvider.future);
  final target = await ref.watch(calorieTargetProvider.future);
  final now = ref.read(clockProvider)().toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final entries = await ref
      .watch(foodRepositoryProvider)
      .between(DateTime(today.year, today.month, today.day - intakeWindowDays), DateTime(today.year, today.month, today.day - 1));
  final perDay = <DateTime, double>{};
  for (final e in entries) {
    perDay[e.day] = (perDay[e.day] ?? 0) + (e.nutrients[Nutrient.energy] ?? 0);
  }
  final eaten = diaryIntake([for (final v in perDay.values) if (v > 0) v]);
  final (intake, source) = eaten != null
      ? (eaten, IntakeSource.diary)
      : target != null
      ? (target.kcal, IntakeSource.target)
      : (energy.maintenance, IntakeSource.maintenance);
  return forecast(
    startKg: weighIns.last.weightKg,
    heightCm: profile.heightCm!,
    age: profile.ageOn(today)!,
    sex: profile.sex!,
    energy: energy,
    intake: intake,
    source: source,
    today: today,
    goal: goal,
  );
});

/// Imports the last week's watch workouts into Activity (once each).
/// Returns how many were new.
final watchSyncProvider = FutureProvider<int>((ref) async {
  if (await ref.watch(watchStatusProvider.future) != WatchStatus.linked) return 0;
  final now = ref.read(clockProvider)().toUtc();
  final List<WatchWorkout> workouts;
  try {
    workouts = await ref.watch(healthSourceProvider).workouts(now.subtract(const Duration(days: 7)), now);
  } catch (_) {
    return 0;
  }
  final added = await ref.read(activityRepositoryProvider).importWatch([
    for (final w in workouts)
      ActivityEntry(
        type: w.type,
        startedAt: w.start.toUtc(),
        minutes: w.end.difference(w.start).inMinutes.clamp(minActivityMinutes, maxActivityMinutes),
        kcal: w.kcal,
        externalId: w.id,
        createdAt: now,
        updatedAt: now,
      ),
  ]);
  if (added > 0) {
    ref.invalidate(activityDayProvider);
    ref.invalidate(recentActivitiesProvider);
    ref.invalidate(daySummariesProvider);
  }
  return added;
});

class WatchActions {
  WatchActions(this._ref);
  final Ref _ref;

  /// Asks Health Connect for read access; returns the resulting status.
  Future<WatchStatus> connect() async {
    final hc = _ref.read(healthSourceProvider);
    if (!await hc.available()) {
      refresh();
      return WatchStatus.unavailable;
    }
    final ok = await hc.connect();
    await _ref.read(settingsRepositoryProvider).setFlag('watch.linked', ok);
    refresh();
    return ok ? WatchStatus.linked : WatchStatus.needsPermission;
  }

  /// Stops reading (permissions can be fully revoked in Health Connect).
  Future<void> disconnect() async {
    await _ref.read(settingsRepositoryProvider).setFlag('watch.linked', false);
    refresh();
  }

  /// Re-reads watch data (on app resume and after connecting).
  void refresh() {
    _ref.invalidate(watchStatusProvider);
    _ref.invalidate(watchCaloriesTodayProvider);
    _ref.invalidate(watchSyncProvider);
    _ref.invalidate(watchStepsTodayProvider);
    _ref.invalidate(watchStepsSyncedProvider);
    _ref.invalidate(watchBreakdownProvider);
    _ref.invalidate(dayStatsProvider);
  }
}

final watchActionsProvider = Provider(WatchActions.new);

// --- Account (Supabase) --------------------------------------------------------------

final accountServiceProvider = Provider<AccountService>((ref) => SupabaseAccountService());

/// Who's signed in (null when nobody).
final accountProvider = StreamProvider<Account?>((ref) async* {
  final service = ref.watch(accountServiceProvider);
  yield service.current;
  yield* service.changes;
});

/// You chose to use MagnaVita without an account (data on this phone only).
final localOnlyProvider = FutureProvider<bool>((ref) => ref.watch(settingsRepositoryProvider).flag('account.local'));

class AccountActions {
  AccountActions(this._ref);
  final Ref _ref;

  AccountService get _service => _ref.read(accountServiceProvider);

  /// After signing in or up: a finished profile saved in the account comes
  /// to this phone (a new phone gets your setup back); otherwise this phone's
  /// profile goes to the account. Uses the account's name if you have none.
  Future<void> signedIn({String? name}) async {
    final s = await _ref.read(settingsProvider.future);
    final fromAccount = (name ?? _service.current?.name ?? '').trim();
    if (s.userName.trim().isEmpty && fromAccount.isNotEmpty) {
      await _ref.read(settingsProvider.notifier).save(s.copyWith(userName: fromAccount));
    }
    await _ref.read(settingsRepositoryProvider).setFlag('account.local', false);
    try {
      final remote = await _service.fetchProfile();
      if (remote != null && remote['setup_done'] == true) {
        await _apply(remote);
      } else {
        await push();
      }
    } on Exception {
      // Offline: the next change pushes it.
    }
    _ref.invalidate(localOnlyProvider);
    _ref.invalidate(accountProvider);
  }

  /// Saves this phone's profile and goals to the account (best effort).
  Future<void> push() async {
    if (_service.current == null) return;
    try {
      await _service.saveProfile(await _fields());
    } on Exception {
      // Offline or signed out meanwhile; the next change tries again.
    }
  }

  Future<Map<String, Object?>> _fields() async {
    final repo = _ref.read(settingsRepositoryProvider);
    final s = await repo.load();
    final body = await _ref.read(bodyRepositoryProvider).profile();
    final weighIns = await _ref.read(bodyRepositoryProvider).weighIns();
    final goalJson = await repo.value('goal.weight');
    final goal = goalJson == null ? null : WeightGoal.fromJson(jsonDecode(goalJson) as Map<String, dynamic>);
    final goalsJson = await repo.value('goals');
    final goals = goalsJson == null ? const UserGoals() : UserGoals.fromJson(jsonDecode(goalsJson) as Map<String, dynamic>);
    return {
      'display_name': s.userName.trim(),
      'sex': body.sex?.name,
      'birth_year': body.birthYear,
      'height_cm': body.heightCm,
      'weight_kg': weighIns.isEmpty ? null : weighIns.last.weightKg,
      'main_goal': goals.main?.name,
      'goal_weight_kg': goal?.goalKg,
      'pace_kg': goal?.paceKg,
      'activity_level': await repo.value('energy.level'),
      'meals_per_day': goals.mealsPerDay,
      'training_days': goals.trainingDays,
      'experience': goals.level?.name,
      'equipment': goals.equipment?.name,
      'diet': s.diet.name,
      'allergies': [for (final a in s.allergies) a.name],
      'units': s.units.name,
      'setup_done': await repo.flag('setup.done'),
    };
  }

  /// Puts an account's saved profile on this phone.
  Future<void> _apply(Map<String, dynamic> r) async {
    final repo = _ref.read(settingsRepositoryProvider);
    final s = await _ref.read(settingsProvider.future);
    final name = (r['display_name'] as String?)?.trim() ?? '';
    await repo.save(
      s.copyWith(
        userName: name.isEmpty ? null : name,
        units: UnitSystem.values.asNameMap()[r['units']],
        diet: DietPreference.values.asNameMap()[r['diet']],
        allergies: {for (final a in (r['allergies'] as List?) ?? const []) ?Allergen.values.asNameMap()[a]},
      ),
    );
    final bodyRepo = _ref.read(bodyRepositoryProvider);
    final body = await bodyRepo.profile();
    await bodyRepo.saveProfile(
      BodyProfile(
        heightCm: (r['height_cm'] as num?)?.toDouble() ?? body.heightCm,
        birthYear: (r['birth_year'] as num?)?.toInt() ?? body.birthYear,
        sex: Sex.values.asNameMap()[r['sex']] ?? body.sex,
        trackWeight: body.trackWeight,
      ),
    );
    final kg = (r['weight_kg'] as num?)?.toDouble();
    if (kg != null && (await bodyRepo.weighIns()).isEmpty) {
      await bodyRepo.addWeighIn(WeighIn(at: _ref.read(clockProvider)().toUtc(), weightKg: kg));
    }
    final goalKg = (r['goal_weight_kg'] as num?)?.toDouble();
    if (goalKg != null) {
      final pace = (r['pace_kg'] as num?)?.toDouble() ?? 0.5;
      await repo.setValue('goal.weight', jsonEncode(WeightGoal(goalKg: goalKg, paceKg: pace).toJson()));
    }
    if (ActivityLevel.values.asNameMap()[r['activity_level']] case final level?) {
      await repo.setValue('energy.level', level.name);
    }
    await repo.setValue(
      'goals',
      jsonEncode(
        UserGoals(
          main: MainGoal.values.asNameMap()[r['main_goal']],
          mealsPerDay: (r['meals_per_day'] as num?)?.toInt(),
          trainingDays: (r['training_days'] as num?)?.toInt(),
          level: PlanLevel.values.asNameMap()[r['experience']],
          equipment: PlanEquipment.values.asNameMap()[r['equipment']],
        ).toJson(),
      ),
    );
    await repo.setFlag('setup.done', true);
    _ref
      ..invalidate(settingsProvider)
      ..invalidate(bodyProfileProvider)
      ..invalidate(weighInsProvider)
      ..invalidate(weightGoalProvider)
      ..invalidate(chosenActivityLevelProvider)
      ..invalidate(userGoalsProvider)
      ..invalidate(setupDoneProvider);
  }

  Future<void> useWithoutAccount() async {
    await _ref.read(settingsRepositoryProvider).setFlag('account.local', true);
    _ref.invalidate(localOnlyProvider);
  }

  /// Signs out; what's on this phone stays.
  Future<void> signOut() async {
    await _service.signOut();
    _ref.invalidate(accountProvider);
  }

  /// Deletes the account and its profile; what's on this phone stays.
  Future<void> deleteAccount() async {
    await _service.deleteAccount();
    _ref.invalidate(accountProvider);
  }
}

final accountActionsProvider = Provider(AccountActions.new);

// --- App updates (published to the release page by tool/release.py) ----------------

final updateCheckerProvider = Provider((ref) => UpdateChecker());

/// A newer release than this build, or null.
final availableUpdateProvider = FutureProvider<AppRelease?>((ref) async {
  final latest = await ref.watch(updateCheckerProvider).latest();
  return latest != null && latest.build > appBuild ? latest : null;
});
