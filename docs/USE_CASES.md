# MagnaVita — Use Cases

| | |
|---|---|
| Version | 1.1 (as built) |
| Date | 10 November 2026 |
| Related | [PRD.md](PRD.md) (requirement ids FR-xx), [TRD.md](TRD.md) |

## 1. Actors

| Actor | Type | Description |
|---|---|---|
| **User** | Primary | An adult using MagnaVita on their own phone |
| **Under-18 user** | Primary | Someone who answered "under 18" at onboarding; gets no fasting controls or adult classifications |
| **Phone OS** | Secondary | Delivers notifications, pedometer readings, camera, files and sharing |
| **Health Connect** | Secondary | Supplies watch steps, calories and workouts (read-only) |
| **Gemini** | Secondary | Estimates meals, lists groceries and drafts recipes from photos/text, using the user's key |
| **TheMealDB** | Secondary | Recipe catalogue |
| **Open Food Facts** | Secondary | Barcode product data |
| **Release page** | Secondary | Publishes the newest APK and `version.json` |
| **Supabase** | Secondary | Holds accounts (email/password, Google) and each user's profile and goals row |
| **Google** | Secondary | Confirms who the user is for "Continue with Google" |

## 2. Use case overview

| Id | Use case | Actor(s) | PRD |
|---|---|---|---|
| UC-01 | Complete onboarding and age check | User, Under-18 user | FR-01–03 |
| UC-02 | Start a fast | User | FR-10, FR-12 |
| UC-03 | Follow a fast and read a milestone | User | FR-11, FR-13–14 |
| UC-04 | End a fast | User | FR-16 |
| UC-05 | Correct a fast's start or end | User | FR-15, FR-106 |
| UC-06 | Review history | User | FR-105–106 |
| UC-07 | Log food from the database | User | FR-30–34 |
| UC-08 | Log a packaged food by barcode | User, Open Food Facts | FR-35 |
| UC-09 | Estimate a meal from a photo | User, Gemini | FR-36 |
| UC-10 | Export a meal or a day as an image | User, Phone OS | FR-25, FR-38 |
| UC-11 | Manage kitchen ingredients | User, Open Food Facts, Gemini | FR-40–45 |
| UC-12 | Do the monthly kitchen review | User, Phone OS | FR-50–54 |
| UC-13 | Find and cook a recipe | User, TheMealDB | FR-60–65, FR-68 |
| UC-14 | Write a recipe (optionally with AI) | User, Gemini | FR-66–67 |
| UC-15 | Log an activity or a swim | User | FR-70–72 |
| UC-16 | Connect a watch and see steps | User, Health Connect, Phone OS | FR-73–77 |
| UC-17 | Edit today's steps | User | FR-76 |
| UC-18 | Do a strength workout | User, Phone OS | FR-80–84 |
| UC-19 | Create and follow a workout plan | User, Phone OS | FR-85–88 |
| UC-20 | Review training progress | User | FR-89 |
| UC-21 | Log water | User, Phone OS | FR-90–93 |
| UC-22 | Record weight and measurements | User | FR-100–104 |
| UC-23 | Set preferences and reminders | User, Phone OS | FR-110–113 |
| UC-24 | Back up and restore data | User, Phone OS | FR-114 |
| UC-25 | Delete all data | User | FR-115 |
| UC-26 | Update the app | User, Release page | FR-26 |
| UC-27 | Create an account | User, Supabase | FR-04–06 |
| UC-28 | Sign in (email or Google) | User, Supabase, Google | FR-04–05, FR-09 |
| UC-29 | Continue without an account | User | FR-04 |
| UC-30 | Answer the setup questions | User, Supabase | FR-07–09 |
| UC-31 | See resting energy and maintenance calories | User | FR-107–108, FR-109b |
| UC-32 | Set a goal weight and get a calorie target | User | FR-109 |
| UC-33 | Read the weight forecast | User | FR-109a |
| UC-34 | Follow your goal on Activity, Home and the diary | User | FR-23, FR-39, FR-89a–b |
| UC-35 | Sign out or delete the account | User, Supabase | FR-117 |

