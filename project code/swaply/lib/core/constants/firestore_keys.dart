/// All Firestore collection / field keys in one place.
/// Use these instead of raw strings to avoid typos.
abstract class FirestoreKeys {
  FirestoreKeys._();

  // Collections
  static const String sessions = 'sessions';
  static const String users    = 'users';

  // Session fields
  static const String studentId       = 'studentId';
  static const String teacherId       = 'teacherId';
  static const String studentName     = 'studentName';
  static const String teacherName     = 'teacherName';
  static const String studentAvatar   = 'studentAvatar';
  static const String teacherAvatar   = 'teacherAvatar';
  static const String skill           = 'skill';
  static const String scheduledAt     = 'scheduledAt';
  static const String durationMinutes = 'durationMinutes';
  static const String cost            = 'cost';
  static const String status          = 'status';
  static const String message         = 'message';
  static const String createdAt       = 'createdAt';
}
