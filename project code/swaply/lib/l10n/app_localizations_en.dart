// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get myProfile => 'My Profile';

  @override
  String get rating => 'RATING';

  @override
  String get reviews => 'REVIEWS';

  @override
  String get sessions => 'SESSIONS';

  @override
  String get skillsToLearn => 'Skills to Learn';

  @override
  String get skillsCanTeach => 'Skills I can Teach';

  @override
  String get addSkill => 'Add Skill';

  @override
  String get manageSkills => 'Manage Skills';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get sessionHistory => 'Session History';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get logout => 'Logout';

  @override
  String get points => 'Points';

  @override
  String get topUp => 'Top Up';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get noSkillsAddedYet => 'No skills added yet.';

  @override
  String get newSkill => 'New skill';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get messages => 'Messages';

  @override
  String get profile => 'Profile';

  @override
  String couldNotLoadProfile(String error) {
    return 'Could not load your profile: $error';
  }

  @override
  String get goodMorning => 'Good Morning,';

  @override
  String get goodAfternoon => 'Good Afternoon,';

  @override
  String get goodEvening => 'Good Evening,';

  @override
  String get searchSkillsUsers => 'Search skills, users...';

  @override
  String get learn => 'Learn';

  @override
  String get teach => 'Teach';

  @override
  String get categories => 'Categories';

  @override
  String get seeAll => 'See All';

  @override
  String get recommendedMentors => 'Recommended Mentors';

  @override
  String get activeRequests => 'Active Requests';

  @override
  String get noActiveRequests => 'No active requests right now.';

  @override
  String get letsLearn => 'Let\'s learn something today';

  @override
  String get topMentors => 'Top Mentors';

  @override
  String get justForYou => 'Just for you';

  @override
  String get promo1Title => 'New skills added daily';

  @override
  String get promo1Desc => 'Explore fresh learning opportunities';

  @override
  String get promo2Title => 'Start your first exchange';

  @override
  String get promo2Desc => 'Connect with skilled community members';

  @override
  String get promo3Title => 'Earn rewards while helping';

  @override
  String get promo3Desc => 'Teach a skill and collect points';

  @override
  String mentorsCount(int count) {
    return '$count Mentors';
  }

  @override
  String get searchHint => 'Search skills, users...';

  @override
  String get filterAll => 'All';

  @override
  String get filterLatest => 'Latest';

  @override
  String get filterMostPopular => 'Most Popular';

  @override
  String get filterCheapest => 'Cheapest';

  @override
  String get popularSkills => 'Popular Skills';

  @override
  String get recentSearches => 'Recent Searches';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noMentorsFound => 'No mentors found for';

  @override
  String get tryDifferentKeyword => 'Try a different keyword or category';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get tagHot => 'Hot';

  @override
  String get tagNew => 'New';

  @override
  String get tagPopular => 'Popular';

  @override
  String get manageSessionsDesc =>
      'Manage skill swap requests sent to and from you.';

  @override
  String get myRequests => 'My Requests';

  @override
  String get incomingRequests => 'Incoming Requests';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noSessionsYet => 'No sessions yet';

  @override
  String get sessionsWillAppearHere =>
      'Sessions will appear here once created.';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusOngoing => 'Ongoing';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get joinSession => 'Join Session';

  @override
  String startsAt(String time) {
    return 'Starts $time';
  }

  @override
  String get btnDecline => 'Decline';

  @override
  String get btnAccept => 'Accept';

  @override
  String get actionDeclined => 'Declined';

  @override
  String get btnDelete => 'Delete';

  @override
  String get cancelSession => 'Cancel Session';

  @override
  String get cancelSessionConfirm =>
      'Are you sure you want to cancel this session request?';

  @override
  String get btnNo => 'No';

  @override
  String get btnYesCancel => 'Yes, Cancel';

  @override
  String get deleteSession => 'Delete Session';

  @override
  String get deleteSessionConfirm =>
      'This will permanently remove the session. This cannot be undone.';

  @override
  String get btnYesDelete => 'Yes, Delete';

  @override
  String get rated => 'Rated';

  @override
  String get rateStudent => 'Rate Student';

  @override
  String get rateTeacher => 'Rate Teacher';

  @override
  String get searchConversations => 'Search conversations';

  @override
  String get pleaseSignInChats => 'Please sign in to view your conversations.';

  @override
  String get unableToLoadChats => 'Unable to load conversations.';

  @override
  String get noChatsYet =>
      'No chats yet. Start a conversation from the home screen.';

  @override
  String get pricePerHour => 'Price per hour';

  @override
  String setBy(String name) {
    return 'Set by $name';
  }

  @override
  String pointsAmount(String pts) {
    return '$pts pts';
  }

  @override
  String get skillsOffered => 'Skills offered';

  @override
  String get nextAvailability => 'Next availability';

  @override
  String get mockAvailability =>
      'Today 4:00 PM · Tomorrow 10:00 AM · Thu 2:30 PM';

  @override
  String get requestSession => 'Request Session';

  @override
  String get online => 'Online';

  @override
  String get signInToChat => 'Sign in to chat.';

  @override
  String get unableToLoadMessages => 'Unable to load messages';

  @override
  String get noMessagesYet => 'No messages yet. Start the conversation.';

  @override
  String get messageHint => 'Message...';

  @override
  String get pointsAbbr => 'pts';

  @override
  String get earnPointsHint => 'Earn points by teaching skills.';

  @override
  String get privacySecurityHint =>
      'Your privacy settings are in a safe place. You can manage app permissions, data sharing and security notifications here.';
}
