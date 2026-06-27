class UserModel {
  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final int points;
  final List<dynamic> skills;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.points,
    required this.skills,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      points: json['points'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}
