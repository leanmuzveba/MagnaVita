import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_fasting/data/account.dart';
import 'package:life_fasting/data/app_database.dart';
import 'package:life_fasting/data/food_facts_api.dart';
import 'package:life_fasting/data/health_source.dart';
import 'package:life_fasting/data/meal_photo_api.dart';
import 'package:life_fasting/domain/kitchen.dart';
import 'package:life_fasting/domain/meal_estimate.dart';
import 'package:life_fasting/domain/recipe.dart';
import 'package:life_fasting/data/notification_service.dart';
import 'package:life_fasting/data/recipe_repository.dart';
import 'package:life_fasting/data/step_counter.dart';
import 'package:life_fasting/data/update_checker.dart';
import 'package:life_fasting/domain/hydration.dart';
import 'package:life_fasting/state/providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Mutable fake clock for tests.
class FakeClock {
  FakeClock(this.now);
  DateTime now;
  DateTime call() => now;
  void advance(Duration d) => now = now.add(d);
}

Future<Database> openTestDb() {
  sqfliteFfiInit();
  return AppDatabase.open(factory: databaseFactoryFfiNoIsolate, path: inMemoryDatabasePath);
}

Future<ProviderContainer> testContainer(Database db, FakeClock clock) async {
  final c = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock.call),
      notificationServiceProvider.overrideWithValue(FakeNotifications()),
      recipeApiProvider.overrideWithValue(FakeRecipeApi()),
      accountServiceProvider.overrideWithValue(FakeAccountService()),
    ],
  );
  await c.read(settingsProvider.future);
  await c.read(activeSessionProvider.future);
  return c;
}

bool _fontsLoaded = false;

/// Loads the bundled brand fonts so widget tests lay out like the real app
/// (the default test font renders every glyph as a wide box).
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  const families = {
    'Lexend': ('Lexend', [500, 600, 700, 800]),
    'DM Sans': ('DMSans', [400, 500, 600, 700]),
    'JetBrains Mono': ('JetBrainsMono', [500, 600]),
  };
  for (final MapEntry(key: family, value: (file, weights)) in families.entries) {
    final loader = FontLoader(family);
    for (final w in weights) {
      loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$file-$w.ttf').readAsBytesSync())));
    }
    await loader.load();
  }
  // Material icons, so visual checks show real glyphs instead of boxes.
  final sdk = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icons = File('$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())))).load();
  }
  _fontsLoaded = true;
}

/// Accounts without a server: one known user, a profile row in memory.
/// Emailed codes are always [code]; [sent] records each email.
class FakeAccountService implements AccountService {
  FakeAccountService({this.confirmEmail = true});

  /// Sign-up needs the emailed code before signing in (Supabase "Confirm email").
  bool confirmEmail;
  static const code = '123456';
  final users = <String, ({String password, String name})>{'ann@example.com': (password: 'correct horse', name: 'Ann')};
  final unconfirmed = <String>{};
  final sent = <String>[];
  Map<String, dynamic>? profile;
  bool deleted = false;
  Account? _current;
  final _changes = StreamController<Account?>.broadcast();

  void _set(Account? a) {
    _current = a;
    _changes.add(a);
  }

  @override
  Account? get current => _current;

  @override
  Stream<Account?> get changes => _changes.stream;

  @override
  Future<SignUpResult> signUp({required String name, required String email, required String password}) async {
    if (users.containsKey(email)) throw const AuthFailure(AuthProblem.emailTaken);
    users[email] = (password: password, name: name);
    profile = {'display_name': name};
    if (confirmEmail) {
      unconfirmed.add(email);
      sent.add('signup:$email');
      return SignUpResult.confirmEmail;
    }
    _set(Account(id: email, email: email, name: name));
    return SignUpResult.signedIn;
  }

  @override
  Future<void> confirmSignUp({required String email, required String code}) async {
    if (!unconfirmed.contains(email) || code != FakeAccountService.code) {
      throw const AuthFailure(AuthProblem.codeInvalid);
    }
    unconfirmed.remove(email);
    _set(Account(id: email, email: email, name: users[email]!.name));
  }

  @override
  Future<void> resendSignUpCode(String email) async => sent.add('signup:$email');

  @override
  Future<void> signIn({required String email, required String password}) async {
    final u = users[email];
    if (u == null || u.password != password) throw const AuthFailure(AuthProblem.invalidCredentials);
    if (unconfirmed.contains(email)) throw const AuthFailure(AuthProblem.emailNotConfirmed);
    _set(Account(id: email, email: email, name: u.name));
  }

  @override
  Future<void> sendPasswordResetCode(String email) async => sent.add('reset:$email');

  @override
  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {
    final u = users[email];
    if (u == null || code != FakeAccountService.code) throw const AuthFailure(AuthProblem.codeInvalid);
    users[email] = (password: newPassword, name: u.name);
    _set(Account(id: email, email: email, name: u.name));
  }

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> deleteAccount() async {
    deleted = true;
    profile = null;
    _set(null);
  }

  @override
  Future<Map<String, dynamic>?> fetchProfile() async => _current == null ? null : profile;

  @override
  Future<void> saveProfile(Map<String, Object?> fields) async {
    if (_current != null) profile = {...?profile, ...fields};
  }
}

