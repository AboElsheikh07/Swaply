
import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/shared_atoms/section_label.dart';

class MessageSection extends StatelessWidget {
  final TextEditingController controller;
  const MessageSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Message (optional)'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tell the mentor what you want to work on...',
              hintStyle: TextStyle(color: colors.muted, fontSize: 13),
              contentPadding: const EdgeInsets.all(14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}