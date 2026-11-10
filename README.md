# MagnaVita

A calm, offline-first personal wellness app for Android (iOS project included), built with Flutter. It grew out of the Fasting Companion app (and was briefly called RUVA): the circular fasting timer is still the centrepiece, and food, kitchen, recipes, workouts, activity, water and body measurements sit around it.

> **Not a medical device.** Milestone times, calorie burn and nutrition values are general estimates. The app cannot detect ketosis, fat burning or any other metabolic state, and BMI is shown with its limitations. Talk to a qualified healthcare professional before changing your eating or exercise patterns.

## Features

### Getting started in the app
- **Account**: after the age check, create an account (name, email, password) and confirm it with the code emailed to you, sign in, reset a forgotten password with an emailed code, or carry on without an account. Only your profile and goals are saved to the account, so signing in on a new phone brings them back
- **Setup questions**: seven short, skippable steps: about you, weight today, main goal (lose weight, stay where I am, build muscle, get fitter, better fasting habits) with goal weight and pace, activity level, meals a day, training, and food preferences. Existing installs see it once, filled in with what's already saved

### Home
- **Today dashboard**: forest hero card with a compact fasting ring and Start/End, plus tiles for steps, calories eaten (against your daily target), calories burned and water
- **Day export**: any day's steps, distance, calories and active time as a transparent PNG in four styles (white, lime, forest, badge) with the MagnaVita wordmark
- **In-app updates**: a "New version available" banner when a newer release is published

### Fasting
- Circular ring with milestone markers (fast begins, fat burning at ~10 h, ketosis may begin, later stage) you can tap for an explanation and a disclaimer
- Presets of 12/14/16/18 h or a custom 1–24 h target; edit the start to any day and time as long as it doesn't overlap another fast
- Elapsed time comes from saved timestamps, so it survives restarts, reboots and time-zone changes
- Under-18s never see fasting controls

### Nutrition
- **Food diary**: breakfast, lunch, dinner and snacks; search the bundled USDA food list, scan barcodes (Open Food Facts), save foods, create your own, or estimate a meal from a photo (camera or gallery, Gemini, reviewed before saving). Export a meal's totals as a PNG
- **My Kitchen**: ingredient inventory with categories, quantities, units, food state, purchase/expiry dates and low-stock flags. Add by typing, scanning a barcode or photographing your groceries
- **Monthly kitchen review**: go item by item (kept, used up, spoiled), add purchases and build a shopping list. Nothing is wiped when a month starts
- **Recipes**: TheMealDB recipes matched to your kitchen, showing available and missing ingredients, with allergy and diet filters, expiring-first suggestions, batch size, substitutions, shopping list, mark as cooked and log to diary. Write your own recipes or let Gemini draft one from a photo or description

### Activity
- **Goal card**: the page is arranged around your goal: calories eaten vs your target for losing or keeping weight; workouts this week, streak and protein for building muscle; active minutes toward 150 a week for getting fitter
- **Activity log**: walk, run, cycle, swim, strength, yoga and other, with optional intensity, notes and a calorie estimate from MET values and your weight
- **Swims**: pool length and laps, with time worked out from your pace per lap and calories from your own resting energy
- **Strength workouts**: track each set's weight and reps from an 870-exercise library, with a rest timer (and a notification when rest is over). Each exercise starts from what you did last time
- **Exercise library**: photos, steps and muscles for each exercise, plus your heaviest set and best estimated 1-rep max
- **Workout planner**: pick a goal, 3–5 days a week, experience level and equipment (filled in from your setup answers); each day works different muscles, and starting a day fills in the workout
- **Scheduling**: choose the weekdays you train, see this week at a glance, and get an optional reminder on training days
- **Progress**: workouts per week, week streak, personal bests and a 1-rep max chart per exercise
- **Steps and watch**: phone pedometer plus Health Connect (Mi Fitness first). The higher count wins, you can edit today's steps to match your watch, and watch workouts are imported into your history
- **Water**: entries in ml or fl oz, a personal daily goal and optional reminders every 2 hours (8 AM–8 PM)

### Profile
- Name, height, sex and birth year (all optional); weigh-ins with a chart, tape measurements, BMI with its caveats and an estimated body-fat %. Weight tracking can be switched off, and under-18s get no adult classifications
- **Energy**: resting energy (BMR), calories to keep your weight steady, and how active you are, worked out from 28 days of activities, watch calories and steps (or the level you pick)
- **Calorie calculator**: a goal weight and pace give a daily calorie target. Adults only, never below your resting energy or 1,200 (women) / 1,500 (men) kcal, no goal below BMI 18.5, gaining capped at 0.5 kg a week
- **Weight forecast**: your weigh-ins plus a 12-week projection from what your diary shows (or your target) and your activity, with the date you'd reach your goal
- **Account**: sign in later, sign out, or delete your account
- **History**: fasting sessions in a list and calendar, plus food, activity, water and measurement history in one place
- **Settings**: target, 24-hour clock, units, diet and allergies, reminders (target reached, daily, water, monthly review, training days), watch connection and Gemini key

