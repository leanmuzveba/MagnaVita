# MagnaVita — Product Requirements Document

| | |
|---|---|
| Version | 2.1 (as built) |
| Date | 10 November 2026 |
| Product | MagnaVita, personal fasting, nutrition, fitness and wellness app |
| Platform | Flutter mobile app; Android is the release target, iOS project included |
| Status | Implemented and in use (release series 1.2.NNN) |
| Supersedes | Intermittent Fasting Companion PRD v1.0 and RUVA PRD v1.2 (both kept in `docs/` as history) |

This document describes MagnaVita as it is implemented today. Requirements carried over from the earlier PRDs keep their meaning; where the product deliberately departs from them, section 12 records the decision.

## 1. Overview

MagnaVita is a calm, offline-first personal wellness app. It started as the Fasting Companion (a circular fasting timer with milestone markers), was expanded under the name RUVA into a nutrition, kitchen and activity hub, and was renamed MagnaVita in October 2026. The circular fasting timer remains the signature component; food, kitchen, recipes, workouts, activity, steps, water and body measurements are organised around it. Since November 2026 people can create an account (email or Google), answer a few setup questions about themselves and their goal, and get personal calorie targets and a weight forecast.

### Vision

One convenient place to understand and manage everyday wellness habits (food, movement, fasting and personal health) without pressure, and with as little personal data as possible leaving the phone.

### Objectives

1. Keep the circular fasting timer and milestone interface accurate and calm.
2. Record food and nutrition with honest, clearly labelled estimates.
3. Keep a living kitchen inventory and suggest recipes from what is actually at home.
4. Track activity, strength training, steps and water, with plans and progress.
5. Offer optional body measurements with BMI caveats and age safeguards.
6. Give adults personal energy numbers (resting energy, maintenance calories, a calorie target and a weight forecast) with firm safety limits.
7. Shape the app around each person's main goal.
8. Keep day-to-day records on the device; only the profile and goals go to an optional account, and a user-controlled backup covers the rest.
9. Stay accessible and easy to use.

## 2. Users and safety boundaries

- **Primary user:** an adult tracking their own habits. Accounts are optional and personal; there are no social features or shared data.
- **Age gate:** onboarding asks whether the user is 18 or over. Under-18s (and anyone not yet confirmed adult) never see fasting controls, fasting presets or encouragement to fast, and never get adult BMI classifications or body-fat estimates.
- **Not a medical device:** milestone times, calorie estimates, nutrition values and body-fat figures are estimates. The app never claims elapsed time confirms ketosis, fat burning, autophagy or any internal state. A persistent "Not a medical device" notice is in Settings and every milestone detail carries a disclaimer.
- **Neutral copy:** no fasting streaks, no guilt, no prompts to extend a fast. A fast can be ended at any time without judgement. History copy says skipping a day is fine.
- **AI review:** any AI-generated entry (meal estimate, grocery list, recipe) is shown for review and is saved only when the user confirms.
- **Allergies:** recipes containing a recorded allergen are hidden, and the app warns that ingredient data cannot guarantee a recipe is allergen-free.
- **Weight-loss targets for adults only, with safety limits:** a daily calorie target never goes below the person's resting energy or 1,200 kcal (women) / 1,500 kcal (men); a goal weight can't be below BMI 18.5; losing is limited to 1 kg a week and gaining to 0.5 kg a week; under-18s never see calorie targets or forecasts. Targets and forecasts are labelled estimates, with advice to see a professional when pregnant, breastfeeding, managing a medical condition or with a history of disordered eating. Weight loss is offered as a choice, never the default.

## 3. Navigation

Bottom navigation: **Home · Activity · (+) · Nutrition · Profile**.

| Section | Contents |
|---|---|
| Home | Today dashboard: fasting hero card, steps, calories eaten (against your daily target) and burned, water, day export, update banner |
| Activity | A goal card at the top that matches your main goal, then strength workouts, plan, schedule, progress, exercise library, activity log, swims |
| (+) | Quick-add menu: a glass of water, start/end a fast, log food, log an activity, add a weigh-in |
| Nutrition | Food diary, My Kitchen, monthly review, recipes, meal export |
| Profile | Profile, body measurements, resting energy, calorie target and weight forecast, History, Account, Settings |

The full fasting timer opens by tapping the ring on Home.

## 4. Functional requirements