## 3. Use cases

### UC-01 Complete onboarding and age check
- **Precondition:** first launch (or after deleting all data).
- **Main flow:**
  1. The splash shows the MagnaVita logo while data loads.
  2. Welcome screens explain what the app does, that it is not a medical device, and that data stays on the phone.
  3. The user confirms they are 18 or over.
  4. The account step opens (UC-27, UC-28 or UC-29), then the setup questions (UC-30), then Home.
- **Alternative 3a:** the user is under 18 → an educational screen recommends talking to a parent/guardian and a healthcare professional; the app opens without fasting controls, fasting presets or adult BMI classifications.
- **Postcondition:** eligibility and member-since date are saved.

### UC-02 Start a fast
- **Precondition:** adult user, no active fast.
- **Main flow:**
  1. The user taps Start on the Home hero card (or (+) → Start fast).
  2. The app saves the start time (UTC) and current target, and schedules the optional target-reached notice.
  3. The ring starts filling.
- **Alternative 1a:** the user first changes the target (presets 12/14/16/18 h or custom 1–24 h).
- **Exception:** a second active fast is impossible; the database allows only one.

### UC-03 Follow a fast and read a milestone
- **Main flow:**
  1. The user taps the ring on Home to open the full timer.
  2. The timer shows elapsed time, target and planned end, computed from the saved start.
  3. The user taps a milestone marker (e.g. yellow Fat burning).
  4. A card shows the explanation, the estimated window and the disclaimer that the app cannot measure metabolic state.
- **Alternative:** the target passes → the ring shows "Target reached" and keeps counting without asking the user to continue.
- **Note:** closing, rebooting or changing time zone never changes the elapsed time.

### UC-04 End a fast
- **Main flow:** the user taps End → confirms → the session is saved as "target reached" or "ended", with no failure wording; pending notices are cancelled.
- **Alternative:** the user cancels the confirmation and the fast continues.

### UC-05 Correct a fast's start or end
- **Main flow:** from the timer (edit start) or History (open a session), the user picks a new date and time → the app validates and saves → ring and history recalculate.
- **Exceptions:** a time in the future, an end before the start, or an overlap with another fast is rejected with an explanation.
- **Alternative:** the user deletes the session from History.

### UC-06 Review history
- **Main flow:** Profile → History → the user filters (All, Fasting, …) and switches between list and calendar → opens a day to see fasting, food, activity, water and measurements.
- **Alternative:** nothing recorded → a calm empty state ("Skipping a day is completely fine").

### UC-07 Log food from the database
- **Main flow:**
  1. Nutrition → a meal (breakfast, lunch, dinner, snacks) → Add.
  2. The user searches the bundled USDA list, recent or saved foods.
  3. Picks a food, enters grams/ml or a portion.
  4. Sees the estimated nutrients and saves.
- **Alternatives:** 2a food not found → create a custom food with nutrition per 100 g; 4a save the food as a favourite.

### UC-08 Log a packaged food by barcode
- **Main flow:** Add food → Scan → the camera reads the barcode → Open Food Facts returns name, brand and nutrients → the user sets the amount and saves; the product is remembered for next time.
- **Alternative:** unknown barcode → a form opens with the code filled in for manual entry.
- **Exception:** offline → the user is told and can enter it manually.

### UC-09 Estimate a meal from a photo
- **Precondition:** a Gemini key is set in Settings.
- **Main flow:**
  1. Add food → Photo → the user chooses camera or gallery.
  2. The photo is sent to Gemini.
  3. The app lists the foods and weights it estimated.
  4. The user edits, removes or adds items and saves.
- **Exceptions:** no key → the user is directed to Settings; invalid key or quota → a clear message, nothing saved; not food → nothing to add.

### UC-10 Export a meal or a day as an image
- **Main flow:** the user opens the day export from Home (or the meal export from Nutrition) → picks a day and style (white, lime, forest, badge) → shares the transparent PNG.

