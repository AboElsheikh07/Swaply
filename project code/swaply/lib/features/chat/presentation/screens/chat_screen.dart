import 'package:flutter/material.dart';
import 'messages_screen.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final String time;
  final bool isMine;

  const ChatMessage({
    required this.text,
    required this.time,
    required this.isMine,
  });
}

// ── Sample messages (replace with your data source) ───────────────────────────

final List<ChatMessage> sarahMessages = [
  ChatMessage(
    text: "Hey! Excited for our session.",
    time: '10:21 AM',
    isMine: false,
  ),
  ChatMessage(
    text: "Me too! I prepared some questions.",
    time: '10:22 AM',
    isMine: true,
  ),
  ChatMessage(
    text: "Great — share them whenever you're ready.",
    time: '10:23 AM',
    isMine: false,
  ),
  ChatMessage(
    text: "Is Thursday 4pm still good for you?",
    time: '10:24 AM',
    isMine: true,
  ),
  ChatMessage(
    text: "Sounds great, let's schedule for Thursday!",
    time: '10:25 AM',
    isMine: false,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = List.from(sarahMessages);

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          time: TimeOfDay.now().format(context),
          isMine: true,
        ),
      );
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: const Color(0xFFE5E5EA),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1C1C1E),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFD1D1D6),
                  child: Text(
                    c.name[0],
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (c.online)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
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
                if (c.online)
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF34C759),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF1C1C1E),
              size: 22,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.videocam_outlined,
              color: Color(0xFF5B4FCF),
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _ChatBubble(message: _messages[i]),
            ),
          ),
          _InputBar(controller: _controller, onSend: _sendMessage),
        ],
      ),
    );
  }
}

// ── Bubble ────────────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: mine ? const Color(0xFF5B4FCF) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(mine ? 20 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: mine ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message.time,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_file,
              color: Color(0xFF8E8E93),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(21),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF5B4FCF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
