import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String avatarUrl;
  final List<String> skillsCanTeach;
  final List<String> skillsWantsToLearn;
  final int balance;

  const UserModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.skillsCanTeach,
    required this.skillsWantsToLearn,
    required this.balance,
  });

  // ── Factories ─────────────────────────────

  /// Safe default before Firestore loads — avoids null checks everywhere
  factory UserModel.empty() => const UserModel(
        id:                 '',
        username:           '',
        avatarUrl:          '',
        skillsCanTeach:     [],
        skillsWantsToLearn: [],
        balance:            50,
      );

  /// Called after signup — sets initial values for a brand new user
  factory UserModel.initial({
    required String id,
    required String username,
    String avatarUrl = '',
  }) => UserModel(
        id:                 id,
        username:           username,
        avatarUrl:          avatarUrl,
        skillsCanTeach:     const [],
        skillsWantsToLearn: const [],
        balance:            50, // ✅ every new user starts with 50 pts
      );

  /// Deserialize from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id:                 doc.id,
      username:           data['username']            ?? '',
      avatarUrl:          data['avatarUrl']           ?? '',
      skillsCanTeach:     List<String>.from(data['skillsCanTeach']     ?? []),
      skillsWantsToLearn: List<String>.from(data['skillsWantsToLearn'] ?? []),
      balance:            data['balance']             ?? 50,
    );
  }

  // ── Serialization ─────────────────────────

  /// Used when writing to Firestore (signup or profile update)
  Map<String, dynamic> toFirestore() => {
        'username':           username,
        'avatarUrl':          avatarUrl,
        'skillsCanTeach':     skillsCanTeach,
        'skillsWantsToLearn': skillsWantsToLearn,
        'balance':            balance,
      };

  // ── copyWith ──────────────────────────────

  UserModel copyWith({
    String?       id,
    String?       username,
    String?       avatarUrl,
    List<String>? skillsCanTeach,
    List<String>? skillsWantsToLearn,
    int?          balance,
  }) =>
      UserModel(
        id:                 id                 ?? this.id,
        username:           username           ?? this.username,
        avatarUrl:          avatarUrl          ?? this.avatarUrl,
        skillsCanTeach:     skillsCanTeach     ?? this.skillsCanTeach,
        skillsWantsToLearn: skillsWantsToLearn ?? this.skillsWantsToLearn,
        balance:            balance            ?? this.balance,
      );

  // ── Helpers ───────────────────────────────

  /// Check if a real user is loaded yet
  bool get isEmpty    => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  /// Used in Explore screen to filter teachers by skill
  bool canTeach(String skill) =>
      skillsCanTeach.any((s) => s.toLowerCase() == skill.toLowerCase());

  /// Used for matching / recommendations
  bool wantsToLearn(String skill) =>
      skillsWantsToLearn.any((s) => s.toLowerCase() == skill.toLowerCase());

  /// Used in RequestSessionScreen instead of hardcoded _userPoints
  bool canAfford(int cost) => balance >= cost;

  // ── Equality ──────────────────────────────

  /// Proper equality by id so BLoC doesn't re-emit identical states
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, username: $username, balance: $balance)';
}