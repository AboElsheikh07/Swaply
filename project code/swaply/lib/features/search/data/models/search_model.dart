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
  final bool online;

  const SearchMentorModel({
    required this.id,
    required this.name,
    required this.skill,
    required this.rate,
    required this.rating,
    this.online = false,
  });

  factory SearchMentorModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SearchMentorModel(
      id: id,
      name: data['name'] ?? '',
      skill: data['skill'] ?? '',
      rate: data['rate'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      online: data['online'] ?? false,
    );
  }
}