Priority: **M** = must, **S** = should, **C** = could. Status: ✅ implemented, ◐ partly, ✗ not implemented.

### 4.1 Onboarding and safety

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-01 | Welcome screens explain the app's purpose, limits and privacy | M | ✅ |
| FR-02 | Age check; under-18s see an educational screen and no fasting controls | M | ✅ |
| FR-03 | Splash with the MagnaVita logo while data loads | C | ✅ |
| FR-04 | After the age check, adults create an account (name, email, password), sign in, continue with Google, or continue without an account | M | ✅ (Google needs its client ID configured) |
| FR-05 | Sign-up validates name, email and an 8+ character password; explains wrong password, existing email, weak password, unconfirmed email and offline | M | ✅ |
| FR-06 | When email confirmation is on, sign-up says to confirm by email, then sign in | S | ✅ |
| FR-07 | Setup questions (7 short steps, each optional and skippable): name, sex, birth year, height, units; current weight; main goal (lose weight, stay where I am, build muscle, get fitter, better fasting habits) with goal weight and pace; activity level; meals a day; training days, experience and equipment; diet and allergies | M | ✅ |
| FR-08 | Existing installs see the setup once, filled in from what's already saved | S | ✅ |
| FR-09 | Signed in, profile and goals are saved to the account; signing in on a new phone brings them back and skips setup | S | ✅ |

### 4.2 Fasting timer

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-10 | Start and end a fast; the start timestamp is saved immediately | M | ✅ |
| FR-11 | Elapsed time derived from saved UTC timestamps, correct after restart, reboot and time-zone change | M | ✅ |
| FR-12 | Target presets 12/14/16/18 h and a custom 1–24 h target; no preset is a recommendation | M | ✅ |
| FR-13 | Ring shows progress capped at 100 % while elapsed time continues; "Target reached" without urging to continue | M | ✅ |
| FR-14 | Milestone markers (fast begins, fat burning ~10 h in yellow, ketosis may begin ~14 h in red, later stage ~20 h) placed from data; tap opens explanation, estimate window and disclaimer | M | ✅ |
| FR-15 | Edit a fast's start to any day and time; rejected if it is in the future, after the end or overlaps another fast | S | ✅ |
| FR-16 | Confirm before ending a fast to avoid accidental taps | M | ✅ |
| FR-17 | Optional notice when the target time is reached | S | ✅ |

### 4.3 Home dashboard

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-20 | Greeting with the user's name when set | C | ✅ |
| FR-21 | Fasting hero card with compact ring and Start/End; tap opens the full timer | M | ✅ |
| FR-22 | Steps with goal, distance and source (phone, watch or edited) and when the watch last synced | S | ✅ |
| FR-23 | Calories eaten (from the diary) and burned (watch and/or logged activities), both labelled estimates; eaten shown against the daily target when there is one | S | ✅ |
| FR-24 | Water progress toward a personal goal | S | ✅ |
| FR-25 | Export any day's steps, km, kcal and active time as a transparent PNG in four styles | C | ✅ |
| FR-26 | Show "New version available · Update" when a newer release is published | S | ✅ |

### 4.4 Food diary and nutrition

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-30 | Log food to breakfast, lunch, dinner or snacks for any day | M | ✅ |
| FR-31 | Search a bundled offline food database (USDA FoodData Central SR Legacy) | M | ✅ |
| FR-32 | Quantities in grams/ml or named portions | M | ✅ |
| FR-33 | Save frequent foods; create custom foods with nutrition per 100 g | M | ✅ |
| FR-34 | Nutrients: energy, protein, carbs, fat, fibre, calcium, iron, potassium, sodium, vitamin C; missing values shown as unavailable | M | ✅ |
| FR-35 | Scan a barcode and look it up in Open Food Facts; unknown codes fall back to manual entry | S | ✅ |
| FR-36 | Estimate a meal from a photo (camera or gallery) with Gemini; items reviewed and editable before saving | C | ✅ |
| FR-37 | Log a recipe serving to a meal | S | ✅ |
| FR-38 | Export a meal's calorie and macro totals as a transparent PNG | C | ✅ |
| FR-39 | Each meal shows a rough calorie guide from the daily target and meals a day | C | ✅ |

