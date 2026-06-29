import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/models/chat_models.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatelessWidget {
  ConversationsScreen({super.key});

  final ChatRepository _chatRepository = ChatRepository();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Messages',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1E),
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(
                      Icons.search,
                      color: Theme.of(context).iconTheme.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Search conversations',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: currentUser == null
                  ? const Center(
                      child: Text('Please sign in to view your conversations.'),
                    )
                  : StreamBuilder<List<Conversation>>(
                      stream: _chatRepository.watchConversations(
                        currentUserId: currentUser.uid,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Unable to load conversations.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final conversations = snapshot.data ?? [];

                        if (conversations.isEmpty) {
                          return const Center(
                            child: Text(
                              'No chats yet. Start a conversation from the home screen.',
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: conversations.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 82,
                            color: Color(0xFFE5E5EA),
                          ),
                          itemBuilder: (context, index) {
                            final c = conversations[index];
                            return _ConversationTile(
                              conversation: c,
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
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFD1D1D6),
                  child: Text(
                    c.name.isNotEmpty ? c.name[0] : '?',
                    style: TextStyle(
                      color: Theme.of(context).iconTheme.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (c.online)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                    c.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
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
                      color: const Color(0xFF6E6E73),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(height: 5),
                if (c.unread > 0)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5B4FCF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${c.unread}',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
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
  }
}
