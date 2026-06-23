import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus { accepted, waiting, ongoing, pending, completed, rejected }

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
      case SessionStatus.waiting:
        return 'Waiting';
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
  });

  // ── Role helper ──────────────────────────────
  SessionRole roleFor(String uid) =>
      uid == teacherId ? SessionRole.teacher : SessionRole.student;

  String personNameFor(String uid) =>
      uid == teacherId ? studentName : teacherName;

  String personAvatarFor(String uid) =>
      uid == teacherId ? studentAvatar : teacherAvatar;

  // ── Formatted helpers ────────────────────────
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final w = weekdays[scheduledAt.weekday - 1];
    final m = months[scheduledAt.month - 1];
    return '$w, $m ${scheduledAt.day}';
  }

  String get formattedTime {
    final h = scheduledAt.hour;
    final m = scheduledAt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }

  String get formattedDuration {
    if (durationMinutes < 60) return '$durationMinutes min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  // ── Firestore ────────────────────────────────
  // factory SessionModel.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return SessionModel(
  //     id: doc.id,
  //     studentId:     data['studentId']     ?? '',
  //     teacherId:     data['teacherId']     ?? '',
  //     studentName:   data['studentName']   ?? '',
  //     teacherName:   data['teacherName']   ?? '',
  //     studentAvatar: data['studentAvatar'] ?? '',
  //     teacherAvatar: data['teacherAvatar'] ?? '',
  //     skill:         data['skill']         ?? '',
  //     scheduledAt:   (data['scheduledAt'] as Timestamp).toDate(),
  //     durationMinutes: data['durationMinutes'] ?? 60,
  //     cost:          data['cost']          ?? 0,
  //     status: SessionStatusX.fromString(data['status'] ?? 'pending'),
  //     message:       data['message'],
  //     createdAt:     (data['createdAt'] as Timestamp).toDate(),
  //   );
  // }

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
  };

  SessionItem copyWith({SessionStatus? status}) => SessionItem(
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
    isOutgoing: isOutgoing
  );
}
