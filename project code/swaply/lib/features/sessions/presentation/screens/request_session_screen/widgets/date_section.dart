import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/shared_atoms/section_label.dart';
import 'package:intl/intl.dart';

class DateSection extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  const DateSection({
    super.key,
    required this.selectedDate,
    required this.onSelect,
  });

  Future<void> _pick(BuildContext context) async {
    final colors = context.colors;
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: now,                                    // can't book in the past
      lastDate: now.add(const Duration(days: 60)),       // max 2 months ahead
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primary,
              onPrimary: Colors.white,
              surface: colors.card,
              onSurface: colors.text,
              outline: colors.border,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: colors.card,
              headerBackgroundColor: colors.primary,
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                if (states.contains(WidgetState.disabled)) return colors.muted;
                return colors.text;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return colors.primary;
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateProperty.all(colors.primary),
              todayBackgroundColor: WidgetStateProperty.all(colors.primarySoft),
              todayBorder: BorderSide(color: colors.primary),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return colors.text;
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return colors.primary;
                return Colors.transparent;
              }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              dividerColor: colors.border,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) onSelect(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Date'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pick(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.primary),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    size: 18, color: colors.primary),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(selectedDate),         // Monday
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.primary.withValues(alpha:0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(selectedDate),  // Jun 12, 2025
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: colors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}