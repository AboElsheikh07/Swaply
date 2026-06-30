enum SkillTag { hot, newSkill, popular }

class SkillModel {
  final String id;
  final String name;
  final String count;
  final SkillTag tag;

  const SkillModel({
    required this.id,
    required this.name,
    required this.count,
    required this.tag,
  });

  factory SkillModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SkillModel(
      id: id,
      name: data['name'] ?? '',
      count: data['count'] ?? '',
      tag: SkillTag.values.firstWhere(
        (e) => e.name == data['tag'],
        orElse: () => SkillTag.popular,
      ),
    );
  }
}

class SearchMentorModel {
  final String id;
  final String name;
  final String skill;
  final String rate;
  final double rating;
  final String avatarUrl; // ← أضفنا الصورة

  const SearchMentorModel({
    required this.id,
    required this.name,
    required this.skill,
    required this.rate,
    required this.rating,
    this.avatarUrl = '',
  });

  // بيتبنى من UserModel الـ Firestore doc
  factory SearchMentorModel.fromUserDoc(Map<String, dynamic> data, String id) {
    final skills = List<String>.from(data['skillsCanTeach'] ?? []);
    return SearchMentorModel(
      id:        id,
      name:      data['username']     ?? '',
      skill:     skills.isNotEmpty ? skills.first : '',
      rate:      '${data['pricePerHour'] ?? 0} pts/hr',
      rating:    (data['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      avatarUrl: data['avatarUrl']    ?? '',
    );
  }
}
