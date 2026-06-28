import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';

import 'package:swaply/features/user/cubit/user_cubit.dart';
import 'package:swaply/features/user/cubit/user_state.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_cubit.dart';
import 'package:swaply/features/sessions/presentation/controllers/cubit/sessions_state.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/helpers.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/views/confirmed_view.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/widgets/cost_summary_section.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/widgets/date_section.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/widgets/duration_section.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/widgets/header_section.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/widgets/message_section.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/widgets/skill_section.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/widgets/time_section.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

// ── Screen ────────────────────────────────────────────────

class RequestSessionScreen extends StatefulWidget {
  final UserModel mentor;
  const RequestSessionScreen({super.key, required this.mentor});

  @override
  State<RequestSessionScreen> createState() => _RequestSessionScreenState();
}

class _RequestSessionScreenState extends State<RequestSessionScreen> {
  final _msgCtrl = TextEditingController();

  late List<DayOption> _days;

  // ── Local form state ──
  late String _selectedSkill;
  late DateTime _selectedDate;
  String _selectedTime = times[0];
  int _selectedMinutes = 60;

  // ── UI state ──
  bool _isLoading = false;
  String? _errorMsg;
  bool _confirmed = false;

  int get _cost {
    final hours = _selectedMinutes / 60;
    return (widget.mentor.pricePerHour * hours).round();
  }

  @override
  void initState() {
    super.initState();
    _selectedSkill = widget.mentor.skillsCanTeach.isNotEmpty
        ? widget.mentor.skillsCanTeach.first
        : '';
    _days = List.generate(
      7,
      (i) => DayOption(date: DateTime.now().add(Duration(days: i))),
    );
    _selectedDate = _days[0].date;
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

    final user = context.read<UserCubit>().currentUser;

    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    try {
      await context.read<SessionsCubit>().requestSession(
        teacherId: widget.mentor.id,
        teacherName: widget.mentor.username,
        teacherAvatar: widget.mentor.avatarUrl,
        studentName: user.username,
        studentAvatar: user.avatarUrl,
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

    // ✅ watch so UI rebuilds when balance changes
    final userState = context.watch<UserCubit>().state;
    final isUserLoading = userState is UserLoading;
    final spendableBalance = context.read<UserCubit>().spendableBalance;
    final canAfford = context.read<UserCubit>().canAfford(_cost);

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
          ? ConfirmedView(mentorName: widget.mentor.username)
          : Scaffold(
              backgroundColor: colors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    Header(mentorName: widget.mentor.username),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkillSection(
                              mentor: widget.mentor,
                              selectedSkill: _selectedSkill,
                              onSelect: (s) =>
                                  setState(() => _selectedSkill = s),
                            ),
                            const SizedBox(height: 24),
                            DateSection(
                              selectedDate: _selectedDate,
                              onSelect: (d) =>
                                  setState(() => _selectedDate = d),
                            ),
                            const SizedBox(height: 24),
                            TimeSection(
                              selectedTime: _selectedTime,
                              onSelect: (t) =>
                                  setState(() => _selectedTime = t),
                            ),
                            const SizedBox(height: 24),
                            DurationSection(
                              selectedMinutes: _selectedMinutes,
                              onSelect: (m) =>
                                  setState(() => _selectedMinutes = m),
                            ),
                            const SizedBox(height: 24),
                            MessageSection(controller: _msgCtrl),
                            const SizedBox(height: 24),
                            CostSummary(
                              pricePerHour: widget.mentor.pricePerHour,
                              userPoints: spendableBalance,
                              canAfford: canAfford,
                              isLoadingBalance: isUserLoading,
                              cost: _cost,
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
                    onTap: (canAfford && !_isLoading && !isUserLoading)
                        ? _confirm
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 52,
                      decoration: BoxDecoration(
                        color: canAfford
                            ? colors.primary
                            : colors.primary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      alignment: Alignment.center,
                      child: (_isLoading || isUserLoading)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              canAfford
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
