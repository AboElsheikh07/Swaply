import '../models/notification_model.dart';
import 'notifications_repository.dart';

class MockNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<NotifChannelModel>> getChannels() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      NotifChannelModel(id: 'push', label: 'Push Notifications', prefs: [
        NotifPrefModel(id: 'p_sessions',  label: 'Session updates',   description: 'Accepted, started, or ending soon.', defaultVal: true),
        NotifPrefModel(id: 'p_messages',  label: 'New messages',      description: 'DMs from mentors & learners.',       defaultVal: true),
        NotifPrefModel(id: 'p_reminders', label: 'Session reminders', description: '15 minutes before a session.',      defaultVal: true),
        NotifPrefModel(id: 'p_promos',    label: 'Tips & promos',     description: 'Feature announcements and offers.',  defaultVal: false),
      ]),
      NotifChannelModel(id: 'email', label: 'Email', prefs: [
        NotifPrefModel(id: 'e_weekly',   label: 'Weekly recap',    description: 'Sessions, new mentors, earnings.',   defaultVal: true),
        NotifPrefModel(id: 'e_security', label: 'Security alerts', description: 'New sign-ins and password changes.', defaultVal: true),
        NotifPrefModel(id: 'e_news',     label: 'Product news',    description: 'Highlights twice a month.',         defaultVal: false),
      ]),
    ];
  }

  @override
  Future<void> updatePref({required String prefId, required bool value}) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

// 🔥 لما Firebase يتجهز
// class FirebaseNotificationsRepository implements NotificationsRepository {
//   final _db = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//
//   @override
//   Future<List<NotifChannelModel>> getChannels() async { ... }
//
//   @override
//   Future<void> updatePref({required String prefId, required bool value}) async {
//     final uid = _auth.currentUser!.uid;
//     await _db.collection('users').doc(uid).update({'notifPrefs.$prefId': value});
//   }
// }
