class ProfileState {
  final String name;
  final String email;
  final int points;
  final double rating;
  final int taught;
  final int learned;
  final List<String> offeredSkills;
  final String language;
  final bool isDarkMode;
  final String? profileImagePath;

  const ProfileState({
    required this.name,
    required this.email,
    required this.points,
    required this.rating,
    required this.taught,
    required this.learned,
    required this.offeredSkills,
    required this.language,
    required this.isDarkMode,
    this.profileImagePath,
  });

  factory ProfileState.initial({bool isDarkMode = false}) {
    return ProfileState(
      name: 'Jonathan Patterson',
      email: 'jonathan@swaply.app',
      points: 480,
      rating: 4.9,
      taught: 22,
      learned: 15,
      offeredSkills: const ['UI Design', 'Figma', 'Design Systems'],
      language: 'English',
      isDarkMode: isDarkMode,
      profileImagePath: null,
    );
  }

  ProfileState copyWith({
    String? name,
    String? email,
    int? points,
    double? rating,
    int? taught,
    int? learned,
    List<String>? offeredSkills,
    String? language,
    bool? isDarkMode,
    String? profileImagePath,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      points: points ?? this.points,
      rating: rating ?? this.rating,
      taught: taught ?? this.taught,
      learned: learned ?? this.learned,
      offeredSkills: offeredSkills ?? this.offeredSkills,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
