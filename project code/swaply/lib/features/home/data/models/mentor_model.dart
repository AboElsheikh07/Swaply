class MentorModel {
  final String id;
  final String name;
  final String skill;
  final String rate;
  final double rating;
  final int reviews;
  final bool online;
  final String? imageUrl;

  const MentorModel({
    required this.id,
    required this.name,
    required this.skill,
    required this.rate,
    required this.rating,
    required this.reviews,
    this.online = false,
    this.imageUrl,
  });

  // لما تربط Firebase بتستخدم الـ fromFirestore ده
  factory MentorModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MentorModel(
      id: id,
      name: data['name'] ?? '',
      skill: data['skill'] ?? '',
      rate: data['rate'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      online: data['online'] ?? false,
      imageUrl: data['imageUrl'],
    );
  }
}
