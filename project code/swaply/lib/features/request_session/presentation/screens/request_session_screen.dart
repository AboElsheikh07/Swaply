import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/session_request_model.dart';
import '../../data/repositories/session_request_repository_mock.dart';
import '../cubit/session_request_cubit.dart';
import '../cubit/session_request_state.dart';

const rsPrimary = Color(0xFF5B4CB8);
const rsBorder  = Color(0xFFEAEAF0);
const rsMutedFg = Color(0xFF8A8A9A);
const rsDark    = Color(0xFF1A1A2E);

class RequestSessionScreen extends StatelessWidget {
  final String mentorId;
  final String mentorName;
  final List<String> mentorSkills;
  final int pricePerHour;
  final int userPoints;

  const RequestSessionScreen({
    super.key,
    required this.mentorId,
    required this.mentorName,
    required this.mentorSkills,
    required this.pricePerHour,
    this.userPoints = 1250,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ✅ بدّل MockSessionRequestRepository بـ FirebaseSessionRequestRepository لما Firebase يتجهز
      create: (_) => SessionRequestCubit(MockSessionRequestRepository()),
      child: RequestSessionView(
        mentorId: mentorId,
        mentorName: mentorName,
        mentorSkills: mentorSkills,
        pricePerHour: pricePerHour,
        userPoints: userPoints,
      ),
    );
  }
}

class RequestSessionView extends StatefulWidget {
  final String mentorId;
  final String mentorName;
  final List<String> mentorSkills;
  final int pricePerHour;
  final int userPoints;

  const RequestSessionView({
    super.key,
    required this.mentorId,
    required this.mentorName,
    required this.mentorSkills,
    required this.pricePerHour,
    required this.userPoints,
  });

  @override
  State<RequestSessionView> createState() => RequestSessionViewState();
}

class RequestSessionViewState extends State<RequestSessionView> {
  late String selectedSkill;
  int selectedDayIndex  = 1;
  int selectedTimeIndex = 3;
  int selectedDuration  = 60;
  final messageCtrl = TextEditingController();

  List<({String key, String dow, int date})> get days {
    const dowNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return List.generate(7, (i) {
      final d = DateTime.now().add(Duration(days: i));
      return (key: d.toIso8601String().substring(0, 10), dow: dowNames[d.weekday % 7], date: d.day);
    });
  }

  int get cost => ((widget.pricePerHour * selectedDuration) / 60).round();
  bool get canAfford => widget.userPoints >= cost;

  @override
  void initState() {
    super.initState();
    selectedSkill = widget.mentorSkills.first;
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    super.dispose();
  }

