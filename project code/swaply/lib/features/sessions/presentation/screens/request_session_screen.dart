import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sessions_controller.dart';
import '../../../../core/constants/app_colors.dart';

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

// ── Constants ───────────────────────────────────────────
const _durations = [
  _DurationOption('30 min', 30),
  _DurationOption('45 min', 45),
  _DurationOption('1 hr',   60),
  _DurationOption('1.5 hr', 90),
];

const _times = [
  '9:00 AM', '10:30 AM', '1:00 PM',
  '2:30 PM', '4:00 PM',  '5:30 PM', '7:00 PM',
];

class _DurationOption {
  final String label;
  final int    value;
  const _DurationOption(this.label, this.value);
}

// ── Screen ──────────────────────────────────────────────
class RequestSessionScreen extends StatefulWidget {
  /// Pass a [MentorArg] via Get.arguments or Get.toNamed args.
  final MentorArg mentor;

  const RequestSessionScreen({super.key, required this.mentor});

  @override
  State<RequestSessionScreen> createState() => _RequestSessionScreenState();
}

class _RequestSessionScreenState extends State<RequestSessionScreen> {
  final _ctrl    = Get.find<SessionsController>();
  final _msgCtrl = TextEditingController();

  late List<_DayOption> _days;

  @override
  void initState() {
    super.initState();
    _ctrl.resetForm();
    _ctrl.selectedSkill.value   = widget.mentor.skills.first;
    _ctrl.selectedMinutes.value = 60;

    _days = List.generate(7, (i) {
      final d = DateTime.now().add(Duration(days: i));
      return _DayOption(date: d);
    });
    _ctrl.selectedDate.value = _days[1].date;
    _ctrl.selectedTime.value = _times[3];
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  int get _cost => _ctrl.computeCost(widget.mentor.pricePerHour);

  // Replace with actual wallet balance from your user controller.
  int get _userPoints => 120;
  bool get _canAfford => _userPoints >= _cost;

  Future<void> _confirm() async {
    await _ctrl.requestSession(
      teacherId:     widget.mentor.id,
      teacherName:   widget.mentor.name,
      teacherAvatar: widget.mentor.avatarUrl,
      studentName:   'You',           // replace with current user's name
      studentAvatar: '',              // replace with current user's avatar
      pricePerHour:  widget.mentor.pricePerHour,
      message:       _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_ctrl.confirmed.value) return _ConfirmedView(mentorName: widget.mentor.name);

      return Scaffold(
        backgroundColor: AppColors.background,
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
                      _SkillSection(mentor: widget.mentor),
                      const SizedBox(height: 24),
                      _DateSection(days: _days),
                      const SizedBox(height: 24),
                      _TimeSection(),
                      const SizedBox(height: 24),
                      _DurationSection(),
                      const SizedBox(height: 24),
                      _MessageSection(controller: _msgCtrl),
                      const SizedBox(height: 24),
                      _CostSummary(
                        pricePerHour: widget.mentor.pricePerHour,
                        userPoints:   _userPoints,
                        cost:         _cost,
                        canAfford:    _canAfford,
                      ),
                      if (_ctrl.errorMsg.value != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _ctrl.errorMsg.value!,
                          style: const TextStyle(fontSize: 12, color: AppColors.rose),
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
            decoration: const BoxDecoration(
              color:  AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Obx(() => GestureDetector(
              onTap: (_canAfford && !_ctrl.isLoading.value) ? _confirm : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height:   52,
                decoration: BoxDecoration(
                  color: _canAfford
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: _ctrl.isLoading.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _canAfford ? 'Confirm · $_cost pts' : 'Not enough points',
                        style: const TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.w700,
                          color:      Colors.white,
                        ),
                      ),
              ),
            )),
          ),
        ),
      );
    });
  }
}

// ── Section widgets ──────────────────────────────────────

class _Header extends StatelessWidget {
  final String mentorName;
  const _Header({required this.mentorName});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back, color: AppColors.text),
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Request Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
                Text('with $mentorName', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ],
        ),
      );
}

class _SkillSection extends StatelessWidget {
  final MentorArg mentor;
  const _SkillSection({required this.mentor});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Skill'),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8, runSpacing: 8,
          children: mentor.skills.map((s) => _ToggleChip(
            label:    s,
            selected: ctrl.selectedSkill.value == s,
            onTap:    () => ctrl.selectedSkill.value = s,
          )).toList(),
        )),
      ],
    );
  }
}

