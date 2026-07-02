class ProfileState {
  final String language;
  final bool isDarkMode;

  const ProfileState({
    required this.language,
    required this.isDarkMode,
  });

  factory ProfileState.initial({bool isDarkMode = false}) {
    return ProfileState(
      language: 'English',
      isDarkMode: isDarkMode,
    );
  }

  ProfileState copyWith({
    String? language,
    bool? isDarkMode,
  }) {
    return ProfileState(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  List<Object?> get props => [language, isDarkMode];
}