### 4.5 My Kitchen

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-40 | Ingredient records: name, one or more categories, quantity, unit, state (fresh/frozen/canned/dried), purchase and expiry dates, low-stock level, brand, notes | M | ✅ |
| FR-41 | Add, edit, update quantity, mark finished, discard and remove; finished and discarded items kept as history | M | ✅ |
| FR-42 | Search and filter by category; overview of expiring-soon and low-stock items | M | ✅ |
| FR-43 | Add by barcode scan (fills name, brand, pack size) | S | ✅ |
| FR-44 | Add from a grocery photo; Gemini lists items, user reviews before saving | C | ✅ |
| FR-45 | Never delete inventory automatically when a month starts | M | ✅ |

### 4.6 Monthly kitchen review

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-50 | Optional reminder on the 1st of each month at 10:00; can be switched off | S | ✅ |
| FR-51 | Walk through each ingredient: still have it (update quantity), used up, or spoiled | M | ✅ |
| FR-52 | Add new purchases during the review | M | ✅ |
| FR-53 | Add items to a shopping list; check items off | S | ✅ |
| FR-54 | Keep each review and its changes as history | S | ✅ |

### 4.7 Recipes

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-60 | Suggest TheMealDB recipes from kitchen ingredients, ranked by ingredients available | M | ✅ |
| FR-61 | Filters: all, ready to cook, uses expiring items, favourites, my recipes; diet (vegetarian, vegan, pescatarian, halal) | M | ✅ |
| FR-62 | Hide recipes with recorded allergens and show which allergens are being hidden | M | ✅ |
| FR-63 | Recipe card: image, ingredients available and missing, steps, estimated nutrition, source | M | ✅ |
| FR-64 | Batch size, substitutions from fresh kitchen items (expired ones skipped), add missing to shopping list | S | ✅ |
| FR-65 | Save favourites, mark as cooked, log to diary | S | ✅ |
| FR-66 | Write your own recipes with photo, time, servings and nutrition per serving | S | ✅ |
| FR-67 | Gemini drafts a recipe from a plate photo and/or description; user checks before saving | C | ✅ |
| FR-68 | Cache fetched recipes so they work offline | S | ✅ |
| FR-69 | Estimated additional cost of missing ingredients | C | ✗ |

### 4.8 Activity, steps and watch

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-70 | Log an activity: type (walk, run, cycle, swim, strength, yoga, other), date/time, 1–600 min, optional intensity and notes | M | ✅ |
| FR-71 | Estimate active calories from MET × weight × time, labelled as an estimate | S | ✅ |
| FR-72 | Swims: pool length (presets or custom) and laps; time from total minutes or pace per lap; calories from personal resting energy | S | ✅ |
| FR-73 | Steps from the phone pedometer, with a daily goal and distance from height | S | ✅ |
| FR-74 | Read Health Connect (read-only): steps, calories, workouts, preferring Mi Fitness; show the higher of phone and watch | S | ✅ |
| FR-75 | Import watch workouts into activity history once each; hide unwanted ones | S | ✅ |
| FR-76 | Edit today's steps to match the watch; the phone keeps adding; a later higher sync takes over | C | ✅ |
| FR-77 | Per-app Health Connect totals in Settings for troubleshooting | C | ✅ |

### 4.9 Strength training

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-80 | Track a workout: exercises, each set's weight and reps (seconds for holds), tick sets done; saved as you go so closing the app never loses it | M | ✅ |
| FR-81 | Pick exercises from a bundled 870-exercise library (free-exercise-db), grouped by equipment, or type your own | M | ✅ |
| FR-82 | Each exercise starts from what you did last time | S | ✅ |
| FR-83 | Rest timer between sets with a notification when rest is over | S | ✅ |
| FR-84 | Exercise detail: photos (online), steps, primary and secondary muscles, your heaviest set and best estimated 1-rep max | S | ✅ |
| FR-85 | Workout planner: goal (strength, muscle, endurance, fat loss), 3–5 days, level, equipment; each day trains different muscles; sets, reps and rest from the goal | S | ✅ |
| FR-86 | Edit a plan: change sets and reps, swap or remove exercises; starting a plan day fills in the workout | S | ✅ |
| FR-87 | Schedule: choose training weekdays, see this week (trained, training, rest); a missed day waits rather than being skipped | S | ✅ |
| FR-88 | Optional reminder on training days at a chosen time | C | ✅ |
| FR-89 | Progress: workouts per week (8 weeks), week streak, this week vs plan, last 30 days, personal bests, estimated 1-rep max chart per exercise | S | ✅ |
| FR-89a | Activity page arranged around the main goal: lose weight / stay where I am → calories eaten vs target, burned, steps; build muscle → workouts this week vs plan, streak, protein vs ~1.6 g/kg; get fitter → active minutes this week toward 150, steps | S | ✅ |
| FR-89b | A new workout plan starts from the setup answers (goal, days, experience, equipment) | C | ✅ |

