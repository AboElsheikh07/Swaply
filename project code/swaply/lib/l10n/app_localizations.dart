import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'RATING'**
  String get rating;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'REVIEWS'**
  String get reviews;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'SESSIONS'**
  String get sessions;

  /// No description provided for @skillsToLearn.
  ///
  /// In en, this message translates to:
  /// **'Skills to Learn'**
  String get skillsToLearn;

  /// No description provided for @skillsCanTeach.
  ///
  /// In en, this message translates to:
  /// **'Skills I can Teach'**
  String get skillsCanTeach;

  /// No description provided for @addSkill.
  ///
  /// In en, this message translates to:
  /// **'Add Skill'**
  String get addSkill;

  /// No description provided for @manageSkills.
  ///
  /// In en, this message translates to:
  /// **'Manage Skills'**
  String get manageSkills;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get sessionHistory;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @noSkillsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No skills added yet.'**
  String get noSkillsAddedYet;

  /// No description provided for @newSkill.
  ///
  /// In en, this message translates to:
  /// **'New skill'**
  String get newSkill;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

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

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile: {error}'**
  String couldNotLoadProfile(String error);

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning,'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon,'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening,'**
  String get goodEvening;

  /// No description provided for @searchSkillsUsers.
  ///
  /// In en, this message translates to:
  /// **'Search skills, users...'**
  String get searchSkillsUsers;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @teach.
  ///
  /// In en, this message translates to:
  /// **'Teach'**
  String get teach;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @recommendedMentors.
  ///
  /// In en, this message translates to:
  /// **'Recommended Mentors'**
  String get recommendedMentors;

  /// No description provided for @activeRequests.
  ///
  /// In en, this message translates to:
  /// **'Active Requests'**
  String get activeRequests;

  /// No description provided for @noActiveRequests.
  ///
  /// In en, this message translates to:
  /// **'No active requests right now.'**
  String get noActiveRequests;

  /// No description provided for @letsLearn.
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn something today'**
  String get letsLearn;

  /// No description provided for @topMentors.
  ///
  /// In en, this message translates to:
  /// **'Top Mentors'**
  String get topMentors;

  /// No description provided for @justForYou.
  ///
  /// In en, this message translates to:
  /// **'Just for you'**
  String get justForYou;

  /// No description provided for @promo1Title.
  ///
  /// In en, this message translates to:
  /// **'New skills added daily'**
  String get promo1Title;

  /// No description provided for @promo1Desc.
  ///
  /// In en, this message translates to:
  /// **'Explore fresh learning opportunities'**
  String get promo1Desc;

  /// No description provided for @promo2Title.
  ///
  /// In en, this message translates to:
  /// **'Start your first exchange'**
  String get promo2Title;

  /// No description provided for @promo2Desc.
  ///
  /// In en, this message translates to:
  /// **'Connect with skilled community members'**
  String get promo2Desc;

  /// No description provided for @promo3Title.
  ///
  /// In en, this message translates to:
  /// **'Earn rewards while helping'**
  String get promo3Title;

  /// No description provided for @promo3Desc.
  ///
  /// In en, this message translates to:
  /// **'Teach a skill and collect points'**
  String get promo3Desc;

  /// No description provided for @mentorsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Mentors'**
  String mentorsCount(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search skills, users...'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get filterLatest;

  /// No description provided for @filterMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get filterMostPopular;

  /// No description provided for @filterCheapest.
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get filterCheapest;

  /// No description provided for @popularSkills.
  ///
  /// In en, this message translates to:
  /// **'Popular Skills'**
  String get popularSkills;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noMentorsFound.
  ///
  /// In en, this message translates to:
  /// **'No mentors found for'**
  String get noMentorsFound;

  /// No description provided for @tryDifferentKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or category'**
  String get tryDifferentKeyword;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// No description provided for @tagHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get tagHot;

  /// No description provided for @tagNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get tagNew;

  /// No description provided for @tagPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get tagPopular;

  /// No description provided for @manageSessionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage skill swap requests sent to and from you.'**
  String get manageSessionsDesc;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @incomingRequests.
  ///
  /// In en, this message translates to:
  /// **'Incoming Requests'**
  String get incomingRequests;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get noSessionsYet;

  /// No description provided for @sessionsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Sessions will appear here once created.'**
  String get sessionsWillAppearHere;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get statusOngoing;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @joinSession.
  ///
  /// In en, this message translates to:
  /// **'Join Session'**
  String get joinSession;

  /// No description provided for @startsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts {time}'**
  String startsAt(String time);

  /// No description provided for @btnDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get btnDecline;

  /// No description provided for @btnAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get btnAccept;

  /// No description provided for @actionDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get actionDeclined;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @cancelSession.
  ///
  /// In en, this message translates to:
  /// **'Cancel Session'**
  String get cancelSession;

  /// No description provided for @cancelSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this session request?'**
  String get cancelSessionConfirm;

  /// No description provided for @btnNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get btnNo;

  /// No description provided for @btnYesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get btnYesCancel;

  /// No description provided for @deleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete Session'**
  String get deleteSession;

  /// No description provided for @deleteSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove the session. This cannot be undone.'**
  String get deleteSessionConfirm;

  /// No description provided for @btnYesDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get btnYesDelete;

  /// No description provided for @rated.
  ///
  /// In en, this message translates to:
  /// **'Rated'**
  String get rated;

  /// No description provided for @rateStudent.
  ///
  /// In en, this message translates to:
  /// **'Rate Student'**
  String get rateStudent;

  /// No description provided for @rateTeacher.
  ///
  /// In en, this message translates to:
  /// **'Rate Teacher'**
  String get rateTeacher;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get searchConversations;

  /// No description provided for @pleaseSignInChats.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your conversations.'**
  String get pleaseSignInChats;

  /// No description provided for @unableToLoadChats.
  ///
  /// In en, this message translates to:
  /// **'Unable to load conversations.'**
  String get unableToLoadChats;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet. Start a conversation from the home screen.'**
  String get noChatsYet;

  /// No description provided for @pricePerHour.
  ///
  /// In en, this message translates to:
  /// **'Price per hour'**
  String get pricePerHour;

  /// No description provided for @setBy.
  ///
  /// In en, this message translates to:
  /// **'Set by {name}'**
  String setBy(String name);

  /// No description provided for @pointsAmount.
  ///
  /// In en, this message translates to:
  /// **'{pts} pts'**
  String pointsAmount(String pts);

  /// No description provided for @skillsOffered.
  ///
  /// In en, this message translates to:
  /// **'Skills offered'**
  String get skillsOffered;

  /// No description provided for @nextAvailability.
  ///
  /// In en, this message translates to:
  /// **'Next availability'**
  String get nextAvailability;

  /// No description provided for @mockAvailability.
  ///
  /// In en, this message translates to:
  /// **'Today 4:00 PM · Tomorrow 10:00 AM · Thu 2:30 PM'**
  String get mockAvailability;

  /// No description provided for @requestSession.
  ///
  /// In en, this message translates to:
  /// **'Request Session'**
  String get requestSession;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @signInToChat.
  ///
  /// In en, this message translates to:
  /// **'Sign in to chat.'**
  String get signInToChat;

  /// No description provided for @unableToLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Unable to load messages'**
  String get unableToLoadMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Start the conversation.'**
  String get noMessagesYet;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get messageHint;

  /// No description provided for @pointsAbbr.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pointsAbbr;

  /// No description provided for @earnPointsHint.
  ///
  /// In en, this message translates to:
  /// **'Earn points by teaching skills.'**
  String get earnPointsHint;

  /// No description provided for @privacySecurityHint.
  ///
  /// In en, this message translates to:
  /// **'Your privacy settings are in a safe place. You can manage app permissions, data sharing and security notifications here.'**
  String get privacySecurityHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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