### UC-11 Manage kitchen ingredients
- **Main flow:**
  1. Nutrition → My Kitchen → Add Ingredient → "Type it in".
  2. The user enters name, categories, quantity, unit, state, dates, low-stock level, brand and notes.
  3. The ingredient appears in the list and in the expiring-soon / low-stock overview when relevant.
- **Alternatives:** 1a scan a barcode (name, brand, pack size filled in); 1b photograph groceries → Gemini lists items → the user ticks and edits them before saving; later the user updates a quantity, marks it finished, discards or removes it; search and category filters narrow the list.
- **Rule:** nothing is removed automatically when a month starts.

### UC-12 Do the monthly kitchen review
- **Trigger:** the reminder on the 1st at 10:00, Settings → Review my kitchen now, or the button in My Kitchen.
- **Main flow:**
  1. The app shows each ingredient in turn.
  2. For each, the user chooses: still have it (update quantity), used it up, or spoiled.
  3. Optionally adds it to the shopping list.
  4. Adds new purchases.
  5. Finishes; the review and every change are saved as history and recipe suggestions refresh.
- **Alternative:** the user stops part-way and continues later.

### UC-13 Find and cook a recipe
- **Main flow:**
  1. Nutrition → Recipes shows what can be made from the kitchen.
  2. The user filters (ready to cook, uses expiring items, favourites) and by diet; allergen recipes are hidden.
  3. Opens a recipe: available and missing ingredients, substitutions, steps, estimated nutrition.
  4. Adjusts the batch size, adds missing items to the shopping list.
  5. Marks it cooked and logs a serving to a meal.
- **Alternatives:** save as favourite; offline → cached recipes still open; nothing found → "No recipes match these filters".

### UC-14 Write a recipe (optionally with AI)
- **Main flow:** Recipes → New recipe → the user enters name, photo, time, servings, ingredients, steps and nutrition per serving → saves; it appears under "My recipes".
- **Alternative:** "Let MagnaVita write it" → the user adds a plate photo and/or a description → Gemini fills the form → the user checks and saves.

### UC-15 Log an activity or a swim
- **Main flow:** Activity (or (+)) → Log activity → type, date/time, duration, optional intensity and notes → the app shows an estimated calorie burn → save.
- **Alternative (swim):** choose a pool length and laps → enter total minutes or pace per lap (time is worked out) → calories from the user's resting energy → save.
- **Exception:** duration outside 1–600 minutes is rejected.

### UC-16 Connect a watch and see steps
- **Main flow:**
  1. Settings → Watch → Connect.
  2. Health Connect's permission screen opens; the user allows reading.
  3. On each app open, MagnaVita reads today's steps, calories and new workouts (Mi Fitness first).
  4. Home shows the higher of the phone and watch counts and when the watch last synced; watch workouts appear in activity history.
- **Alternatives:** Health Connect missing → "Install Health Connect" opens the store; permission denied → status "Needs permission"; the user can hide an imported workout or stop reading watch data.
- **Without a watch:** "Count my steps" asks for activity permission and uses the phone pedometer.

### UC-17 Edit today's steps
- **Main flow:** Home → steps tile → Edit steps → enter the watch's number → the tile shows "edited" and keeps adding steps the phone counts afterwards.
- **Alternatives:** a later watch sync that's higher takes over; "Go back to the automatic count" removes the edit.

### UC-18 Do a strength workout
- **Main flow:**
  1. Activity → Start workout (empty, or from a plan day).
  2. Add exercise → pick from the library by equipment group or search, or type a name.
  3. Each exercise starts with last time's sets; the user adjusts weight and reps and ticks each set.
  4. A rest timer runs after each set; a notification says when rest is over.
  5. Finish workout → saved as a strength activity.
- **Alternatives:** open an exercise to see photos, steps, muscles and your bests; add or remove sets; discard the workout (with confirmation); close the app and resume later.
- **Exception:** finishing with no ticked sets → "Tick off at least one set to save the workout".

