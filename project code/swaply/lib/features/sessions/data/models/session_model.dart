import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum SessionStatus { accepted, ongoing, pending, completed, rejected }

enum SessionRole { teacher, student }

extension SessionStatusX on SessionStatus {
  String get label {
    switch (this) {
      case SessionStatus.pending:
        return 'Pending';
      case SessionStatus.accepted:
        return 'Accepted';
      case SessionStatus.rejected:
        return 'Rejected';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.ongoing:
        return 'Ongoing';

    }
  }

  static SessionStatus fromString(String value) {
    return SessionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SessionStatus.pending,
    );
  }
}

class SessionItem {
  final String id;
  final String studentId;
  final String teacherId;
  final String studentName;
  final String teacherName;
  final String studentAvatar;
  final String teacherAvatar;
  final String skill;
  final DateTime scheduledAt;
  final int durationMinutes;
  final bool isOutgoing;
  final int points; // in points
  final SessionStatus status;
  final String? message; // optional message from student
  final DateTime createdAt;

  // Set by the Cloud Function the moment each side's rating doc is
  // created — NOT by whether the rating is visible yet. A session can be
  // fully rated (both true) while the ratings themselves are still hidden
  // pending the double-blind reveal. These two fields only answer "did
  // this person submit a rating", which is exactly what the UI needs to
  // decide whether to show the Rate button at all.
  final bool studentRated;
  final bool teacherRated;

  const SessionItem({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.studentName,
    required this.teacherName,
    required this.studentAvatar,
    required this.teacherAvatar,
    required this.skill,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.points,
    required this.status,
    required this.isOutgoing,
    this.message,
    required this.createdAt,
    required this.studentRated,
    required this.teacherRated,
  });

  // ── Role helper ──────────────────────────────
  SessionRole roleFor(String uid) =>
      uid == teacherId ? SessionRole.teacher : SessionRole.student;

  String personNameFor(String uid) =>
      uid == teacherId ? studentName : teacherName;

  String personAvatarFor(String uid) =>
      uid == teacherId ? studentAvatar : teacherAvatar;

  /// Has the given uid already submitted their rating for this session?
  bool hasRated(String uid) =>
      uid == teacherId ? teacherRated : studentRated;

  /// Has the *other* participant (relative to uid) already rated?
  bool otherPartyHasRated(String uid) =>
      uid == teacherId ? studentRated : teacherRated;

  /// True once both sides have rated, regardless of reveal state.
  bool get isFullyRated => studentRated && teacherRated;

  // ── Formatted helpers ────────────────────────
  String get formattedDate => DateFormat('EEE, MMM d').format(scheduledAt);

  String get formattedTime => DateFormat('h:mm a').format(scheduledAt);

  String get formattedDuration {
    if (durationMinutes < 60) return '$durationMinutes min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  // ── Firestore ────────────────────────────────
 factory SessionItem.fromFirestore(DocumentSnapshot doc, String currentUid) {
  final data = doc.data() as Map<String, dynamic>;
  return SessionItem(
    id: doc.id,
    studentId:      data['studentId']      ?? '',
    teacherId:      data['teacherId']      ?? '',
    studentName:    data['studentName']    ?? '',
    teacherName:    data['teacherName']    ?? '',
    studentAvatar:  data['studentAvatar']  ?? '',
    teacherAvatar:  data['teacherAvatar']  ?? '',
    skill:          data['skill']          ?? '',
    scheduledAt:    (data['scheduledAt'] as Timestamp).toDate(),
    durationMinutes: data['durationMinutes'] ?? 60,
    points:          data['points']          ?? 0,
    status: SessionStatusX.fromString(data['status'] ?? 'pending'),
    message:        data['message'],
    createdAt:      (data['createdAt'] as Timestamp).toDate(),
    isOutgoing:     data['studentId'] == currentUid, // ← student = sent it
    studentRated:   data['studentRated'] ?? false,
    teacherRated:   data['teacherRated'] ?? false,
  );
}
  Map<String, dynamic> toFirestore() => {
    'studentId': studentId,
    'teacherId': teacherId,
    'studentName': studentName,
    'teacherName': teacherName,
    'studentAvatar': studentAvatar,
    'teacherAvatar': teacherAvatar,
    'skill': skill,
    'scheduledAt': Timestamp.fromDate(scheduledAt),
    'durationMinutes': durationMinutes,
    'points': points,
    'status': status.name,
    'message': message,
    'createdAt': Timestamp.fromDate(createdAt),
    'studentRated': studentRated,
    'teacherRated': teacherRated,
  };

  SessionItem copyWith({
    SessionStatus? status,
    bool? studentRated,
    bool? teacherRated,
  }) => SessionItem(
    id: id,
    studentId: studentId,
    teacherId: teacherId,
    studentName: studentName,
    teacherName: teacherName,
    studentAvatar: studentAvatar,
    teacherAvatar: teacherAvatar,
    skill: skill,
    scheduledAt: scheduledAt,
    durationMinutes: durationMinutes,
    points: points,
    status: status ?? this.status,
    message: message,
    createdAt: createdAt,
    isOutgoing: isOutgoing,
    studentRated: studentRated ?? this.studentRated,
    teacherRated: teacherRated ?? this.teacherRated,
  );
}