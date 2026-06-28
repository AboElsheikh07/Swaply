import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String avatarUrl;
  final List<String> skillsCanTeach;
  final List<String> skillsWantsToLearn;
  final int balance;
  final int pricePerHour;
  final bool onboardingComplete;
  final bool isPublic;
  final double ratingAvg;
  final int ratingCount;

  const UserModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.skillsCanTeach,
    required this.skillsWantsToLearn,
    required this.balance,
    required this.pricePerHour,
    required this.onboardingComplete,
    required this.isPublic,
    required this.ratingAvg,
    required this.ratingCount,
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
        pricePerHour:       0,
        onboardingComplete: false,
        isPublic:           false,
        ratingAvg:          0.0,
        ratingCount:        0,
      );

  /// Called after signup — sets initial values for a brand new user.
  /// onboardingComplete starts false; completeOnboarding() flips it to true.
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
        pricePerHour:       0,
        onboardingComplete: false,
        isPublic:           false,
        ratingAvg:          0.0,
        ratingCount:        0,
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
      pricePerHour:       data['pricePerHour']        ?? 0,
      onboardingComplete: data['onboardingComplete']  ?? false,
      isPublic:           data['isPublic']             ?? false,
      ratingAvg:          (data['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount:        data['ratingCount']          ?? 0,
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
        'pricePerHour':       pricePerHour,
        'onboardingComplete': onboardingComplete,
        'isPublic':           isPublic,
        'ratingAvg':          ratingAvg,
        'ratingCount':        ratingCount,
      };

  // ── copyWith ──────────────────────────────

  UserModel copyWith({
    String?       id,
    String?       username,
    String?       avatarUrl,
    List<String>? skillsCanTeach,
    List<String>? skillsWantsToLearn,
    int?          balance,
    int?          pricePerHour,
    bool?         onboardingComplete,
    bool?         isPublic,
    double?       ratingAvg,
    int?          ratingCount,
  }) =>
      UserModel(
        id:                 id                 ?? this.id,
        username:           username           ?? this.username,
        avatarUrl:          avatarUrl          ?? this.avatarUrl,
        skillsCanTeach:     skillsCanTeach     ?? this.skillsCanTeach,
        skillsWantsToLearn: skillsWantsToLearn ?? this.skillsWantsToLearn,
        balance:            balance            ?? this.balance,
        pricePerHour:       pricePerHour       ?? this.pricePerHour,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        isPublic:           isPublic           ?? this.isPublic,
        ratingAvg:          ratingAvg          ?? this.ratingAvg,
        ratingCount:        ratingCount        ?? this.ratingCount,
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
      'UserModel(id: $id, username: $username, balance: $balance, '
      'pricePerHour: $pricePerHour, onboardingComplete: $onboardingComplete)';
}