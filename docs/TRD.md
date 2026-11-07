# MagnaVita — Technical Requirements Document

| | |
|---|---|
| Version | 1.0 (as built) |
| Date | 7 November 2026 |
| Companion to | [PRD.md](PRD.md) (what the product does) and [USE_CASES.md](USE_CASES.md) (how people use it) |
| Code | `frontend/` (Flutter app); `backend/` is intentionally empty |

This document describes how MagnaVita is built: architecture, data, integrations, platform requirements, testing and releases. It reflects the code at schema version 14.

## 1. Platform and toolchain

| Item | Requirement |
|---|---|
| Framework | Flutter (stable), Dart SDK `^3.13.1` |
| Android | `minSdk 26` (Android 8, needed for Health Connect); target = Flutter's default; release build is arm64 |
| iOS | Project included and kept compiling; not released |
| Package id | `com.leanmuzveba.life_fasting` (never changes, so installs keep their data) |
| Pub package name | `life_fasting` |
| Lints | `flutter_lints`, `flutter analyze` clean |

### Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` 3 | State management (no code generation) |
| `sqflite` | On-device SQLite |
| `flutter_local_notifications`, `timezone` | Opt-in local reminders |
| `health` | Health Connect (read-only) |
| `pedometer`, `permission_handler` | Phone step counter and runtime permissions |
| `mobile_scanner` | Barcode scanning |
| `image_picker` | Meal, grocery and recipe photos |
| `file_picker`, `share_plus` | Backup restore and sharing (backups, PNG exports) |
| `url_launcher` | Opening the update page and Health Connect store page |
| `flutter_svg`, `intl`, `flutter_localizations` | Icons, formatting, localisation |
| Dev: `sqflite_common_ffi`, `flutter_launcher_icons`, `flutter_native_splash` | Desktop DB in tests, icon and splash generation |

## 2. Architecture

Layered, offline-first, with dependencies pointing inwards:

```
features/  (screens and widgets, one folder per feature)
   │ watch/read
state/providers.dart  (Riverpod providers, notifiers, "actions" classes)
   │ call
data/  (repositories, database, APIs, platform services)
   │ use
domain/  (pure Dart models and calculations; no Flutter imports)
```

| Layer | Folder | Responsibilities |
|---|---|---|
| Core | `lib/core/` | Theme and design tokens, fonts, icons, formatting, shared widgets (`ruva_kit.dart`, pill buttons, sheets, logo) |
| Domain | `lib/domain/` | Fasting timer maths, milestones, food and nutrients, kitchen, recipes and matching, activity and MET, swims, steps merging, workouts, plan builder, body/BMI, history aggregation, settings |
| Data | `lib/data/` | `AppDatabase` and migrations, one repository per area, backup, Health Connect, pedometer, notifications, Gemini, TheMealDB, Open Food Facts, update checker |
| State | `lib/state/providers.dart` | Providers wiring repositories to UI; injectable clock (`clockProvider`, `nowProvider`) so time-based logic is testable |
| Features | `lib/features/` | `today`, `home` (timer), `ring`, `milestones`, `setup`, `history`, `food`, `kitchen`, `recipes`, `activity_water`, `hydration`, `workout`, `profile`, `settings`, `onboarding`, `splash`, `shell` |
| l10n | `lib/l10n/` | `app_en.arb` (≈880 strings), generated `AppLocalizations`; accessed via `context.l10n` |

### Key design rules

1. **Timestamps are truth.** A fast stores `started_at` (UTC epoch ms) and the target; elapsed, remaining, ring progress and milestone state are computed by `TimerSnapshot.compute` from the clock each tick. Nothing stores the displayed counter.
2. **Milestones are data** (`domain/milestone.dart`): key, kind, title, offset, estimate window, body, disclaimer, review status.
3. **Write-through state.** Notifiers write to SQLite first and then update state, so a crash never leaves the UI ahead of storage. An in-progress workout is stored under `settings['workout.current']` after every change.
4. **Estimates are explicit.** Domain functions that estimate (calories, 1RM, body fat, swim time, distance from steps) are named and documented as estimates and labelled in the UI.
5. **No strings in widgets.** All copy is in the ARB file; milestone education copy lives in domain data for health review.

## 3. Data

### 3.1 Storage

- One SQLite file, `life_fasting.db`, in the app's databases directory. `PRAGMA foreign_keys = ON`.
- Times are UTC epoch milliseconds; calendar days are local `YYYY-MM-DD` text.
- Flexible structures (nutrients, exercises, recipe ingredients and steps, portions) are JSON text columns.
- Small preferences and state live in the `settings` key/value table.

### 3.2 Migrations

`AppDatabase.migrations` is an append-only list; entry *i* upgrades version *i* → *i+1*. Fresh installs run all of them; upgrades run only the missing ones, inside sqflite's single transaction (all or nothing). Shipped migrations are never edited or reordered.