  void submit(BuildContext context) {
    context.read<SessionRequestCubit>().sendRequest(
      request: SessionRequestModel(
        mentorId: widget.mentorId,
        skill: selectedSkill,
        date: days[selectedDayIndex].key,
        time: availableTimes[selectedTimeIndex],
        durationMinutes: selectedDuration,
        message: messageCtrl.text.trim().isEmpty ? null : messageCtrl.text.trim(),
        totalCost: cost,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: BlocConsumer<SessionRequestCubit, SessionRequestState>(
        listener: (context, state) {
          if (state is SessionRequestSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => SessionConfirmedScreen(mentorName: widget.mentorName),
              ),
            );
          }
          if (state is SessionRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
            context.read<SessionRequestCubit>().resetState();
          }
        },
        builder: (context, state) {
          final isLoading = state is SessionRequestLoading;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    floating: true,
                    leading: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Request Session',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: rsDark)),
                        Text('with ${widget.mentorName}',
                            style: const TextStyle(fontSize: 11, color: rsMutedFg)),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Skill ──
                          const RsSectionLabel(label: 'Skill'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: widget.mentorSkills.map((s) => GestureDetector(
                              onTap: () => setState(() => selectedSkill = s),
                              child: RsSelectChip(label: s, active: selectedSkill == s),
                            )).toList(),
                          ),
                          const SizedBox(height: 20),

                          // ── Date ──
                          const RsSectionLabel(label: 'Date'),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: days.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                final active = selectedDayIndex == i;
                                return GestureDetector(
                                  onTap: () => setState(() => selectedDayIndex = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 54,
                                    decoration: BoxDecoration(
                                      color: active ? rsPrimary : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: active ? rsPrimary : rsBorder),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(days[i].dow,
                                            style: TextStyle(
                                              fontSize: 10, fontWeight: FontWeight.w600,
                                              color: active ? Colors.white70 : rsMutedFg,
                                            )),
                                        Text('${days[i].date}',
                                            style: TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold,
                                              color: active ? Colors.white : rsDark,
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Time ──
                          const RsSectionLabel(label: 'Time'),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: availableTimes.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2.6,
                            ),
                            itemBuilder: (_, i) => GestureDetector(
                              onTap: () => setState(() => selectedTimeIndex = i),
                              child: RsSelectChip(
                                  label: availableTimes[i],
                                  active: selectedTimeIndex == i,
                                  rounded: 12),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Duration ──
                          const RsSectionLabel(label: 'Duration'),
                          const SizedBox(height: 10),
                          Row(
                            children: durationOptions.map((d) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => setState(() => selectedDuration = d.value),
                                  child: RsSelectChip(
                                      label: d.label,
                                      active: selectedDuration == d.value,
                                      rounded: 12),
                                ),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 20),

                          // ── Message ──
                          const RsSectionLabel(label: 'Message (optional)'),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: rsBorder),
                            ),
                            child: TextField(
                              controller: messageCtrl,
                              maxLines: 3,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Tell the mentor what you want to work on...',
                                hintStyle: TextStyle(color: rsMutedFg, fontSize: 13),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Cost summary ──
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: rsBorder),
                            ),
                            child: Column(
                              children: [
                                RsSummaryRow(label: 'Price per hour', value: '${widget.pricePerHour} pts'),
                                const SizedBox(height: 8),
                                RsSummaryRow(label: 'Duration', value: '$selectedDuration min'),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(color: rsBorder, height: 1),
                                ),
                                Row(
                                  children: [
                                    const Text('Total cost',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text('$cost pts',
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold, color: rsPrimary)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Your balance: ',
                                        style: TextStyle(fontSize: 12, color: rsMutedFg)),
                                    Text('${widget.userPoints} pts',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    if (!canAfford) ...[
                                      const SizedBox(width: 8),
                                      const Text('Not enough points',
                                          style: TextStyle(fontSize: 12,
                                              fontWeight: FontWeight.w600, color: Color(0xFFE53935))),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Confirm button
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: rsBorder)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (canAfford && !isLoading) ? () => submit(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rsPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(
                              canAfford ? 'Confirm · $cost pts' : 'Not enough points',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Confirmed Screen ─────────────────────
class SessionConfirmedScreen extends StatelessWidget {
  final String mentorName;
  const SessionConfirmedScreen({super.key, required this.mentorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Color(0xFF2E7D32), size: 44),
              ),
              const SizedBox(height: 24),
              const Text('Request sent!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'We notified $mentorName. You\'ll see this in Sessions once they accept.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: rsMutedFg),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rsPrimary, foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Text('View Sessions',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F5FA), foregroundColor: rsDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Text('Back to Home',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ───────────────────────
class RsSectionLabel extends StatelessWidget {
  final String label;
  const RsSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold,
            letterSpacing: 0.8, color: rsMutedFg),
      );
}

class RsSelectChip extends StatelessWidget {
  final String label;
  final bool active;
  final double rounded;
  const RsSelectChip({super.key, required this.label, required this.active, this.rounded = 20});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active ? rsPrimary : Colors.white,
        borderRadius: BorderRadius.circular(rounded),
        border: Border.all(color: active ? rsPrimary : rsBorder),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: active ? Colors.white : rsDark)),
    );
  }
}

class RsSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const RsSummaryRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: rsMutedFg)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