### Privacy and backup
- Day-to-day records (diary, kitchen, workouts, weigh-ins, fasting) stay on the phone in SQLite. With an account, only your profile and goals are stored in Supabase, protected so only you can read them. Otherwise nothing is sent anywhere except a meal or grocery photo you choose to send to Gemini, and recipe/barcode lookups
- **Settings → Back up my data** shares a backup file (without your Gemini key) to save in Drive, email or Files. **Restore from a backup** brings it back on a new phone. You can also delete everything

## Documentation

| Document | What it covers |
|---|---|
| [docs/PRD.md](docs/PRD.md) | Product requirements for MagnaVita as built (v2.0) |
| [docs/TRD.md](docs/TRD.md) | Technical requirements: architecture, data model, integrations, testing, releases |
| [docs/USE_CASES.md](docs/USE_CASES.md) | Actors and use cases with main and alternative flows |
| [docs/AUDIT.md](docs/AUDIT.md) | Phase 0 audit of the original app before the expansion |
| `docs/Intermittent_Fasting_Companion_PRD.txt` | Original Fasting Companion PRD (v1.0, historical) |
| `docs/RUVA — Project Requirements Document (PRD).pdf` | RUVA PRD v1.2 (historical) |

## Repository structure

```
MagnaVita/
├── frontend/   Flutter app (see frontend/README.md)
│   ├── assets/           fonts, brand art, USDA foods, exercise library
│   ├── tool/release.py   builds the APK and publishes it
│   └── release_site/     generated download page (deployed, not hand-edited)
├── backend/    supabase/schema.sql: the account database (run once in Supabase)
└── docs/       PRD, TRD, use cases, audit, historical PRDs, brand assets
```

## Tech stack

| Layer | Choice |
|---|---|
| UI | Flutter / Dart, Material 3, `CustomPainter` ring and charts |
| State | Riverpod 3 (no code generation) |
| Storage | sqflite, database `life_fasting.db` (schema v14) with tested migrations |
| Notifications | `flutter_local_notifications` |
| Health | `health` (Health Connect), `pedometer` |
| Device | `mobile_scanner`, `image_picker`, `file_picker`, `share_plus` |
| Accounts | Supabase Auth (email + password, codes by email) + `profiles` table with Row Level Security; emails sent through Brevo SMTP |
| Online (optional) | TheMealDB, Open Food Facts, Google Gemini, free-exercise-db photos |

## Brand

Forest `#135D44`, lime `#B9F36C`, mint `#F6FCEF`, ink `#1A2A20`. Fonts are Lexend, DM Sans and JetBrains Mono (OFL, bundled). Tokens live in `frontend/lib/core/theme/tokens.dart`. The MagnaVita logo and icon files are in `docs/BRANDING/new` (the colour guide is still `docs/BRANDING/Ruva_Brand_Guide.pdf`).

## Getting started

```bash
git clone https://github.com/leanmuzveba/MagnaVita.git
cd MagnaVita/frontend
flutter pub get
flutter run
flutter test
```

Photo estimates, grocery photos and AI recipes need a Gemini API key, entered on the phone in **Settings → Meal photo estimates**. Release builds never include a key.

### Accounts (Supabase)

The project URL and publishable key are in `frontend/lib/core/config.dart` (both are public by design; never put the service-role key, SMTP key or a Brevo API key in the app). The one-time dashboard setup (database, Brevo SMTP, code email templates) is in [backend/README.md](backend/README.md).

## Releasing

Commit first, then from `frontend/`:

```bash
python tool/release.py "What changed"
python tool/release.py --deploy-only   # retry the upload without rebuilding
```

This builds an arm64 APK (build number = git commit count, version name `1.2.NNN`) and deploys it to https://ruva-releases.vercel.app. The installed app checks `version.json` on launch and offers the update on Home.

## Principles

- Saved timestamps are the source of truth for the timer, never the displayed counter
- Neutral copy: no fasting streaks, no guilt, and you can end a fast at any time
- Weight-loss targets for adults only, with safety limits; weight loss is a choice, never the default
- Estimates are labelled as estimates. Charts only show recorded data
- AI output is always reviewed by you before it is saved
- Package id `com.leanmuzveba.life_fasting`, the database name and internal code names (`Ruva*`) stay unchanged so existing data and releases keep working
- The app works fully without an account
- Accessible: WCAG AA contrast, screen-reader labels, scalable text, and state is never shown by colour alone