| Version | Change |
|---|---|
| 1 | `sessions` (one active session enforced by a partial unique index; `ended_at > started_at`), `settings`, `notification_prefs` |
| 2 | `hydration_entries` |
| 3 | `activity_entries` (1–600 minutes, optional intensity) |
| 4 | `ingredients` (categories, quantity ≥ 0, state, dates, low-stock, status kept as history) |
| 5 | `kitchen_reviews`, `kitchen_review_changes` (cascade), `shopping_items` |
| 6 | `food_entries` (indexed by day), `saved_foods`, `custom_foods` |
| 7 | `api_cache`, `saved_recipes`, `recipe_logs` |
| 8 | Barcode, brand, unit and portions on `custom_foods` (unique barcode); unit on `food_entries` |
| 9 | `weigh_ins` (weight > 0, optional waist/neck/hip) |
| 10 | `my_recipes` |
| 11 | Recipe photo (JPEG BLOB ≤ 1024 px) and nutrients per serving |
| 12 | Watch workouts: `external_id` (unique when set), `kcal`, `hidden` on `activity_entries` |
| 13 | `exercises` JSON on `activity_entries` (sets with weight and reps) |
| 14 | Swims: `laps`, `pool_m` on `activity_entries` |

### 3.3 Settings keys (selection)

| Key | Contents |
|---|---|
| `targetMinutes`, `use24HourTime`, `onboardingComplete`, `eligibility`, `units`, `diet`, `allergies`, `waterGoalMl`, `userName`, `memberSince` | User preferences |
| `steps.goal`, `steps.book` | Step goal; last pedometer readings used to work out today's steps |
| `workout.current` | In-progress workout (JSON) |
| `workout.plan` | Current workout plan, training weekdays and reminder time (JSON) |
| `workout.rest` | Rest seconds between sets |
| `apiKey.gemini` | User's Gemini key (never in backups) |

### 3.4 Backup and restore

- **Create:** `VACUUM INTO` a temporary file, delete `apiKey.*` rows, `VACUUM` again so no trace remains, then share the bytes.
- **Restore:** open the file read-only and accept it only if it has a `sessions` table and `1 ≤ user_version ≤ latest`; migrate a copy to the current schema; then, in one transaction, replace each table's rows from the attached backup (keeping this phone's API keys). Any failure leaves existing data untouched.
- Known limit: `VACUUM INTO` needs SQLite 3.27 (Android 11+).

## 4. Domain logic

| Area | Rule |
|---|---|
| Fasting | Elapsed = now − start; progress = min(elapsed / target, 1); session edits rejected for start/end in the future, end before start, or overlap with another fast |
| Milestones | Fast begins (0 h), Fat burning (10 h, window 8–12 h), Ketosis may begin (14 h, 12–18 h), Later fasting stage (20 h, 18–24 h); milestones beyond a shorter target are noted, never used to urge a longer fast |
| Activity calories | (MET − 1) × weight kg × hours, MET from the Compendium per type and intensity; resting energy excluded so it adds up with watch calories |
| Swims | Duration = laps × seconds per lap; calories = Mifflin-St Jeor BMR ÷ 1440 × MET × minutes; distance = laps × pool length |
| Steps | Shown count = max(watch, phone, manual + phone steps since the manual entry); distance = steps × 41.5 % of height |
| 1-rep max | Epley: weight × (1 + reps / 30); bests per exercise keyed by library id, else name |
| Progress | Workouts per ISO week (Monday 00:00 local) for 8 weeks; streak counts consecutive weeks with a workout, and the current week only breaks it once over |
| Plan builder | Splits: 3 days push/pull/legs; 4 days chest-triceps/back-biceps/legs/shoulders-core; 5 days chest/back/legs/shoulders/arms-core. Each slot picks a well-known exercise for the muscle, then the rest of the library, filtered by level and equipment (gym, dumbbells, bodyweight). Sets, reps and rest come from the goal |
| Schedule | Default weekdays spread with rest between; the next plan day is the next scheduled weekday from today, so a missed day waits |
| Body | WHO adult BMI bands (none under 18); healthy weight range for BMI 18.5–24.9; body fat by US Navy tape method, else Deurenberg |
| Recipes | Match kitchen ingredient names to recipe ingredients; rank by available share, expiring items first when filtered; hide allergens and diets; substitutions only from fresh, unexpired kitchen items |
| Kitchen | Expiring-soon and low-stock flags; review actions kept / used up / spoiled recorded with old and new quantities |

## 5. Integrations

| Integration | Mechanism | Failure behaviour |
|---|---|---|
| USDA FoodData Central SR Legacy | Bundled TSV (`assets/foods/usda_sr_legacy.tsv`, built by `tool/build_usda.py`), loaded once | Always available |
| free-exercise-db | Bundled `assets/exercises/exercises.json` (870 exercises, public domain); photos from the dataset's GitHub raw URLs | Text works offline; photos say they load when online |
| TheMealDB | HTTPS JSON, 15 s timeout; responses cached in `api_cache` (lists 7 days, recipes kept) | Cached data used; otherwise a retry message |
| Open Food Facts | Barcode lookup | Unknown code → manual entry pre-filled with the code |
| Google Gemini | Vision requests with structured JSON replies; `gemini-3.5-flash` with `gemini-3.5-flash-lite` as fallback when overloaded, slow or retired; key entered by the user | Clear error for bad key/quota; nothing saved without review |
| Health Connect | `health` package, read-only: steps, active and total calories, exercise, distance. Mi Fitness preferred, otherwise the app with the most data; per-app totals so steps aren't double counted | Status shown (not installed, needs permission, connected); app works without it |
| Phone pedometer | `pedometer` stream folded into a daily step book | "Count my steps" permission prompt; unavailable message if no sensor |
| Release page | `version.json` on https://ruva-releases.vercel.app compared with the build number passed by `--dart-define` | Silent when offline or unconfigured |

