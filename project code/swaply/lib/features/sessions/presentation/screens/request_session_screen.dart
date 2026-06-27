import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_state.dart';

// ── Mentor stub (replace with your actual MentorModel) ──
class MentorArg {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> skills;
  final int pricePerHour;

  const MentorArg({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.skills,
    required this.pricePerHour,
  });
}

// ── Constants ─────────────────────────────────────────────
const _durations = [
  _DurationOption('30 min', 30),
  _DurationOption('45 min', 45),
  _DurationOption('1 hr', 60),
  _DurationOption('1.5 hr', 90),
];

const _times = [
  '9:00 AM',
  '10:30 AM',
  '1:00 PM',
  '2:30 PM',
  '4:00 PM',
  '5:30 PM',
  '7:00 PM',
];

class _DurationOption {
  final String label;
  final int value;
  const _DurationOption(this.label, this.value);
}

// ── Screen ────────────────────────────────────────────────
class RequestSessionScreen extends StatefulWidget {
  final MentorArg mentor;
  const RequestSessionScreen({super.key, required this.mentor});

  @override
  State<RequestSessionScreen> createState() => _RequestSessionScreenState();
}

class _RequestSessionScreenState extends State<RequestSessionScreen> {
  final _msgCtrl = TextEditingController();

  late List<_DayOption> _days;

  // ── Local form state ──
  late String _selectedSkill;
  late DateTime _selectedDate;
  String _selectedTime = _times[3];
  int _selectedMinutes = 60;

  // ── UI state ──
  bool _isLoading = false;
  String? _errorMsg;
  bool _confirmed = false;

  // Replace with actual wallet balance from your user controller.
  int get _userPoints => 120;

  int get _cost {
    final hours = _selectedMinutes / 60;
    return (widget.mentor.pricePerHour * hours).round();
  }

  bool get _canAfford => _userPoints >= _cost;

