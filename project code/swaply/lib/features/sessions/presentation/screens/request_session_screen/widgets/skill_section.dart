import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/shared_atoms/section_label.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

class SkillSection extends StatelessWidget {
  final UserModel mentor;
  final String selectedSkill;
  final ValueChanged<String> onSelect;

  const SkillSection({
    super.key,
    required this.mentor,
    required this.selectedSkill,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Skill'),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: mentor.skillsCanTeach.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final skill = mentor.skillsCanTeach[i];
              final selected = selectedSkill == skill;
              return GestureDetector(
                onTap: () => onSelect(skill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? colors.primary : colors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? colors.primary : colors.border,
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : colors.text,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
