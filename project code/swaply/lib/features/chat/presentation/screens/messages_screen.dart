import 'package:flutter/material.dart';
import 'chat_screen.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class Conversation {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool online;

  const Conversation({
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.online = false,
  });
}

final List<Conversation> conversations = [
  Conversation(
    name: 'Sarah Chen',
    lastMessage: "Sounds great, let's schedule for Thursday!",
    time: '2m',
    unread: 2,
    online: true,
  ),
  Conversation(
    name: 'James Wilson',
    lastMessage: 'I sent over the Flutter resources.',
    time: '1h',
  ),
  Conversation(
    name: 'Maria Lopez',
    lastMessage: 'Perfecto! See you tomorrow.',
    time: '3h',
    unread: 1,
    online: true,
  ),
  Conversation(
    name: 'Derek Knight',
    lastMessage: 'Try practicing those chords tonight.',
    time: 'Yesterday',
  ),
  Conversation(
    name: 'Priya Patel',
    lastMessage: 'Namaste! Great session today.',
    time: '2d',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 14),
                    Icon(Icons.search, color: Color(0xFF8E8E93), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Search conversations',
                      style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

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
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFD1D1D6),
                  child: Text(
                    c.name[0],
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
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
                      fontWeight:
                          c.unread > 0 ? FontWeight.w600 : FontWeight.w400,
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
                  c.time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
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
  }
}