  @override
  void initState() {
    super.initState();
    _selectedSkill = widget.mentor.skills.first;
    _days = List.generate(
      7,
      (i) => _DayOption(date: DateTime.now().add(Duration(days: i))),
    );
    _selectedDate = _days[1].date;
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    try {
      await context.read<SessionsCubit>().requestSession(
        teacherId: widget.mentor.id,
        teacherName: widget.mentor.name,
        teacherAvatar: widget.mentor.avatarUrl,
        studentName: 'You', // replace with current user's name
        studentAvatar: '', // replace with current user's avatar
        skill: _selectedSkill,
        scheduledAt: scheduledAt,
        durationMinutes: _selectedMinutes,
        pricePerHour: widget.mentor.pricePerHour,
        message: _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim(),
      );
    } catch (_) {
      setState(() => _errorMsg = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<SessionsCubit, SessionsState>(
      listener: (context, state) {
        if (state is SessionRequestSuccess) {
          setState(() => _confirmed = true);
        } else if (state is SessionsError) {
          setState(() {
            _errorMsg = state.message;
            _isLoading = false;
          });
        }
      },
      child: _confirmed
          ? _ConfirmedView(mentorName: widget.mentor.name)
          : Scaffold(
              backgroundColor: colors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    _Header(mentorName: widget.mentor.name),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SkillSection(
                              mentor: widget.mentor,
                              selectedSkill: _selectedSkill,
                              onSelect: (s) =>
                                  setState(() => _selectedSkill = s),
                            ),
                            const SizedBox(height: 24),
                            _DateSection(
                              days: _days,
                              selectedDate: _selectedDate,
                              onSelect: (d) =>
                                  setState(() => _selectedDate = d),
                            ),
                            const SizedBox(height: 24),
                            _TimeSection(
                              selectedTime: _selectedTime,
                              onSelect: (t) =>
                                  setState(() => _selectedTime = t),
                            ),
                            const SizedBox(height: 24),
                            _DurationSection(
                              selectedMinutes: _selectedMinutes,
                              onSelect: (m) =>
                                  setState(() => _selectedMinutes = m),
                            ),
                            const SizedBox(height: 24),
                            _MessageSection(controller: _msgCtrl),
                            const SizedBox(height: 24),
                            _CostSummary(
                              pricePerHour: widget.mentor.pricePerHour,
                              userPoints: _userPoints,
                              cost: _cost,
                              canAfford: _canAfford,
                              selectedMinutes: _selectedMinutes,
                            ),
                            if (_errorMsg != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _errorMsg!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.rose,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    border: Border(top: BorderSide(color: colors.border)),
                  ),
                  child: GestureDetector(
                    onTap: (_canAfford && !_isLoading) ? _confirm : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 52,
                      decoration: BoxDecoration(
                        color: _canAfford
                            ? colors.primary
                            : colors.primary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _canAfford
                                  ? 'Confirm · $_cost pts'
                                  : 'Not enough points',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ── Section widgets ───────────────────────────────────────

class _Header extends StatelessWidget {
  final String mentorName;
  const _Header({required this.mentorName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: colors.text),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Session',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.text,
                ),
              ),
              Text(
                'with $mentorName',
                style: TextStyle(fontSize: 12, color: colors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillSection extends StatelessWidget {
  final MentorArg mentor;
  final String selectedSkill;
  final ValueChanged<String> onSelect;

  const _SkillSection({
    required this.mentor,
    required this.selectedSkill,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionLabel(text: 'Skill'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: mentor.skills
            .map(
              (s) => _ToggleChip(
                label: s,
                selected: selectedSkill == s,
                onTap: () => onSelect(s),
              ),
            )
            .toList(),
      ),
    ],
  );
}

class _DateSection extends StatelessWidget {
  final List<_DayOption> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  const _DateSection({
    required this.days,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Date'),
        const SizedBox(height: 8),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = days[i];
              final sel =
                  selectedDate.day == d.date.day &&
                  selectedDate.month == d.date.month;
              return GestureDetector(
                onTap: () => onSelect(d.date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 54,
                  decoration: BoxDecoration(
                    color: sel ? colors.primary : colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? colors.primary : colors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        d.dow,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: sel ? Colors.white70 : colors.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d.date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : colors.text,
                        ),
                      ),
                    ],
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

class _TimeSection extends StatelessWidget {
  final String selectedTime;
  final ValueChanged<String> onSelect;

  const _TimeSection({required this.selectedTime, required this.onSelect});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionLabel(text: 'Time'),
      const SizedBox(height: 8),
      GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 2.8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: _times
            .map(
              (t) => _ToggleChip(
                label: t,
                selected: selectedTime == t,
                onTap: () => onSelect(t),
                radius: 12,
              ),
            )
            .toList(),
      ),
    ],
  );
}

class _DurationSection extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onSelect;

  const _DurationSection({
    required this.selectedMinutes,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionLabel(text: 'Duration'),
      const SizedBox(height: 8),
      Row(
        children: List.generate(_durations.length, (i) {
          final d = _durations[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i < _durations.length - 1 ? 8 : 0,
              ),
              child: _ToggleChip(
                label: d.label,
                selected: selectedMinutes == d.value,
                onTap: () => onSelect(d.value),
                radius: 12,
              ),
            ),
          );
        }),
      ),
    ],
  );
}

class _MessageSection extends StatelessWidget {
  final TextEditingController controller;
  const _MessageSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Message (optional)'),
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

class _CostSummary extends StatelessWidget {
  final int pricePerHour;
  final int userPoints;
  final int cost;
  final bool canAfford;
  final int selectedMinutes;

  const _CostSummary({
    required this.pricePerHour,
    required this.userPoints,
    required this.cost,
    required this.canAfford,
    required this.selectedMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _CostRow(
            icon: Icons.monetization_on_outlined,
            label: 'Price per hour',
            value: '$pricePerHour pts',
          ),
          const SizedBox(height: 8),
          _CostRow(
            icon: Icons.access_time_outlined,
            label: 'Duration',
            value: '$selectedMinutes min',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: colors.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total cost',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              Text(
                '$cost pts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: colors.border, height: 1),
          ),
          Row(
            children: [
              Text(
                'Your balance: ',
                style: TextStyle(fontSize: 12, color: colors.muted),
              ),
              Text(
                '$userPoints pts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              if (!canAfford) ...[
                const SizedBox(width: 8),
                Text(
                  'Not enough points',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.rose,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Confirmed view ────────────────────────────────────────

class _ConfirmedView extends StatelessWidget {
  final String mentorName;
  const _ConfirmedView({required this.mentorName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.greenBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 40, color: colors.green),
              ),
              const SizedBox(height: 20),
              Text(
                'Request sent!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We notified $mentorName. You'll see this in Sessions once they accept.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.muted),
              ),
              const SizedBox(height: 32),
              _BigBtn(
                label: 'View Sessions',
                filled: true,
                onTap: () => Navigator.of(context).pushNamed('/sessions'),
              ),
              const SizedBox(height: 10),
              _BigBtn(
                label: 'Back to Home',
                filled: false,
                onTap: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (_) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared atoms ──────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      color: context.colors.muted,
    ),
  );
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double radius;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.card,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : colors.text,
          ),
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _CostRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: colors.muted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: colors.muted)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
      ],
    );
  }
}

class _BigBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _BigBtn({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? colors.primary : colors.background,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: filled ? Colors.white : colors.text,
          ),
        ),
      ),
    );
  }
}

// ── Day option helper ─────────────────────────────────────

class _DayOption {
  final DateTime date;
  _DayOption({required this.date});

  String get dow {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
