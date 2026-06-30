import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'package:swaply/features/user/data/repositories/user_repository.dart';
import '../../data/models/chat_models.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_screen.dart';
import 'package:swaply/l10n/app_localizations.dart';

class ConversationsScreen extends StatelessWidget {
  ConversationsScreen({super.key});

  final ChatRepository _chatRepository = ChatRepository();
  final UserRepository _userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.messages,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: colors.text,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search, color: colors.mutedFg, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.searchConversations,
                      style: TextStyle(fontSize: 15, color: colors.mutedFg),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: currentUser == null
                  ? Center(
                      child: Text(
                        l10n.pleaseSignInChats,
                        style: TextStyle(color: colors.mutedFg),
                      ),
                    )
                  : StreamBuilder<List<Conversation>>(
                      stream: _chatRepository.watchConversations(
                        currentUserId: currentUser.uid,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              l10n.unableToLoadChats,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: colors.primary,
                            ),
                          );
                        }

                        final conversations = snapshot.data ?? [];

                        if (conversations.isEmpty) {
                          return Center(
                            child: Text(
                              l10n.noChatsYet,
                              style: TextStyle(color: colors.mutedFg),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: conversations.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            indent: 82,
                            color: colors.border,
                          ),
                          itemBuilder: (context, index) {
                            final c = conversations[index];
                            return _ConversationTile(
                              conversation: c,
                              userRepository: _userRepository,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(conversation: c),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final UserRepository userRepository;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.userRepository,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = conversation;
    return StreamBuilder<UserModel?>(
      stream: userRepository.watchUser(c.otherUserId),
      builder: (context, snapshot) {
        final other = snapshot.data;
        final name = other?.username ?? c.name;
        final avatarUrl = other?.avatarUrl ?? '';
        final online = other?.online ?? c.online;

        return InkWell(
          onTap: onTap,
          child: Container(
            color: colors.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: colors.primarySoft,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl) as ImageProvider
                          : null,
                      child: avatarUrl.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0] : '?',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                    if (online)
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.card, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        c.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: c.unread > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: colors.mutedFg,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      c.formattedTime,
                      style: TextStyle(fontSize: 13, color: colors.mutedFg),
                    ),
                    const SizedBox(height: 5),
                    if (c.unread > 0)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${c.unread}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 22),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