### UC-19 Create and follow a workout plan
- **Main flow:**
  1. Activity → Make a workout plan.
  2. The user picks goal, days a week (3–5), experience and equipment → Create my plan.
  3. The plan shows each day's focus and exercises; the user can change sets and reps or swap/remove an exercise.
  4. The user taps the weekdays they train and optionally turns on a reminder at a chosen time.
  5. On a training day Home/Activity shows "Today: Day n"; Start day n fills in the workout (UC-18).
- **Alternatives:** a missed day waits and becomes "Up next"; Change my plan replaces the current plan after a warning.

### UC-20 Review training progress
- **Main flow:** Activity → Progress → this week vs plan, week streak, last 30 days, workouts per week (8 weeks), personal bests; tap an exercise for its estimated 1-rep max chart.
- **Alternative:** no workouts yet → an empty state explains what will appear.

### UC-21 Log water
- **Main flow:** Home water tile or (+) → add a glass (250/500 ml or 8/16 fl oz, or a custom amount) → progress toward the daily goal updates.
- **Alternatives:** edit or delete an entry; change the goal; turn on reminders every 2 hours 8 AM–8 PM.

### UC-22 Record weight and measurements
- **Main flow:** Profile → add a weigh-in (weight, optional waist, neck, hip) → the chart, BMI with its limitations note, healthy weight range and estimated body fat update.
- **Alternatives:** edit or delete a weigh-in; switch weight tracking off (weight sections hidden).
- **Rule:** under-18 users see no BMI band or body-fat estimate.

### UC-23 Set preferences and reminders
- **Main flow:** Profile → Settings → the user changes target, 24-hour clock, units, diet, allergies, and switches reminders (target reached, daily, water, monthly review, training days) on or off.
- **Alternatives:** notifications blocked by the OS → the app says so and links to phone settings; enter or remove the Gemini key.

### UC-24 Back up and restore data
- **Main flow (back up):** Settings → Back up my data → the share sheet opens → the user saves the file to Drive, email or Files. The Gemini key is not included.
- **Main flow (restore):** on a new phone, Settings → Restore from a backup → confirm → choose the file → everything is replaced and reminders are rescheduled → "Your data is back".
- **Exceptions:** the file is not a MagnaVita backup or is from a newer version → rejected, nothing changed; an error during restore → nothing changed.

### UC-25 Delete all data
- **Main flow:** Settings → Delete all data → confirm → all records and settings are removed, reminders cancelled, and onboarding starts again.

### UC-26 Update the app
- **Main flow:** on launch the app reads `version.json`; if newer, Home shows "New version available · Update" → the user taps Update → the release page opens → the user installs the APK over the old one and keeps all data.
- **Alternative:** offline → no banner, nothing else affected.

### UC-27 Create an account
- **Precondition:** adult, account step showing (after the age check, or Profile → Account → Sign in or create an account).
- **Main flow:**
  1. The user enters name, email and a password of 8+ characters and taps Create account.
  2. Supabase creates the account; a profile row is created with the name.
  3. The user is signed in; their name is used in the app if none was set; the setup questions follow (UC-30).
- **Alternatives:** 1a fields missing or invalid → each one says what's wrong; 2a email confirmation is on → "we sent a link to …", the screen switches to Sign in; 2b the email already has an account → "sign in instead"; 2c weak password → asked for a longer one.
- **Exception:** offline → "You're offline", nothing created.

### UC-28 Sign in (email or Google)
- **Main flow (email):** Already have an account? Sign in → email and password → Sign in.
- **Main flow (Google):** Continue with Google → choose a Google account → signed in.
- **Then:** if the account already holds a finished setup (e.g. a new phone), it is copied to the phone (name, body details, latest weight if the phone has none, goal weight and pace, activity level, setup answers, diet, allergies, units) and the setup questions are skipped; otherwise this phone's profile is saved to the account.
- **Alternatives:** wrong password → "That email and password don't match"; email not confirmed → asked to confirm first; Google cancelled → "Sign-in was cancelled"; Google not configured → "use your email for now".

