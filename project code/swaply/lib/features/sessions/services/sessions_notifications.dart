// lib/features/sessions/services/sessions_notifications.dart

import 'package:swaply/features/sessions/services/onesignal_push_service.dart';

class SessionNotificationService {
  /// Maps sessionId -> OneSignal notification id, so it can be cancelled.
  /// NOTE: in-memory only. If the app is killed/restarted before the
  /// session is cancelled, this map is lost and cancelSessionAlert won't
  /// find an id to cancel (the reminder will still fire as scheduled).
  /// Fine for a grad project demo; for production you'd persist this on
  /// the session document in Firestore instead.
  static final Map<String, String> _scheduledIds = {};

  /// init() is no longer needed for local notifications, but kept as a
  /// no-op so main.dart doesn't need to change.
  static Future<void> init() async {}



}
