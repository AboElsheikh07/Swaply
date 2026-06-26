import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalDataSource {
  static const _skillsKey = 'offered_skills';
  static const _themeKey = 'is_dark_mode';
  static const _imageKey = 'profile_image_path';

  Future<void> saveSkills(List<String> skills) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_skillsKey, skills);
  }

  Future<List<String>> getSkills() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_skillsKey) ?? [];
  }

  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imageKey, path);
  }

  Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_imageKey);
  }
}