### Android permissions

`INTERNET`, `ACTIVITY_RECOGNITION`, `RECEIVE_BOOT_COMPLETED` (reschedule reminders), Health Connect `READ_STEPS`, `READ_ACTIVE_CALORIES_BURNED`, `READ_TOTAL_CALORIES_BURNED`, `READ_EXERCISE`, `READ_DISTANCE`, plus `START_VIEW_PERMISSION_USAGE` for Health Connect's rationale screen. Camera and notification permissions are requested at runtime when first needed.

## 6. Notifications

All local and opt-in; copy is neutral and never urges extending a fast.

| Id | Notification | Schedule |
|---|---|---|
| 1 | Target reached | Once, at start + target |
| 2 | Daily reminder | Daily at a chosen time |
| 100+ | Water reminders | Every 2 h, 08:00–20:00 local |
| 200 | Monthly kitchen review | 1st of each month, 10:00 |
| 300 | Rest over | End of the rest timer between sets |
| 401–407 | Training day reminders | Weekly on each chosen weekday at a chosen time |

Notifications are re-synced with saved preferences on every launch and after restore.

## 7. Security and privacy

- No backend, accounts, analytics or advertising SDKs.
- Data leaves the device only for: TheMealDB and Open Food Facts lookups (search terms and barcodes), exercise photo downloads, photos and descriptions the user chooses to send to Gemini, and the update check.
- No API key is compiled into any build; the user's Gemini key is stored locally and excluded from backups.
- Health Connect access is read-only and can be revoked from Settings → Watch.
- "Delete all data" clears fasting sessions, water, activities and workouts, kitchen and reviews, food diary, body measurements and recipes, and resets settings.

## 8. Accessibility and UI

- Design tokens in `core/theme/tokens.dart`: forest `#135D44`, lime `#B9F36C`, mint `#F6FCEF`, ink `#1A2A20`; milestone yellow and red.
- Fonts bundled (OFL): Lexend, DM Sans, JetBrains Mono.
- Contrast pairs are unit-tested for WCAG AA; tap targets ≥ 48 dp; semantics labels on the ring, charts, set ticks and exports; layouts tested at increased text scale.
- Exports render off-screen widgets to transparent PNGs and share them.

## 9. Testing

`flutter test` runs about 170 tests in 35 files, all required to pass before a release.

| Folder | Covers |
|---|---|
| `test/domain/` | Timer maths (midnight, edits, time zones), hydration, kitchen rules, step merging |
| `test/data/` | Every migration from v1 with seeded data, repositories and constraints, backup and restore |
| `test/state/` | Start/edit/end flow, restart recovery, age gate |
| `test/features/` | Widget tests for each screen: ring, home, history, food diary, barcode, meal photo, kitchen, review, recipes, my recipes, activity, watch, workout, plan, progress, profile, settings, onboarding, splash, exports |
| `test/core/` | Design-system tokens |
| `test/features/accessibility_test.dart` | Tap targets, contrast, text scaling |

Tests use `sqflite_common_ffi` with an in-memory or temp database, an injected clock, and fakes for Health Connect, notifications, Gemini and HTTP.

## 10. Build and release

- `python tool/release.py "notes"` (run from `frontend/` after committing):
  1. builds a release arm64 APK with build number = git commit count and version name `SERIES.NNN` (series 1.2; NNN = commits since the series began);
  2. writes `release_site/version.json` and a download page;
  3. deploys `release_site/` to the Vercel project **ruva-releases** (https://ruva-releases.vercel.app), retrying a failed deploy up to three times.
- `--deploy-only` re-uploads an existing build without rebuilding.
- The Vercel project stays disconnected from GitHub; `vercel` commands run only in `release_site/`.
- The installed app reads `version.json` on launch and shows the update banner on Home.

## 11. Naming and continuity

The product name is MagnaVita and the GitHub repository is `leanmuzveba/MagnaVita`. These deliberately keep older names because changing them would break installs or releases:

| Kept | Why |
|---|---|
| Package id `com.leanmuzveba.life_fasting` | Android treats a new id as a different app (data lost) |
| Database `life_fasting.db` | Existing data location |
| Internal `Ruva*` widget names, `ruva_kit.dart` | Code-only; renaming adds churn without user benefit |
| `ruva-releases.vercel.app` | Installed apps check this URL for updates |

## 12. Known limitations

- Backup creation needs Android 11+ (`VACUUM INTO`).
- Exercise photos need a connection.
- Health Connect integration is Android-only; Apple Health is not implemented.
- English only, though all strings are ready for translation.
- No estimated cost for missing recipe ingredients.
