import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String avatarUrl;
  final bool online;
  final List<String> skillsCanTeach;
  final List<String> skillsWantsToLearn;
  final int balance;
  final int heldBalance; // points reserved for accepted-but-not-yet-completed
  // sessions; spendable balance is balance - heldBalance
  final int pricePerHour;
  final bool onboardingComplete;
  final bool isPublic;
  final double ratingAvg;
  final int ratingCount;

  const UserModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.online,
    required this.skillsCanTeach,
    required this.skillsWantsToLearn,
    required this.balance,
    required this.heldBalance,
    required this.pricePerHour,
    required this.onboardingComplete,
    required this.isPublic,
    required this.ratingAvg,
    required this.ratingCount,
  });

  // ── Factories ─────────────────────────────

  /// Safe default before Firestore loads — avoids null checks everywhere
  factory UserModel.empty() => const UserModel(
    id: '',
    username: '',
    avatarUrl: '',
    online: false,
    skillsCanTeach: [],
    skillsWantsToLearn: [],
    balance: 50,
    heldBalance: 0,
    pricePerHour: 0,
    onboardingComplete: false,
    isPublic: false,
    ratingAvg: 0.0,
    ratingCount: 0,
  );

  /// Called after signup — sets initial values for a brand new user.
  /// onboardingComplete starts false; completeOnboarding() flips it to true.
  factory UserModel.initial({
    required String id,
    required String username,
    String avatarUrl = '',
  }) => UserModel(
    id: id,
    username: username,
    avatarUrl: avatarUrl,
    online: false,
    skillsCanTeach: const [],
    skillsWantsToLearn: const [],
    balance: 50, // ✅ every new user starts with 50 pts
    heldBalance: 0,
    pricePerHour: 0,
    onboardingComplete: false,
    isPublic: false,
    ratingAvg: 0.0,
    ratingCount: 0,
  );

  /// Deserialize from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      online: data['online'] as bool? ?? false,
      skillsCanTeach: List<String>.from(data['skillsCanTeach'] ?? []),
      skillsWantsToLearn: List<String>.from(data['skillsWantsToLearn'] ?? []),
      balance: data['balance'] ?? 50,
      heldBalance: data['heldBalance'] ?? 0,
      pricePerHour: data['pricePerHour'] ?? 0,
      onboardingComplete: data['onboardingComplete'] ?? false,
      isPublic: data['isPublic'] ?? false,
      ratingAvg: (data['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: data['ratingCount'] ?? 0,
    );
  }

  // ── Serialization ─────────────────────────

  /// Used when writing to Firestore (signup or profile update)
  Map<String, dynamic> toFirestore() => {
    'username': username,
    'avatarUrl': avatarUrl,
    'online': online,
    'skillsCanTeach': skillsCanTeach,
    'skillsWantsToLearn': skillsWantsToLearn,
    'balance': balance,
    'heldBalance': heldBalance,
    'pricePerHour': pricePerHour,
    'onboardingComplete': onboardingComplete,
    'isPublic': isPublic,
    'ratingAvg': ratingAvg,
    'ratingCount': ratingCount,
  };

  // ── copyWith ──────────────────────────────

  UserModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    bool? online,
    List<String>? skillsCanTeach,
    List<String>? skillsWantsToLearn,
    int? balance,
    int? heldBalance,
    int? pricePerHour,
    bool? onboardingComplete,
    bool? isPublic,
    double? ratingAvg,
    int? ratingCount,
  }) => UserModel(
    id: id ?? this.id,
    username: username ?? this.username,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    online: online ?? this.online,
    skillsCanTeach: skillsCanTeach ?? this.skillsCanTeach,
    skillsWantsToLearn: skillsWantsToLearn ?? this.skillsWantsToLearn,
    balance: balance ?? this.balance,
    heldBalance: heldBalance ?? this.heldBalance,
    pricePerHour: pricePerHour ?? this.pricePerHour,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    isPublic: isPublic ?? this.isPublic,
    ratingAvg: ratingAvg ?? this.ratingAvg,
    ratingCount: ratingCount ?? this.ratingCount,
  );

  // ── Helpers ───────────────────────────────

  /// Check if a real user is loaded yet
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  /// Used in Explore screen to filter teachers by skill
  bool canTeach(String skill) =>
      skillsCanTeach.any((s) => s.toLowerCase() == skill.toLowerCase());

  /// Used for matching / recommendations
  bool wantsToLearn(String skill) =>
      skillsWantsToLearn.any((s) => s.toLowerCase() == skill.toLowerCase());

  /// Points actually available to spend right now — total balance minus
  /// whatever's currently held for accepted-but-not-yet-completed sessions.
  int get spendableBalance => balance - heldBalance;

  /// Used in RequestSessionScreen instead of hardcoded _userPoints
  bool canAfford(int cost) => spendableBalance >= cost;

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
