import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/features/chat/data/repositories/chat_repository.dart';
import 'package:swaply/features/chat/presentation/screens/chat_screen.dart';
import 'package:swaply/features/mentor_details/data/repositories/mentor_details_repository.dart';
import 'package:swaply/features/mentor_details/presentation/cubit/mentor_details_cubit.dart';
import 'package:swaply/features/mentor_details/presentation/cubit/mentor_details_state.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/request_session_screen.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/l10n/app_localizations.dart';

const mdPrimary = Color(0xFF5B4CB8);
const mdPrimarySoft = Color(0xFFEEECFB);
const mdBorder = Color(0xFFEAEAF0);
const mdMutedFg = Color(0xFF8A8A9A);
const mdDark = Color(0xFF1A1A2E);

class MentorDetailsScreen extends StatelessWidget {
  final String mentorId;

  const MentorDetailsScreen({super.key, required this.mentorId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      // ✅ بدّل MockMentorDetailsRepository بـ FirebaseMentorDetailsRepository لما Firebase يتجهز
      create: (_) =>
          MentorDetailsCubit(MentorDetailsRepository())..loadMentor(mentorId),
      child: const MentorDetailsView(),
    );
  }
}

class MentorDetailsView extends StatelessWidget {
  const MentorDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<MentorDetailsCubit, MentorDetailsState>(
        builder: (context, state) {
          return switch (state) {
            MentorDetailsLoading() => const Center(
              child: CircularProgressIndicator(color: mdPrimary),
            ),
            MentorDetailsError(:final message) => Center(
              child: Text(message, style: const TextStyle(color: mdMutedFg)),
            ),
            MentorDetailsLoaded(:final user, :final availability) =>
              MentorDetailsContent(
              mentor: user,
              availability: availability,
            ),
          };
        },
      ),
    );
  }
}

class MentorDetailsContent extends StatelessWidget {
  final UserModel mentor;
  final MentorAvailability availability; // ✅ بيانات حقيقية
  final ChatRepository _chatRepository = ChatRepository();

  MentorDetailsContent({
    super.key,
    required this.mentor,
    required this.availability,
  });

  Future<void> _openChat(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final conversationId = await _chatRepository.getOrCreateConversation(
      currentUserId: currentUser.uid,
      otherUserId: mentor.id,
      otherUserName: mentor.username,
    );

    final conversation = await _chatRepository.fetchConversation(
      conversationId: conversationId,
      currentUserId: currentUser.uid,
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // ✅ صورة البروفايل الحقيقية لو موجودة عند المينتور
                  ClipRect(
                    child: SizedBox(
                      height: 280,
                      width: double.infinity,
                      child: mentor.avatarUrl.isNotEmpty
                          ? Image.network(
                              mentor.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const _MentorAvatarFallback(),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: mdPrimarySoft,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: mdPrimary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                          : const _MentorAvatarFallback(),
                    ),
                  ),
                  Container(
                    height: 280,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.white],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MdCircleBtn(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.of(context).maybePop(),
                            ),
                            MdCircleBtn(
                              icon: Icons.share_outlined,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + rate
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    mentor.username,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                mentor.skillsCanTeach.isEmpty
                                    ? "No Skill"
                                    : mentor.skillsCanTeach.first,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: mdMutedFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${mentor.pricePerHour} pts/hr",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: mdDark,
                              ),
                            ),
                            const Text(
                              'session rate',
                              style: TextStyle(fontSize: 11, color: mdMutedFg),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stats
                    Row(
                      children: [
                        MdStatCard(
                          value: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFC107),
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                mentor.ratingAvg.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          label: l10n.rating,
                        ),
                        const SizedBox(width: 8),
                        MdStatCard(
                          value: Text(
                            '${mentor.ratingCount}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          label: l10n.reviews,
                        ),
                        const SizedBox(width: 8),
                        MdStatCard(
                          value: Text(
                            '${availability.totalSessions}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          label: l10n.sessions,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // About

                    // Price box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: mdPrimarySoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: mdBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: mdPrimary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.toll_rounded,
                              color: mdPrimary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.pricePerHour,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: mdMutedFg,
                                  ),
                                ),
                                Text(
                                  l10n.setBy(mentor.username.split(' ').first),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            l10n.pointsAmount(mentor.pricePerHour.toString()),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: mdPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Skills
                    Text(
                      l10n.skillsOffered,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: mentor.skillsCanTeach
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: mdPrimarySoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: mdPrimary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    // Availability
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: mdBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.nextAvailability,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            availability.upcomingSlots.isEmpty
                                ? 'No upcoming sessions scheduled yet.'
                                : availability.upcomingSlots.join(' · '),
                            style: TextStyle(fontSize: 12, color: mdMutedFg),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reviews
                  ],
                ),
              ),
            ),
          ],
        ),

        // Bottom action bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: mdBorder)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _openChat(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: mdBorder),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final cubit = context.read<MentorDetailsCubit>();
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        await cubit.loadMentor(mentor.id);

                        final state = cubit.state;

                        if (state is MentorDetailsLoaded) {
                          navigator.push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RequestSessionScreen(mentor: state.user),
                            ),
                          );
                        } else if (state is MentorDetailsError) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mdPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        l10n.requestSession,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ✅ صورة افتراضية لما مفيش avatarUrl عند المينتور
class _MentorAvatarFallback extends StatelessWidget {
  const _MentorAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mdPrimarySoft,
      child: const Icon(
        Icons.person_outline_rounded,
        color: mdPrimary,
        size: 80,
      ),
    );
  }
}

class MdCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const MdCircleBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class MdStatCard extends StatelessWidget {
  final Widget value;
  final String label;
  const MdStatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: mdBorder),
        ),
        child: Column(
          children: [
            value,
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: mdMutedFg,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}