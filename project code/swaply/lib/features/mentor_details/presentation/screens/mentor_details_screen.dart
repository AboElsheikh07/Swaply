import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/chat/data/repositories/chat_repository.dart';
import 'package:swaply/features/chat/presentation/screens/chat_screen.dart';
import 'package:swaply/features/mentor_details/data/repositories/mentor_details_repository.dart';
import 'package:swaply/features/mentor_details/presentation/cubit/mentor_details_cubit.dart';
import 'package:swaply/features/mentor_details/presentation/cubit/mentor_details_state.dart';
import 'package:swaply/features/sessions/presentation/screens/request_session_screen/request_session_screen.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/l10n/app_localizations.dart';

class MentorDetailsScreen extends StatelessWidget {
  final String mentorId;

  const MentorDetailsScreen({super.key, required this.mentorId});

  @override
  Widget build(BuildContext context) {
  
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
   
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: BlocBuilder<MentorDetailsCubit, MentorDetailsState>(
        builder: (context, state) {
          return switch (state) {
            MentorDetailsLoading() => Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
            MentorDetailsError(:final message) => Center(
              child: Text(message, style: TextStyle(color: colors.mutedFg)),
            ),
            MentorDetailsLoaded(:final user) => MentorDetailsContent(
              mentor: user,
            ),
          };
        },
      ),
    );
  }
}

class MentorDetailsContent extends StatelessWidget {
  final UserModel mentor;
  final ChatRepository _chatRepository = ChatRepository();

  MentorDetailsContent({super.key, required this.mentor});

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
    final colors = context.colors;
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
                              errorBuilder: (_, _ ,_) =>
                                  const _MentorAvatarFallback(),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: colors.primarySoft,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: colors.primary,
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, colors.background],
                        stops: const [0.5, 1.0],
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
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colors.text,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                mentor.skillsCanTeach.isEmpty
                                    ? "No Skill"
                                    : mentor.skillsCanTeach.first,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.mutedFg,
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
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            Text(
                              'session rate',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.mutedFg,
                              ),
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
                              Icon(
                                Icons.star_rounded,
                                color: colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                mentor.ratingAvg.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text,
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                          label: l10n.reviews,
                        ),
                        const SizedBox(width: 8),
                        MdStatCard(
                          value: Text(
                            '120+',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
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
                        color: colors.primarySoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha:0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.toll_rounded,
                              color: colors.primary,
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
                                    color: colors.mutedFg,
                                  ),
                                ),
                                Text(
                                  l10n.setBy(mentor.username.split(' ').first),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            l10n.pointsAmount(mentor.pricePerHour.toString()),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
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
                        color: colors.text,
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
                                color: colors.primarySoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
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
                        color: colors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.nextAvailability,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.mockAvailability,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.mutedFg,
                            ),
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
            decoration: BoxDecoration(
              color: colors.card,
              border: Border(top: BorderSide(color: colors.border)),
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
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: colors.text,
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
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        l10n.requestSession,
                        style: const TextStyle(
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
    final colors = context.colors;
    return Container(
      color: colors.primarySoft,
      child: Icon(
        Icons.person_outline_rounded,
        color: colors.primary,
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
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.card.withValues(alpha:0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha:0.08), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 18, color: colors.text),
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
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            value,
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colors.mutedFg,
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