### 4.10 Water

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-90 | Add water in ml or fl oz with quick amounts | M | ✅ |
| FR-91 | Daily summary toward a personal goal (not a medical recommendation) | M | ✅ |
| FR-92 | Review, edit and delete entries | M | ✅ |
| FR-93 | Optional reminders every 2 hours from 8 AM to 8 PM | S | ✅ |

### 4.11 Profile, body and history

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-100 | Optional name, height, birth year and sex; member-since date | S | ✅ |
| FR-101 | Weigh-ins with optional waist, neck and hip; history chart of recorded points only | S | ✅ |
| FR-102 | BMI with WHO adult bands, healthy-range weights and a limitations note; none for under-18s | S | ✅ |
| FR-103 | Estimated body fat (US Navy tape method, else Deurenberg), adults only | C | ✅ |
| FR-104 | Switch weight tracking off | M | ✅ |
| FR-107 | Resting energy (BMR, Mifflin-St Jeor) for adults with weight, height, age and sex | S | ✅ |
| FR-108 | Maintenance calories and activity level worked out from up to 28 days of logged activities, watch calories and steps (7+ days with records), otherwise from the level the user picks | S | ✅ |
| FR-109 | Calorie calculator: goal weight and pace (0.25–1 kg a week) give a daily target within the safety limits in §2 | S | ✅ |
| FR-109a | 12-week weight forecast from what the diary shows (7+ of the last 14 days logged), else the target, with current activity; recorded weigh-ins, goal line and the date the goal is reached | S | ✅ |
| FR-109b | The phone keeps each day's step total so past days count toward the activity level | S | ✅ |
| FR-105 | History hub: fasting list and calendar, plus food, activity, water and measurements by day | M | ✅ |
| FR-106 | Edit or delete a fasting session; "target reached" vs "ended" with no failure language | M | ✅ |

### 4.12 Settings, privacy and updates

| ID | Requirement | P | Status |
|---|---|---|---|
| FR-110 | Preferences: target, 24-hour clock, units (metric/imperial), diet, allergies | M | ✅ |
| FR-111 | Reminders, all opt-in: target reached, daily reminder, water, monthly review, training days | S | ✅ |
| FR-112 | Watch connection: install Health Connect, grant permission, disconnect | S | ✅ |
| FR-113 | Enter or remove a personal Gemini API key; release builds contain no key | S | ✅ |
| FR-114 | Back up all data to a file (excluding API keys) and restore it on a new phone | S | ✅ |
| FR-115 | Delete all data | M | ✅ |
| FR-116 | About and safety notes, "Not a medical device" | M | ✅ |
| FR-117 | Account section: shows who's signed in; sign out; delete my account (removes the account and its profile, keeps the phone's data); sign in later when using without an account | M | ✅ |

## 5. Non-functional requirements

