import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/shared_atoms/section_label.dart';

class TimeSection extends StatelessWidget {
  final String selectedTime;
  final ValueChanged<String> onSelect;

  const TimeSection({
    super.key,
    required this.selectedTime,
    required this.onSelect,
  });

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  Future<void> _pick(BuildContext context) async {
    final colors = context.colors;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Theme the native picker to match your app colors
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primary,
              onPrimary: Colors.white,
              surface: colors.card,
              onSurface: colors.text,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: colors.card,
              hourMinuteColor: colors.primarySoft,
              hourMinuteTextColor: colors.primary,
              dialBackgroundColor: colors.primarySoft,
              dialHandColor: colors.primary,
              dialTextColor: colors.text,
              entryModeIconColor: colors.primary,
              dayPeriodColor: colors.primarySoft,
              dayPeriodTextColor: colors.primary,
              dayPeriodBorderSide: BorderSide(color: colors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelect(_formatTime(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasTime = selectedTime.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Time'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pick(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasTime ? colors.primarySoft : colors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasTime ? colors.primary : colors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: hasTime ? colors.primary : colors.muted,
                ),
                const SizedBox(width: 10),
                Text(
                  hasTime ? selectedTime : 'Select a time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasTime ? colors.primary : colors.muted,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: hasTime ? colors.primary : colors.muted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
