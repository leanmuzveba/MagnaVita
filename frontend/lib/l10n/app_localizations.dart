import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MagnaVita'**
  String get appName;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navToday;

  /// No description provided for @navTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @navNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get navNutrition;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navSettings;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @homeSessionInProgress.
  ///
  /// In en, this message translates to:
  /// **'{date} · Session in progress'**
  String homeSessionInProgress(String date);

  /// No description provided for @startFast.
  ///
  /// In en, this message translates to:
  /// **'Start fast'**
  String get startFast;

  /// No description provided for @endFast.
  ///
  /// In en, this message translates to:
  /// **'End fast'**
  String get endFast;

  /// No description provided for @editStartTime.
  ///
  /// In en, this message translates to:
  /// **'Edit start time'**
  String get editStartTime;

  /// No description provided for @changeTarget.
  ///
  /// In en, this message translates to:
  /// **'Change target'**
  String get changeTarget;

  /// No description provided for @cardFastStarted.
  ///
  /// In en, this message translates to:
  /// **'FAST STARTED'**
  String get cardFastStarted;

  /// No description provided for @cardPlannedEnd.
  ///
  /// In en, this message translates to:
  /// **'PLANNED END'**
  String get cardPlannedEnd;

  /// No description provided for @cardTarget.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get cardTarget;

  /// No description provided for @cardIfStartedNow.
  ///
  /// In en, this message translates to:
  /// **'IF STARTED NOW'**
  String get cardIfStartedNow;

  /// No description provided for @cardChangeAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Change any time'**
  String get cardChangeAnyTime;

  /// No description provided for @targetHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String targetHours(int hours);

  /// No description provided for @ringReady.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are'**
  String get ringReady;

  /// No description provided for @ringTargetReached.
  ///
  /// In en, this message translates to:
  /// **'Target reached'**
  String get ringTargetReached;

  /// No description provided for @ringInProgress.
  ///
  /// In en, this message translates to:
  /// **'Fasting in progress'**
  String get ringInProgress;

  /// No description provided for @ringTimeElapsed.
  ///
  /// In en, this message translates to:
  /// **'TIME ELAPSED'**
  String get ringTimeElapsed;

  /// No description provided for @ringTargetLine.
  ///
  /// In en, this message translates to:
  /// **'{target} target'**
  String ringTargetLine(String target);

  /// No description provided for @ringOfTargetLine.
  ///
  /// In en, this message translates to:
  /// **'of {target} target'**
  String ringOfTargetLine(String target);

  /// No description provided for @ringCenterHint.
  ///
  /// In en, this message translates to:
  /// **'Shows start and planned end times'**
  String get ringCenterHint;

  /// No description provided for @ringSemantics.
  ///
  /// In en, this message translates to:
  /// **'{status}. {elapsed} elapsed, {targetLine}.'**
  String ringSemantics(String status, String elapsed, String targetLine);

  /// No description provided for @ringSemanticsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{status}. {elapsed} elapsed, {targetLine}, {remaining} remaining.'**
  String ringSemanticsRemaining(String status, String elapsed, String targetLine, String remaining);

  /// No description provided for @markerCurrent.
  ///
  /// In en, this message translates to:
  /// **'current estimate'**
  String get markerCurrent;

  /// No description provided for @markerPassed.
  ///
  /// In en, this message translates to:
  /// **'passed'**
  String get markerPassed;

  /// No description provided for @markerUpcoming.
  ///
  /// In en, this message translates to:
  /// **'upcoming'**
  String get markerUpcoming;

  /// No description provided for @markerSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {state}. Opens details.'**
  String markerSemantics(String title, String state);

  /// No description provided for @markerSemanticsAround.
  ///
  /// In en, this message translates to:
  /// **'{title}, around {time}, {state}. Opens details.'**
  String markerSemanticsAround(String title, String time, String state);

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @endSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'End this session?'**
  String get endSessionTitle;

  /// No description provided for @endSessionRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded so far: '**
  String get endSessionRecorded;

  /// No description provided for @endSessionBody.
  ///
  /// In en, this message translates to:
  /// **'. You can end a session whenever you choose. It will be saved to your history.'**
  String get endSessionBody;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get endSession;

  /// No description provided for @editStartBody.
  ///
  /// In en, this message translates to:
  /// **'Forgot to press Start? Set when you actually began. The ring and history update after you save.'**
  String get editStartBody;

  /// No description provided for @startedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'STARTED AT'**
  String get startedAtLabel;

  /// No description provided for @startedAtSemantics.
  ///
  /// In en, this message translates to:
  /// **'Started at {time}. Change time'**
  String startedAtSemantics(String time);

  /// No description provided for @willStart.
  ///
  /// In en, this message translates to:
  /// **'Will start {day} at {time}.'**
  String willStart(String day, String time);

  /// No description provided for @errorStartInFuture.
  ///
  /// In en, this message translates to:
  /// **'Start time can’t be in the future.'**
  String get errorStartInFuture;

  /// No description provided for @errorEndInFuture.
  ///
  /// In en, this message translates to:
  /// **'End time can’t be in the future.'**
  String get errorEndInFuture;

  /// No description provided for @errorEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after the start time.'**
  String get errorEndBeforeStart;

  /// No description provided for @errorOverlaps.
  ///
  /// In en, this message translates to:
  /// **'That overlaps another fast in your history.'**
  String get errorOverlaps;

  /// No description provided for @milestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get milestoneTitle;

  /// No description provided for @milestoneMarkerNote.
  ///
  /// In en, this message translates to:
  /// **'The position of this marker is a visual reference for elapsed time. It is not proof that anything has happened in your body, and reaching it is not a goal or a health achievement.'**
  String get milestoneMarkerNote;

  /// No description provided for @milestoneReviewed.
  ///
  /// In en, this message translates to:
  /// **'Content reviewed'**
  String get milestoneReviewed;

  /// No description provided for @milestoneReviewedSource.
  ///
  /// In en, this message translates to:
  /// **'Content reviewed · {source}'**
  String milestoneReviewedSource(String source);

  /// No description provided for @milestoneDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft educational copy — awaiting review by a qualified health professional.'**
  String get milestoneDraft;

  /// No description provided for @targetTitle.
  ///
  /// In en, this message translates to:
  /// **'Your target'**
  String get targetTitle;

  /// No description provided for @targetIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose how long you’d like to track. No option here is a recommendation, and you can end any session whenever you choose.'**
  String get targetIntro;

  /// No description provided for @targetCustom.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get targetCustom;

  /// No description provided for @targetDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease by 30 minutes'**
  String get targetDecrease;

  /// No description provided for @targetIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase by 30 minutes'**
  String get targetIncrease;

  /// No description provided for @saveTarget.
  ///
  /// In en, this message translates to:
  /// **'Save target'**
  String get saveTarget;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When you end a session, it’s saved here. You can edit or delete it at any time.'**
  String get historyEmptyBody;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusTargetReached.
  ///
  /// In en, this message translates to:
  /// **'Target reached'**
  String get statusTargetReached;

  /// No description provided for @statusEnded.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get statusEnded;

  /// No description provided for @sessionTimesOngoing.
  ///
  /// In en, this message translates to:
  /// **'{start} → now'**
  String sessionTimesOngoing(String start);

  /// No description provided for @sessionTimes.
  ///
  /// In en, this message translates to:
  /// **'{start} → {end}'**
  String sessionTimes(String start, String end);

  /// No description provided for @sessionTileDetail.
  ///
  /// In en, this message translates to:
  /// **'{times} · {target} target'**
  String sessionTileDetail(String times, String target);

  /// No description provided for @sessionTileSemantics.
  ///
  /// In en, this message translates to:
  /// **'{day}, {times}, {duration} of {target} target, {status}. Opens options.'**
  String sessionTileSemantics(String day, String times, String duration, String target, String status);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionTitle;

  /// No description provided for @sessionStarted.
  ///
  /// In en, this message translates to:
  /// **'STARTED'**
  String get sessionStarted;

  /// No description provided for @sessionEnded.
  ///
  /// In en, this message translates to:
  /// **'ENDED'**
  String get sessionEnded;

  /// No description provided for @timeFieldSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label} {value}. Change'**
  String timeFieldSemantics(String label, String value);

  /// No description provided for @deleteSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get deleteSessionTitle;

  /// No description provided for @deleteSessionBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from your history on this phone. This can’t be undone.'**
  String get deleteSessionBody;

  /// No description provided for @settingsTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get settingsTarget;

  /// No description provided for @settings24h.
  ///
  /// In en, this message translates to:
  /// **'24-hour clock'**
  String get settings24h;

  /// No description provided for @settingsTargetReached.
  ///
  /// In en, this message translates to:
  /// **'Target time reached'**
  String get settingsTargetReached;

  /// No description provided for @settingsTargetReachedSub.
  ///
  /// In en, this message translates to:
  /// **'A quiet notice when your planned time passes'**
  String get settingsTargetReachedSub;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingsDailyReminder;

  /// No description provided for @settingsEveryDayAt.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String settingsEveryDayAt(String time);

  /// No description provided for @settingsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsOff;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// No description provided for @settingsNotificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for this app in your phone’s settings.'**
  String get settingsNotificationsBlocked;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get settingsPrivacy;

  /// No description provided for @settingsDataStays.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this phone'**
  String get settingsDataStays;

  /// No description provided for @settingsDataStaysSub.
  ///
  /// In en, this message translates to:
  /// **'Nothing is uploaded or shared. There are no accounts or ads. Recipe search sends only ingredient names and search words to TheMealDB; barcode scans send only the barcode number to Open Food Facts; meal photos are sent to Google Gemini.'**
  String get settingsDataStaysSub;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Back up my data'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSub.
  ///
  /// In en, this message translates to:
  /// **'Save a backup file to Google Drive, email or Files. Your Gemini key isn’t included.'**
  String get settingsBackupSub;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get settingsRestore;

  /// No description provided for @settingsRestoreSub.
  ///
  /// In en, this message translates to:
  /// **'On a new phone, pick the backup file to bring everything back'**
  String get settingsRestoreSub;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup?'**
  String get restoreTitle;

  /// No description provided for @restoreBody.
  ///
  /// In en, this message translates to:
  /// **'Everything on this phone is replaced by what’s in the backup file.'**
  String get restoreBody;

  /// No description provided for @restorePick.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get restorePick;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Your data is back'**
  String get restoreDone;

  /// No description provided for @restoreNotBackup.
  ///
  /// In en, this message translates to:
  /// **'That file isn’t a MagnaVita backup, or it’s from a newer version. Nothing was changed.'**
  String get restoreNotBackup;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t make the backup. Nothing was changed.'**
  String get backupFailed;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get settingsDeleteAll;

  /// No description provided for @settingsDeleteAllSub.
  ///
  /// In en, this message translates to:
  /// **'Sessions, settings and reminders'**
  String get settingsDeleteAllSub;

  /// No description provided for @settingsNotMedical.
  ///
  /// In en, this message translates to:
  /// **'Not a medical device'**
  String get settingsNotMedical;

  /// No description provided for @settingsNotMedicalSub.
  ///
  /// In en, this message translates to:
  /// **'This app records time only. Milestones are general estimates and can’t tell what is happening in your body. Speak with a qualified healthcare professional before changing how you eat.'**
  String get settingsNotMedicalSub;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'This removes every session, your settings and any reminders from this phone. It can’t be undone.'**
  String get deleteAllBody;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MagnaVita, your calm place for fasting, food and wellness'**
  String get onboardingTitle;

  /// No description provided for @onboardingNotMedical.
  ///
  /// In en, this message translates to:
  /// **'This app records time. It is a tracking and educational tool, not a medical device, and it cannot tell what is happening in your body.'**
  String get onboardingNotMedical;

  /// No description provided for @onboardingEstimates.
  ///
  /// In en, this message translates to:
  /// **'Milestones on the timer are general estimates that vary between people. They are never goals.'**
  String get onboardingEstimates;

  /// No description provided for @onboardingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your sessions stay on this phone. Nothing is uploaded, and you can delete everything at any time.'**
  String get onboardingPrivacy;

  /// No description provided for @onboardingSafety.
  ///
  /// In en, this message translates to:
  /// **'Speak with a qualified healthcare professional before changing how you eat — especially if you have a medical condition, take medication, are pregnant, or have a history of disordered eating.'**
  String get onboardingSafety;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @ageTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you 18 or older?'**
  String get ageTitle;

  /// No description provided for @ageBody.
  ///
  /// In en, this message translates to:
  /// **'Fasting tools in this app are designed for adults only. If you’re under 18, we’ll show general information instead.'**
  String get ageBody;

  /// No description provided for @ageAdult.
  ///
  /// In en, this message translates to:
  /// **'I’m 18 or older'**
  String get ageAdult;

  /// No description provided for @ageUnder18.
  ///
  /// In en, this message translates to:
  /// **'I’m under 18'**
  String get ageUnder18;

  /// No description provided for @underageTitle.
  ///
  /// In en, this message translates to:
  /// **'This app is designed for adults'**
  String get underageTitle;

  /// No description provided for @underageMeals.
  ///
  /// In en, this message translates to:
  /// **'Growing bodies need regular, balanced meals. Fasting isn’t recommended for people under 18 unless a doctor advises it.'**
  String get underageMeals;

  /// No description provided for @underageTalk.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about eating, food or your body, talk with a parent or guardian and a qualified healthcare professional such as your doctor or a dietitian.'**
  String get underageTalk;

  /// No description provided for @underageSupport.
  ///
  /// In en, this message translates to:
  /// **'If you’re worried about how you feel about food, you deserve support — a trusted adult or your doctor can help you find it.'**
  String get underageSupport;

  /// No description provided for @underageReset.
  ///
  /// In en, this message translates to:
  /// **'I answered by mistake — start again'**
  String get underageReset;

  /// No description provided for @notifTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Target time reached'**
  String get notifTargetTitle;

  /// No description provided for @notifTargetBody.
  ///
  /// In en, this message translates to:
  /// **'Your planned time has passed. End your session whenever you’re ready.'**
  String get notifTargetBody;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'MagnaVita, loading'**
  String get splashLoading;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @heroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'FASTING'**
  String get heroEyebrow;

  /// No description provided for @heroReady.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are'**
  String get heroReady;

  /// No description provided for @heroFastingFor.
  ///
  /// In en, this message translates to:
  /// **'Fasting for {duration}'**
  String heroFastingFor(String duration);

  /// No description provided for @heroEndsAt.
  ///
  /// In en, this message translates to:
  /// **'{target} target · ends {time}'**
  String heroEndsAt(String target, String time);

  /// No description provided for @heroIfStartedNow.
  ///
  /// In en, this message translates to:
  /// **'{target} target · ends {time} if you start now'**
  String heroIfStartedNow(String target, String time);

  /// No description provided for @openTimer.
  ///
  /// In en, this message translates to:
  /// **'Open timer'**
  String get openTimer;

  /// No description provided for @milestoneEstimateNote.
  ///
  /// In en, this message translates to:
  /// **'Milestones on the timer are estimates and vary between people.'**
  String get milestoneEstimateNote;

  /// No description provided for @notifWaterBody.
  ///
  /// In en, this message translates to:
  /// **'A gentle reminder to have some water, if you\'d like.'**
  String get notifWaterBody;

  /// No description provided for @waterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get waterTitle;

  /// No description provided for @waterToday.
  ///
  /// In en, this message translates to:
  /// **'WATER TODAY'**
  String get waterToday;

  /// No description provided for @waterAdd.
  ///
  /// In en, this message translates to:
  /// **'Add {amount}'**
  String waterAdd(String amount);

  /// No description provided for @waterAddCustom.
  ///
  /// In en, this message translates to:
  /// **'Add amount'**
  String get waterAddCustom;

  /// No description provided for @waterEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No entries} =1{1 entry} other{{count} entries}}'**
  String waterEntries(int count);

  /// No description provided for @waterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No water recorded for this day.'**
  String get waterEmpty;

  /// No description provided for @waterDayTotal.
  ///
  /// In en, this message translates to:
  /// **'Total for the day'**
  String get waterDayTotal;

  /// No description provided for @waterAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT ({unit})'**
  String waterAmountLabel(String unit);

  /// No description provided for @waterTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get waterTimeLabel;

  /// No description provided for @waterInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount between 1 and {max}.'**
  String waterInvalidAmount(String max);

  /// No description provided for @waterEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Water entry'**
  String get waterEditTitle;

  /// No description provided for @waterAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add water'**
  String get waterAddTitle;

  /// No description provided for @waterEntrySemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} at {time}. Edit'**
  String waterEntrySemantics(String amount, String time);

  /// No description provided for @mealExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export a meal'**
  String get mealExportTitle;

  /// No description provided for @mealExportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export a meal\'s nutrition'**
  String get mealExportTooltip;

  /// No description provided for @mealExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged for {meal} on this day.'**
  String mealExportEmpty(String meal);

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnits;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitFlOz.
  ///
  /// In en, this message translates to:
  /// **'fl oz'**
  String get unitFlOz;

  /// No description provided for @settingsWaterReminders.
  ///
  /// In en, this message translates to:
  /// **'Water reminders'**
  String get settingsWaterReminders;

  /// No description provided for @settingsWaterRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'Every 2 hours, 8 AM to 8 PM'**
  String get settingsWaterRemindersSub;

  /// No description provided for @awTitle.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get awTitle;

  /// No description provided for @awWaterTab.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get awWaterTab;

  /// No description provided for @awActivityTab.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get awActivityTab;

  /// No description provided for @waterOfGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal} goal'**
  String waterOfGoal(String goal);

  /// No description provided for @waterCustomAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom amount'**
  String get waterCustomAmount;

  /// No description provided for @waterTodaysEntries.
  ///
  /// In en, this message translates to:
  /// **'Today\'s entries'**
  String get waterTodaysEntries;

  /// No description provided for @waterNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No water logged yet today.'**
  String get waterNoneYet;

  /// No description provided for @waterGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached — lovely work.'**
  String get waterGoalReached;

  /// No description provided for @waterKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Nice pace — every glass counts.'**
  String get waterKeepGoing;

  /// No description provided for @waterEditGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily water goal'**
  String get waterEditGoal;

  /// No description provided for @waterGoalHint.
  ///
  /// In en, this message translates to:
  /// **'A personal goal you choose. Needs vary from person to person.'**
  String get waterGoalHint;

  /// No description provided for @entryOptions.
  ///
  /// In en, this message translates to:
  /// **'Options for {entry}'**
  String entryOptions(String entry);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @activityRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get activityRecent;

  /// No description provided for @activityNone.
  ///
  /// In en, this message translates to:
  /// **'No activities logged yet.'**
  String get activityNone;

  /// No description provided for @activityLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log an activity'**
  String get activityLogTitle;

  /// No description provided for @activityEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit activity'**
  String get activityEditTitle;

  /// No description provided for @activityType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get activityType;

  /// No description provided for @activityWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get activityWalk;

  /// No description provided for @activityRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get activityRun;

  /// No description provided for @activityCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get activityCycle;

  /// No description provided for @activityStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get activityStrength;

  /// No description provided for @activityYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get activityYoga;

  /// No description provided for @activitySwim.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get activitySwim;

  /// No description provided for @swimPool.
  ///
  /// In en, this message translates to:
  /// **'Pool length'**
  String get swimPool;

  /// No description provided for @swimPoolCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get swimPoolCustom;

  /// No description provided for @swimPoolCustomField.
  ///
  /// In en, this message translates to:
  /// **'Pool length in metres'**
  String get swimPoolCustomField;

  /// No description provided for @swimLaps.
  ///
  /// In en, this message translates to:
  /// **'Laps completed'**
  String get swimLaps;

  /// No description provided for @swimLapsSummary.
  ///
  /// In en, this message translates to:
  /// **'{laps} laps · {metres} m'**
  String swimLapsSummary(int laps, String metres);

  /// No description provided for @swimTime.
  ///
  /// In en, this message translates to:
  /// **'Swim time'**
  String get swimTime;

  /// No description provided for @swimByMinutes.
  ///
  /// In en, this message translates to:
  /// **'Total minutes'**
  String get swimByMinutes;

  /// No description provided for @swimByPace.
  ///
  /// In en, this message translates to:
  /// **'Pace per lap'**
  String get swimByPace;

  /// No description provided for @swimPaceField.
  ///
  /// In en, this message translates to:
  /// **'Average seconds per lap'**
  String get swimPaceField;

  /// No description provided for @swimDurationFromPace.
  ///
  /// In en, this message translates to:
  /// **'≈ {minutes} min in the water'**
  String swimDurationFromPace(int minutes);

  /// No description provided for @swimNeedPace.
  ///
  /// In en, this message translates to:
  /// **'Enter your laps and pace per lap to work out the time.'**
  String get swimNeedPace;

  /// No description provided for @intensityLeisurely.
  ///
  /// In en, this message translates to:
  /// **'Leisurely'**
  String get intensityLeisurely;

  /// No description provided for @intensityVigorous.
  ///
  /// In en, this message translates to:
  /// **'Vigorous'**
  String get intensityVigorous;

  /// No description provided for @activityKcalPersonal.
  ///
  /// In en, this message translates to:
  /// **'≈ {kcal} kcal burned (est.) · from your weight, height, age and sex'**
  String activityKcalPersonal(int kcal);

  /// No description provided for @activityOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get activityOther;

  /// No description provided for @activityDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get activityDuration;

  /// No description provided for @activityMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String activityMinutes(int minutes);

  /// No description provided for @activityIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity (optional)'**
  String get activityIntensity;

  /// No description provided for @intensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get intensityLight;

  /// No description provided for @intensityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get intensityModerate;

  /// No description provided for @intensityHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get intensityHeavy;

  /// No description provided for @activityNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get activityNotes;

  /// No description provided for @activityWhen.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get activityWhen;

  /// No description provided for @activityLogButton.
  ///
  /// In en, this message translates to:
  /// **'Log activity'**
  String get activityLogButton;

  /// No description provided for @activityLogged.
  ///
  /// In en, this message translates to:
  /// **'{type} logged — {minutes} min'**
  String activityLogged(String type, int minutes);

  /// No description provided for @activityFutureError.
  ///
  /// In en, this message translates to:
  /// **'The start time can\'t be in the future.'**
  String get activityFutureError;

  /// No description provided for @decreaseMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute less'**
  String get decreaseMinute;

  /// No description provided for @increaseMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute more'**
  String get increaseMinute;

  /// No description provided for @activityToday.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY TODAY'**
  String get activityToday;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsRemindersOptional.
  ///
  /// In en, this message translates to:
  /// **'Reminders (all optional)'**
  String get settingsRemindersOptional;

  /// No description provided for @settingsAboutSafety.
  ///
  /// In en, this message translates to:
  /// **'About & safety'**
  String get settingsAboutSafety;

  /// No description provided for @settingsDiet.
  ///
  /// In en, this message translates to:
  /// **'Dietary preferences'**
  String get settingsDiet;

  /// No description provided for @settingsAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get settingsAllergies;

  /// No description provided for @settingsHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How MagnaVita works + safety notes'**
  String get settingsHowItWorks;

  /// No description provided for @settingsHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'MagnaVita helps you record fasting times, water, activity, meals and your kitchen, all on this phone. Fasting milestones and nutrition values are estimates, not measurements. MagnaVita does not diagnose anything. Speak with a qualified healthcare professional before changing how you eat.'**
  String get settingsHowItWorksBody;

  /// No description provided for @settingsFooter.
  ///
  /// In en, this message translates to:
  /// **'Made with care. Not medical advice.'**
  String get settingsFooter;

  /// No description provided for @settingsCurrentState.
  ///
  /// In en, this message translates to:
  /// **'Current state: {state}'**
  String settingsCurrentState(String state);

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @unitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitsMetric;

  /// No description provided for @unitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitsImperial;

  /// No description provided for @dietNone.
  ///
  /// In en, this message translates to:
  /// **'No preference'**
  String get dietNone;

  /// No description provided for @dietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietVegetarian;

  /// No description provided for @dietVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietVegan;

  /// No description provided for @dietPescatarian.
  ///
  /// In en, this message translates to:
  /// **'Pescatarian'**
  String get dietPescatarian;

  /// No description provided for @dietHalal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get dietHalal;

  /// No description provided for @allergiesNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get allergiesNone;

  /// No description provided for @allergiesHint.
  ///
  /// In en, this message translates to:
  /// **'Recipes with these ingredients will never be suggested. Always check labels — a database can\'t guarantee a food is allergen-free.'**
  String get allergiesHint;

  /// No description provided for @allergenEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergenEggs;

  /// No description provided for @allergenDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get allergenDairy;

  /// No description provided for @allergenPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergenPeanuts;

  /// No description provided for @allergenTreeNuts.
  ///
  /// In en, this message translates to:
  /// **'Tree nuts'**
  String get allergenTreeNuts;

  /// No description provided for @allergenGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get allergenGluten;

  /// No description provided for @allergenSoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergenSoy;

  /// No description provided for @allergenFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergenFish;

  /// No description provided for @allergenShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergenShellfish;

  /// No description provided for @allergenSesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get allergenSesame;

  /// No description provided for @profileAddName.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get profileAddName;

  /// No description provided for @profileEditHint.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditHint;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileTitle;

  /// No description provided for @profileOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional. Your name is only used to greet you and stays on this phone.'**
  String get profileOptional;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String profileMemberSince(String date);

  /// No description provided for @historyAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyAll;

  /// No description provided for @historyFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get historyFasting;

  /// No description provided for @historyRecentDays.
  ///
  /// In en, this message translates to:
  /// **'Recent days'**
  String get historyRecentDays;

  /// No description provided for @historyNothingRecent.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded in the last two weeks. That\'s completely fine.'**
  String get historyNothingRecent;

  /// No description provided for @historyNothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged'**
  String get historyNothingLogged;

  /// No description provided for @historyDaySummary.
  ///
  /// In en, this message translates to:
  /// **'Day summary'**
  String get historyDaySummary;

  /// No description provided for @historySkipFine.
  ///
  /// In en, this message translates to:
  /// **'Skipping a day is completely fine.'**
  String get historySkipFine;

  /// No description provided for @historyQuote.
  ///
  /// In en, this message translates to:
  /// **'“Trends are guides, not grades. Skip a day anytime.”'**
  String get historyQuote;

  /// No description provided for @historyFastInProgress.
  ///
  /// In en, this message translates to:
  /// **'Fast in progress'**
  String get historyFastInProgress;

  /// No description provided for @historyFastDone.
  ///
  /// In en, this message translates to:
  /// **'{duration} fast · {status}'**
  String historyFastDone(String duration, String status);

  /// No description provided for @historyWater.
  ///
  /// In en, this message translates to:
  /// **'{amount} water'**
  String historyWater(String amount);

  /// No description provided for @historyActivity.
  ///
  /// In en, this message translates to:
  /// **'{duration} activity'**
  String historyActivity(String duration);

  /// No description provided for @historyWaterEntries.
  ///
  /// In en, this message translates to:
  /// **'{amount} of water · {count, plural, =1{1 entry} other{{count} entries}}'**
  String historyWaterEntries(String amount, int count);

  /// No description provided for @weekdayInitialsSundayFirst.
  ///
  /// In en, this message translates to:
  /// **'S,M,T,W,T,F,S'**
  String get weekdayInitialsSundayFirst;

  /// No description provided for @trendEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Fasting · last 14 days'**
  String get trendEyebrow;

  /// No description provided for @trendAverageFast.
  ///
  /// In en, this message translates to:
  /// **'average fast'**
  String get trendAverageFast;

  /// No description provided for @trendLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get trendLongest;

  /// No description provided for @trendTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get trendTotal;

  /// No description provided for @trendFastCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 fast} other{{count} fasts}}'**
  String trendFastCount(int count);

  /// No description provided for @trendEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed fasts in the last 14 days.'**
  String get trendEmpty;

  /// No description provided for @trendSemantics.
  ///
  /// In en, this message translates to:
  /// **'Fasting, last 14 days ({range}): average fast {average}, longest {longest}, {count, plural, =1{1 fast} other{{count} fasts}}.'**
  String trendSemantics(String average, String longest, int count, String range);

  /// No description provided for @kitchenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Kitchen'**
  String get kitchenTitle;

  /// No description provided for @kitchenEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get kitchenEyebrow;

  /// No description provided for @kitchenSearch.
  ///
  /// In en, this message translates to:
  /// **'Search your kitchen…'**
  String get kitchenSearch;

  /// No description provided for @kitchenAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get kitchenAll;

  /// No description provided for @catProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get catProtein;

  /// No description provided for @catCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get catCarbs;

  /// No description provided for @catVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get catVegetables;

  /// No description provided for @catFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get catFruits;

  /// No description provided for @catFatsNutsSeeds.
  ///
  /// In en, this message translates to:
  /// **'Fats, nuts & seeds'**
  String get catFatsNutsSeeds;

  /// No description provided for @catDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy & alternatives'**
  String get catDairy;

  /// No description provided for @catHerbsSpices.
  ///
  /// In en, this message translates to:
  /// **'Herbs & spices'**
  String get catHerbsSpices;

  /// No description provided for @catPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry essentials'**
  String get catPantry;

  /// No description provided for @stateFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get stateFresh;

  /// No description provided for @stateFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get stateFrozen;

  /// No description provided for @stateCanned.
  ///
  /// In en, this message translates to:
  /// **'Canned'**
  String get stateCanned;

  /// No description provided for @stateDried.
  ///
  /// In en, this message translates to:
  /// **'Dried'**
  String get stateDried;

  /// No description provided for @kitchenOverview.
  ///
  /// In en, this message translates to:
  /// **'Kitchen overview'**
  String get kitchenOverview;

  /// No description provided for @kitchenItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String kitchenItems(int count);

  /// No description provided for @kitchenWellStocked.
  ///
  /// In en, this message translates to:
  /// **'Your pantry is well stocked.'**
  String get kitchenWellStocked;

  /// No description provided for @kitchenShoppingTrip.
  ///
  /// In en, this message translates to:
  /// **'Time for a shopping trip.'**
  String get kitchenShoppingTrip;

  /// No description provided for @kitchenEmptyOverview.
  ///
  /// In en, this message translates to:
  /// **'Add what you have at home to get started.'**
  String get kitchenEmptyOverview;

  /// No description provided for @kitchenExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get kitchenExpiringSoon;

  /// No description provided for @kitchenLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get kitchenLowStock;

  /// No description provided for @kitchenInYourKitchen.
  ///
  /// In en, this message translates to:
  /// **'In your kitchen · {count, plural, =1{1 item} other{{count} items}}'**
  String kitchenInYourKitchen(int count);

  /// No description provided for @kitchenNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get kitchenNothingHere;

  /// No description provided for @kitchenNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No ingredients match your search.'**
  String get kitchenNoMatches;

  /// No description provided for @kitchenAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get kitchenAddIngredient;

  /// No description provided for @kitchenExpiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get kitchenExpiresToday;

  /// No description provided for @kitchenExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Expires in 1 day} other{Expires in {days} days}}'**
  String kitchenExpiresIn(int days);

  /// No description provided for @kitchenExpired.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Expired 1 day ago} other{Expired {days} days ago}}'**
  String kitchenExpired(int days);

  /// No description provided for @ingredientAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get ingredientAddTitle;

  /// No description provided for @ingredientEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get ingredientEditTitle;

  /// No description provided for @ingredientStatusEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ingredientStatusEyebrow;

  /// No description provided for @ingredientNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New Stock Entry'**
  String get ingredientNewEntry;

  /// No description provided for @ingredientNewEntrySub.
  ///
  /// In en, this message translates to:
  /// **'Adding to your main inventory'**
  String get ingredientNewEntrySub;

  /// No description provided for @ingredientUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Stock'**
  String get ingredientUpdate;

  /// No description provided for @ingredientUpdateSub.
  ///
  /// In en, this message translates to:
  /// **'Editing an item in your inventory'**
  String get ingredientUpdateSub;

  /// No description provided for @ingredientName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get ingredientName;

  /// No description provided for @ingredientNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Baby spinach'**
  String get ingredientNameHint;

  /// No description provided for @ingredientCategory.
  ///
  /// In en, this message translates to:
  /// **'Category (one or more)'**
  String get ingredientCategory;

  /// No description provided for @ingredientQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity & unit'**
  String get ingredientQuantity;

  /// No description provided for @ingredientState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get ingredientState;

  /// No description provided for @ingredientDates.
  ///
  /// In en, this message translates to:
  /// **'Dates (optional)'**
  String get ingredientDates;

  /// No description provided for @ingredientPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get ingredientPurchased;

  /// No description provided for @ingredientExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get ingredientExpires;

  /// No description provided for @ingredientNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get ingredientNotSet;

  /// No description provided for @ingredientClearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear {label} date'**
  String ingredientClearDate(String label);

  /// No description provided for @ingredientLowStockAt.
  ///
  /// In en, this message translates to:
  /// **'Low-stock alert at (optional)'**
  String get ingredientLowStockAt;

  /// No description provided for @ingredientLowStockHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2'**
  String get ingredientLowStockHint;

  /// No description provided for @ingredientBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get ingredientBrand;

  /// No description provided for @ingredientBrandHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Woolworths'**
  String get ingredientBrandHint;

  /// No description provided for @ingredientNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get ingredientNotes;

  /// No description provided for @ingredientNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything to remember'**
  String get ingredientNotesHint;

  /// No description provided for @ingredientSave.
  ///
  /// In en, this message translates to:
  /// **'Save ingredient'**
  String get ingredientSave;

  /// No description provided for @ingredientSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved to My Kitchen'**
  String ingredientSaved(String name);

  /// No description provided for @ingredientMarkFinished.
  ///
  /// In en, this message translates to:
  /// **'Mark as finished'**
  String get ingredientMarkFinished;

  /// No description provided for @ingredientFinished.
  ///
  /// In en, this message translates to:
  /// **'{name} marked as finished'**
  String ingredientFinished(String name);

  /// No description provided for @ingredientRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from kitchen'**
  String get ingredientRemove;

  /// No description provided for @ingredientRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String ingredientRemoveConfirm(String name);

  /// No description provided for @ingredientRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes the item and its history. To keep a record, mark it as finished instead.'**
  String get ingredientRemoveBody;

  /// No description provided for @ingredientRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String ingredientRemoved(String name);

  /// No description provided for @errNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get errNameRequired;

  /// No description provided for @errQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity of 0 or more.'**
  String get errQuantityInvalid;

  /// No description provided for @errLowStockInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a low-stock amount of 0 or more, or leave it empty.'**
  String get errLowStockInvalid;

  /// No description provided for @errExpiryBeforePurchase.
  ///
  /// In en, this message translates to:
  /// **'The expiry date can\'t be before the purchase date.'**
  String get errExpiryBeforePurchase;

  /// No description provided for @kitchenItemSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {quantity}, {state}'**
  String kitchenItemSemantics(String name, String quantity, String state);

  /// No description provided for @notifReviewBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s a new month — a quick kitchen review keeps your inventory and recipe ideas accurate. Optional, as always.'**
  String get notifReviewBody;

  /// No description provided for @reviewEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Monthly kitchen review'**
  String get reviewEyebrow;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your kitchen'**
  String get reviewTitle;

  /// No description provided for @reviewProgress.
  ///
  /// In en, this message translates to:
  /// **'Item {current} of {total} · {name}'**
  String reviewProgress(int current, int total, String name);

  /// No description provided for @reviewCardText.
  ///
  /// In en, this message translates to:
  /// **'A few minutes now saves food and money all month.'**
  String get reviewCardText;

  /// No description provided for @reviewQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is this still in your kitchen?'**
  String get reviewQuestion;

  /// No description provided for @reviewKeep.
  ///
  /// In en, this message translates to:
  /// **'Still have it — update quantity'**
  String get reviewKeep;

  /// No description provided for @reviewUsedUp.
  ///
  /// In en, this message translates to:
  /// **'We ate it / used it up'**
  String get reviewUsedUp;

  /// No description provided for @reviewSpoiled.
  ///
  /// In en, this message translates to:
  /// **'Spoiled — remove it'**
  String get reviewSpoiled;

  /// No description provided for @reviewNoWrongAnswers.
  ///
  /// In en, this message translates to:
  /// **'No wrong answers — this just keeps your inventory honest. Spoiled food happens to everyone.'**
  String get reviewNoWrongAnswers;

  /// No description provided for @reviewAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list'**
  String get reviewAddToList;

  /// No description provided for @reviewAddPurchases.
  ///
  /// In en, this message translates to:
  /// **'Add new purchases this month'**
  String get reviewAddPurchases;

  /// No description provided for @reviewAddPurchase.
  ///
  /// In en, this message translates to:
  /// **'Add a purchase'**
  String get reviewAddPurchase;

  /// No description provided for @reviewAdded.
  ///
  /// In en, this message translates to:
  /// **'Added: {names}'**
  String reviewAdded(String names);

  /// No description provided for @reviewContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue review'**
  String get reviewContinue;

  /// No description provided for @reviewFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish review'**
  String get reviewFinish;

  /// No description provided for @reviewPreviewList.
  ///
  /// In en, this message translates to:
  /// **'Preview shopping list ({count})'**
  String reviewPreviewList(int count);

  /// No description provided for @reviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your kitchen is empty — add what you have and review it next month.'**
  String get reviewEmpty;

  /// No description provided for @reviewDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Review complete'**
  String get reviewDoneTitle;

  /// No description provided for @reviewDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your inventory is up to date. Thanks for keeping it honest.'**
  String get reviewDoneBody;

  /// No description provided for @reviewUpdateQuantity.
  ///
  /// In en, this message translates to:
  /// **'Update {name}'**
  String reviewUpdateQuantity(String name);

  /// No description provided for @reviewPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased {date}'**
  String reviewPurchased(String date);

  /// No description provided for @kitchenStartReview.
  ///
  /// In en, this message translates to:
  /// **'Start monthly review'**
  String get kitchenStartReview;

  /// No description provided for @shoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingTitle;

  /// No description provided for @shoppingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to buy} =1{1 item to buy} other{{count} items to buy}}'**
  String shoppingCount(int count);

  /// No description provided for @shoppingAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add an item…'**
  String get shoppingAddHint;

  /// No description provided for @shoppingAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get shoppingAdd;

  /// No description provided for @shoppingClearChecked.
  ///
  /// In en, this message translates to:
  /// **'Clear ticked items'**
  String get shoppingClearChecked;

  /// No description provided for @shoppingRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String shoppingRemove(String name);

  /// No description provided for @shoppingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your shopping list is empty.'**
  String get shoppingEmpty;

  /// No description provided for @settingsMonthlyReview.
  ///
  /// In en, this message translates to:
  /// **'Monthly kitchen review'**
  String get settingsMonthlyReview;

  /// No description provided for @settingsMonthlyReviewSub.
  ///
  /// In en, this message translates to:
  /// **'1st of each month at 10:00'**
  String get settingsMonthlyReviewSub;

  /// No description provided for @settingsReviewNow.
  ///
  /// In en, this message translates to:
  /// **'Review my kitchen now'**
  String get settingsReviewNow;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get mealSnacks;

  /// No description provided for @nutrientEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get nutrientEnergy;

  /// No description provided for @nutrientProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutrientProtein;

  /// No description provided for @nutrientCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get nutrientCarbs;

  /// No description provided for @nutrientFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutrientFat;

  /// No description provided for @nutrientFibre.
  ///
  /// In en, this message translates to:
  /// **'Fibre'**
  String get nutrientFibre;

  /// No description provided for @nutrientCalcium.
  ///
  /// In en, this message translates to:
  /// **'Calcium'**
  String get nutrientCalcium;

  /// No description provided for @nutrientIron.
  ///
  /// In en, this message translates to:
  /// **'Iron'**
  String get nutrientIron;

  /// No description provided for @nutrientPotassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get nutrientPotassium;

  /// No description provided for @nutrientSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get nutrientSodium;

  /// No description provided for @nutrientVitaminC.
  ///
  /// In en, this message translates to:
  /// **'Vitamin C'**
  String get nutrientVitaminC;

  /// No description provided for @nutrientEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get nutrientEstimated;

  /// No description provided for @nutrientPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get nutrientPartial;

  /// No description provided for @nutrientUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get nutrientUnavailable;

  /// No description provided for @diaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Diary'**
  String get diaryTitle;

  /// No description provided for @diaryPrevDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get diaryPrevDay;

  /// No description provided for @diaryNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get diaryNextDay;

  /// No description provided for @diarySummaryToday.
  ///
  /// In en, this message translates to:
  /// **'Today’s summary'**
  String get diarySummaryToday;

  /// No description provided for @diarySummaryDay.
  ///
  /// In en, this message translates to:
  /// **'Day summary'**
  String get diarySummaryDay;

  /// No description provided for @diaryInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About these numbers'**
  String get diaryInfoTitle;

  /// No description provided for @diaryInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Nutrition values are estimates from USDA FoodData Central and the foods you create. “Partial” means some foods you logged have no data for that nutrient; “Unavailable” means none do. MagnaVita doesn’t set targets or judge what you eat.'**
  String get diaryInfoBody;

  /// No description provided for @diaryMicros.
  ///
  /// In en, this message translates to:
  /// **'Vitamins & minerals'**
  String get diaryMicros;

  /// No description provided for @diaryMealEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet — that’s perfectly fine.'**
  String get diaryMealEmpty;

  /// No description provided for @diaryKcal.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String diaryKcal(String kcal);

  /// No description provided for @diaryEst.
  ///
  /// In en, this message translates to:
  /// **'(est.)'**
  String get diaryEst;

  /// No description provided for @diaryEntryLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, {time}, {amount}'**
  String diaryEntryLabel(String name, String time, String amount);

  /// No description provided for @diaryChangeAmount.
  ///
  /// In en, this message translates to:
  /// **'Change amount'**
  String get diaryChangeAmount;

  /// No description provided for @diaryRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get diaryRemove;

  /// No description provided for @diaryRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String diaryRemoved(String name);

  /// No description provided for @diaryAddFood.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get diaryAddFood;

  /// No description provided for @addFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFoodTitle;

  /// No description provided for @addFoodTo.
  ///
  /// In en, this message translates to:
  /// **'to {meal} · {date}'**
  String addFoodTo(String meal, String date);

  /// No description provided for @addFoodDatabase.
  ///
  /// In en, this message translates to:
  /// **'Food database'**
  String get addFoodDatabase;

  /// No description provided for @addFoodSearch.
  ///
  /// In en, this message translates to:
  /// **'Search foods…'**
  String get addFoodSearch;

  /// No description provided for @addFoodSource.
  ///
  /// In en, this message translates to:
  /// **'USDA FoodData Central & Open Food Facts · values are estimates'**
  String get addFoodSource;

  /// No description provided for @addFoodLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading foods…'**
  String get addFoodLoading;

  /// No description provided for @addFoodRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get addFoodRecent;

  /// No description provided for @addFoodSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get addFoodSaved;

  /// No description provided for @addFoodResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get addFoodResults;

  /// No description provided for @addFoodNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No foods match “{query}”. You can create your own.'**
  String addFoodNoMatch(String query);

  /// No description provided for @addFoodPer100.
  ///
  /// In en, this message translates to:
  /// **'100 g · {kcal} kcal · {protein} g protein (est.)'**
  String addFoodPer100(String kcal, String protein);

  /// No description provided for @addFoodNoData.
  ///
  /// In en, this message translates to:
  /// **'Nutrition unavailable'**
  String get addFoodNoData;

  /// No description provided for @addFoodYours.
  ///
  /// In en, this message translates to:
  /// **'Your food'**
  String get addFoodYours;

  /// No description provided for @addFoodSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected item'**
  String get addFoodSelected;

  /// No description provided for @addFoodClear.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get addFoodClear;

  /// No description provided for @addFoodLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get addFoodLess;

  /// No description provided for @addFoodMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get addFoodMore;

  /// No description provided for @addFoodAbout.
  ///
  /// In en, this message translates to:
  /// **'≈ {kcal} kcal (est.)'**
  String addFoodAbout(String kcal);

  /// No description provided for @addFoodMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get addFoodMeal;

  /// No description provided for @addFoodTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get addFoodTime;

  /// No description provided for @addFoodAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String addFoodAddTo(String meal);

  /// No description provided for @addFoodAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added to {meal}'**
  String addFoodAdded(String name, String meal);

  /// No description provided for @addFoodSave.
  ///
  /// In en, this message translates to:
  /// **'Save to favourites'**
  String get addFoodSave;

  /// No description provided for @addFoodUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get addFoodUnsave;

  /// No description provided for @addFoodCreate.
  ///
  /// In en, this message translates to:
  /// **'Create custom food'**
  String get addFoodCreate;

  /// No description provided for @customTitle.
  ///
  /// In en, this message translates to:
  /// **'Your own food'**
  String get customTitle;

  /// No description provided for @customName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get customName;

  /// No description provided for @customServing.
  ///
  /// In en, this message translates to:
  /// **'Serving size'**
  String get customServing;

  /// No description provided for @customPerServing.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per serving · optional'**
  String get customPerServing;

  /// No description provided for @customHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank anything you don’t know — it will show as unavailable, never as zero.'**
  String get customHint;

  /// No description provided for @customSave.
  ///
  /// In en, this message translates to:
  /// **'Save and select'**
  String get customSave;

  /// No description provided for @customNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get customNameRequired;

  /// No description provided for @customServingRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a serving size in grams.'**
  String get customServingRequired;

  /// No description provided for @customServingLabel.
  ///
  /// In en, this message translates to:
  /// **'1 serving'**
  String get customServingLabel;

  /// No description provided for @settingsFoodData.
  ///
  /// In en, this message translates to:
  /// **'Food data'**
  String get settingsFoodData;

  /// No description provided for @settingsFoodDataSub.
  ///
  /// In en, this message translates to:
  /// **'Foods: USDA FoodData Central, SR Legacy (public domain). Scanned packaged foods: Open Food Facts (Open Database Licence). Values are estimates.'**
  String get settingsFoodDataSub;

  /// No description provided for @diaryRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get diaryRecipes;

  /// No description provided for @diaryRecipesSub.
  ///
  /// In en, this message translates to:
  /// **'What you can make'**
  String get diaryRecipesSub;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

  /// No description provided for @recipesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Smart recipe planner'**
  String get recipesEyebrow;

  /// No description provided for @recipesHero.
  ///
  /// In en, this message translates to:
  /// **'What you can make'**
  String get recipesHero;

  /// No description provided for @recipesHeroSub.
  ///
  /// In en, this message translates to:
  /// **'{items} in your kitchen · {found}'**
  String recipesHeroSub(String items, String found);

  /// No description provided for @recipesFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no matches yet} =1{1 recipe found} other{{count} recipes found}}'**
  String recipesFound(int count);

  /// No description provided for @recipesTagline.
  ///
  /// In en, this message translates to:
  /// **'Built from what you already have — less waste, less stress.'**
  String get recipesTagline;

  /// No description provided for @recipesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search recipes by name…'**
  String get recipesSearch;

  /// No description provided for @recipesShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get recipesShow;

  /// No description provided for @recipesShowAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get recipesShowAll;

  /// No description provided for @recipesShowReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to cook'**
  String get recipesShowReady;

  /// No description provided for @recipesShowExpiring.
  ///
  /// In en, this message translates to:
  /// **'Uses expiring items'**
  String get recipesShowExpiring;

  /// No description provided for @recipesShowSaved.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get recipesShowSaved;

  /// No description provided for @recipesDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get recipesDiet;

  /// No description provided for @recipesDietAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get recipesDietAny;

  /// No description provided for @recipesAllergyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Ingredient lists can’t guarantee a recipe is free from allergens or cross-contamination — always check labels.'**
  String get recipesAllergyGeneric;

  /// No description provided for @recipesPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Recipes come from TheMealDB online. Only ingredient names and search words are sent.'**
  String get recipesPrivacy;

  /// No description provided for @recipesEmptyKitchen.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients to My Kitchen and MagnaVita will suggest what you can make. You can still search by name.'**
  String get recipesEmptyKitchen;

  /// No description provided for @recipesNone.
  ///
  /// In en, this message translates to:
  /// **'No recipes match these filters.'**
  String get recipesNone;

  /// No description provided for @recipesOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t reach the recipe catalogue. Check your connection and try again.'**
  String get recipesOffline;

  /// No description provided for @recipesRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get recipesRetry;

  /// No description provided for @recipesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{have} of {total} ingredients available'**
  String recipesAvailable(int have, int total);

  /// No description provided for @recipesUsesExpiring.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Uses 1 item expiring soon} other{Uses {count} items expiring soon}}'**
  String recipesUsesExpiring(int count);

  /// No description provided for @recipesSave.
  ///
  /// In en, this message translates to:
  /// **'Save to favourites'**
  String get recipesSave;

  /// No description provided for @recipesUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get recipesUnsave;

  /// No description provided for @recipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredients;

  /// No description provided for @recipeTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String recipeTotal(int count);

  /// No description provided for @recipeAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get recipeAvailable;

  /// No description provided for @recipeMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get recipeMissing;

  /// No description provided for @recipeSubstitute.
  ///
  /// In en, this message translates to:
  /// **'Substitute: {missing} → {have} (you have it)'**
  String recipeSubstitute(String missing, String have);

  /// No description provided for @recipeBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch size'**
  String get recipeBatch;

  /// No description provided for @recipeBatchHint.
  ///
  /// In en, this message translates to:
  /// **'Amounts are scaled from the original recipe. The catalogue doesn’t list servings or cooking times.'**
  String get recipeBatchHint;

  /// No description provided for @recipeSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get recipeSteps;

  /// No description provided for @recipeNutrition.
  ///
  /// In en, this message translates to:
  /// **'Estimated nutrition'**
  String get recipeNutrition;

  /// No description provided for @recipeNutritionNone.
  ///
  /// In en, this message translates to:
  /// **'Nutrition isn’t available for this recipe, so diary entries show it as unavailable.'**
  String get recipeNutritionNone;

  /// No description provided for @recipeMarkCooked.
  ///
  /// In en, this message translates to:
  /// **'Mark as cooked'**
  String get recipeMarkCooked;

  /// No description provided for @recipeCooked.
  ///
  /// In en, this message translates to:
  /// **'Marked as cooked. Update quantities in My Kitchen if you used things up.'**
  String get recipeCooked;

  /// No description provided for @recipeLog.
  ///
  /// In en, this message translates to:
  /// **'Log to Food Diary'**
  String get recipeLog;

  /// No description provided for @recipeLogWhich.
  ///
  /// In en, this message translates to:
  /// **'Which meal?'**
  String get recipeLogWhich;

  /// No description provided for @recipeLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged to {meal}'**
  String recipeLogged(String meal);

  /// No description provided for @recipeAlreadyLogged.
  ///
  /// In en, this message translates to:
  /// **'Already in today’s {meal}'**
  String recipeAlreadyLogged(String meal);

  /// No description provided for @recipeServing.
  ///
  /// In en, this message translates to:
  /// **'1 serving'**
  String get recipeServing;

  /// No description provided for @recipeAddMissing.
  ///
  /// In en, this message translates to:
  /// **'Add missing to shopping list'**
  String get recipeAddMissing;

  /// No description provided for @recipeAddedMissing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Already on your shopping list} =1{1 item added to your shopping list} other{{count} items added to your shopping list}}'**
  String recipeAddedMissing(int count);

  /// No description provided for @recipeSource.
  ///
  /// In en, this message translates to:
  /// **'Recipe from TheMealDB'**
  String get recipeSource;

  /// No description provided for @recipeNotFound.
  ///
  /// In en, this message translates to:
  /// **'This recipe couldn’t be loaded. Check your connection and try again.'**
  String get recipeNotFound;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the barcode on the pack. Product data comes from Open Food Facts.'**
  String get scanHint;

  /// No description provided for @scanType.
  ///
  /// In en, this message translates to:
  /// **'Type the barcode instead'**
  String get scanType;

  /// No description provided for @scanNumber.
  ///
  /// In en, this message translates to:
  /// **'Barcode number'**
  String get scanNumber;

  /// No description provided for @scanLookUp.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get scanLookUp;

  /// No description provided for @scanInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 8–14 digits under the barcode.'**
  String get scanInvalid;

  /// No description provided for @scanTorch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get scanTorch;

  /// No description provided for @scanLooking.
  ///
  /// In en, this message translates to:
  /// **'Looking up the product…'**
  String get scanLooking;

  /// No description provided for @scanCameraError.
  ///
  /// In en, this message translates to:
  /// **'The camera isn’t available. You can type the barcode instead.'**
  String get scanCameraError;

  /// No description provided for @scanNotFound.
  ///
  /// In en, this message translates to:
  /// **'{code} isn’t in Open Food Facts yet — add it from the label.'**
  String scanNotFound(String code);

  /// No description provided for @scanOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t look up the barcode. Check your connection and try again.'**
  String get scanOffline;

  /// No description provided for @scanAddFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode {code}. Copy the values from the nutrition label; next time the scan will find it.'**
  String scanAddFromLabel(String code);

  /// No description provided for @foodPack.
  ///
  /// In en, this message translates to:
  /// **'Whole pack'**
  String get foodPack;

  /// No description provided for @foodPackaged.
  ///
  /// In en, this message translates to:
  /// **'Packaged food'**
  String get foodPackaged;

  /// No description provided for @addFoodPer100ml.
  ///
  /// In en, this message translates to:
  /// **'100 ml · {kcal} kcal · {protein} g protein (est.)'**
  String addFoodPer100ml(String kcal, String protein);

  /// No description provided for @customGrams.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get customGrams;

  /// No description provided for @customMl.
  ///
  /// In en, this message translates to:
  /// **'Millilitres'**
  String get customMl;

  /// No description provided for @logHow.
  ///
  /// In en, this message translates to:
  /// **'How do you want to log it?'**
  String get logHow;

  /// No description provided for @logSearch.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get logSearch;

  /// No description provided for @logSearchSub.
  ///
  /// In en, this message translates to:
  /// **'Food database, recent and favourites'**
  String get logSearchSub;

  /// No description provided for @logScanSub.
  ///
  /// In en, this message translates to:
  /// **'Packaged foods and drinks'**
  String get logScanSub;

  /// No description provided for @logPhotoSub.
  ///
  /// In en, this message translates to:
  /// **'AI estimate from a photo — you check it first'**
  String get logPhotoSub;

  /// No description provided for @photoTitle.
  ///
  /// In en, this message translates to:
  /// **'Snap a meal photo'**
  String get photoTitle;

  /// No description provided for @photoYourPhoto.
  ///
  /// In en, this message translates to:
  /// **'Your meal photo'**
  String get photoYourPhoto;

  /// No description provided for @photoEstimating.
  ///
  /// In en, this message translates to:
  /// **'Estimating what’s on the plate…'**
  String get photoEstimating;

  /// No description provided for @photoCheck.
  ///
  /// In en, this message translates to:
  /// **'AI estimate — check every item before adding. Rename anything it got wrong and adjust the amounts. Photo estimates are often 20–40% off, especially for oil, sauces and hidden ingredients.'**
  String get photoCheck;

  /// No description provided for @photoItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item found} other{{count} items found}}'**
  String photoItems(int count);

  /// No description provided for @photoRename.
  ///
  /// In en, this message translates to:
  /// **'Rename {name}'**
  String photoRename(String name);

  /// No description provided for @photoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String photoRemove(String name);

  /// No description provided for @photoAdd.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 item to {meal}} other{Add {count} items to {meal}}}'**
  String photoAdd(int count, String meal);

  /// No description provided for @photoLogged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item added to {meal}} other{{count} items added to {meal}}}'**
  String photoLogged(int count, String meal);

  /// No description provided for @photoLabel.
  ///
  /// In en, this message translates to:
  /// **'photo estimate'**
  String get photoLabel;

  /// No description provided for @photoTake.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get photoTake;

  /// No description provided for @photoRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get photoRetake;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoGallery;

  /// No description provided for @photoNotFood.
  ///
  /// In en, this message translates to:
  /// **'No food was recognised in that photo. Try again with the whole plate in view.'**
  String get photoNotFood;

  /// No description provided for @photoNoKey.
  ///
  /// In en, this message translates to:
  /// **'Meal photos need a Gemini API key. Add one in Settings → Meal photo estimates.'**
  String get photoNoKey;

  /// No description provided for @photoKeyError.
  ///
  /// In en, this message translates to:
  /// **'Gemini didn’t accept the API key. Check it in Settings → Meal photo estimates.'**
  String get photoKeyError;

  /// No description provided for @photoOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t reach Gemini. Check your connection and try again.'**
  String get photoOffline;

  /// No description provided for @photoCameraError.
  ///
  /// In en, this message translates to:
  /// **'The camera isn’t available. Try choosing a photo from the gallery.'**
  String get photoCameraError;

  /// No description provided for @settingsPhotoKey.
  ///
  /// In en, this message translates to:
  /// **'Meal photo estimates'**
  String get settingsPhotoKey;

  /// No description provided for @settingsPhotoKeyNone.
  ///
  /// In en, this message translates to:
  /// **'No key'**
  String get settingsPhotoKeyNone;

  /// No description provided for @settingsPhotoKeyOwn.
  ///
  /// In en, this message translates to:
  /// **'Your key'**
  String get settingsPhotoKeyOwn;

  /// No description provided for @settingsPhotoKeyBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in key'**
  String get settingsPhotoKeyBuiltIn;

  /// No description provided for @settingsPhotoKeyBody.
  ///
  /// In en, this message translates to:
  /// **'Meal photos are estimated by Google Gemini using an API key. Paste your own key to use it instead of the built-in one; it’s stored only on this phone.'**
  String get settingsPhotoKeyBody;

  /// No description provided for @settingsPhotoKeyField.
  ///
  /// In en, this message translates to:
  /// **'Gemini API key'**
  String get settingsPhotoKeyField;

  /// No description provided for @settingsPhotoKeyClear.
  ///
  /// In en, this message translates to:
  /// **'Remove my key'**
  String get settingsPhotoKeyClear;

  /// No description provided for @bodyStats.
  ///
  /// In en, this message translates to:
  /// **'Your stats'**
  String get bodyStats;

  /// No description provided for @bodyHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get bodyHeight;

  /// No description provided for @bodyAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get bodyAge;

  /// No description provided for @bodySex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get bodySex;

  /// No description provided for @bodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get bodyWeight;

  /// No description provided for @bodyNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get bodyNotSet;

  /// No description provided for @bodyUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update stats'**
  String get bodyUpdate;

  /// No description provided for @bodyFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get bodyFemale;

  /// No description provided for @bodyMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get bodyMale;

  /// No description provided for @bodySexNone.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get bodySexNone;

  /// No description provided for @bodySexHint.
  ///
  /// In en, this message translates to:
  /// **'Only used in the body-fat formulas.'**
  String get bodySexHint;

  /// No description provided for @bodyAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String bodyAgeYears(int age);

  /// No description provided for @bodyOptional.
  ///
  /// In en, this message translates to:
  /// **'Everything here is optional and stays on this phone.'**
  String get bodyOptional;

  /// No description provided for @bodyTape.
  ///
  /// In en, this message translates to:
  /// **'Tape measurements · optional'**
  String get bodyTape;

  /// No description provided for @bodyTapeHint.
  ///
  /// In en, this message translates to:
  /// **'Waist at the navel, neck just below the Adam’s apple, hips at the widest point. They give a better body-fat estimate than BMI alone.'**
  String get bodyTapeHint;

  /// No description provided for @bodyWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get bodyWaist;

  /// No description provided for @bodyNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get bodyNeck;

  /// No description provided for @bodyHip.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get bodyHip;

  /// No description provided for @bodyFeet.
  ///
  /// In en, this message translates to:
  /// **'Height (ft)'**
  String get bodyFeet;

  /// No description provided for @bodyInches.
  ///
  /// In en, this message translates to:
  /// **'(in)'**
  String get bodyInches;

  /// No description provided for @bodyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please check the numbers — they look out of range.'**
  String get bodyInvalid;

  /// No description provided for @bodyNumbers.
  ///
  /// In en, this message translates to:
  /// **'Your numbers'**
  String get bodyNumbers;

  /// No description provided for @bodyBmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bodyBmi;

  /// No description provided for @bmiUnder.
  ///
  /// In en, this message translates to:
  /// **'Below the healthy range'**
  String get bmiUnder;

  /// No description provided for @bmiHealthy.
  ///
  /// In en, this message translates to:
  /// **'Within the healthy range'**
  String get bmiHealthy;

  /// No description provided for @bmiOver.
  ///
  /// In en, this message translates to:
  /// **'Above the healthy range'**
  String get bmiOver;

  /// No description provided for @bmiObese.
  ///
  /// In en, this message translates to:
  /// **'Well above the healthy range'**
  String get bmiObese;

  /// No description provided for @bodyRange.
  ///
  /// In en, this message translates to:
  /// **'Healthy range for your height: {low} – {high}'**
  String bodyRange(String low, String high);

  /// No description provided for @bodyLose.
  ///
  /// In en, this message translates to:
  /// **'To reach it: lose about {amount}'**
  String bodyLose(String amount);

  /// No description provided for @bodyGain.
  ///
  /// In en, this message translates to:
  /// **'To reach it: gain about {amount}'**
  String bodyGain(String amount);

  /// No description provided for @bodyInRange.
  ///
  /// In en, this message translates to:
  /// **'You’re within it.'**
  String get bodyInRange;

  /// No description provided for @bodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat (estimate)'**
  String get bodyFat;

  /// No description provided for @bodyFatTape.
  ///
  /// In en, this message translates to:
  /// **'From your tape measurements (US Navy method) · about ±3%'**
  String get bodyFatTape;

  /// No description provided for @bodyFatBmi.
  ///
  /// In en, this message translates to:
  /// **'Rough, from BMI · add tape measurements for a better estimate'**
  String get bodyFatBmi;

  /// No description provided for @bodyFatNeeds.
  ///
  /// In en, this message translates to:
  /// **'Add your age and sex for an estimate.'**
  String get bodyFatNeeds;

  /// No description provided for @bodyUnder18.
  ///
  /// In en, this message translates to:
  /// **'Adult BMI categories and weight targets don’t apply under 18 — growth charts do. A doctor or nurse can help you make sense of these numbers.'**
  String get bodyUnder18;

  /// No description provided for @bodyNeedStats.
  ///
  /// In en, this message translates to:
  /// **'Add your height and weight to see your BMI and healthy weight range.'**
  String get bodyNeedStats;

  /// No description provided for @bodyAboutBmi.
  ///
  /// In en, this message translates to:
  /// **'About BMI'**
  String get bodyAboutBmi;

  /// No description provided for @bodyAboutBmiBody.
  ///
  /// In en, this message translates to:
  /// **'BMI compares weight with height. It’s a quick screening number, not a diagnosis: it can’t tell muscle from fat, and it reads differently for athletes, older adults, pregnancy and some ethnic groups. Body-fat estimates can be several percent off. Treat these numbers as one signal among many — MagnaVita never sets calorie targets from BMI alone, and a healthcare professional can help you interpret them.'**
  String get bodyAboutBmiBody;

  /// No description provided for @energyBmr.
  ///
  /// In en, this message translates to:
  /// **'Resting energy (BMR)'**
  String get energyBmr;

  /// No description provided for @energyKcalDay.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal a day'**
  String energyKcalDay(String kcal);

  /// No description provided for @energyBmrSub.
  ///
  /// In en, this message translates to:
  /// **'What your body uses at rest — breathing, heartbeat, staying warm. Estimated from your weight, height, age and sex (Mifflin-St Jeor, about ±10%).'**
  String get energyBmrSub;

  /// No description provided for @energyNeeds.
  ///
  /// In en, this message translates to:
  /// **'Add your height, weight, age and sex to see your resting energy.'**
  String get energyNeeds;

  /// No description provided for @energyMaintain.
  ///
  /// In en, this message translates to:
  /// **'Calories to keep your weight steady'**
  String get energyMaintain;

  /// No description provided for @energyLevel.
  ///
  /// In en, this message translates to:
  /// **'How active you are'**
  String get energyLevel;

  /// No description provided for @energyMeasured.
  ///
  /// In en, this message translates to:
  /// **'Worked out from {days} days of your activities and steps · about {kcal} active kcal a day'**
  String energyMeasured(int days, String kcal);

  /// No description provided for @energyChosen.
  ///
  /// In en, this message translates to:
  /// **'The level you chose. After {days} days of activities or steps, MagnaVita works it out from your records.'**
  String energyChosen(int days);

  /// No description provided for @energyPickLevel.
  ///
  /// In en, this message translates to:
  /// **'How active are you on a usual day?'**
  String get energyPickLevel;

  /// No description provided for @levelSedentary.
  ///
  /// In en, this message translates to:
  /// **'Mostly sitting'**
  String get levelSedentary;

  /// No description provided for @levelLight.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get levelLight;

  /// No description provided for @levelModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get levelModerate;

  /// No description provided for @levelActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get levelActive;

  /// No description provided for @levelVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get levelVeryActive;

  /// No description provided for @levelSedentarySub.
  ///
  /// In en, this message translates to:
  /// **'Desk work, little walking'**
  String get levelSedentarySub;

  /// No description provided for @levelLightSub.
  ///
  /// In en, this message translates to:
  /// **'Some walking, light exercise 1–3 days a week'**
  String get levelLightSub;

  /// No description provided for @levelModerateSub.
  ///
  /// In en, this message translates to:
  /// **'On your feet a lot, or exercise 3–5 days a week'**
  String get levelModerateSub;

  /// No description provided for @levelActiveSub.
  ///
  /// In en, this message translates to:
  /// **'Hard exercise 6–7 days a week'**
  String get levelActiveSub;

  /// No description provided for @levelVeryActiveSub.
  ///
  /// In en, this message translates to:
  /// **'Physical job plus daily training'**
  String get levelVeryActiveSub;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weight goal'**
  String get goalTitle;

  /// No description provided for @goalSet.
  ///
  /// In en, this message translates to:
  /// **'Set a goal weight'**
  String get goalSet;

  /// No description provided for @goalEdit.
  ///
  /// In en, this message translates to:
  /// **'Change goal'**
  String get goalEdit;

  /// No description provided for @goalRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove goal'**
  String get goalRemove;

  /// No description provided for @goalWeight.
  ///
  /// In en, this message translates to:
  /// **'Goal weight ({unit})'**
  String goalWeight(String unit);

  /// No description provided for @goalPace.
  ///
  /// In en, this message translates to:
  /// **'How fast'**
  String get goalPace;

  /// No description provided for @goalPacePerWeek.
  ///
  /// In en, this message translates to:
  /// **'{amount} a week'**
  String goalPacePerWeek(String amount);

  /// No description provided for @goalTooLow.
  ///
  /// In en, this message translates to:
  /// **'That’s below the healthy range for your height. The lowest goal MagnaVita sets is {min}.'**
  String goalTooLow(String min);

  /// No description provided for @goalSummary.
  ///
  /// In en, this message translates to:
  /// **'{goal} at {pace} a week'**
  String goalSummary(String goal, String pace);

  /// No description provided for @goalEatLose.
  ///
  /// In en, this message translates to:
  /// **'Eat about {kcal} kcal a day to lose about {amount} a week'**
  String goalEatLose(String kcal, String amount);

  /// No description provided for @goalEatGain.
  ///
  /// In en, this message translates to:
  /// **'Eat about {kcal} kcal a day to gain about {amount} a week'**
  String goalEatGain(String kcal, String amount);

  /// No description provided for @goalEatMaintain.
  ///
  /// In en, this message translates to:
  /// **'You’re at your goal. About {kcal} kcal a day keeps you there.'**
  String goalEatMaintain(String kcal);

  /// No description provided for @goalLimited.
  ///
  /// In en, this message translates to:
  /// **'Kept at your safe minimum of {kcal} kcal a day — never below your resting energy, or 1,200 (women) / 1,500 (men). Moving more is a safer way to go faster.'**
  String goalLimited(String kcal);

  /// No description provided for @goalGainCapped.
  ///
  /// In en, this message translates to:
  /// **'Gaining is limited to {amount} a week so it’s mostly muscle, not fat.'**
  String goalGainCapped(String amount);

  /// No description provided for @goalNeedsEnergy.
  ///
  /// In en, this message translates to:
  /// **'Choose how active you are above to get a calorie target.'**
  String get goalNeedsEnergy;

  /// No description provided for @goalEstimate.
  ///
  /// In en, this message translates to:
  /// **'An estimate. Bodies adapt, so check your weigh-ins every few weeks and adjust. If you’re pregnant, breastfeeding, have a medical condition or a history of disordered eating, talk to a healthcare professional first.'**
  String get goalEstimate;

  /// No description provided for @forecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight forecast'**
  String get forecastTitle;

  /// No description provided for @forecastIn.
  ///
  /// In en, this message translates to:
  /// **'In {weeks} weeks: about {weight}'**
  String forecastIn(int weeks, String weight);

  /// No description provided for @forecastReach.
  ///
  /// In en, this message translates to:
  /// **'Reaches {goal} around {date}'**
  String forecastReach(String goal, String date);

  /// No description provided for @forecastNotReached.
  ///
  /// In en, this message translates to:
  /// **'{goal} isn’t reached in this time at this pace.'**
  String forecastNotReached(String goal);

  /// No description provided for @forecastChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight forecast: from {start} today to about {end} in {weeks} weeks'**
  String forecastChartLabel(String start, int weeks, String end);

  /// No description provided for @forecastPast.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get forecastPast;

  /// No description provided for @forecastToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get forecastToday;

  /// No description provided for @forecastAhead.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ahead'**
  String forecastAhead(int weeks);

  /// No description provided for @forecastFromDiary.
  ///
  /// In en, this message translates to:
  /// **'Based on what your food diary shows (about {kcal} kcal a day over the last 2 weeks) and your activity.'**
  String forecastFromDiary(String kcal);

  /// No description provided for @forecastFromTarget.
  ///
  /// In en, this message translates to:
  /// **'Based on eating your target of {kcal} kcal a day with your current activity. Log your meals on most days to forecast from what you actually eat.'**
  String forecastFromTarget(String kcal);

  /// No description provided for @forecastFromMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Based on eating about {kcal} kcal a day with your current activity. Set a goal or log your meals for a more useful forecast.'**
  String forecastFromMaintenance(String kcal);

  /// No description provided for @forecastEstimate.
  ///
  /// In en, this message translates to:
  /// **'A projection, not a promise: water, hormones and how your body adapts all move the scale.'**
  String get forecastEstimate;

  /// No description provided for @authCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authCreateTitle;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authSignInTitle;

  /// No description provided for @authWhy.
  ///
  /// In en, this message translates to:
  /// **'Your account keeps your profile and goals safe, so signing in on a new phone brings them back. Your diary, kitchen and workouts stay on this phone.'**
  String get authWhy;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authCreate.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreate;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authHaveAccount;

  /// No description provided for @authNeedAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authNeedAccount;

  /// No description provided for @authSkip.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get authSkip;

  /// No description provided for @authSkipSub.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone only. You can sign in later in Profile → Account.'**
  String get authSkipSub;

  /// No description provided for @authNameNeeded.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get authNameNeeded;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least {count} characters.'**
  String authPasswordShort(int count);

  /// No description provided for @authWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That email and password don’t match.'**
  String get authWrongPassword;

  /// No description provided for @authEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'There’s already an account with that email — sign in instead.'**
  String get authEmailTaken;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'That password is too easy to guess. Try a longer one.'**
  String get authWeakPassword;

  /// No description provided for @authNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email first. We’ve sent you a new code.'**
  String get authNotConfirmed;

  /// No description provided for @authOffline.
  ///
  /// In en, this message translates to:
  /// **'You’re offline. Connect to the internet and try again.'**
  String get authOffline;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authFailed;

  /// No description provided for @authConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authConfirmTitle;

  /// No description provided for @authConfirmIntro.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {email}. Enter it here to confirm your account.'**
  String authConfirmIntro(String email);

  /// No description provided for @authCode.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get authCode;

  /// No description provided for @authCodeFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from the email (numbers only).'**
  String get authCodeFormat;

  /// No description provided for @authCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is wrong or has expired. Check the latest email, or send a new code.'**
  String get authCodeInvalid;

  /// No description provided for @authCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {email}.'**
  String authCodeSent(String email);

  /// No description provided for @authCodeResent.
  ///
  /// In en, this message translates to:
  /// **'A new code is on its way to {email}.'**
  String authCodeResent(String email);

  /// No description provided for @authConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get authConfirm;

  /// No description provided for @authResend.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get authResend;

  /// No description provided for @authCheckSpam.
  ///
  /// In en, this message translates to:
  /// **'Can’t find it? Check your spam or promotions folder.'**
  String get authCheckSpam;

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// No description provided for @authForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgot;

  /// No description provided for @authForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authForgotTitle;

  /// No description provided for @authForgotIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your account’s email and we’ll send you a code.'**
  String get authForgotIntro;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get authResetTitle;

  /// No description provided for @authResetIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent to {email} and a new password.'**
  String authResetIntro(String email);

  /// No description provided for @authResetSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {email}.'**
  String authResetSent(String email);

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authResetSave.
  ///
  /// In en, this message translates to:
  /// **'Save and sign in'**
  String get authResetSave;

  /// No description provided for @authTooManyEmails.
  ///
  /// In en, this message translates to:
  /// **'Too many emails were sent just now. Wait a minute, then try again.'**
  String get authTooManyEmails;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @accountSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in · profile and goals saved to your account'**
  String get accountSignedIn;

  /// No description provided for @accountSignInOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account'**
  String get accountSignInOrCreate;

  /// No description provided for @accountLocalSub.
  ///
  /// In en, this message translates to:
  /// **'Keep your profile and goals safe if you change phones'**
  String get accountLocalSub;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get accountSignOutTitle;

  /// No description provided for @accountSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Everything on this phone stays. Sign in again any time.'**
  String get accountSignOutBody;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get accountDelete;

  /// No description provided for @accountDeleteSub.
  ///
  /// In en, this message translates to:
  /// **'Removes your account and the profile saved in it'**
  String get accountDeleteSub;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your account and the profile and goals saved in it are deleted for good. What’s on this phone stays; use “Delete all data” to remove that too.'**
  String get accountDeleteBody;

  /// No description provided for @goalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get goalLoseWeight;

  /// No description provided for @goalLoseWeightSub.
  ///
  /// In en, this message translates to:
  /// **'Steadily, at a pace you choose'**
  String get goalLoseWeightSub;

  /// No description provided for @goalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Stay where I am'**
  String get goalMaintain;

  /// No description provided for @goalMaintainSub.
  ///
  /// In en, this message translates to:
  /// **'Keep my weight steady and eat well'**
  String get goalMaintainSub;

  /// No description provided for @goalBuildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get goalBuildMuscle;

  /// No description provided for @goalBuildMuscleSub.
  ///
  /// In en, this message translates to:
  /// **'Get stronger and add muscle'**
  String get goalBuildMuscleSub;

  /// No description provided for @goalGetFitter.
  ///
  /// In en, this message translates to:
  /// **'Get fitter'**
  String get goalGetFitter;

  /// No description provided for @goalGetFitterSub.
  ///
  /// In en, this message translates to:
  /// **'More energy, steps and stamina'**
  String get goalGetFitterSub;

  /// No description provided for @goalFasting.
  ///
  /// In en, this message translates to:
  /// **'Better fasting habits'**
  String get goalFasting;

  /// No description provided for @goalFastingSub.
  ///
  /// In en, this message translates to:
  /// **'A calm, regular eating window'**
  String get goalFastingSub;

  /// No description provided for @setupStep.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String setupStep(int n, int total);

  /// No description provided for @setupSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get setupSkip;

  /// No description provided for @setupBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get setupBack;

  /// No description provided for @setupFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get setupFinish;

  /// No description provided for @setupOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get setupOptional;

  /// No description provided for @setupAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get setupAboutTitle;

  /// No description provided for @setupAboutSub.
  ///
  /// In en, this message translates to:
  /// **'So the numbers MagnaVita shows fit you. Leave out anything you’d rather not share.'**
  String get setupAboutSub;

  /// No description provided for @setupSexWhy.
  ///
  /// In en, this message translates to:
  /// **'Used for resting energy and body-fat estimates only.'**
  String get setupSexWhy;

  /// No description provided for @setupBirthYear.
  ///
  /// In en, this message translates to:
  /// **'Year of birth'**
  String get setupBirthYear;

  /// No description provided for @setupYearInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please check the year — MagnaVita’s goals are for people 18 and over.'**
  String get setupYearInvalid;

  /// No description provided for @setupWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weight today'**
  String get setupWeightTitle;

  /// No description provided for @setupWeightSub.
  ///
  /// In en, this message translates to:
  /// **'Your starting point. It stays private, and you can turn weight tracking off later.'**
  String get setupWeightSub;

  /// No description provided for @setupGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What’s your main goal?'**
  String get setupGoalTitle;

  /// No description provided for @setupGoalSub.
  ///
  /// In en, this message translates to:
  /// **'Your Activity and Home pages are arranged around it. Change it any time in Profile.'**
  String get setupGoalSub;

  /// No description provided for @setupGoalSafety.
  ///
  /// In en, this message translates to:
  /// **'MagnaVita never suggests a goal below a healthy weight for your height, or eating less than your body needs at rest.'**
  String get setupGoalSafety;

  /// No description provided for @setupActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'How active are you?'**
  String get setupActivityTitle;

  /// No description provided for @setupActivitySub.
  ///
  /// In en, this message translates to:
  /// **'On a usual day, before any changes.'**
  String get setupActivitySub;

  /// No description provided for @setupActivityLater.
  ///
  /// In en, this message translates to:
  /// **'After a week of logged activities or steps, MagnaVita works this out from your records instead.'**
  String get setupActivityLater;

  /// No description provided for @setupMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'How many meals a day?'**
  String get setupMealsTitle;

  /// No description provided for @setupMealsSub.
  ///
  /// In en, this message translates to:
  /// **'Snacks count if they’re proper meals for you.'**
  String get setupMealsSub;

  /// No description provided for @setupMealsN.
  ///
  /// In en, this message translates to:
  /// **'{n} meals'**
  String setupMealsN(int n);

  /// No description provided for @setupMealsFivePlus.
  ///
  /// In en, this message translates to:
  /// **'5 or more'**
  String get setupMealsFivePlus;

  /// No description provided for @setupMealsWhy.
  ///
  /// In en, this message translates to:
  /// **'Used to split your daily calories into a guide for each meal.'**
  String get setupMealsWhy;

  /// No description provided for @setupTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you train?'**
  String get setupTrainingTitle;

  /// No description provided for @setupTrainingSub.
  ///
  /// In en, this message translates to:
  /// **'Workouts like the gym, home exercise or classes.'**
  String get setupTrainingSub;

  /// No description provided for @setupTrainingDays.
  ///
  /// In en, this message translates to:
  /// **'Days a week'**
  String get setupTrainingDays;

  /// No description provided for @setupNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get setupNotYet;

  /// No description provided for @setupDietTitle.
  ///
  /// In en, this message translates to:
  /// **'Food preferences'**
  String get setupDietTitle;

  /// No description provided for @setupDietSub.
  ///
  /// In en, this message translates to:
  /// **'Recipes with your allergens are never suggested.'**
  String get setupDietSub;

  /// No description provided for @focusYourGoal.
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get focusYourGoal;

  /// No description provided for @focusLoseTitle.
  ///
  /// In en, this message translates to:
  /// **'Today, toward your goal weight'**
  String get focusLoseTitle;

  /// No description provided for @focusMaintainTitle.
  ///
  /// In en, this message translates to:
  /// **'Today, keeping steady'**
  String get focusMaintainTitle;

  /// No description provided for @focusMuscleTitle.
  ///
  /// In en, this message translates to:
  /// **'Building muscle'**
  String get focusMuscleTitle;

  /// No description provided for @focusFitterTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting fitter'**
  String get focusFitterTitle;

  /// No description provided for @focusEaten.
  ///
  /// In en, this message translates to:
  /// **'Eaten'**
  String get focusEaten;

  /// No description provided for @focusBurned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get focusBurned;

  /// No description provided for @focusSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get focusSteps;

  /// No description provided for @focusEstimate.
  ///
  /// In en, this message translates to:
  /// **'estimate'**
  String get focusEstimate;

  /// No description provided for @focusOf.
  ///
  /// In en, this message translates to:
  /// **'of {kcal}'**
  String focusOf(String kcal);

  /// No description provided for @focusOfGrams.
  ///
  /// In en, this message translates to:
  /// **'of about {grams} g'**
  String focusOfGrams(String grams);

  /// No description provided for @focusEatenLabel.
  ///
  /// In en, this message translates to:
  /// **'{eaten} of {target} kcal eaten today'**
  String focusEatenLabel(String eaten, String target);

  /// No description provided for @focusLeft.
  ///
  /// In en, this message translates to:
  /// **'About {kcal} kcal left today'**
  String focusLeft(String kcal);

  /// No description provided for @focusOver.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal over today — that’s fine, it evens out over the week.'**
  String focusOver(String kcal);

  /// No description provided for @focusSetUpCalories.
  ///
  /// In en, this message translates to:
  /// **'Get a daily calorie target in Profile'**
  String get focusSetUpCalories;

  /// No description provided for @focusWorkouts.
  ///
  /// In en, this message translates to:
  /// **'workouts'**
  String get focusWorkouts;

  /// No description provided for @focusProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein today'**
  String get focusProtein;

  /// No description provided for @focusProteinWhy.
  ///
  /// In en, this message translates to:
  /// **'About 1.6 g of protein per kg of body weight a day helps muscles grow (a general guide).'**
  String get focusProteinWhy;

  /// No description provided for @focusActiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'Active minutes'**
  String get focusActiveMinutes;

  /// No description provided for @focusMinutesOf.
  ///
  /// In en, this message translates to:
  /// **'{minutes} of {target}'**
  String focusMinutesOf(int minutes, int target);

  /// No description provided for @focusMinutesLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes} more active minutes reach the 150 a week that health guidelines suggest.'**
  String focusMinutesLeft(int minutes);

  /// No description provided for @focusMinutesDone.
  ///
  /// In en, this message translates to:
  /// **'You’ve reached the 150 active minutes a week that health guidelines suggest.'**
  String get focusMinutesDone;

  /// No description provided for @homeCaloriesOf.
  ///
  /// In en, this message translates to:
  /// **'of {kcal} kcal today · estimated'**
  String homeCaloriesOf(String kcal);

  /// No description provided for @diaryMealGuide.
  ///
  /// In en, this message translates to:
  /// **'{eaten} of about {guide} kcal'**
  String diaryMealGuide(String eaten, String guide);

  /// No description provided for @bodyHistory.
  ///
  /// In en, this message translates to:
  /// **'Weight history'**
  String get bodyHistory;

  /// No description provided for @bodyAddWeighIn.
  ///
  /// In en, this message translates to:
  /// **'Add weigh-in'**
  String get bodyAddWeighIn;

  /// No description provided for @bodyWeighIn.
  ///
  /// In en, this message translates to:
  /// **'Weigh-in'**
  String get bodyWeighIn;

  /// No description provided for @bodyNoWeighIns.
  ///
  /// In en, this message translates to:
  /// **'No weigh-ins yet.'**
  String get bodyNoWeighIns;

  /// No description provided for @bodyChange.
  ///
  /// In en, this message translates to:
  /// **'{amount} since {date}'**
  String bodyChange(String amount, String date);

  /// No description provided for @bodyTrack.
  ///
  /// In en, this message translates to:
  /// **'Track my weight'**
  String get bodyTrack;

  /// No description provided for @bodyTrackSub.
  ///
  /// In en, this message translates to:
  /// **'Turn off to hide weight, BMI and history. Records are kept until you delete them.'**
  String get bodyTrackSub;

  /// No description provided for @bodyTrackOff.
  ///
  /// In en, this message translates to:
  /// **'Weight tracking is off.'**
  String get bodyTrackOff;

  /// No description provided for @bodyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Weigh-in deleted'**
  String get bodyDeleted;

  /// No description provided for @bodyWeighInLabel.
  ///
  /// In en, this message translates to:
  /// **'{weight} on {date}'**
  String bodyWeighInLabel(String weight, String date);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}!'**
  String homeGreeting(String greeting, String name);

  /// No description provided for @homeSteps.
  ///
  /// In en, this message translates to:
  /// **'Today’s steps'**
  String get homeSteps;

  /// No description provided for @homeStepGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal {goal}'**
  String homeStepGoal(String goal);

  /// No description provided for @homeKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String homeKm(String km);

  /// No description provided for @homeOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of goal'**
  String homeOfGoal(int pct);

  /// No description provided for @homeStepsAllow.
  ///
  /// In en, this message translates to:
  /// **'Count my steps'**
  String get homeStepsAllow;

  /// No description provided for @homeStepsWhy.
  ///
  /// In en, this message translates to:
  /// **'MagnaVita can read your phone’s step sensor. Steps stay on this phone.'**
  String get homeStepsWhy;

  /// No description provided for @homeStepsDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow “Physical activity” for MagnaVita in your phone’s settings to count steps.'**
  String get homeStepsDenied;

  /// No description provided for @homeStepsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get homeStepsOpenSettings;

  /// No description provided for @homeStepsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This phone doesn’t have a step counter.'**
  String get homeStepsUnavailable;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories eaten'**
  String get homeCalories;

  /// No description provided for @homeCaloriesSub.
  ///
  /// In en, this message translates to:
  /// **'From your food diary · estimated'**
  String get homeCaloriesSub;

  /// No description provided for @homeFasted.
  ///
  /// In en, this message translates to:
  /// **'Hours fasted'**
  String get homeFasted;

  /// No description provided for @homeFastGoal.
  ///
  /// In en, this message translates to:
  /// **'Target {target} · {pct}%'**
  String homeFastGoal(String target, int pct);

  /// No description provided for @homeNotFasting.
  ///
  /// In en, this message translates to:
  /// **'Not fasting · tap + to start'**
  String get homeNotFasting;

  /// No description provided for @homeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get homeWater;

  /// No description provided for @homeWaterGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String homeWaterGoal(String goal);

  /// No description provided for @quickEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickEyebrow;

  /// No description provided for @quickTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to log?'**
  String get quickTitle;

  /// No description provided for @quickWater.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get quickWater;

  /// No description provided for @quickWaterSub.
  ///
  /// In en, this message translates to:
  /// **'Add a {amount} glass'**
  String quickWaterSub(String amount);

  /// No description provided for @quickWaterAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {amount} · {total} today'**
  String quickWaterAdded(String amount, String total);

  /// No description provided for @quickStart.
  ///
  /// In en, this message translates to:
  /// **'Start fast'**
  String get quickStart;

  /// No description provided for @quickStartSub.
  ///
  /// In en, this message translates to:
  /// **'Begin your {target} fast'**
  String quickStartSub(String target);

  /// No description provided for @quickStarted.
  ///
  /// In en, this message translates to:
  /// **'Fast started — the timer is running.'**
  String get quickStarted;

  /// No description provided for @quickEnd.
  ///
  /// In en, this message translates to:
  /// **'End fast'**
  String get quickEnd;

  /// No description provided for @quickEndSub.
  ///
  /// In en, this message translates to:
  /// **'{elapsed} so far'**
  String quickEndSub(String elapsed);

  /// No description provided for @quickFood.
  ///
  /// In en, this message translates to:
  /// **'Log food'**
  String get quickFood;

  /// No description provided for @quickFoodSub.
  ///
  /// In en, this message translates to:
  /// **'Search, scan a barcode or snap a meal'**
  String get quickFoodSub;

  /// No description provided for @quickActivity.
  ///
  /// In en, this message translates to:
  /// **'Log activity'**
  String get quickActivity;

  /// No description provided for @quickActivitySub.
  ///
  /// In en, this message translates to:
  /// **'Walk, run, cycle, strength…'**
  String get quickActivitySub;

  /// No description provided for @quickWeigh.
  ///
  /// In en, this message translates to:
  /// **'Weigh in'**
  String get quickWeigh;

  /// No description provided for @quickWeighSub.
  ///
  /// In en, this message translates to:
  /// **'Update your weight'**
  String get quickWeighSub;

  /// No description provided for @kitchenAddHow.
  ///
  /// In en, this message translates to:
  /// **'How do you want to add it?'**
  String get kitchenAddHow;

  /// No description provided for @kitchenAddType.
  ///
  /// In en, this message translates to:
  /// **'Type it in'**
  String get kitchenAddType;

  /// No description provided for @kitchenAddTypeSub.
  ///
  /// In en, this message translates to:
  /// **'Name, amount, dates and more'**
  String get kitchenAddTypeSub;

  /// No description provided for @kitchenAddScanSub.
  ///
  /// In en, this message translates to:
  /// **'Fills in the name, brand and pack size'**
  String get kitchenAddScanSub;

  /// No description provided for @kitchenAddPhotoSub.
  ///
  /// In en, this message translates to:
  /// **'AI lists what’s in the photo — you check it first'**
  String get kitchenAddPhotoSub;

  /// No description provided for @kitchenScanNotFound.
  ///
  /// In en, this message translates to:
  /// **'{code} isn’t in Open Food Facts yet — add it yourself.'**
  String kitchenScanNotFound(String code);

  /// No description provided for @groceryTitle.
  ///
  /// In en, this message translates to:
  /// **'Snap your groceries'**
  String get groceryTitle;

  /// No description provided for @groceryPhoto.
  ///
  /// In en, this message translates to:
  /// **'Your groceries photo'**
  String get groceryPhoto;

  /// No description provided for @groceryLooking.
  ///
  /// In en, this message translates to:
  /// **'Looking for food items…'**
  String get groceryLooking;

  /// No description provided for @groceryCheck.
  ///
  /// In en, this message translates to:
  /// **'AI suggestions — untick anything that’s wrong and tap the pencil to fix names or amounts.'**
  String get groceryCheck;

  /// No description provided for @groceryNone.
  ///
  /// In en, this message translates to:
  /// **'No food items were recognised. Try again with the items spread out and labels facing the camera.'**
  String get groceryNone;

  /// No description provided for @groceryAdd.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing selected} =1{Add 1 item to My Kitchen} other{Add {count} items to My Kitchen}}'**
  String groceryAdd(int count);

  /// No description provided for @groceryAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing added} =1{1 item added to My Kitchen} other{{count} items added to My Kitchen}}'**
  String groceryAdded(int count);

  /// No description provided for @groceryNote.
  ///
  /// In en, this message translates to:
  /// **'Added from a photo'**
  String get groceryNote;

  /// No description provided for @myRecipeNew.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get myRecipeNew;

  /// No description provided for @myRecipeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get myRecipeEditTitle;

  /// No description provided for @myRecipeName.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get myRecipeName;

  /// No description provided for @myRecipeCategory.
  ///
  /// In en, this message translates to:
  /// **'Type · optional'**
  String get myRecipeCategory;

  /// No description provided for @myRecipeCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Breakfast, Dinner, Snack'**
  String get myRecipeCategoryHint;

  /// No description provided for @myRecipeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Time (min) · optional'**
  String get myRecipeMinutes;

  /// No description provided for @myRecipeServings.
  ///
  /// In en, this message translates to:
  /// **'Servings · optional'**
  String get myRecipeServings;

  /// No description provided for @myRecipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get myRecipeIngredients;

  /// No description provided for @myRecipeIngredient.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get myRecipeIngredient;

  /// No description provided for @myRecipeAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get myRecipeAmount;

  /// No description provided for @myRecipeAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get myRecipeAddIngredient;

  /// No description provided for @myRecipeRemoveIngredient.
  ///
  /// In en, this message translates to:
  /// **'Remove ingredient'**
  String get myRecipeRemoveIngredient;

  /// No description provided for @myRecipeSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps · one per line'**
  String get myRecipeSteps;

  /// No description provided for @myRecipeStepsHint.
  ///
  /// In en, this message translates to:
  /// **'Rinse the rice.\nBring to the boil…'**
  String get myRecipeStepsHint;

  /// No description provided for @myRecipeSave.
  ///
  /// In en, this message translates to:
  /// **'Save recipe'**
  String get myRecipeSave;

  /// No description provided for @myRecipeSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved'**
  String myRecipeSaved(String name);

  /// No description provided for @myRecipeNeedName.
  ///
  /// In en, this message translates to:
  /// **'Give the recipe a name.'**
  String get myRecipeNeedName;

  /// No description provided for @myRecipeNeedIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient.'**
  String get myRecipeNeedIngredient;

  /// No description provided for @myRecipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get myRecipeDelete;

  /// No description provided for @myRecipeDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String myRecipeDeleteConfirm(String name);

  /// No description provided for @myRecipeDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes your recipe from this phone. Meals you logged from it stay in your diary.'**
  String get myRecipeDeleteBody;

  /// No description provided for @myRecipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String myRecipeDeleted(String name);

  /// No description provided for @myRecipeBadge.
  ///
  /// In en, this message translates to:
  /// **'Your recipe'**
  String get myRecipeBadge;

  /// No description provided for @recipesShowMine.
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get recipesShowMine;

  /// No description provided for @recipesMineEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven’t written any recipes yet — tap “New recipe”.'**
  String get recipesMineEmpty;

  /// No description provided for @recipeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String recipeMinutes(int count);

  /// No description provided for @recipeServings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 serving} other{{count} servings}}'**
  String recipeServings(int count);

  /// No description provided for @recipesHiding.
  ///
  /// In en, this message translates to:
  /// **'Hiding recipes with: {list}.'**
  String recipesHiding(String list);

  /// No description provided for @recipesHaveShort.
  ///
  /// In en, this message translates to:
  /// **'{have}/{total} ingredients'**
  String recipesHaveShort(int have, int total);

  /// No description provided for @homeStepGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily steps goal'**
  String get homeStepGoalTitle;

  /// No description provided for @bmiBandUnder.
  ///
  /// In en, this message translates to:
  /// **'Under'**
  String get bmiBandUnder;

  /// No description provided for @bmiBandHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy 18.5–25'**
  String get bmiBandHealthy;

  /// No description provided for @bmiBandOver.
  ///
  /// In en, this message translates to:
  /// **'Over'**
  String get bmiBandOver;

  /// No description provided for @diaryCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy to another day'**
  String get diaryCopy;

  /// No description provided for @diaryCopyTo.
  ///
  /// In en, this message translates to:
  /// **'Copy to which day?'**
  String get diaryCopyTo;

  /// No description provided for @diaryCopyMeal.
  ///
  /// In en, this message translates to:
  /// **'Copy {meal} to another day'**
  String diaryCopyMeal(String meal);

  /// No description provided for @diaryCopied.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copied to {day}} other{{count} items copied to {day}}}'**
  String diaryCopied(int count, String day);

  /// No description provided for @addFoodLoggedBefore.
  ///
  /// In en, this message translates to:
  /// **'Logged before'**
  String get addFoodLoggedBefore;

  /// No description provided for @recipePerServing.
  ///
  /// In en, this message translates to:
  /// **'Per serving'**
  String get recipePerServing;

  /// No description provided for @myRecipeNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per serving · optional'**
  String get myRecipeNutrition;

  /// No description provided for @myRecipeTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get myRecipeTakePhoto;

  /// No description provided for @myRecipeRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get myRecipeRemovePhoto;

  /// No description provided for @myRecipePhoto.
  ///
  /// In en, this message translates to:
  /// **'Recipe photo'**
  String get myRecipePhoto;

  /// No description provided for @recipeAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Let MagnaVita write it'**
  String get recipeAiTitle;

  /// No description provided for @recipeAiBody.
  ///
  /// In en, this message translates to:
  /// **'Add a photo of the plate above and/or describe what you made and how. Gemini fills in the name, ingredients, steps and nutrition per serving. It\'s an estimate, so check it before saving.'**
  String get recipeAiBody;

  /// No description provided for @recipeAiDescribe.
  ///
  /// In en, this message translates to:
  /// **'What you made · optional'**
  String get recipeAiDescribe;

  /// No description provided for @recipeAiHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Fried 2 eggs in 1 tsp butter, 2 slices brown toast, half an avocado'**
  String get recipeAiHint;

  /// No description provided for @recipeAiGenerate.
  ///
  /// In en, this message translates to:
  /// **'Write the recipe'**
  String get recipeAiGenerate;

  /// No description provided for @recipeAiWorking.
  ///
  /// In en, this message translates to:
  /// **'Writing your recipe…'**
  String get recipeAiWorking;

  /// No description provided for @recipeAiNeedInput.
  ///
  /// In en, this message translates to:
  /// **'Add a photo or describe the meal first.'**
  String get recipeAiNeedInput;

  /// No description provided for @recipeAiFilled.
  ///
  /// In en, this message translates to:
  /// **'Recipe filled in. Check it, then save.'**
  String get recipeAiFilled;

  /// No description provided for @diarySaveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save {meal} as a recipe'**
  String diarySaveRecipe(String meal);

  /// No description provided for @homeBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories burned'**
  String get homeBurned;

  /// No description provided for @homeBurnedSub.
  ///
  /// In en, this message translates to:
  /// **'From your watch'**
  String get homeBurnedSub;

  /// No description provided for @watchSection.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchSection;

  /// No description provided for @watchTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your watch'**
  String get watchTitle;

  /// No description provided for @watchOff.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get watchOff;

  /// No description provided for @watchLinked.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get watchLinked;

  /// No description provided for @watchNeedsPermission.
  ///
  /// In en, this message translates to:
  /// **'Needs permission'**
  String get watchNeedsPermission;

  /// No description provided for @watchUnavailableShort.
  ///
  /// In en, this message translates to:
  /// **'Health Connect needed'**
  String get watchUnavailableShort;

  /// No description provided for @watchIntro.
  ///
  /// In en, this message translates to:
  /// **'MagnaVita can read the workouts, calories burned and steps your watch records, through Android’s Health Connect.'**
  String get watchIntro;

  /// No description provided for @watchSteps.
  ///
  /// In en, this message translates to:
  /// **'Xiaomi watch? First open Mi Fitness → Profile → Settings → Health Connect and allow it to share exercise, calories and steps. Then tap Connect below.'**
  String get watchSteps;

  /// No description provided for @watchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Health Connect isn’t installed on this phone yet.'**
  String get watchUnavailable;

  /// No description provided for @watchInstall.
  ///
  /// In en, this message translates to:
  /// **'Install Health Connect'**
  String get watchInstall;

  /// No description provided for @watchConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get watchConnect;

  /// No description provided for @watchConnected.
  ///
  /// In en, this message translates to:
  /// **'Watch connected'**
  String get watchConnected;

  /// No description provided for @watchDenied.
  ///
  /// In en, this message translates to:
  /// **'MagnaVita wasn’t given access. You can allow it in Health Connect any time.'**
  String get watchDenied;

  /// No description provided for @watchLinkedBody.
  ///
  /// In en, this message translates to:
  /// **'Connected — MagnaVita reads your watch data when you open the app.'**
  String get watchLinkedBody;

  /// No description provided for @watchDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Stop reading watch data'**
  String get watchDisconnect;

  /// No description provided for @watchPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Read-only: MagnaVita never writes to your health data, and nothing leaves this phone. You can revoke access in Health Connect.'**
  String get watchPrivacy;

  /// No description provided for @activityFromWatch.
  ///
  /// In en, this message translates to:
  /// **'From your watch'**
  String get activityFromWatch;

  /// No description provided for @homeStepsWatch.
  ///
  /// In en, this message translates to:
  /// **'watch'**
  String get homeStepsWatch;

  /// No description provided for @homeStepsEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get homeStepsEdited;

  /// No description provided for @homeStepsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit steps'**
  String get homeStepsEdit;

  /// No description provided for @stepsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s steps'**
  String get stepsEditTitle;

  /// No description provided for @stepsEditBody.
  ///
  /// In en, this message translates to:
  /// **'Type the number your watch shows. MagnaVita keeps adding the steps your phone counts after this, and uses your watch’s own count again once it syncs past it.'**
  String get stepsEditBody;

  /// No description provided for @stepsEditField.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsEditField;

  /// No description provided for @stepsEditReset.
  ///
  /// In en, this message translates to:
  /// **'Go back to the automatic count'**
  String get stepsEditReset;

  /// No description provided for @homeWatchSynced.
  ///
  /// In en, this message translates to:
  /// **'Watch last synced {time}'**
  String homeWatchSynced(String time);

  /// No description provided for @homeBurnedNone.
  ///
  /// In en, this message translates to:
  /// **'Connected · nothing synced from your watch yet today'**
  String get homeBurnedNone;

  /// No description provided for @watchFromApps.
  ///
  /// In en, this message translates to:
  /// **'Today in Health Connect, by app'**
  String get watchFromApps;

  /// No description provided for @watchNoData.
  ///
  /// In en, this message translates to:
  /// **'Nothing from today yet. Open Mi Fitness and let it sync, then tap Refresh.'**
  String get watchNoData;

  /// No description provided for @watchAppSteps.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String watchAppSteps(int count);

  /// No description provided for @watchAppActive.
  ///
  /// In en, this message translates to:
  /// **'{kcal} active kcal'**
  String watchAppActive(int kcal);

  /// No description provided for @watchAppTotal.
  ///
  /// In en, this message translates to:
  /// **'{kcal} total kcal'**
  String watchAppTotal(int kcal);

  /// No description provided for @watchUsedNote.
  ///
  /// In en, this message translates to:
  /// **'✓ is the app MagnaVita uses (Mi Fitness when present), so nothing is counted twice. Mi Fitness shares data with Health Connect when it syncs, so MagnaVita can lag behind your watch face until then.'**
  String get watchUsedNote;

  /// No description provided for @watchRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get watchRefresh;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get updateAvailable;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'MagnaVita {version}'**
  String appVersion(String version);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateNow;

  /// No description provided for @activityKcalEstimate.
  ///
  /// In en, this message translates to:
  /// **'≈ {kcal} kcal burned (est.) · at {kg} kg'**
  String activityKcalEstimate(int kcal, String kg);

  /// No description provided for @activityKcalNeedWeight.
  ///
  /// In en, this message translates to:
  /// **'Add your weight in Profile to estimate calories burned.'**
  String get activityKcalNeedWeight;

  /// No description provided for @activityKcalWatch.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal burned · from your watch'**
  String activityKcalWatch(int kcal);

  /// No description provided for @activityKcalOwn.
  ///
  /// In en, this message translates to:
  /// **'Calories burned · optional, if you know them'**
  String get activityKcalOwn;

  /// No description provided for @homeBurnedLogged.
  ///
  /// In en, this message translates to:
  /// **'From activities you logged · estimated'**
  String get homeBurnedLogged;

  /// No description provided for @homeBurnedBoth.
  ///
  /// In en, this message translates to:
  /// **'Watch + activities you logged'**
  String get homeBurnedBoth;

  /// No description provided for @activityExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises (optional)'**
  String get activityExercises;

  /// No description provided for @activityAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get activityAddExercise;

  /// No description provided for @exerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseTitle;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Name, e.g. crunches'**
  String get exerciseName;

  /// No description provided for @exerciseWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight per set ({unit}) · optional'**
  String exerciseWeight(String unit);

  /// No description provided for @exerciseSets.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 set} other{{n} sets}}'**
  String exerciseSets(int n);

  /// No description provided for @exerciseReps.
  ///
  /// In en, this message translates to:
  /// **'{n} reps'**
  String exerciseReps(int n);

  /// No description provided for @exerciseRepsHint.
  ///
  /// In en, this message translates to:
  /// **'For holds like plank, count seconds as reps.'**
  String get exerciseRepsHint;

  /// No description provided for @notifRestTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest over'**
  String get notifRestTitle;

  /// No description provided for @notifRestBody.
  ///
  /// In en, this message translates to:
  /// **'Time for your next set.'**
  String get notifRestBody;

  /// No description provided for @workoutCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Strength workout'**
  String get workoutCardTitle;

  /// No description provided for @workoutCardSub.
  ///
  /// In en, this message translates to:
  /// **'Track every set\'s weight and reps, with a rest timer between sets'**
  String get workoutCardSub;

  /// No description provided for @workoutStart.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get workoutStart;

  /// No description provided for @workoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress · {time}'**
  String workoutInProgress(String time);

  /// No description provided for @workoutResume.
  ///
  /// In en, this message translates to:
  /// **'Resume workout'**
  String get workoutResume;

  /// No description provided for @workoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutTitle;

  /// No description provided for @workoutElapsed.
  ///
  /// In en, this message translates to:
  /// **'{time} · {sets, plural, =1{1 set} other{{sets} sets}} done'**
  String workoutElapsed(String time, int sets);

  /// No description provided for @workoutFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get workoutFinish;

  /// No description provided for @workoutEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add your first exercise. Each one starts from what you did last time.'**
  String get workoutEmpty;

  /// No description provided for @workoutAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get workoutAddExercise;

  /// No description provided for @workoutDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard workout'**
  String get workoutDiscard;

  /// No description provided for @workoutDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this workout?'**
  String get workoutDiscardTitle;

  /// No description provided for @workoutDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing from it will be saved.'**
  String get workoutDiscardBody;

  /// No description provided for @workoutNothingDone.
  ///
  /// In en, this message translates to:
  /// **'Tick off at least one set to save the workout.'**
  String get workoutNothingDone;

  /// No description provided for @workoutSaved.
  ///
  /// In en, this message translates to:
  /// **'Workout saved — {minutes} min, {sets, plural, =1{1 set} other{{sets} sets}}'**
  String workoutSaved(int minutes, int sets);

  /// No description provided for @workoutLastTime.
  ///
  /// In en, this message translates to:
  /// **'Last time: {what}'**
  String workoutLastTime(String what);

  /// No description provided for @workoutSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get workoutSet;

  /// No description provided for @workoutReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get workoutReps;

  /// No description provided for @workoutAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get workoutAddSet;

  /// No description provided for @workoutRemoveSet.
  ///
  /// In en, this message translates to:
  /// **'Remove set {n}'**
  String workoutRemoveSet(int n);

  /// No description provided for @workoutRemoveExercise.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String workoutRemoveExercise(String name);

  /// No description provided for @workoutSetDone.
  ///
  /// In en, this message translates to:
  /// **'Set {n} done'**
  String workoutSetDone(int n);

  /// No description provided for @workoutSetTodo.
  ///
  /// In en, this message translates to:
  /// **'Mark set {n} done'**
  String workoutSetTodo(int n);

  /// No description provided for @restTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restTitle;

  /// No description provided for @restLess.
  ///
  /// In en, this message translates to:
  /// **'15 seconds less rest'**
  String get restLess;

  /// No description provided for @restMore.
  ///
  /// In en, this message translates to:
  /// **'15 seconds more rest'**
  String get restMore;

  /// No description provided for @restSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get restSkip;

  /// No description provided for @pickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an exercise'**
  String get pickerTitle;

  /// No description provided for @pickerSearch.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get pickerSearch;

  /// No description provided for @pickerYours.
  ///
  /// In en, this message translates to:
  /// **'Your exercises'**
  String get pickerYours;

  /// No description provided for @pickerAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pickerAll;

  /// No description provided for @pickerOwn.
  ///
  /// In en, this message translates to:
  /// **'Add “{name}” as your own'**
  String pickerOwn(String name);

  /// No description provided for @pickerNone.
  ///
  /// In en, this message translates to:
  /// **'No exercises match.'**
  String get pickerNone;

  /// No description provided for @equipFreeWeights.
  ///
  /// In en, this message translates to:
  /// **'Free weights'**
  String get equipFreeWeights;

  /// No description provided for @equipMachines.
  ///
  /// In en, this message translates to:
  /// **'Machines'**
  String get equipMachines;

  /// No description provided for @equipBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get equipBodyweight;

  /// No description provided for @equipOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get equipOther;

  /// No description provided for @goalStrength.
  ///
  /// In en, this message translates to:
  /// **'Get stronger'**
  String get goalStrength;

  /// No description provided for @goalMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get goalMuscle;

  /// No description provided for @goalEndurance.
  ///
  /// In en, this message translates to:
  /// **'Tone and endurance'**
  String get goalEndurance;

  /// No description provided for @goalFatLoss.
  ///
  /// In en, this message translates to:
  /// **'Lose fat'**
  String get goalFatLoss;

  /// No description provided for @focusPush.
  ///
  /// In en, this message translates to:
  /// **'Push: chest, shoulders, triceps'**
  String get focusPush;

  /// No description provided for @focusPull.
  ///
  /// In en, this message translates to:
  /// **'Pull: back, biceps'**
  String get focusPull;

  /// No description provided for @focusLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get focusLegs;

  /// No description provided for @focusChestTriceps.
  ///
  /// In en, this message translates to:
  /// **'Chest & triceps'**
  String get focusChestTriceps;

  /// No description provided for @focusBackBiceps.
  ///
  /// In en, this message translates to:
  /// **'Back & biceps'**
  String get focusBackBiceps;

  /// No description provided for @focusShouldersCore.
  ///
  /// In en, this message translates to:
  /// **'Shoulders & core'**
  String get focusShouldersCore;

  /// No description provided for @focusChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get focusChest;

  /// No description provided for @focusBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get focusBack;

  /// No description provided for @focusShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get focusShoulders;

  /// No description provided for @focusArmsCore.
  ///
  /// In en, this message translates to:
  /// **'Arms & core'**
  String get focusArmsCore;

  /// No description provided for @planDay.
  ///
  /// In en, this message translates to:
  /// **'Day {n} · {focus}'**
  String planDay(int n, String focus);

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get planTitle;

  /// No description provided for @planSummary.
  ///
  /// In en, this message translates to:
  /// **'{goal} · {days} days a week · {rest} s rest between sets'**
  String planSummary(String goal, int days, int rest);

  /// No description provided for @planEditHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an exercise to change its sets and reps or swap it.'**
  String get planEditHint;

  /// No description provided for @planChange.
  ///
  /// In en, this message translates to:
  /// **'Change my plan'**
  String get planChange;

  /// No description provided for @planNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get planNext;

  /// No description provided for @planStartDay.
  ///
  /// In en, this message translates to:
  /// **'Start day {n}'**
  String planStartDay(int n);

  /// No description provided for @planSets.
  ///
  /// In en, this message translates to:
  /// **'{n} sets'**
  String planSets(int n);

  /// No description provided for @planReps.
  ///
  /// In en, this message translates to:
  /// **'{n} reps'**
  String planReps(int n);

  /// No description provided for @planSwapFor.
  ///
  /// In en, this message translates to:
  /// **'Swap for'**
  String get planSwapFor;

  /// No description provided for @planRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from the plan'**
  String get planRemove;

  /// No description provided for @planSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Make a workout plan'**
  String get planSetupTitle;

  /// No description provided for @planSetupSub.
  ///
  /// In en, this message translates to:
  /// **'Each day works different muscles'**
  String get planSetupSub;

  /// No description provided for @planGoal.
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get planGoal;

  /// No description provided for @planDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Days a week'**
  String get planDaysPerWeek;

  /// No description provided for @planDaysChip.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String planDaysChip(int n);

  /// No description provided for @planLevel.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get planLevel;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// No description provided for @levelExpert.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get levelExpert;

  /// No description provided for @planEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get planEquipment;

  /// No description provided for @planEquipGym.
  ///
  /// In en, this message translates to:
  /// **'Full gym'**
  String get planEquipGym;

  /// No description provided for @planEquipDumbbells.
  ///
  /// In en, this message translates to:
  /// **'Dumbbells at home'**
  String get planEquipDumbbells;

  /// No description provided for @planEquipBodyweight.
  ///
  /// In en, this message translates to:
  /// **'No equipment'**
  String get planEquipBodyweight;

  /// No description provided for @planReplaces.
  ///
  /// In en, this message translates to:
  /// **'This replaces your current plan.'**
  String get planReplaces;

  /// No description provided for @planCreate.
  ///
  /// In en, this message translates to:
  /// **'Create my plan'**
  String get planCreate;

  /// No description provided for @planUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next: {day}'**
  String planUpNext(String day);

  /// No description provided for @planToday.
  ///
  /// In en, this message translates to:
  /// **'Today: {day}'**
  String planToday(String day);

  /// No description provided for @planUpNextOn.
  ///
  /// In en, this message translates to:
  /// **'Up next {weekday}: {day}'**
  String planUpNextOn(String weekday, String day);

  /// No description provided for @planWeek.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get planWeek;

  /// No description provided for @planWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the days you train. Miss one and your next workout waits for you.'**
  String get planWeekHint;

  /// No description provided for @planWeekdayTrained.
  ///
  /// In en, this message translates to:
  /// **'{weekday}: trained'**
  String planWeekdayTrained(String weekday);

  /// No description provided for @planWeekdayTraining.
  ///
  /// In en, this message translates to:
  /// **'{weekday}: training day'**
  String planWeekdayTraining(String weekday);

  /// No description provided for @planWeekdayRest.
  ///
  /// In en, this message translates to:
  /// **'{weekday}: rest day'**
  String planWeekdayRest(String weekday);

  /// No description provided for @planRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind me on training days'**
  String get planRemind;

  /// No description provided for @planRemindAt.
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String planRemindAt(String time);

  /// No description provided for @notifWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Training day'**
  String get notifWorkoutTitle;

  /// No description provided for @notifWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'Your plan has a workout today, whenever suits you.'**
  String get notifWorkoutBody;

  /// No description provided for @planMake.
  ///
  /// In en, this message translates to:
  /// **'Make a workout plan'**
  String get planMake;

  /// No description provided for @planYours.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get planYours;

  /// No description provided for @workoutEmptyStart.
  ///
  /// In en, this message translates to:
  /// **'Empty workout'**
  String get workoutEmptyStart;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressSub.
  ///
  /// In en, this message translates to:
  /// **'From the workouts you\'ve logged'**
  String get progressSub;

  /// No description provided for @progressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Finish a strength workout and your progress shows here.'**
  String get progressEmpty;

  /// No description provided for @progressThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get progressThisWeek;

  /// No description provided for @progressOfPlan.
  ///
  /// In en, this message translates to:
  /// **'{n} of {target}'**
  String progressOfPlan(int n, int target);

  /// No description provided for @progressStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get progressStreak;

  /// No description provided for @progressWeeks.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 week} other{{n} weeks}}'**
  String progressWeeks(int n);

  /// No description provided for @progressMonth.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get progressMonth;

  /// No description provided for @progressPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Workouts per week'**
  String get progressPerWeek;

  /// No description provided for @progressPerWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Workouts per week, last 8 weeks: {counts}'**
  String progressPerWeekLabel(String counts);

  /// No description provided for @progressBests.
  ///
  /// In en, this message translates to:
  /// **'Personal bests'**
  String get progressBests;

  /// No description provided for @progressNoBests.
  ///
  /// In en, this message translates to:
  /// **'Tick off sets in a workout to set your first bests.'**
  String get progressNoBests;

  /// No description provided for @progressBest1rm.
  ///
  /// In en, this message translates to:
  /// **'Best estimated 1-rep max {load}'**
  String progressBest1rm(String load);

  /// No description provided for @progressMostReps.
  ///
  /// In en, this message translates to:
  /// **'Most reps in a set: {n}'**
  String progressMostReps(int n);

  /// No description provided for @progressChart.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1-rep max over time'**
  String get progressChart;

  /// No description provided for @progressChartLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1-rep max went from {first} to {last}'**
  String progressChartLabel(String first, String last);

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise library'**
  String get libraryTitle;

  /// No description provided for @libraryBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse the exercise library'**
  String get libraryBrowse;

  /// No description provided for @exerciseAbout.
  ///
  /// In en, this message translates to:
  /// **'How to do {name}'**
  String exerciseAbout(String name);

  /// No description provided for @exerciseAddToWorkout.
  ///
  /// In en, this message translates to:
  /// **'Add to workout'**
  String get exerciseAddToWorkout;

  /// No description provided for @exerciseYours.
  ///
  /// In en, this message translates to:
  /// **'Your history'**
  String get exerciseYours;

  /// No description provided for @exerciseNoHistory.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t logged this yet. Your best sets will show here.'**
  String get exerciseNoHistory;

  /// No description provided for @exerciseHeaviest.
  ///
  /// In en, this message translates to:
  /// **'Heaviest set: {set}'**
  String exerciseHeaviest(String set);

  /// No description provided for @exerciseBest1rm.
  ///
  /// In en, this message translates to:
  /// **'Best estimated 1-rep max: {load} (from {set})'**
  String exerciseBest1rm(String load, String set);

  /// No description provided for @exerciseMuscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get exerciseMuscles;

  /// No description provided for @exerciseAlsoWorks.
  ///
  /// In en, this message translates to:
  /// **'Also works: {muscles}'**
  String exerciseAlsoWorks(String muscles);

  /// No description provided for @exerciseHow.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get exerciseHow;

  /// No description provided for @exercisePhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos showing how to do {name}'**
  String exercisePhotos(String name);

  /// No description provided for @exercisePhotosOffline.
  ///
  /// In en, this message translates to:
  /// **'Photos load when you\'re online.'**
  String get exercisePhotosOffline;

  /// No description provided for @exerciseSource.
  ///
  /// In en, this message translates to:
  /// **'Exercises from free-exercise-db (public domain).'**
  String get exerciseSource;

  /// No description provided for @exerciseFewerSets.
  ///
  /// In en, this message translates to:
  /// **'1 set less'**
  String get exerciseFewerSets;

  /// No description provided for @exerciseMoreSets.
  ///
  /// In en, this message translates to:
  /// **'1 set more'**
  String get exerciseMoreSets;

  /// No description provided for @exerciseFewerReps.
  ///
  /// In en, this message translates to:
  /// **'1 rep less'**
  String get exerciseFewerReps;

  /// No description provided for @exerciseMoreReps.
  ///
  /// In en, this message translates to:
  /// **'1 rep more'**
  String get exerciseMoreReps;

  /// No description provided for @exerciseAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get exerciseAdd;

  /// No description provided for @exerciseRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String exerciseRemove(String name);

  /// No description provided for @shareDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your day'**
  String get shareDayTitle;

  /// No description provided for @shareDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export the day\'s stats'**
  String get shareDayTooltip;

  /// No description provided for @shareDayButton.
  ///
  /// In en, this message translates to:
  /// **'Export PNG'**
  String get shareDayButton;

  /// No description provided for @statSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get statSteps;

  /// No description provided for @statDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get statDistance;

  /// No description provided for @statBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories burned'**
  String get statBurned;

  /// No description provided for @statActive.
  ///
  /// In en, this message translates to:
  /// **'Active time'**
  String get statActive;

  /// No description provided for @exportStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get exportStyle;

  /// No description provided for @styleWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get styleWhite;

  /// No description provided for @styleLime.
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get styleLime;

  /// No description provided for @styleForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get styleForest;

  /// No description provided for @styleBadge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get styleBadge;

  /// No description provided for @layoutCompact.
  ///
  /// In en, this message translates to:
  /// **'Stats first'**
  String get layoutCompact;

  /// No description provided for @layoutPoster.
  ///
  /// In en, this message translates to:
  /// **'Icon first'**
  String get layoutPoster;

  /// No description provided for @pickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get pickDay;

  /// No description provided for @notifDailyBody.
  ///
  /// In en, this message translates to:
  /// **'Your daily reminder. Open the app to start or review a session.'**
  String get notifDailyBody;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
