// خريطة ثابتة: كل category مرتبط بمجموعة skills.
// لو اليوزر مضيف أي skill من القايمة دي في skillsCanTeach بتاعه،
// بيتحسب ضمن الـ category ده.
//
// ✅ زوّد/عدّل الأسماء هنا حسب الـ skills الفعلية اللي عندكم في الـ onboarding
const Map<String, List<String>> categorySkillsMap = {
  'Programming': [
    'Flutter', 'Dart', 'JavaScript', 'TypeScript', 'Python', 'Java',
    'Kotlin', 'Swift', 'React', 'React Native', 'Node.js', 'Next.js',
    'C++', 'C#', 'PHP', 'Ruby', 'Go', 'Rust', 'SQL', 'Firebase',
    'Web Development', 'Mobile Development', 'Backend Development',
  ],
  'Design': [
    'UI/UX Design', 'UI Design', 'UX Design', 'Graphic Design',
    'Figma', 'Adobe XD', 'Illustrator', 'Photoshop', 'Branding',
    'Product Design', 'Motion Design', 'Web Design',
  ],
  'Languages': [
    'English', 'Arabic', 'Spanish', 'French', 'German',
    'Italian', 'Chinese', 'Japanese', 'Turkish', 'Translation',
  ],
  'Music': [
    'Guitar', 'Piano', 'Violin', 'Singing', 'Music Production',
    'Drums', 'Music Theory', 'Oud', 'DJing',
  ],
  'Business': [
    'Marketing', 'Digital Marketing', 'SEO', 'Sales', 'Finance',
    'Accounting', 'Entrepreneurship', 'Project Management',
    'Public Speaking', 'Copywriting', 'Social Media Marketing',
  ],
  'Fitness & Wellness': [
    'Yoga', 'Fitness Training', 'Nutrition', 'Meditation',
    'Personal Training', 'Pilates', 'Mental Health Coaching',
  ],
  'Photography': [
    'Photography', 'Video Editing', 'Photo Editing', 'Videography',
    'Cinematography',
  ],
  'Cooking': [
    'Cooking', 'Baking', 'Pastry', 'Nutrition Coaching',
  ],
};

// بيرجعلك اسم الـ category اللي الـ skill ده تابعها
String? categoryForSkill(String skill) {
  final normalized = skill.trim().toLowerCase();
  for (final entry in categorySkillsMap.entries) {
    if (entry.value.any((s) => s.toLowerCase() == normalized)) {
      return entry.key;
    }
  }
  return null;
}

// بيرجعلك كل الـ skills التابعة لـ category معين (بحروف صغيرة، للمقارنة)
List<String> skillsInCategory(String categoryName) {
  return (categorySkillsMap[categoryName] ?? [])
      .map((s) => s.toLowerCase())
      .toList();
}