### UC-29 Continue without an account
- **Main flow:** on the account step the user taps Continue without an account → setup questions (UC-30) → the app. Everything stays on the phone.
- **Alternative:** later, Profile → Account → Sign in or create an account (UC-27/UC-28).

### UC-30 Answer the setup questions
- **Precondition:** account step done; setup not finished on this phone.
- **Main flow (7 steps, each optional):**
  1. About you: name, sex, year of birth, units, height.
  2. Weight today.
  3. Main goal: lose weight, stay where I am, build muscle, get fitter or better fasting habits; for losing or building, a goal weight and pace.
  4. How active you are (five levels).
  5. Meals a day (2, 3, 4, 5+).
  6. Training: days a week, experience, equipment.
  7. Food preferences: diet and allergies → Finish.
- **Postcondition:** answers saved to the phone (and the account when signed in); the app opens arranged around the goal.
- **Alternatives:** Skip for now on any step → what's valid so far is saved and the app opens; Back to change an answer; switching units converts what was typed.
- **Exceptions:** a birth year under 18 → "goals are for people 18 and over"; a goal weight below BMI 18.5 → refused with the lowest allowed; impossible heights or weights → "check the numbers".
- **Existing installs:** shown once, filled in with what's already saved; an unchanged weight adds no new weigh-in.

### UC-31 See resting energy and maintenance calories
- **Precondition:** adult with height, weight, age and sex; weight tracking on.
- **Main flow:** Profile → the energy card shows resting energy (BMR); with 7+ days of activities, watch calories or steps, it shows calories to keep the weight steady and the activity level worked out from those records.
- **Alternative:** fewer than 7 days of records → the user picks a usual activity level and sees maintenance from it.
- **Rule:** under-18s and anyone without the details see a prompt instead of numbers.

### UC-32 Set a goal weight and get a calorie target
- **Main flow:** Profile → Set a goal weight → goal and pace (0.25–1 kg a week) → Save → "Eat about N kcal a day to lose about X a week".
- **Alternatives:** the pace would go below the safe minimum (resting energy, 1,200 women / 1,500 men) → the target stays at the minimum and the actual pace is shown; gaining faster than 0.5 kg a week → capped with an explanation; within half a kilo of the goal → maintenance calories; Change goal or Remove goal.
- **Exception:** goal below BMI 18.5 → refused.

### UC-33 Read the weight forecast
- **Main flow:** Profile → Weight forecast → recorded weigh-ins (solid), 12 weeks ahead (dashed), the goal line, "In 12 weeks: about N" and "Reaches goal around date".
- **Alternatives:** 7+ of the last 14 days logged in the diary → forecast from what was eaten; otherwise from the target, or maintenance without a goal; goal not reached in 12 weeks → said plainly.

### UC-34 Follow your goal on Activity, Home and the diary
- **Main flow:** the Activity page opens with a goal card:
  - lose weight / stay where I am → calories eaten vs the daily target, burned and steps, with kcal left;
  - build muscle → the workout card first, then workouts this week vs the plan, week streak and protein vs ~1.6 g per kg;
  - get fitter → active minutes this week toward 150 and steps, with logging an activity before the workout card.
- **Also:** Home shows "of N kcal today" under calories eaten with a progress bar; each meal in the diary shows "eaten of about N kcal" from meals a day; Make a workout plan starts with the goal, days, experience and equipment from setup.
- **Alternatives:** no target yet → a link to set one up in Profile; better fasting habits or no goal → no goal card.

### UC-35 Sign out or delete the account
- **Main flow (sign out):** Profile → Account → Sign out → confirm → back to the account step; everything on the phone stays.
- **Main flow (delete):** Profile → Account → Delete my account → confirm → the account and its profile are deleted; the phone's data stays (UC-25 removes that).
- **Exception:** offline → an offline message, nothing changed.
