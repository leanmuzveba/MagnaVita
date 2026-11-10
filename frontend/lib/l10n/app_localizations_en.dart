// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MagnaVita';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get navToday => 'Home';

  @override
  String get navTimer => 'Timer';

  @override
  String get navNutrition => 'Nutrition';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Profile';

  @override
  String get navActivity => 'Activity';

  @override
  String homeSessionInProgress(String date) {
    return '$date · Session in progress';
  }

  @override
  String get startFast => 'Start fast';

  @override
  String get endFast => 'End fast';

  @override
  String get editStartTime => 'Edit start time';

  @override
  String get changeTarget => 'Change target';

  @override
  String get cardFastStarted => 'FAST STARTED';

  @override
  String get cardPlannedEnd => 'PLANNED END';

  @override
  String get cardTarget => 'TARGET';

  @override
  String get cardIfStartedNow => 'IF STARTED NOW';

  @override
  String get cardChangeAnyTime => 'Change any time';

  @override
  String targetHours(int hours) {
    return '$hours hours';
  }

  @override
  String get ringReady => 'Ready when you are';

  @override
  String get ringTargetReached => 'Target reached';

  @override
  String get ringInProgress => 'Fasting in progress';

  @override
  String get ringTimeElapsed => 'TIME ELAPSED';

  @override
  String ringTargetLine(String target) {
    return '$target target';
  }

  @override
  String ringOfTargetLine(String target) {
    return 'of $target target';
  }

  @override
  String get ringCenterHint => 'Shows start and planned end times';

  @override
  String ringSemantics(String status, String elapsed, String targetLine) {
    return '$status. $elapsed elapsed, $targetLine.';
  }

  @override
  String ringSemanticsRemaining(String status, String elapsed, String targetLine, String remaining) {
    return '$status. $elapsed elapsed, $targetLine, $remaining remaining.';
  }

  @override
  String get markerCurrent => 'current estimate';

  @override
  String get markerPassed => 'passed';

  @override
  String get markerUpcoming => 'upcoming';

  @override
  String markerSemantics(String title, String state) {
    return '$title, $state. Opens details.';
  }

  @override
  String markerSemanticsAround(String title, String time, String state) {
    return '$title, around $time, $state. Opens details.';
  }

  @override
  String get readMore => 'Read more';

  @override
  String get endSessionTitle => 'End this session?';

  @override
  String get endSessionRecorded => 'Recorded so far: ';

  @override
  String get endSessionBody => '. You can end a session whenever you choose. It will be saved to your history.';

  @override
  String get endSession => 'End session';

  @override
  String get editStartBody =>
      'Forgot to press Start? Set when you actually began. The ring and history update after you save.';

  @override
  String get startedAtLabel => 'STARTED AT';

  @override
  String startedAtSemantics(String time) {
    return 'Started at $time. Change time';
  }

  @override
  String willStart(String day, String time) {
    return 'Will start $day at $time.';
  }

  @override
  String get errorStartInFuture => 'Start time can’t be in the future.';

  @override
  String get errorEndInFuture => 'End time can’t be in the future.';

  @override
  String get errorEndBeforeStart => 'End time must be after the start time.';

  @override
  String get errorOverlaps => 'That overlaps another fast in your history.';

  @override
  String get milestoneTitle => 'Milestone';

  @override
  String get milestoneMarkerNote =>
      'The position of this marker is a visual reference for elapsed time. It is not proof that anything has happened in your body, and reaching it is not a goal or a health achievement.';

  @override
  String get milestoneReviewed => 'Content reviewed';

  @override
  String milestoneReviewedSource(String source) {
    return 'Content reviewed · $source';
  }

  @override
  String get milestoneDraft => 'Draft educational copy — awaiting review by a qualified health professional.';

  @override
  String get targetTitle => 'Your target';

  @override
  String get targetIntro =>
      'Choose how long you’d like to track. No option here is a recommendation, and you can end any session whenever you choose.';

  @override
  String get targetCustom => 'CUSTOM';

  @override
  String get targetDecrease => 'Decrease by 30 minutes';

  @override
  String get targetIncrease => 'Increase by 30 minutes';

  @override
  String get saveTarget => 'Save target';

  @override
  String get historyEmptyTitle => 'No sessions yet';

  @override
  String get historyEmptyBody => 'When you end a session, it’s saved here. You can edit or delete it at any time.';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusTargetReached => 'Target reached';

  @override
  String get statusEnded => 'Session ended';

  @override
  String sessionTimesOngoing(String start) {
    return '$start → now';
  }

  @override
  String sessionTimes(String start, String end) {
    return '$start → $end';
  }

  @override
  String sessionTileDetail(String times, String target) {
    return '$times · $target target';
  }

  @override
  String sessionTileSemantics(String day, String times, String duration, String target, String status) {
    return '$day, $times, $duration of $target target, $status. Opens options.';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get sessionTitle => 'Session';

  @override
  String get sessionStarted => 'STARTED';

  @override
  String get sessionEnded => 'ENDED';

  @override
  String timeFieldSemantics(String label, String value) {
    return '$label $value. Change';
  }

  @override
  String get deleteSessionTitle => 'Delete this session?';

  @override
  String get deleteSessionBody => 'It will be removed from your history on this phone. This can’t be undone.';

  @override
  String get settingsTarget => 'Target';

  @override
  String get settings24h => '24-hour clock';

  @override
  String get settingsTargetReached => 'Target time reached';

  @override
  String get settingsTargetReachedSub => 'A quiet notice when your planned time passes';

  @override
  String get settingsDailyReminder => 'Daily reminder';

  @override
  String settingsEveryDayAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get settingsOff => 'Off';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsNotificationsBlocked => 'Notifications are turned off for this app in your phone’s settings.';

  @override
  String get settingsPrivacy => 'Privacy & data';

  @override
  String get settingsDataStays => 'Your data stays on this phone';

  @override
  String get settingsDataStaysSub =>
      'Nothing is uploaded or shared. There are no accounts or ads. Recipe search sends only ingredient names and search words to TheMealDB; barcode scans send only the barcode number to Open Food Facts; meal photos are sent to Google Gemini.';

  @override
  String get settingsBackup => 'Back up my data';

  @override
  String get settingsBackupSub => 'Save a backup file to Google Drive, email or Files. Your Gemini key isn’t included.';

  @override
  String get settingsRestore => 'Restore from a backup';

  @override
  String get settingsRestoreSub => 'On a new phone, pick the backup file to bring everything back';

  @override
  String get restoreTitle => 'Restore from a backup?';

  @override
  String get restoreBody => 'Everything on this phone is replaced by what’s in the backup file.';

  @override
  String get restorePick => 'Choose file';

  @override
  String get restoreDone => 'Your data is back';

  @override
  String get restoreNotBackup =>
      'That file isn’t a MagnaVita backup, or it’s from a newer version. Nothing was changed.';

  @override
  String get backupFailed => 'Couldn’t make the backup. Nothing was changed.';

  @override
  String get settingsDeleteAll => 'Delete all data';

  @override
  String get settingsDeleteAllSub => 'Sessions, settings and reminders';

  @override
  String get settingsNotMedical => 'Not a medical device';

  @override
  String get settingsNotMedicalSub =>
      'This app records time only. Milestones are general estimates and can’t tell what is happening in your body. Speak with a qualified healthcare professional before changing how you eat.';

  @override
  String get deleteAllTitle => 'Delete all data?';

  @override
  String get deleteAllBody =>
      'This removes every session, your settings and any reminders from this phone. It can’t be undone.';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get onboardingTitle => 'Welcome to MagnaVita, your calm place for fasting, food and wellness';

  @override
  String get onboardingNotMedical =>
      'This app records time. It is a tracking and educational tool, not a medical device, and it cannot tell what is happening in your body.';

  @override
  String get onboardingEstimates =>
      'Milestones on the timer are general estimates that vary between people. They are never goals.';

  @override
  String get onboardingPrivacy =>
      'Your sessions stay on this phone. Nothing is uploaded, and you can delete everything at any time.';

  @override
  String get onboardingSafety =>
      'Speak with a qualified healthcare professional before changing how you eat — especially if you have a medical condition, take medication, are pregnant, or have a history of disordered eating.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get ageTitle => 'Are you 18 or older?';

  @override
  String get ageBody =>
      'Fasting tools in this app are designed for adults only. If you’re under 18, we’ll show general information instead.';

  @override
  String get ageAdult => 'I’m 18 or older';

  @override
  String get ageUnder18 => 'I’m under 18';

  @override
  String get underageTitle => 'This app is designed for adults';

  @override
  String get underageMeals =>
      'Growing bodies need regular, balanced meals. Fasting isn’t recommended for people under 18 unless a doctor advises it.';

  @override
  String get underageTalk =>
      'If you have questions about eating, food or your body, talk with a parent or guardian and a qualified healthcare professional such as your doctor or a dietitian.';

  @override
  String get underageSupport =>
      'If you’re worried about how you feel about food, you deserve support — a trusted adult or your doctor can help you find it.';

  @override
  String get underageReset => 'I answered by mistake — start again';

  @override
  String get notifTargetTitle => 'Target time reached';

  @override
  String get notifTargetBody => 'Your planned time has passed. End your session whenever you’re ready.';

  @override
  String get splashLoading => 'MagnaVita, loading';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get heroEyebrow => 'FASTING';

  @override
  String get heroReady => 'Ready when you are';

  @override
  String heroFastingFor(String duration) {
    return 'Fasting for $duration';
  }

  @override
  String heroEndsAt(String target, String time) {
    return '$target target · ends $time';
  }

  @override
  String heroIfStartedNow(String target, String time) {
    return '$target target · ends $time if you start now';
  }

  @override
  String get openTimer => 'Open timer';

  @override
  String get milestoneEstimateNote => 'Milestones on the timer are estimates and vary between people.';

  @override
  String get notifWaterBody => 'A gentle reminder to have some water, if you\'d like.';

  @override
  String get waterTitle => 'Water';

  @override
  String get waterToday => 'WATER TODAY';

  @override
  String waterAdd(String amount) {
    return 'Add $amount';
  }

  @override
  String get waterAddCustom => 'Add amount';

  @override
  String waterEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: 'No entries',
    );
    return '$_temp0';
  }

  @override
  String get waterEmpty => 'No water recorded for this day.';

  @override
  String get waterDayTotal => 'Total for the day';

  @override
  String waterAmountLabel(String unit) {
    return 'AMOUNT ($unit)';
  }

  @override
  String get waterTimeLabel => 'TIME';

  @override
  String waterInvalidAmount(String max) {
    return 'Enter an amount between 1 and $max.';
  }

  @override
  String get waterEditTitle => 'Water entry';

  @override
  String get waterAddTitle => 'Add water';

  @override
  String waterEntrySemantics(String amount, String time) {
    return '$amount at $time. Edit';
  }

  @override
  String get mealExportTitle => 'Export a meal';

  @override
  String get mealExportTooltip => 'Export a meal\'s nutrition';

  @override
  String mealExportEmpty(String meal) {
    return 'Nothing logged for $meal on this day.';
  }

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get today => 'Today';

  @override
  String get settingsUnits => 'Units';

  @override
  String get unitMl => 'ml';

  @override
  String get unitFlOz => 'fl oz';

  @override
  String get settingsWaterReminders => 'Water reminders';

  @override
  String get settingsWaterRemindersSub => 'Every 2 hours, 8 AM to 8 PM';

  @override
  String get awTitle => 'Water';

  @override
  String get awWaterTab => 'Water';

  @override
  String get awActivityTab => 'Activity';

  @override
  String waterOfGoal(String goal) {
    return 'of $goal goal';
  }

  @override
  String get waterCustomAmount => 'Custom amount';

  @override
  String get waterTodaysEntries => 'Today\'s entries';

  @override
  String get waterNoneYet => 'No water logged yet today.';

  @override
  String get waterGoalReached => 'Goal reached — lovely work.';

  @override
  String get waterKeepGoing => 'Nice pace — every glass counts.';

  @override
  String get waterEditGoal => 'Daily water goal';

  @override
  String get waterGoalHint => 'A personal goal you choose. Needs vary from person to person.';

  @override
  String entryOptions(String entry) {
    return 'Options for $entry';
  }

  @override
  String get edit => 'Edit';

  @override
  String get activityRecent => 'Recent activity';

  @override
  String get activityNone => 'No activities logged yet.';

  @override
  String get activityLogTitle => 'Log an activity';

  @override
  String get activityEditTitle => 'Edit activity';

  @override
  String get activityType => 'Type';

  @override
  String get activityWalk => 'Walk';

  @override
  String get activityRun => 'Run';

  @override
  String get activityCycle => 'Cycle';

  @override
  String get activityStrength => 'Strength';

  @override
  String get activityYoga => 'Yoga';

  @override
  String get activitySwim => 'Swim';

  @override
  String get swimPool => 'Pool length';

  @override
  String get swimPoolCustom => 'Custom';

  @override
  String get swimPoolCustomField => 'Pool length in metres';

  @override
  String get swimLaps => 'Laps completed';

  @override
  String swimLapsSummary(int laps, String metres) {
    return '$laps laps · $metres m';
  }

  @override
  String get swimTime => 'Swim time';

  @override
  String get swimByMinutes => 'Total minutes';

  @override
  String get swimByPace => 'Pace per lap';

  @override
  String get swimPaceField => 'Average seconds per lap';

  @override
  String swimDurationFromPace(int minutes) {
    return '≈ $minutes min in the water';
  }

  @override
  String get swimNeedPace => 'Enter your laps and pace per lap to work out the time.';

  @override
  String get intensityLeisurely => 'Leisurely';

  @override
  String get intensityVigorous => 'Vigorous';

  @override
  String activityKcalPersonal(int kcal) {
    return '≈ $kcal kcal burned (est.) · from your weight, height, age and sex';
  }

  @override
  String get activityOther => 'Other';

  @override
  String get activityDuration => 'Duration';

  @override
  String activityMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get activityIntensity => 'Intensity (optional)';

  @override
  String get intensityLight => 'Light';

  @override
  String get intensityModerate => 'Moderate';

  @override
  String get intensityHeavy => 'Heavy';

  @override
  String get activityNotes => 'Notes (optional)';

  @override
  String get activityWhen => 'Date & time';

  @override
  String get activityLogButton => 'Log activity';

  @override
  String activityLogged(String type, int minutes) {
    return '$type logged — $minutes min';
  }

  @override
  String get activityFutureError => 'The start time can\'t be in the future.';

  @override
  String get decreaseMinute => '1 minute less';

  @override
  String get increaseMinute => '1 minute more';

  @override
  String get activityToday => 'ACTIVITY TODAY';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsRemindersOptional => 'Reminders (all optional)';

  @override
  String get settingsAboutSafety => 'About & safety';

  @override
  String get settingsDiet => 'Dietary preferences';

  @override
  String get settingsAllergies => 'Allergies';

  @override
  String get settingsHowItWorks => 'How MagnaVita works + safety notes';

  @override
  String get settingsHowItWorksBody =>
      'MagnaVita helps you record fasting times, water, activity, meals and your kitchen, all on this phone. Fasting milestones and nutrition values are estimates, not measurements. MagnaVita does not diagnose anything. Speak with a qualified healthcare professional before changing how you eat.';

  @override
  String get settingsFooter => 'Made with care. Not medical advice.';

  @override
  String settingsCurrentState(String state) {
    return 'Current state: $state';
  }

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get done => 'Done';

  @override
  String get unitsMetric => 'Metric';

  @override
  String get unitsImperial => 'Imperial';

  @override
  String get dietNone => 'No preference';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get dietVegan => 'Vegan';

  @override
  String get dietPescatarian => 'Pescatarian';

  @override
  String get dietHalal => 'Halal';

  @override
  String get allergiesNone => 'None';

  @override
  String get allergiesHint =>
      'Recipes with these ingredients will never be suggested. Always check labels — a database can\'t guarantee a food is allergen-free.';

  @override
  String get allergenEggs => 'Eggs';

  @override
  String get allergenDairy => 'Dairy';

  @override
  String get allergenPeanuts => 'Peanuts';

  @override
  String get allergenTreeNuts => 'Tree nuts';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenSoy => 'Soy';

  @override
  String get allergenFish => 'Fish';

  @override
  String get allergenShellfish => 'Shellfish';

  @override
  String get allergenSesame => 'Sesame';

  @override
  String get profileAddName => 'Add your name';

  @override
  String get profileEditHint => 'Edit profile';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileOptional => 'Optional. Your name is only used to greet you and stays on this phone.';

  @override
  String get profileNameLabel => 'Name';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get historyAll => 'All';

  @override
  String get historyFasting => 'Fasting';

  @override
  String get historyRecentDays => 'Recent days';

  @override
  String get historyNothingRecent => 'Nothing recorded in the last two weeks. That\'s completely fine.';

  @override
  String get historyNothingLogged => 'Nothing logged';

  @override
  String get historyDaySummary => 'Day summary';

  @override
  String get historySkipFine => 'Skipping a day is completely fine.';

  @override
  String get historyQuote => '“Trends are guides, not grades. Skip a day anytime.”';

  @override
  String get historyFastInProgress => 'Fast in progress';

  @override
  String historyFastDone(String duration, String status) {
    return '$duration fast · $status';
  }

  @override
  String historyWater(String amount) {
    return '$amount water';
  }

  @override
  String historyActivity(String duration) {
    return '$duration activity';
  }

  @override
  String historyWaterEntries(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count entries', one: '1 entry');
    return '$amount of water · $_temp0';
  }

  @override
  String get weekdayInitialsSundayFirst => 'S,M,T,W,T,F,S';

  @override
  String get trendEyebrow => 'Fasting · last 14 days';

  @override
  String get trendAverageFast => 'average fast';

  @override
  String get trendLongest => 'Longest';

  @override
  String get trendTotal => 'Total';

  @override
  String trendFastCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count fasts', one: '1 fast');
    return '$_temp0';
  }

  @override
  String get trendEmpty => 'No completed fasts in the last 14 days.';

  @override
  String trendSemantics(String average, String longest, int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count fasts', one: '1 fast');
    return 'Fasting, last 14 days ($range): average fast $average, longest $longest, $_temp0.';
  }

  @override
  String get kitchenTitle => 'My Kitchen';

  @override
  String get kitchenEyebrow => 'Nutrition';

  @override
  String get kitchenSearch => 'Search your kitchen…';

  @override
  String get kitchenAll => 'All';

  @override
  String get catProtein => 'Protein';

  @override
  String get catCarbs => 'Carbs';

  @override
  String get catVegetables => 'Vegetables';

  @override
  String get catFruits => 'Fruits';

  @override
  String get catFatsNutsSeeds => 'Fats, nuts & seeds';

  @override
  String get catDairy => 'Dairy & alternatives';

  @override
  String get catHerbsSpices => 'Herbs & spices';

  @override
  String get catPantry => 'Pantry essentials';

  @override
  String get stateFresh => 'Fresh';

  @override
  String get stateFrozen => 'Frozen';

  @override
  String get stateCanned => 'Canned';

  @override
  String get stateDried => 'Dried';

  @override
  String get kitchenOverview => 'Kitchen overview';

  @override
  String kitchenItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items', one: '1 item');
    return '$_temp0';
  }

  @override
  String get kitchenWellStocked => 'Your pantry is well stocked.';

  @override
  String get kitchenShoppingTrip => 'Time for a shopping trip.';

  @override
  String get kitchenEmptyOverview => 'Add what you have at home to get started.';

  @override
  String get kitchenExpiringSoon => 'Expiring soon';

  @override
  String get kitchenLowStock => 'Low stock';

  @override
  String kitchenInYourKitchen(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items', one: '1 item');
    return 'In your kitchen · $_temp0';
  }

  @override
  String get kitchenNothingHere => 'Nothing here yet.';

  @override
  String get kitchenNoMatches => 'No ingredients match your search.';

  @override
  String get kitchenAddIngredient => 'Add Ingredient';

  @override
  String get kitchenExpiresToday => 'Expires today';

  @override
  String kitchenExpiresIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expires in $days days',
      one: 'Expires in 1 day',
    );
    return '$_temp0';
  }

  @override
  String kitchenExpired(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expired $days days ago',
      one: 'Expired 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get ingredientAddTitle => 'Add Ingredient';

  @override
  String get ingredientEditTitle => 'Edit Ingredient';

  @override
  String get ingredientStatusEyebrow => 'Status';

  @override
  String get ingredientNewEntry => 'New Stock Entry';

  @override
  String get ingredientNewEntrySub => 'Adding to your main inventory';

  @override
  String get ingredientUpdate => 'Update Stock';

  @override
  String get ingredientUpdateSub => 'Editing an item in your inventory';

  @override
  String get ingredientName => 'Name';

  @override
  String get ingredientNameHint => 'e.g. Baby spinach';

  @override
  String get ingredientCategory => 'Category (one or more)';

  @override
  String get ingredientQuantity => 'Quantity & unit';

  @override
  String get ingredientState => 'State';

  @override
  String get ingredientDates => 'Dates (optional)';

  @override
  String get ingredientPurchased => 'Purchased';

  @override
  String get ingredientExpires => 'Expires';

  @override
  String get ingredientNotSet => 'Not set';

  @override
  String ingredientClearDate(String label) {
    return 'Clear $label date';
  }

  @override
  String get ingredientLowStockAt => 'Low-stock alert at (optional)';

  @override
  String get ingredientLowStockHint => 'e.g. 2';

  @override
  String get ingredientBrand => 'Brand (optional)';

  @override
  String get ingredientBrandHint => 'e.g. Woolworths';

  @override
  String get ingredientNotes => 'Notes (optional)';

  @override
  String get ingredientNotesHint => 'Anything to remember';

  @override
  String get ingredientSave => 'Save ingredient';

  @override
  String ingredientSaved(String name) {
    return '$name saved to My Kitchen';
  }

  @override
  String get ingredientMarkFinished => 'Mark as finished';

  @override
  String ingredientFinished(String name) {
    return '$name marked as finished';
  }

  @override
  String get ingredientRemove => 'Remove from kitchen';

  @override
  String ingredientRemoveConfirm(String name) {
    return 'Remove $name?';
  }

  @override
  String get ingredientRemoveBody =>
      'This deletes the item and its history. To keep a record, mark it as finished instead.';

  @override
  String ingredientRemoved(String name) {
    return '$name removed';
  }

  @override
  String get errNameRequired => 'Please enter a name.';

  @override
  String get errQuantityInvalid => 'Enter a quantity of 0 or more.';

  @override
  String get errLowStockInvalid => 'Enter a low-stock amount of 0 or more, or leave it empty.';

  @override
  String get errExpiryBeforePurchase => 'The expiry date can\'t be before the purchase date.';

  @override
  String kitchenItemSemantics(String name, String quantity, String state) {
    return '$name, $quantity, $state';
  }

  @override
  String get notifReviewBody =>
      'It\'s a new month — a quick kitchen review keeps your inventory and recipe ideas accurate. Optional, as always.';

  @override
  String get reviewEyebrow => 'Monthly kitchen review';

  @override
  String get reviewTitle => 'Review your kitchen';

  @override
  String reviewProgress(int current, int total, String name) {
    return 'Item $current of $total · $name';
  }

  @override
  String get reviewCardText => 'A few minutes now saves food and money all month.';

  @override
  String get reviewQuestion => 'Is this still in your kitchen?';

  @override
  String get reviewKeep => 'Still have it — update quantity';

  @override
  String get reviewUsedUp => 'We ate it / used it up';

  @override
  String get reviewSpoiled => 'Spoiled — remove it';

  @override
  String get reviewNoWrongAnswers =>
      'No wrong answers — this just keeps your inventory honest. Spoiled food happens to everyone.';

  @override
  String get reviewAddToList => 'Add to shopping list';

  @override
  String get reviewAddPurchases => 'Add new purchases this month';

  @override
  String get reviewAddPurchase => 'Add a purchase';

  @override
  String reviewAdded(String names) {
    return 'Added: $names';
  }

  @override
  String get reviewContinue => 'Continue review';

  @override
  String get reviewFinish => 'Finish review';

  @override
  String reviewPreviewList(int count) {
    return 'Preview shopping list ($count)';
  }

  @override
  String get reviewEmpty => 'Your kitchen is empty — add what you have and review it next month.';

  @override
  String get reviewDoneTitle => 'Review complete';

  @override
  String get reviewDoneBody => 'Your inventory is up to date. Thanks for keeping it honest.';

  @override
  String reviewUpdateQuantity(String name) {
    return 'Update $name';
  }

  @override
  String reviewPurchased(String date) {
    return 'Purchased $date';
  }

  @override
  String get kitchenStartReview => 'Start monthly review';

  @override
  String get shoppingTitle => 'Shopping list';

  @override
  String shoppingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items to buy',
      one: '1 item to buy',
      zero: 'Nothing to buy',
    );
    return '$_temp0';
  }

  @override
  String get shoppingAddHint => 'Add an item…';

  @override
  String get shoppingAdd => 'Add';

  @override
  String get shoppingClearChecked => 'Clear ticked items';

  @override
  String shoppingRemove(String name) {
    return 'Remove $name';
  }

  @override
  String get shoppingEmpty => 'Your shopping list is empty.';

  @override
  String get settingsMonthlyReview => 'Monthly kitchen review';

  @override
  String get settingsMonthlyReviewSub => '1st of each month at 10:00';

  @override
  String get settingsReviewNow => 'Review my kitchen now';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnacks => 'Snacks';

  @override
  String get nutrientEnergy => 'Energy';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get nutrientCarbs => 'Carbs';

  @override
  String get nutrientFat => 'Fat';

  @override
  String get nutrientFibre => 'Fibre';

  @override
  String get nutrientCalcium => 'Calcium';

  @override
  String get nutrientIron => 'Iron';

  @override
  String get nutrientPotassium => 'Potassium';

  @override
  String get nutrientSodium => 'Sodium';

  @override
  String get nutrientVitaminC => 'Vitamin C';

  @override
  String get nutrientEstimated => 'Estimated';

  @override
  String get nutrientPartial => 'Partial';

  @override
  String get nutrientUnavailable => 'Unavailable';

  @override
  String get diaryTitle => 'Food Diary';

  @override
  String get diaryPrevDay => 'Previous day';

  @override
  String get diaryNextDay => 'Next day';

  @override
  String get diarySummaryToday => 'Today’s summary';

  @override
  String get diarySummaryDay => 'Day summary';

  @override
  String get diaryInfoTitle => 'About these numbers';

  @override
  String get diaryInfoBody =>
      'Nutrition values are estimates from USDA FoodData Central and the foods you create. “Partial” means some foods you logged have no data for that nutrient; “Unavailable” means none do. MagnaVita doesn’t set targets or judge what you eat.';

  @override
  String get diaryMicros => 'Vitamins & minerals';

  @override
  String get diaryMealEmpty => 'Nothing logged yet — that’s perfectly fine.';

  @override
  String diaryKcal(String kcal) {
    return '$kcal kcal';
  }

  @override
  String get diaryEst => '(est.)';

  @override
  String diaryEntryLabel(String name, String time, String amount) {
    return '$name, $time, $amount';
  }

  @override
  String get diaryChangeAmount => 'Change amount';

  @override
  String get diaryRemove => 'Remove';

  @override
  String diaryRemoved(String name) {
    return '$name removed';
  }

  @override
  String get diaryAddFood => 'Add food';

  @override
  String get addFoodTitle => 'Add Food';

  @override
  String addFoodTo(String meal, String date) {
    return 'to $meal · $date';
  }

  @override
  String get addFoodDatabase => 'Food database';

  @override
  String get addFoodSearch => 'Search foods…';

  @override
  String get addFoodSource => 'USDA FoodData Central & Open Food Facts · values are estimates';

  @override
  String get addFoodLoading => 'Loading foods…';

  @override
  String get addFoodRecent => 'Recent';

  @override
  String get addFoodSaved => 'Saved';

  @override
  String get addFoodResults => 'Results';

  @override
  String addFoodNoMatch(String query) {
    return 'No foods match “$query”. You can create your own.';
  }

  @override
  String addFoodPer100(String kcal, String protein) {
    return '100 g · $kcal kcal · $protein g protein (est.)';
  }

  @override
  String get addFoodNoData => 'Nutrition unavailable';

  @override
  String get addFoodYours => 'Your food';

  @override
  String get addFoodSelected => 'Selected item';

  @override
  String get addFoodClear => 'Clear selection';

  @override
  String get addFoodLess => 'Less';

  @override
  String get addFoodMore => 'More';

  @override
  String addFoodAbout(String kcal) {
    return '≈ $kcal kcal (est.)';
  }

  @override
  String get addFoodMeal => 'Meal';

  @override
  String get addFoodTime => 'Time';

  @override
  String addFoodAddTo(String meal) {
    return 'Add to $meal';
  }

  @override
  String addFoodAdded(String name, String meal) {
    return '$name added to $meal';
  }

  @override
  String get addFoodSave => 'Save to favourites';

  @override
  String get addFoodUnsave => 'Remove from favourites';

  @override
  String get addFoodCreate => 'Create custom food';

  @override
  String get customTitle => 'Your own food';

  @override
  String get customName => 'Name';

  @override
  String get customServing => 'Serving size';

  @override
  String get customPerServing => 'Nutrition per serving · optional';

  @override
  String get customHint => 'Leave blank anything you don’t know — it will show as unavailable, never as zero.';

  @override
  String get customSave => 'Save and select';

  @override
  String get customNameRequired => 'Enter a name.';

  @override
  String get customServingRequired => 'Enter a serving size in grams.';

  @override
  String get customServingLabel => '1 serving';

  @override
  String get settingsFoodData => 'Food data';

  @override
  String get settingsFoodDataSub =>
      'Foods: USDA FoodData Central, SR Legacy (public domain). Scanned packaged foods: Open Food Facts (Open Database Licence). Values are estimates.';

  @override
  String get diaryRecipes => 'Recipes';

  @override
  String get diaryRecipesSub => 'What you can make';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get recipesEyebrow => 'Smart recipe planner';

  @override
  String get recipesHero => 'What you can make';

  @override
  String recipesHeroSub(String items, String found) {
    return '$items in your kitchen · $found';
  }

  @override
  String recipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes found',
      one: '1 recipe found',
      zero: 'no matches yet',
    );
    return '$_temp0';
  }

  @override
  String get recipesTagline => 'Built from what you already have — less waste, less stress.';

  @override
  String get recipesSearch => 'Search recipes by name…';

  @override
  String get recipesShow => 'Show';

  @override
  String get recipesShowAll => 'All';

  @override
  String get recipesShowReady => 'Ready to cook';

  @override
  String get recipesShowExpiring => 'Uses expiring items';

  @override
  String get recipesShowSaved => 'Favourites';

  @override
  String get recipesDiet => 'Diet';

  @override
  String get recipesDietAny => 'Any';

  @override
  String get recipesAllergyGeneric =>
      'Ingredient lists can’t guarantee a recipe is free from allergens or cross-contamination — always check labels.';

  @override
  String get recipesPrivacy => 'Recipes come from TheMealDB online. Only ingredient names and search words are sent.';

  @override
  String get recipesEmptyKitchen =>
      'Add ingredients to My Kitchen and MagnaVita will suggest what you can make. You can still search by name.';

  @override
  String get recipesNone => 'No recipes match these filters.';

  @override
  String get recipesOffline => 'Couldn’t reach the recipe catalogue. Check your connection and try again.';

  @override
  String get recipesRetry => 'Try again';

  @override
  String recipesAvailable(int have, int total) {
    return '$have of $total ingredients available';
  }

  @override
  String recipesUsesExpiring(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uses $count items expiring soon',
      one: 'Uses 1 item expiring soon',
    );
    return '$_temp0';
  }

  @override
  String get recipesSave => 'Save to favourites';

  @override
  String get recipesUnsave => 'Remove from favourites';

  @override
  String get recipeIngredients => 'Ingredients';

  @override
  String recipeTotal(int count) {
    return '$count total';
  }

  @override
  String get recipeAvailable => 'Available';

  @override
  String get recipeMissing => 'Missing';

  @override
  String recipeSubstitute(String missing, String have) {
    return 'Substitute: $missing → $have (you have it)';
  }

  @override
  String get recipeBatch => 'Batch size';

  @override
  String get recipeBatchHint =>
      'Amounts are scaled from the original recipe. The catalogue doesn’t list servings or cooking times.';

  @override
  String get recipeSteps => 'Steps';

  @override
  String get recipeNutrition => 'Estimated nutrition';

  @override
  String get recipeNutritionNone =>
      'Nutrition isn’t available for this recipe, so diary entries show it as unavailable.';

  @override
  String get recipeMarkCooked => 'Mark as cooked';

  @override
  String get recipeCooked => 'Marked as cooked. Update quantities in My Kitchen if you used things up.';

  @override
  String get recipeLog => 'Log to Food Diary';

  @override
  String get recipeLogWhich => 'Which meal?';

  @override
  String recipeLogged(String meal) {
    return 'Logged to $meal';
  }

  @override
  String recipeAlreadyLogged(String meal) {
    return 'Already in today’s $meal';
  }

  @override
  String get recipeServing => '1 serving';

  @override
  String get recipeAddMissing => 'Add missing to shopping list';

  @override
  String recipeAddedMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items added to your shopping list',
      one: '1 item added to your shopping list',
      zero: 'Already on your shopping list',
    );
    return '$_temp0';
  }

  @override
  String get recipeSource => 'Recipe from TheMealDB';

  @override
  String get recipeNotFound => 'This recipe couldn’t be loaded. Check your connection and try again.';

  @override
  String get scanTitle => 'Scan a barcode';

  @override
  String get scanHint => 'Point the camera at the barcode on the pack. Product data comes from Open Food Facts.';

  @override
  String get scanType => 'Type the barcode instead';

  @override
  String get scanNumber => 'Barcode number';

  @override
  String get scanLookUp => 'Look up';

  @override
  String get scanInvalid => 'Enter the 8–14 digits under the barcode.';

  @override
  String get scanTorch => 'Torch';

  @override
  String get scanLooking => 'Looking up the product…';

  @override
  String get scanCameraError => 'The camera isn’t available. You can type the barcode instead.';

  @override
  String scanNotFound(String code) {
    return '$code isn’t in Open Food Facts yet — add it from the label.';
  }

  @override
  String get scanOffline => 'Couldn’t look up the barcode. Check your connection and try again.';

  @override
  String scanAddFromLabel(String code) {
    return 'Barcode $code. Copy the values from the nutrition label; next time the scan will find it.';
  }

  @override
  String get foodPack => 'Whole pack';

  @override
  String get foodPackaged => 'Packaged food';

  @override
  String addFoodPer100ml(String kcal, String protein) {
    return '100 ml · $kcal kcal · $protein g protein (est.)';
  }

  @override
  String get customGrams => 'Grams';

  @override
  String get customMl => 'Millilitres';

  @override
  String get logHow => 'How do you want to log it?';

  @override
  String get logSearch => 'Search foods';

  @override
  String get logSearchSub => 'Food database, recent and favourites';

  @override
  String get logScanSub => 'Packaged foods and drinks';

  @override
  String get logPhotoSub => 'AI estimate from a photo — you check it first';

  @override
  String get photoTitle => 'Snap a meal photo';

  @override
  String get photoYourPhoto => 'Your meal photo';

  @override
  String get photoEstimating => 'Estimating what’s on the plate…';

  @override
  String get photoCheck =>
      'AI estimate — check every item before adding. Rename anything it got wrong and adjust the amounts. Photo estimates are often 20–40% off, especially for oil, sauces and hidden ingredients.';

  @override
  String photoItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items found', one: '1 item found');
    return '$_temp0';
  }

  @override
  String photoRename(String name) {
    return 'Rename $name';
  }

  @override
  String photoRemove(String name) {
    return 'Remove $name';
  }

  @override
  String photoAdd(int count, String meal) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count items to $meal',
      one: 'Add 1 item to $meal',
    );
    return '$_temp0';
  }

  @override
  String photoLogged(int count, String meal) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items added to $meal',
      one: '1 item added to $meal',
    );
    return '$_temp0';
  }

  @override
  String get photoLabel => 'photo estimate';

  @override
  String get photoTake => 'Take photo';

  @override
  String get photoRetake => 'Retake';

  @override
  String get photoGallery => 'Choose from gallery';

  @override
  String get photoNotFood => 'No food was recognised in that photo. Try again with the whole plate in view.';

  @override
  String get photoNoKey => 'Meal photos need a Gemini API key. Add one in Settings → Meal photo estimates.';

  @override
  String get photoKeyError => 'Gemini didn’t accept the API key. Check it in Settings → Meal photo estimates.';

  @override
  String get photoOffline => 'Couldn’t reach Gemini. Check your connection and try again.';

  @override
  String get photoCameraError => 'The camera isn’t available. Try choosing a photo from the gallery.';

  @override
  String get settingsPhotoKey => 'Meal photo estimates';

  @override
  String get settingsPhotoKeyNone => 'No key';

  @override
  String get settingsPhotoKeyOwn => 'Your key';

  @override
  String get settingsPhotoKeyBuiltIn => 'Built-in key';

  @override
  String get settingsPhotoKeyBody =>
      'Meal photos are estimated by Google Gemini using an API key. Paste your own key to use it instead of the built-in one; it’s stored only on this phone.';

  @override
  String get settingsPhotoKeyField => 'Gemini API key';

  @override
  String get settingsPhotoKeyClear => 'Remove my key';

  @override
  String get bodyStats => 'Your stats';

  @override
  String get bodyHeight => 'Height';

  @override
  String get bodyAge => 'Age';

  @override
  String get bodySex => 'Sex';

  @override
  String get bodyWeight => 'Weight';

  @override
  String get bodyNotSet => 'Not set';

  @override
  String get bodyUpdate => 'Update stats';

  @override
  String get bodyFemale => 'Female';

  @override
  String get bodyMale => 'Male';

  @override
  String get bodySexNone => 'Prefer not to say';

  @override
  String get bodySexHint => 'Only used in the body-fat formulas.';

  @override
  String bodyAgeYears(int age) {
    return '$age years';
  }

  @override
  String get bodyOptional => 'Everything here is optional and stays on this phone.';

  @override
  String get bodyTape => 'Tape measurements · optional';

  @override
  String get bodyTapeHint =>
      'Waist at the navel, neck just below the Adam’s apple, hips at the widest point. They give a better body-fat estimate than BMI alone.';

  @override
  String get bodyWaist => 'Waist';

  @override
  String get bodyNeck => 'Neck';

  @override
  String get bodyHip => 'Hips';

  @override
  String get bodyFeet => 'Height (ft)';

  @override
  String get bodyInches => '(in)';

  @override
  String get bodyInvalid => 'Please check the numbers — they look out of range.';

  @override
  String get bodyNumbers => 'Your numbers';

  @override
  String get bodyBmi => 'BMI';

  @override
  String get bmiUnder => 'Below the healthy range';

  @override
  String get bmiHealthy => 'Within the healthy range';

  @override
  String get bmiOver => 'Above the healthy range';

  @override
  String get bmiObese => 'Well above the healthy range';

  @override
  String bodyRange(String low, String high) {
    return 'Healthy range for your height: $low – $high';
  }

  @override
  String bodyLose(String amount) {
    return 'To reach it: lose about $amount';
  }

  @override
  String bodyGain(String amount) {
    return 'To reach it: gain about $amount';
  }

  @override
  String get bodyInRange => 'You’re within it.';

  @override
  String get bodyFat => 'Body fat (estimate)';

  @override
  String get bodyFatTape => 'From your tape measurements (US Navy method) · about ±3%';

  @override
  String get bodyFatBmi => 'Rough, from BMI · add tape measurements for a better estimate';

  @override
  String get bodyFatNeeds => 'Add your age and sex for an estimate.';

  @override
  String get bodyUnder18 =>
      'Adult BMI categories and weight targets don’t apply under 18 — growth charts do. A doctor or nurse can help you make sense of these numbers.';

  @override
  String get bodyNeedStats => 'Add your height and weight to see your BMI and healthy weight range.';

  @override
  String get bodyAboutBmi => 'About BMI';

  @override
  String get bodyAboutBmiBody =>
      'BMI compares weight with height. It’s a quick screening number, not a diagnosis: it can’t tell muscle from fat, and it reads differently for athletes, older adults, pregnancy and some ethnic groups. Body-fat estimates can be several percent off. Treat these numbers as one signal among many — MagnaVita never sets calorie targets from BMI alone, and a healthcare professional can help you interpret them.';

  @override
  String get energyBmr => 'Resting energy (BMR)';

  @override
  String energyKcalDay(String kcal) {
    return '$kcal kcal a day';
  }

  @override
  String get energyBmrSub =>
      'What your body uses at rest — breathing, heartbeat, staying warm. Estimated from your weight, height, age and sex (Mifflin-St Jeor, about ±10%).';

  @override
  String get energyNeeds => 'Add your height, weight, age and sex to see your resting energy.';

  @override
  String get energyMaintain => 'Calories to keep your weight steady';

  @override
  String get energyLevel => 'How active you are';

  @override
  String energyMeasured(int days, String kcal) {
    return 'Worked out from $days days of your activities and steps · about $kcal active kcal a day';
  }

  @override
  String energyChosen(int days) {
    return 'The level you chose. After $days days of activities or steps, MagnaVita works it out from your records.';
  }

  @override
  String get energyPickLevel => 'How active are you on a usual day?';

  @override
  String get levelSedentary => 'Mostly sitting';

  @override
  String get levelLight => 'Lightly active';

  @override
  String get levelModerate => 'Moderately active';

  @override
  String get levelActive => 'Active';

  @override
  String get levelVeryActive => 'Very active';

  @override
  String get levelSedentarySub => 'Desk work, little walking';

  @override
  String get levelLightSub => 'Some walking, light exercise 1–3 days a week';

  @override
  String get levelModerateSub => 'On your feet a lot, or exercise 3–5 days a week';

  @override
  String get levelActiveSub => 'Hard exercise 6–7 days a week';

  @override
  String get levelVeryActiveSub => 'Physical job plus daily training';

  @override
  String get goalTitle => 'Your weight goal';

  @override
  String get goalSet => 'Set a goal weight';

  @override
  String get goalEdit => 'Change goal';

  @override
  String get goalRemove => 'Remove goal';

  @override
  String goalWeight(String unit) {
    return 'Goal weight ($unit)';
  }

  @override
  String get goalPace => 'How fast';

  @override
  String goalPacePerWeek(String amount) {
    return '$amount a week';
  }

  @override
  String goalTooLow(String min) {
    return 'That’s below the healthy range for your height. The lowest goal MagnaVita sets is $min.';
  }

  @override
  String goalSummary(String goal, String pace) {
    return '$goal at $pace a week';
  }

  @override
  String goalEatLose(String kcal, String amount) {
    return 'Eat about $kcal kcal a day to lose about $amount a week';
  }

  @override
  String goalEatGain(String kcal, String amount) {
    return 'Eat about $kcal kcal a day to gain about $amount a week';
  }

  @override
  String goalEatMaintain(String kcal) {
    return 'You’re at your goal. About $kcal kcal a day keeps you there.';
  }

  @override
  String goalLimited(String kcal) {
    return 'Kept at your safe minimum of $kcal kcal a day — never below your resting energy, or 1,200 (women) / 1,500 (men). Moving more is a safer way to go faster.';
  }

  @override
  String goalGainCapped(String amount) {
    return 'Gaining is limited to $amount a week so it’s mostly muscle, not fat.';
  }

  @override
  String get goalNeedsEnergy => 'Choose how active you are above to get a calorie target.';

  @override
  String get goalEstimate =>
      'An estimate. Bodies adapt, so check your weigh-ins every few weeks and adjust. If you’re pregnant, breastfeeding, have a medical condition or a history of disordered eating, talk to a healthcare professional first.';

  @override
  String get forecastTitle => 'Weight forecast';

  @override
  String forecastIn(int weeks, String weight) {
    return 'In $weeks weeks: about $weight';
  }

  @override
  String forecastReach(String goal, String date) {
    return 'Reaches $goal around $date';
  }

  @override
  String forecastNotReached(String goal) {
    return '$goal isn’t reached in this time at this pace.';
  }

  @override
  String forecastChartLabel(String start, int weeks, String end) {
    return 'Weight forecast: from $start today to about $end in $weeks weeks';
  }

  @override
  String get forecastPast => 'Recorded';

  @override
  String get forecastToday => 'Today';

  @override
  String forecastAhead(int weeks) {
    return '$weeks weeks ahead';
  }

  @override
  String forecastFromDiary(String kcal) {
    return 'Based on what your food diary shows (about $kcal kcal a day over the last 2 weeks) and your activity.';
  }

  @override
  String forecastFromTarget(String kcal) {
    return 'Based on eating your target of $kcal kcal a day with your current activity. Log your meals on most days to forecast from what you actually eat.';
  }

  @override
  String forecastFromMaintenance(String kcal) {
    return 'Based on eating about $kcal kcal a day with your current activity. Set a goal or log your meals for a more useful forecast.';
  }

  @override
  String get forecastEstimate =>
      'A projection, not a promise: water, hormones and how your body adapts all move the scale.';

  @override
  String get authCreateTitle => 'Create your account';

  @override
  String get authSignInTitle => 'Welcome back';

  @override
  String get authWhy =>
      'Your account keeps your profile and goals safe, so signing in on a new phone brings them back. Your diary, kitchen and workouts stay on this phone.';

  @override
  String get authName => 'Name';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authCreate => 'Create account';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authOr => 'or';

  @override
  String get authGoogle => 'Continue with Google';

  @override
  String get authHaveAccount => 'Already have an account? Sign in';

  @override
  String get authNeedAccount => 'New here? Create an account';

  @override
  String get authSkip => 'Continue without an account';

  @override
  String get authSkipSub => 'Everything stays on this phone only. You can sign in later in Profile → Account.';

  @override
  String get authNameNeeded => 'Please enter your name.';

  @override
  String get authEmailInvalid => 'Please enter a valid email address.';

  @override
  String authPasswordShort(int count) {
    return 'Use at least $count characters.';
  }

  @override
  String authConfirmEmail(String email) {
    return 'Almost there: we sent a link to $email. Tap it to confirm, then sign in here.';
  }

  @override
  String get authWrongPassword => 'That email and password don’t match.';

  @override
  String get authEmailTaken => 'There’s already an account with that email — sign in instead.';

  @override
  String get authWeakPassword => 'That password is too easy to guess. Try a longer one.';

  @override
  String get authNotConfirmed => 'Please confirm your email first — check your inbox for the link.';

  @override
  String get authOffline => 'You’re offline. Connect to the internet and try again.';

  @override
  String get authGoogleNotSetUp => 'Google sign-in isn’t available yet. Use your email for now.';

  @override
  String get authCanceled => 'Sign-in was cancelled.';

  @override
  String get authFailed => 'Something went wrong. Please try again.';

  @override
  String get accountSection => 'Account';

  @override
  String get accountSignedIn => 'Signed in · profile and goals saved to your account';

  @override
  String get accountSignInOrCreate => 'Sign in or create an account';

  @override
  String get accountLocalSub => 'Keep your profile and goals safe if you change phones';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignOutTitle => 'Sign out?';

  @override
  String get accountSignOutBody => 'Everything on this phone stays. Sign in again any time.';

  @override
  String get accountDelete => 'Delete my account';

  @override
  String get accountDeleteSub => 'Removes your account and the profile saved in it';

  @override
  String get accountDeleteTitle => 'Delete your account?';

  @override
  String get accountDeleteBody =>
      'Your account and the profile and goals saved in it are deleted for good. What’s on this phone stays; use “Delete all data” to remove that too.';

  @override
  String get goalLoseWeight => 'Lose weight';

  @override
  String get goalLoseWeightSub => 'Steadily, at a pace you choose';

  @override
  String get goalMaintain => 'Stay where I am';

  @override
  String get goalMaintainSub => 'Keep my weight steady and eat well';

  @override
  String get goalBuildMuscle => 'Build muscle';

  @override
  String get goalBuildMuscleSub => 'Get stronger and add muscle';

  @override
  String get goalGetFitter => 'Get fitter';

  @override
  String get goalGetFitterSub => 'More energy, steps and stamina';

  @override
  String get goalFasting => 'Better fasting habits';

  @override
  String get goalFastingSub => 'A calm, regular eating window';

  @override
  String setupStep(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get setupSkip => 'Skip for now';

  @override
  String get setupBack => 'Back';

  @override
  String get setupFinish => 'Finish';

  @override
  String get setupOptional => 'Optional';

  @override
  String get setupAboutTitle => 'About you';

  @override
  String get setupAboutSub => 'So the numbers MagnaVita shows fit you. Leave out anything you’d rather not share.';

  @override
  String get setupSexWhy => 'Used for resting energy and body-fat estimates only.';

  @override
  String get setupBirthYear => 'Year of birth';

  @override
  String get setupYearInvalid => 'Please check the year — MagnaVita’s goals are for people 18 and over.';

  @override
  String get setupWeightTitle => 'Your weight today';

  @override
  String get setupWeightSub => 'Your starting point. It stays private, and you can turn weight tracking off later.';

  @override
  String get setupGoalTitle => 'What’s your main goal?';

  @override
  String get setupGoalSub => 'Your Activity and Home pages are arranged around it. Change it any time in Profile.';

  @override
  String get setupGoalSafety =>
      'MagnaVita never suggests a goal below a healthy weight for your height, or eating less than your body needs at rest.';

  @override
  String get setupActivityTitle => 'How active are you?';

  @override
  String get setupActivitySub => 'On a usual day, before any changes.';

  @override
  String get setupActivityLater =>
      'After a week of logged activities or steps, MagnaVita works this out from your records instead.';

  @override
  String get setupMealsTitle => 'How many meals a day?';

  @override
  String get setupMealsSub => 'Snacks count if they’re proper meals for you.';

  @override
  String setupMealsN(int n) {
    return '$n meals';
  }

  @override
  String get setupMealsFivePlus => '5 or more';

  @override
  String get setupMealsWhy => 'Used to split your daily calories into a guide for each meal.';

  @override
  String get setupTrainingTitle => 'Do you train?';

  @override
  String get setupTrainingSub => 'Workouts like the gym, home exercise or classes.';

  @override
  String get setupTrainingDays => 'Days a week';

  @override
  String get setupNotYet => 'Not yet';

  @override
  String get setupDietTitle => 'Food preferences';

  @override
  String get setupDietSub => 'Recipes with your allergens are never suggested.';

  @override
  String get focusYourGoal => 'Your goal';

  @override
  String get focusLoseTitle => 'Today, toward your goal weight';

  @override
  String get focusMaintainTitle => 'Today, keeping steady';

  @override
  String get focusMuscleTitle => 'Building muscle';

  @override
  String get focusFitterTitle => 'Getting fitter';

  @override
  String get focusEaten => 'Eaten';

  @override
  String get focusBurned => 'Burned';

  @override
  String get focusSteps => 'Steps';

  @override
  String get focusEstimate => 'estimate';

  @override
  String focusOf(String kcal) {
    return 'of $kcal';
  }

  @override
  String focusOfGrams(String grams) {
    return 'of about $grams g';
  }

  @override
  String focusEatenLabel(String eaten, String target) {
    return '$eaten of $target kcal eaten today';
  }

  @override
  String focusLeft(String kcal) {
    return 'About $kcal kcal left today';
  }

  @override
  String focusOver(String kcal) {
    return '$kcal kcal over today — that’s fine, it evens out over the week.';
  }

  @override
  String get focusSetUpCalories => 'Get a daily calorie target in Profile';

  @override
  String get focusWorkouts => 'workouts';

  @override
  String get focusProtein => 'Protein today';

  @override
  String get focusProteinWhy =>
      'About 1.6 g of protein per kg of body weight a day helps muscles grow (a general guide).';

  @override
  String get focusActiveMinutes => 'Active minutes';

  @override
  String focusMinutesOf(int minutes, int target) {
    return '$minutes of $target';
  }

  @override
  String focusMinutesLeft(int minutes) {
    return '$minutes more active minutes reach the 150 a week that health guidelines suggest.';
  }

  @override
  String get focusMinutesDone => 'You’ve reached the 150 active minutes a week that health guidelines suggest.';

  @override
  String homeCaloriesOf(String kcal) {
    return 'of $kcal kcal today · estimated';
  }

  @override
  String diaryMealGuide(String eaten, String guide) {
    return '$eaten of about $guide kcal';
  }

  @override
  String get bodyHistory => 'Weight history';

  @override
  String get bodyAddWeighIn => 'Add weigh-in';

  @override
  String get bodyWeighIn => 'Weigh-in';

  @override
  String get bodyNoWeighIns => 'No weigh-ins yet.';

  @override
  String bodyChange(String amount, String date) {
    return '$amount since $date';
  }

  @override
  String get bodyTrack => 'Track my weight';

  @override
  String get bodyTrackSub => 'Turn off to hide weight, BMI and history. Records are kept until you delete them.';

  @override
  String get bodyTrackOff => 'Weight tracking is off.';

  @override
  String get bodyDeleted => 'Weigh-in deleted';

  @override
  String bodyWeighInLabel(String weight, String date) {
    return '$weight on $date';
  }

  @override
  String homeGreeting(String greeting, String name) {
    return '$greeting, $name!';
  }

  @override
  String get homeSteps => 'Today’s steps';

  @override
  String homeStepGoal(String goal) {
    return 'Goal $goal';
  }

  @override
  String homeKm(String km) {
    return '$km km';
  }

  @override
  String homeOfGoal(int pct) {
    return '$pct% of goal';
  }

  @override
  String get homeStepsAllow => 'Count my steps';

  @override
  String get homeStepsWhy => 'MagnaVita can read your phone’s step sensor. Steps stay on this phone.';

  @override
  String get homeStepsDenied => 'Allow “Physical activity” for MagnaVita in your phone’s settings to count steps.';

  @override
  String get homeStepsOpenSettings => 'Open settings';

  @override
  String get homeStepsUnavailable => 'This phone doesn’t have a step counter.';

  @override
  String get homeToday => 'Today';

  @override
  String get homeCalories => 'Calories eaten';

  @override
  String get homeCaloriesSub => 'From your food diary · estimated';

  @override
  String get homeFasted => 'Hours fasted';

  @override
  String homeFastGoal(String target, int pct) {
    return 'Target $target · $pct%';
  }

  @override
  String get homeNotFasting => 'Not fasting · tap + to start';

  @override
  String get homeWater => 'Water';

  @override
  String homeWaterGoal(String goal) {
    return 'of $goal';
  }

  @override
  String get quickEyebrow => 'Quick add';

  @override
  String get quickTitle => 'What would you like to log?';

  @override
  String get quickWater => 'Drink water';

  @override
  String quickWaterSub(String amount) {
    return 'Add a $amount glass';
  }

  @override
  String quickWaterAdded(String amount, String total) {
    return 'Added $amount · $total today';
  }

  @override
  String get quickStart => 'Start fast';

  @override
  String quickStartSub(String target) {
    return 'Begin your $target fast';
  }

  @override
  String get quickStarted => 'Fast started — the timer is running.';

  @override
  String get quickEnd => 'End fast';

  @override
  String quickEndSub(String elapsed) {
    return '$elapsed so far';
  }

  @override
  String get quickFood => 'Log food';

  @override
  String get quickFoodSub => 'Search, scan a barcode or snap a meal';

  @override
  String get quickActivity => 'Log activity';

  @override
  String get quickActivitySub => 'Walk, run, cycle, strength…';

  @override
  String get quickWeigh => 'Weigh in';

  @override
  String get quickWeighSub => 'Update your weight';

  @override
  String get kitchenAddHow => 'How do you want to add it?';

  @override
  String get kitchenAddType => 'Type it in';

  @override
  String get kitchenAddTypeSub => 'Name, amount, dates and more';

  @override
  String get kitchenAddScanSub => 'Fills in the name, brand and pack size';

  @override
  String get kitchenAddPhotoSub => 'AI lists what’s in the photo — you check it first';

  @override
  String kitchenScanNotFound(String code) {
    return '$code isn’t in Open Food Facts yet — add it yourself.';
  }

  @override
  String get groceryTitle => 'Snap your groceries';

  @override
  String get groceryPhoto => 'Your groceries photo';

  @override
  String get groceryLooking => 'Looking for food items…';

  @override
  String get groceryCheck =>
      'AI suggestions — untick anything that’s wrong and tap the pencil to fix names or amounts.';

  @override
  String get groceryNone =>
      'No food items were recognised. Try again with the items spread out and labels facing the camera.';

  @override
  String groceryAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count items to My Kitchen',
      one: 'Add 1 item to My Kitchen',
      zero: 'Nothing selected',
    );
    return '$_temp0';
  }

  @override
  String groceryAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items added to My Kitchen',
      one: '1 item added to My Kitchen',
      zero: 'Nothing added',
    );
    return '$_temp0';
  }

  @override
  String get groceryNote => 'Added from a photo';

  @override
  String get myRecipeNew => 'New recipe';

  @override
  String get myRecipeEditTitle => 'Edit recipe';

  @override
  String get myRecipeName => 'Recipe name';

  @override
  String get myRecipeCategory => 'Type · optional';

  @override
  String get myRecipeCategoryHint => 'e.g. Breakfast, Dinner, Snack';

  @override
  String get myRecipeMinutes => 'Time (min) · optional';

  @override
  String get myRecipeServings => 'Servings · optional';

  @override
  String get myRecipeIngredients => 'Ingredients';

  @override
  String get myRecipeIngredient => 'Ingredient';

  @override
  String get myRecipeAmount => 'Amount';

  @override
  String get myRecipeAddIngredient => 'Add ingredient';

  @override
  String get myRecipeRemoveIngredient => 'Remove ingredient';

  @override
  String get myRecipeSteps => 'Steps · one per line';

  @override
  String get myRecipeStepsHint => 'Rinse the rice.\nBring to the boil…';

  @override
  String get myRecipeSave => 'Save recipe';

  @override
  String myRecipeSaved(String name) {
    return '$name saved';
  }

  @override
  String get myRecipeNeedName => 'Give the recipe a name.';

  @override
  String get myRecipeNeedIngredient => 'Add at least one ingredient.';

  @override
  String get myRecipeDelete => 'Delete recipe';

  @override
  String myRecipeDeleteConfirm(String name) {
    return 'Delete $name?';
  }

  @override
  String get myRecipeDeleteBody =>
      'This removes your recipe from this phone. Meals you logged from it stay in your diary.';

  @override
  String myRecipeDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get myRecipeBadge => 'Your recipe';

  @override
  String get recipesShowMine => 'My recipes';

  @override
  String get recipesMineEmpty => 'You haven’t written any recipes yet — tap “New recipe”.';

  @override
  String recipeMinutes(int count) {
    return '$count min';
  }

  @override
  String recipeServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count servings', one: '1 serving');
    return '$_temp0';
  }

  @override
  String recipesHiding(String list) {
    return 'Hiding recipes with: $list.';
  }

  @override
  String recipesHaveShort(int have, int total) {
    return '$have/$total ingredients';
  }

  @override
  String get homeStepGoalTitle => 'Daily steps goal';

  @override
  String get bmiBandUnder => 'Under';

  @override
  String get bmiBandHealthy => 'Healthy 18.5–25';

  @override
  String get bmiBandOver => 'Over';

  @override
  String get diaryCopy => 'Copy to another day';

  @override
  String get diaryCopyTo => 'Copy to which day?';

  @override
  String diaryCopyMeal(String meal) {
    return 'Copy $meal to another day';
  }

  @override
  String diaryCopied(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items copied to $day',
      one: 'Copied to $day',
    );
    return '$_temp0';
  }

  @override
  String get addFoodLoggedBefore => 'Logged before';

  @override
  String get recipePerServing => 'Per serving';

  @override
  String get myRecipeNutrition => 'Nutrition per serving · optional';

  @override
  String get myRecipeTakePhoto => 'Take photo';

  @override
  String get myRecipeRemovePhoto => 'Remove';

  @override
  String get myRecipePhoto => 'Recipe photo';

  @override
  String get recipeAiTitle => 'Let MagnaVita write it';

  @override
  String get recipeAiBody =>
      'Add a photo of the plate above and/or describe what you made and how. Gemini fills in the name, ingredients, steps and nutrition per serving. It\'s an estimate, so check it before saving.';

  @override
  String get recipeAiDescribe => 'What you made · optional';

  @override
  String get recipeAiHint => 'e.g. Fried 2 eggs in 1 tsp butter, 2 slices brown toast, half an avocado';

  @override
  String get recipeAiGenerate => 'Write the recipe';

  @override
  String get recipeAiWorking => 'Writing your recipe…';

  @override
  String get recipeAiNeedInput => 'Add a photo or describe the meal first.';

  @override
  String get recipeAiFilled => 'Recipe filled in. Check it, then save.';

  @override
  String diarySaveRecipe(String meal) {
    return 'Save $meal as a recipe';
  }

  @override
  String get homeBurned => 'Calories burned';

  @override
  String get homeBurnedSub => 'From your watch';

  @override
  String get watchSection => 'Watch';

  @override
  String get watchTitle => 'Connect your watch';

  @override
  String get watchOff => 'Not connected';

  @override
  String get watchLinked => 'Connected';

  @override
  String get watchNeedsPermission => 'Needs permission';

  @override
  String get watchUnavailableShort => 'Health Connect needed';

  @override
  String get watchIntro =>
      'MagnaVita can read the workouts, calories burned and steps your watch records, through Android’s Health Connect.';

  @override
  String get watchSteps =>
      'Xiaomi watch? First open Mi Fitness → Profile → Settings → Health Connect and allow it to share exercise, calories and steps. Then tap Connect below.';

  @override
  String get watchUnavailable => 'Health Connect isn’t installed on this phone yet.';

  @override
  String get watchInstall => 'Install Health Connect';

  @override
  String get watchConnect => 'Connect';

  @override
  String get watchConnected => 'Watch connected';

  @override
  String get watchDenied => 'MagnaVita wasn’t given access. You can allow it in Health Connect any time.';

  @override
  String get watchLinkedBody => 'Connected — MagnaVita reads your watch data when you open the app.';

  @override
  String get watchDisconnect => 'Stop reading watch data';

  @override
  String get watchPrivacy =>
      'Read-only: MagnaVita never writes to your health data, and nothing leaves this phone. You can revoke access in Health Connect.';

  @override
  String get activityFromWatch => 'From your watch';

  @override
  String get homeStepsWatch => 'watch';

  @override
  String get homeStepsEdited => 'edited';

  @override
  String get homeStepsEdit => 'Edit steps';

  @override
  String get stepsEditTitle => 'Today’s steps';

  @override
  String get stepsEditBody =>
      'Type the number your watch shows. MagnaVita keeps adding the steps your phone counts after this, and uses your watch’s own count again once it syncs past it.';

  @override
  String get stepsEditField => 'Steps';

  @override
  String get stepsEditReset => 'Go back to the automatic count';

  @override
  String homeWatchSynced(String time) {
    return 'Watch last synced $time';
  }

  @override
  String get homeBurnedNone => 'Connected · nothing synced from your watch yet today';

  @override
  String get watchFromApps => 'Today in Health Connect, by app';

  @override
  String get watchNoData => 'Nothing from today yet. Open Mi Fitness and let it sync, then tap Refresh.';

  @override
  String watchAppSteps(int count) {
    return '$count steps';
  }

  @override
  String watchAppActive(int kcal) {
    return '$kcal active kcal';
  }

  @override
  String watchAppTotal(int kcal) {
    return '$kcal total kcal';
  }

  @override
  String get watchUsedNote =>
      '✓ is the app MagnaVita uses (Mi Fitness when present), so nothing is counted twice. Mi Fitness shares data with Health Connect when it syncs, so MagnaVita can lag behind your watch face until then.';

  @override
  String get watchRefresh => 'Refresh';

  @override
  String get updateAvailable => 'New version available';

  @override
  String appVersion(String version) {
    return 'MagnaVita $version';
  }

  @override
  String get updateNow => 'Update';

  @override
  String activityKcalEstimate(int kcal, String kg) {
    return '≈ $kcal kcal burned (est.) · at $kg kg';
  }

  @override
  String get activityKcalNeedWeight => 'Add your weight in Profile to estimate calories burned.';

  @override
  String activityKcalWatch(int kcal) {
    return '$kcal kcal burned · from your watch';
  }

  @override
  String get activityKcalOwn => 'Calories burned · optional, if you know them';

  @override
  String get homeBurnedLogged => 'From activities you logged · estimated';

  @override
  String get homeBurnedBoth => 'Watch + activities you logged';

  @override
  String get activityExercises => 'Exercises (optional)';

  @override
  String get activityAddExercise => 'Add exercise';

  @override
  String get exerciseTitle => 'Exercise';

  @override
  String get exerciseName => 'Name, e.g. crunches';

  @override
  String exerciseWeight(String unit) {
    return 'Weight per set ($unit) · optional';
  }

  @override
  String exerciseSets(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n sets', one: '1 set');
    return '$_temp0';
  }

  @override
  String exerciseReps(int n) {
    return '$n reps';
  }

  @override
  String get exerciseRepsHint => 'For holds like plank, count seconds as reps.';

  @override
  String get notifRestTitle => 'Rest over';

  @override
  String get notifRestBody => 'Time for your next set.';

  @override
  String get workoutCardTitle => 'Strength workout';

  @override
  String get workoutCardSub => 'Track every set\'s weight and reps, with a rest timer between sets';

  @override
  String get workoutStart => 'Start workout';

  @override
  String workoutInProgress(String time) {
    return 'Workout in progress · $time';
  }

  @override
  String get workoutResume => 'Resume workout';

  @override
  String get workoutTitle => 'Workout';

  @override
  String workoutElapsed(String time, int sets) {
    String _temp0 = intl.Intl.pluralLogic(sets, locale: localeName, other: '$sets sets', one: '1 set');
    return '$time · $_temp0 done';
  }

  @override
  String get workoutFinish => 'Finish workout';

  @override
  String get workoutEmpty => 'Add your first exercise. Each one starts from what you did last time.';

  @override
  String get workoutAddExercise => 'Add exercise';

  @override
  String get workoutDiscard => 'Discard workout';

  @override
  String get workoutDiscardTitle => 'Discard this workout?';

  @override
  String get workoutDiscardBody => 'Nothing from it will be saved.';

  @override
  String get workoutNothingDone => 'Tick off at least one set to save the workout.';

  @override
  String workoutSaved(int minutes, int sets) {
    String _temp0 = intl.Intl.pluralLogic(sets, locale: localeName, other: '$sets sets', one: '1 set');
    return 'Workout saved — $minutes min, $_temp0';
  }

  @override
  String workoutLastTime(String what) {
    return 'Last time: $what';
  }

  @override
  String get workoutSet => 'Set';

  @override
  String get workoutReps => 'Reps';

  @override
  String get workoutAddSet => 'Add set';

  @override
  String workoutRemoveSet(int n) {
    return 'Remove set $n';
  }

  @override
  String workoutRemoveExercise(String name) {
    return 'Remove $name';
  }

  @override
  String workoutSetDone(int n) {
    return 'Set $n done';
  }

  @override
  String workoutSetTodo(int n) {
    return 'Mark set $n done';
  }

  @override
  String get restTitle => 'Rest';

  @override
  String get restLess => '15 seconds less rest';

  @override
  String get restMore => '15 seconds more rest';

  @override
  String get restSkip => 'Skip';

  @override
  String get pickerTitle => 'Add an exercise';

  @override
  String get pickerSearch => 'Search exercises';

  @override
  String get pickerYours => 'Your exercises';

  @override
  String get pickerAll => 'All';

  @override
  String pickerOwn(String name) {
    return 'Add “$name” as your own';
  }

  @override
  String get pickerNone => 'No exercises match.';

  @override
  String get equipFreeWeights => 'Free weights';

  @override
  String get equipMachines => 'Machines';

  @override
  String get equipBodyweight => 'Bodyweight';

  @override
  String get equipOther => 'Other';

  @override
  String get goalStrength => 'Get stronger';

  @override
  String get goalMuscle => 'Build muscle';

  @override
  String get goalEndurance => 'Tone and endurance';

  @override
  String get goalFatLoss => 'Lose fat';

  @override
  String get focusPush => 'Push: chest, shoulders, triceps';

  @override
  String get focusPull => 'Pull: back, biceps';

  @override
  String get focusLegs => 'Legs';

  @override
  String get focusChestTriceps => 'Chest & triceps';

  @override
  String get focusBackBiceps => 'Back & biceps';

  @override
  String get focusShouldersCore => 'Shoulders & core';

  @override
  String get focusChest => 'Chest';

  @override
  String get focusBack => 'Back';

  @override
  String get focusShoulders => 'Shoulders';

  @override
  String get focusArmsCore => 'Arms & core';

  @override
  String planDay(int n, String focus) {
    return 'Day $n · $focus';
  }

  @override
  String get planTitle => 'Your plan';

  @override
  String planSummary(String goal, int days, int rest) {
    return '$goal · $days days a week · $rest s rest between sets';
  }

  @override
  String get planEditHint => 'Tap an exercise to change its sets and reps or swap it.';

  @override
  String get planChange => 'Change my plan';

  @override
  String get planNext => 'Next';

  @override
  String planStartDay(int n) {
    return 'Start day $n';
  }

  @override
  String planSets(int n) {
    return '$n sets';
  }

  @override
  String planReps(int n) {
    return '$n reps';
  }

  @override
  String get planSwapFor => 'Swap for';

  @override
  String get planRemove => 'Remove from the plan';

  @override
  String get planSetupTitle => 'Make a workout plan';

  @override
  String get planSetupSub => 'Each day works different muscles';

  @override
  String get planGoal => 'Your goal';

  @override
  String get planDaysPerWeek => 'Days a week';

  @override
  String planDaysChip(int n) {
    return '$n days';
  }

  @override
  String get planLevel => 'Experience';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelExpert => 'Advanced';

  @override
  String get planEquipment => 'Equipment';

  @override
  String get planEquipGym => 'Full gym';

  @override
  String get planEquipDumbbells => 'Dumbbells at home';

  @override
  String get planEquipBodyweight => 'No equipment';

  @override
  String get planReplaces => 'This replaces your current plan.';

  @override
  String get planCreate => 'Create my plan';

  @override
  String planUpNext(String day) {
    return 'Up next: $day';
  }

  @override
  String planToday(String day) {
    return 'Today: $day';
  }

  @override
  String planUpNextOn(String weekday, String day) {
    return 'Up next $weekday: $day';
  }

  @override
  String get planWeek => 'Your week';

  @override
  String get planWeekHint => 'Tap the days you train. Miss one and your next workout waits for you.';

  @override
  String planWeekdayTrained(String weekday) {
    return '$weekday: trained';
  }

  @override
  String planWeekdayTraining(String weekday) {
    return '$weekday: training day';
  }

  @override
  String planWeekdayRest(String weekday) {
    return '$weekday: rest day';
  }

  @override
  String get planRemind => 'Remind me on training days';

  @override
  String planRemindAt(String time) {
    return 'At $time';
  }

  @override
  String get notifWorkoutTitle => 'Training day';

  @override
  String get notifWorkoutBody => 'Your plan has a workout today, whenever suits you.';

  @override
  String get planMake => 'Make a workout plan';

  @override
  String get planYours => 'Your plan';

  @override
  String get workoutEmptyStart => 'Empty workout';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressSub => 'From the workouts you\'ve logged';

  @override
  String get progressEmpty => 'Finish a strength workout and your progress shows here.';

  @override
  String get progressThisWeek => 'This week';

  @override
  String progressOfPlan(int n, int target) {
    return '$n of $target';
  }

  @override
  String get progressStreak => 'Streak';

  @override
  String progressWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n weeks', one: '1 week');
    return '$_temp0';
  }

  @override
  String get progressMonth => 'Last 30 days';

  @override
  String get progressPerWeek => 'Workouts per week';

  @override
  String progressPerWeekLabel(String counts) {
    return 'Workouts per week, last 8 weeks: $counts';
  }

  @override
  String get progressBests => 'Personal bests';

  @override
  String get progressNoBests => 'Tick off sets in a workout to set your first bests.';

  @override
  String progressBest1rm(String load) {
    return 'Best estimated 1-rep max $load';
  }

  @override
  String progressMostReps(int n) {
    return 'Most reps in a set: $n';
  }

  @override
  String get progressChart => 'Estimated 1-rep max over time';

  @override
  String progressChartLabel(String first, String last) {
    return 'Estimated 1-rep max went from $first to $last';
  }

  @override
  String get libraryTitle => 'Exercise library';

  @override
  String get libraryBrowse => 'Browse the exercise library';

  @override
  String exerciseAbout(String name) {
    return 'How to do $name';
  }

  @override
  String get exerciseAddToWorkout => 'Add to workout';

  @override
  String get exerciseYours => 'Your history';

  @override
  String get exerciseNoHistory => 'You haven\'t logged this yet. Your best sets will show here.';

  @override
  String exerciseHeaviest(String set) {
    return 'Heaviest set: $set';
  }

  @override
  String exerciseBest1rm(String load, String set) {
    return 'Best estimated 1-rep max: $load (from $set)';
  }

  @override
  String get exerciseMuscles => 'Muscles';

  @override
  String exerciseAlsoWorks(String muscles) {
    return 'Also works: $muscles';
  }

  @override
  String get exerciseHow => 'How to do it';

  @override
  String exercisePhotos(String name) {
    return 'Photos showing how to do $name';
  }

  @override
  String get exercisePhotosOffline => 'Photos load when you\'re online.';

  @override
  String get exerciseSource => 'Exercises from free-exercise-db (public domain).';

  @override
  String get exerciseFewerSets => '1 set less';

  @override
  String get exerciseMoreSets => '1 set more';

  @override
  String get exerciseFewerReps => '1 rep less';

  @override
  String get exerciseMoreReps => '1 rep more';

  @override
  String get exerciseAdd => 'Add';

  @override
  String exerciseRemove(String name) {
    return 'Remove $name';
  }

  @override
  String get shareDayTitle => 'Share your day';

  @override
  String get shareDayTooltip => 'Export the day\'s stats';

  @override
  String get shareDayButton => 'Export PNG';

  @override
  String get statSteps => 'Steps';

  @override
  String get statDistance => 'Distance';

  @override
  String get statBurned => 'Calories burned';

  @override
  String get statActive => 'Active time';

  @override
  String get exportStyle => 'Style';

  @override
  String get styleWhite => 'White';

  @override
  String get styleLime => 'Lime';

  @override
  String get styleForest => 'Forest';

  @override
  String get styleBadge => 'Badge';

  @override
  String get layoutCompact => 'Stats first';

  @override
  String get layoutPoster => 'Icon first';

  @override
  String get pickDay => 'Pick a day';

  @override
  String get notifDailyBody => 'Your daily reminder. Open the app to start or review a session.';
}
