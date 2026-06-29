// lib/core/services/session_notification_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SessionNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // ── Init ─────────────────────────────────────
  // Call this once in main() before runApp()

  static Future<void> init() async {
    tz.initializeTimeZones(); // ✅ required for zonedSchedule

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
  }

  // ── Schedule notifications for accepted sessions ──
  // Call this on app launch and whenever sessions change

  static Future<void> scheduleUpcomingSessionAlerts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final soon = now.add(const Duration(hours: 24));

    final snap = await FirebaseFirestore.instance
        .collection('sessions')
        .where('status', isEqualTo: 'accepted')
        .where('scheduledAt', isGreaterThan: Timestamp.fromDate(now))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(soon))
        .get();

    // Cancel old scheduled notifications before rescheduling
    await _plugin.cancelAll();

    for (final doc in snap.docs) {
      final data = doc.data();
      final participants = [data['studentId'], data['teacherId']];
      if (!participants.contains(uid)) continue;

      final scheduledAt = (data['scheduledAt'] as Timestamp).toDate();
      final skill = data['skill'] as String? ?? 'session';

      final notifyAt = scheduledAt.subtract(const Duration(minutes: 5));
      if (notifyAt.isAfter(now)) {
        await _scheduleNotification(
          id: doc.id.hashCode,
          title: 'Your Session Starting Soon',
          body: 'Your $skill session starts in 5 minutes!',
          scheduledAt: notifyAt,
        );
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    // Convert DateTime to TZDateTime using local timezone
    final tzScheduledAt = tz.TZDateTime.from(scheduledAt, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledAt,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'session_reminders',
          'Session Reminders',
          channelDescription: 'Notifies you before a session starts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}