/// Records what would be scheduled instead of calling the OS.
class FakeNotifications extends NotificationService {
  FakeNotifications({this.permission = true});
  bool permission;
  final scheduled = <int, DateTime>{};

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> scheduleTargetReached(DateTime at) async => scheduled[NotificationService.targetReachedId] = at;

  @override
  Future<void> scheduleDailyReminder(int hour, int minute) async =>
      scheduled[NotificationService.dailyReminderId] = DateTime(2000, 1, 1, hour, minute);

  @override
  Future<void> scheduleWaterReminders() async {
    for (final (i, h) in waterReminderHours.indexed) {
      scheduled[NotificationService.waterReminderBaseId + i] = DateTime(2000, 1, 1, h);
    }
  }

  @override
  Future<void> cancelWaterReminders() async => scheduled.removeWhere(
    (id, _) => id >= NotificationService.waterReminderBaseId && id < NotificationService.monthlyReviewId,
  );

  @override
  Future<void> scheduleMonthlyReview() async =>
      scheduled[NotificationService.monthlyReviewId] = DateTime(2000, 1, 1, 10);

  @override
  Future<void> scheduleRestOver(DateTime at) async => scheduled[NotificationService.restOverId] = at;

  @override
  Future<void> scheduleWorkoutReminders(List<int> weekdays, int hour, int minute) async {
    await cancelWorkoutReminders();
    for (final w in weekdays) {
      scheduled[NotificationService.workoutReminderBaseId + w] = DateTime(2000, 1, 1, hour, minute);
    }
  }

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);

  @override
  Future<void> cancelAll() async => scheduled.clear();
}

/// Serves canned TheMealDB JSON by request path; records requests.
class FakeRecipeApi extends RecipeApi {
  final responses = <String, Map<String, dynamic>>{};
  final requests = <String>[];
  bool offline = false;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    requests.add(path);
    if (offline) throw const SocketException('offline');
    return responses[path] ?? {'meals': null};
  }
}

/// Serves canned Open Food Facts products by barcode; records lookups.
class FakeFoodFactsApi extends FoodFactsApi {
  final products = <String, Map<String, dynamic>>{};
  final lookups = <String>[];
  bool offline = false;

  @override
  Future<Map<String, dynamic>?> product(String barcode) async {
    lookups.add(barcode);
    if (offline) throw const SocketException('offline');
    return products[barcode];
  }
}

/// A valid 1×1 PNG for photo tests.
final onePixelPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, //
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0, //
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, //
  0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// Returns [reply] (or throws [error]) instead of calling Gemini.
class FakeMealPhotoApi extends MealPhotoApi {
  FakeMealPhotoApi() : super('test-key');
  MealEstimate reply = const MealEstimate(isFood: true, items: []);
  Object? error;
  int calls = 0;

  @override
  Future<MealEstimate> estimate(Uint8List jpeg) async {
    calls++;
    if (error != null) throw error!;
    return reply;
  }

  List<SpottedItem> groceriesReply = const [];
  Recipe? recipeReply;
  String? lastRecipeText;

  @override
  Future<Recipe?> recipe({Uint8List? jpeg, String text = ''}) async {
    calls++;
    lastRecipeText = text;
    if (error != null) throw error!;
    return recipeReply;
  }

  @override
  Future<List<SpottedItem>> groceries(Uint8List jpeg) async {
    calls++;
    if (error != null) throw error!;
    return groceriesReply;
  }
}

/// Permission state and a controllable stream of since-boot step totals.
class FakeStepCounter extends StepCounter {
  bool allowed = true;
  bool allowOnRequest = true;
  final readingsController = StreamController<int>.broadcast();

  @override
  Future<bool> granted() async => allowed;

  @override
  Future<bool> request() async => allowed = allowOnRequest;

  @override
  Stream<int> readings() => readingsController.stream;
}

/// Health Connect stand-in: availability, permission and canned readings.
class FakeHealthSource extends HealthSource {
  bool isAvailable = true;
  bool grants = true;
  bool granted = false;
  double? calories;
  int? stepCount;
  List<WatchWorkout> workoutList = const [];

  @override
  Future<bool> available() async => isAvailable;
  @override
  Future<void> install() async {}
  @override
  Future<bool> connect() async => granted = grants;
  @override
  Future<bool> connected() async => granted;
  @override
  Future<int?> steps(DateTime from, DateTime to) async => stepCount;
  DateTime? syncedAt;
  @override
  Future<DateTime?> lastStepsAt(DateTime from, DateTime to) async => syncedAt;
  @override
  Future<double?> caloriesBurned(DateTime from, DateTime to) async => calories;
  int? active;
  @override
  Future<int?> activeMinutes(DateTime from, DateTime to) async => active;
  @override
  Future<List<WatchWorkout>> workouts(DateTime from, DateTime to) async => workoutList;
  List<SourceTotals> apps = const [];
  @override
  Future<List<SourceTotals>> breakdown(DateTime from, DateTime to) async => apps;
}

/// Returns whatever the test sets as the latest release.
class FakeUpdateChecker extends UpdateChecker {
  FakeUpdateChecker(this._latest);
  final AppRelease? Function() _latest;

  @override
  Future<AppRelease?> latest() async => _latest();
}
