import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/shared_atoms/section_label.dart';

class DurationSection extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onSelect;

  const DurationSection({
    super.key,
    required this.selectedMinutes,
    required this.onSelect,
  });

  String _format(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label + selected value ───────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel(text: 'Duration'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _format(selectedMinutes),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Slider ───────────────────────────
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colors.primary,
            inactiveTrackColor: colors.primarySoft,
            thumbColor: colors.primary,
            overlayColor: colors.primary.withValues(alpha: 0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
          ),
          child: Slider(
            min: 15,
            max: 180,
            divisions:
                11, // 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180
            value: selectedMinutes.toDouble(),
            onChanged: (v) => onSelect(v.round()),
          ),
        ),

        // ── Min / Max labels ─────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '15 min',
                style: TextStyle(fontSize: 11, color: colors.muted),
              ),

              Text('3 hr', style: TextStyle(fontSize: 11, color: colors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}