class _DateSection extends StatelessWidget {
  final List<_DayOption> days;
  const _DateSection({required this.days});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Date'),
        const SizedBox(height: 8),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount:       days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = days[i];
              return Obx(() {
                final sel = ctrl.selectedDate.value?.day == d.date.day &&
                            ctrl.selectedDate.value?.month == d.date.month;
                return GestureDetector(
                  onTap: () => ctrl.selectedDate.value = d.date,
                  child: AnimatedContainer(
                    duration:    const Duration(milliseconds: 150),
                    width:       54,
                    decoration: BoxDecoration(
                      color:        sel ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border:       Border.all(color: sel ? AppColors.primary : AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(d.dow,   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: sel ? Colors.white70 : AppColors.muted)),
                        const SizedBox(height: 2),
                        Text('${d.date.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.text)),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}

class _TimeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Time'),
        const SizedBox(height: 8),
        Obx(() => GridView.count(
          physics:      const NeverScrollableScrollPhysics(),
          shrinkWrap:   true,
          crossAxisCount: 3,
          childAspectRatio: 2.8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: _times.map((t) => _ToggleChip(
            label:    t,
            selected: ctrl.selectedTime.value == t,
            onTap:    () => ctrl.selectedTime.value = t,
            radius:   12,
          )).toList(),
        )),
      ],
    );
  }
}

class _DurationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'Duration'),
        const SizedBox(height: 8),
        Obx(() => Row(
          children: List.generate(_durations.length, (i) {
            final d = _durations[i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _durations.length - 1 ? 8 : 0),
                child: _ToggleChip(
                  label:    d.label,
                  selected: ctrl.selectedMinutes.value == d.value,
                  onTap:    () => ctrl.selectedMinutes.value = d.value,
                  radius:   12,
                ),
              ),
            );
          }),
        )),
      ],
    );
  }
}

class _MessageSection extends StatelessWidget {
  final TextEditingController controller;
  const _MessageSection({required this.controller});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(text: 'Message (optional)'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color:        AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border:       Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: controller,
              maxLines:   3,
              decoration: const InputDecoration(
                hintText:        'Tell the mentor what you want to work on...',
                hintStyle:       TextStyle(color: AppColors.muted, fontSize: 13),
                contentPadding:  EdgeInsets.all(14),
                border:          InputBorder.none,
              ),
            ),
          ),
        ],
      );
}

class _CostSummary extends StatelessWidget {
  final int pricePerHour;
  final int userPoints;
  final int cost;
  final bool canAfford;

  const _CostSummary({
    required this.pricePerHour,
    required this.userPoints,
    required this.cost,
    required this.canAfford,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionsController>();
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _CostRow(icon: Icons.monetization_on_outlined, label: 'Price per hour', value: '$pricePerHour pts'),
          const SizedBox(height: 8),
          _CostRow(icon: Icons.access_time_outlined, label: 'Duration', value: '${ctrl.selectedMinutes.value} min'),
          const Padding(
            padding:  EdgeInsets.symmetric(vertical: 10),
            child:    Divider(color: AppColors.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total cost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
              Text('$cost pts', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child:   Divider(color: AppColors.border, height: 1),
          ),
          Row(
            children: [
              const Text('Your balance: ', style: TextStyle(fontSize: 12, color: AppColors.muted)),
              Text('$userPoints pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
              if (!canAfford) ...[
                const SizedBox(width: 8),
                const Text('Not enough points', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.rose)),
              ],
            ],
          ),
        ],
      ),
    ));
  }
}

// ── Confirmed view ───────────────────────────────────────

class _ConfirmedView extends StatelessWidget {
  final String mentorName;
  const _ConfirmedView({required this.mentorName});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 40, color: AppColors.green),
                ),
                const SizedBox(height: 20),
                const Text('Request sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
                const SizedBox(height: 8),
                Text(
                  'We notified $mentorName. You\'ll see this in Sessions once they accept.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 32),
                _BigBtn(label: 'View Sessions', filled: true,  onTap: () => Get.offNamed('/sessions')),
                const SizedBox(height: 10),
                _BigBtn(label: 'Back to Home', filled: false, onTap: () => Get.offAllNamed('/home')),
              ],
            ),
          ),
        ),
      );
}

// ── Shared atoms ─────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize:    10,
          fontWeight:  FontWeight.w700,
          letterSpacing: 0.8,
          color:       AppColors.muted,
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration:  const Duration(milliseconds: 130),
          padding:   const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:        selected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(radius),
            border:       Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      selected ? Colors.white : AppColors.text,
            ),
          ),
        ),
      );
}

class _CostRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _CostRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, size: 15, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          ]),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
        ],
      );
}

class _BigBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _BigBtn({required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height:     52,
          width:      double.infinity,
          alignment:  Alignment.center,
          decoration: BoxDecoration(
            color:        filled ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w700,
              color:      filled ? Colors.white : AppColors.text,
            ),
          ),
        ),
      );
}

// ── Day option helper ────────────────────────────────────

class _DayOption {
  final DateTime date;

  _DayOption({required this.date});

  String get dow {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