| ID | Area | Requirement |
|---|---|---|
| NFR-01 | Privacy | Day-to-day records (diary, kitchen, workouts, weigh-in history, fasting) stay on the device. With an account, only the profile and goals are stored in Supabase, protected by Row Level Security so each person reads and writes only their own row. Other network use: optional lookups (TheMealDB, Open Food Facts, exercise photos), photos the user chooses to send to Gemini, and the update check. No analytics or ads |
| NFR-02 | Offline | Timer, diary (USDA search), kitchen, workouts, exercise library text, activity, water, profile and history work offline; fetched recipes are cached |
| NFR-03 | Reliability | Timestamps are the source of truth; an in-progress workout is persisted after every change; database migrations never drop user data |
| NFR-04 | Performance | Home opens quickly; the timer ticks once a second without heavy work |
| NFR-05 | Accessibility | WCAG AA contrast, screen-reader labels, text scaling to 1.3× and beyond, touch targets ≥ 48 dp, state never shown by colour alone |
| NFR-06 | Localisation readiness | All UI text in `app_en.arb`; no hard-coded strings in widgets |
| NFR-07 | Security | No secret keys in builds (only Supabase's publishable key, which is public by design); the user's Gemini key stays on the phone and is excluded from backups and the account; passwords are handled by Supabase Auth, never stored by the app |
| NFR-08 | Continuity | Package id `com.leanmuzveba.life_fasting` and database `life_fasting.db` unchanged across renames so the installed app keeps its data |
| NFR-09 | Maintainability | Pure-Dart domain logic, repositories for storage, Riverpod state, one folder per feature; automated tests for each module |

## 6. Brand and design

- Name: **MagnaVita** (formerly RUVA, originally Fasting Companion).
- Colours: forest `#135D44` (primary, timer arc), lime `#B9F36C` (accent), mint `#F6FCEF` (background), ink `#1A2A20` (text). Milestone markers keep fat-burning yellow and ketosis red.
- Fonts: Lexend (headings), DM Sans (body), JetBrains Mono (numbers).
- Logo and icons: `docs/BRANDING/new`; app icon is the forest circle mark; the splash animates the logo and fades in the name.

## 7. Integrations

| Service | Used for | Required? |
|---|---|---|
| USDA FoodData Central (bundled) | Food search and nutrients | Bundled, offline |
| free-exercise-db (bundled JSON, online photos) | Exercise library | Bundled; photos online |
| TheMealDB | Recipe catalogue | Online, cached |
| Open Food Facts | Barcode lookup | Online, optional |
| Google Gemini | Meal photo, grocery photo, recipe drafts | Optional, user's own key |
| Health Connect | Steps, calories, watch workouts | Optional, read-only |
| Supabase | Accounts (email/password, Google) and the profile/goals row | Optional |
| Google Sign-In | "Continue with Google" | Optional |
| Vercel (ruva-releases) | APK download and `version.json` update check | Optional |

## 8. Out of scope

- Syncing day-to-day records (diary, kitchen, workouts) to the cloud; social circles, leaderboards
- Medical diagnosis, biomarker measurement
- Calorie targets or weight-loss plans for under-18s, or any target outside the safety limits in §2
- Payments, subscriptions and ads
- Writing data back to Health Connect

## 9. Success criteria

- Fasting timer correct across backgrounding, force-close, reboot, midnight and time-zone changes.
- Existing installs upgrade through every schema version without losing data.
- Every AI result is reviewed before saving.
- Under-18 safeguards are active and tested.
- Calorie targets never break the safety limits (covered by tests).
- The full automated test suite passes before every release.

## 10. Release history (summary)

| Stage | Highlights |
|---|---|
| Fasting Companion v1.0 | Ring, milestones, history, calendar, reminders, age gate |
| RUVA v1.2 | Green brand, Today dashboard, water, activity, kitchen, monthly review, food diary, recipes, body measurements, exports, watch steps, in-app updates |
| MagnaVita (Oct 2026) | Rename and new logo, backup and restore, swims, strength workouts, exercise library, workout planner, progress, scheduling, editable steps |
| MagnaVita (Nov 2026) | Accounts (email, Google), setup questions, goal-shaped Activity page, resting energy, maintenance calories from records, calorie calculator, weight forecast, calorie target on Home and per-meal guides |

## 11. Future considerations

- Estimated cost of missing recipe ingredients (FR-69)
- Password reset from the app
- Optional cloud sync of day-to-day records
- More languages (structure is ready)
- iOS release and Apple Health
- Dark mode
- Voice food logging

## 12. Decisions that differ from earlier PRDs

| Earlier requirement | Decision |
|---|---|
| Light-blue interface (v1.0, v1.2) | Green MagnaVita palette everywhere, including the timer arc; yellow and red milestone markers kept |
| Timer as the first tab | First tab is the Home dashboard with a compact ring; the full timer opens from it |
| Tabs Timer · History · Nutrition · Settings (v1.2) | Home · Activity · (+) · Nutrition · Profile; History and Settings live under Profile |
| No weight or measurements in the MVP (v1.0) | Optional weigh-ins and measurements with opt-out and age safeguards (as allowed by v1.2 §7) |
| AI recipes later (v1.2) | Gemini recipe drafts added, always reviewed by the user before saving |
| Circles / social (v1.2 roadmap) | Not built: the app is for personal use |
| No accounts (v2.0) | Optional accounts (email or Google) holding only the profile and goals; the app still works fully without one |
| "No restrictive calorie targets or weight-loss plans" (v2.0) | Weight-loss targets for adults only, with the safety limits in §2 |
