class MentorDetailsModel {
  final String id;
  final String name;
  final String skill;
  final String rate;
  final double rating;
  final int reviews;
  final bool online;
  final String bio;
  final List<String> skills;
  final int pricePerHour;
  final String? imageUrl;

  const MentorDetailsModel({
    required this.id,
    required this.name,
    required this.skill,
    required this.rate,
    required this.rating,
    required this.reviews,
    required this.online,
    required this.bio,
    required this.skills,
    required this.pricePerHour,
    this.imageUrl,
  });

  factory MentorDetailsModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MentorDetailsModel(
      id: id,
      name: data['name'] ?? '',
      skill: data['skill'] ?? '',
      rate: data['rate'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      online: data['online'] ?? false,
      bio: data['bio'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      pricePerHour: data['pricePerHour'] ?? 0,
      imageUrl: data['imageUrl'],
    );
  }
}

class ReviewModel {
  final String name;
  final String text;
  final double rating;

  const ReviewModel({
    required this.name,
    required this.text,
    required this.rating,
  });
}
