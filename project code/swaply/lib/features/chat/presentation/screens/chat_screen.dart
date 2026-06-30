import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/chat/data/models/chat_models.dart';
import 'package:swaply/features/chat/data/repositories/chat_repository.dart';
import 'package:swaply/l10n/app_localizations.dart';

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
  final ChatRepository _chatRepository = ChatRepository();

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _chatRepository.markConversationRead(
        conversationId: widget.conversation.id,
        currentUserId: _currentUser!.uid,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _currentUser == null) return;

    _controller.clear();
    await _chatRepository.sendMessage(
      conversationId: widget.conversation.id,
      senderId: _currentUser!.uid,
      text: text,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final c = widget.conversation;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0.5,
        shadowColor: colors.border,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.text,
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
                  backgroundColor: colors.primarySoft,
                  child: Text(
                    c.name[0],
                    style: TextStyle(
                      color: colors.primary,
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
                        color: colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.card, width: 1.5),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                if (c.online)
                  Text(
                    l10n.online,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.phone_outlined,
              color: colors.text,
              size: 22,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.videocam_outlined,
              color: colors.primary,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _currentUser == null
          ? Center(child: Text(l10n.signInToChat))
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: _chatRepository.watchMessages(
                      conversationId: widget.conversation.id,
                      currentUserId: _currentUser!.uid,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            l10n.unableToLoadMessages,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: colors.primary),
                        );
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noMessagesYet,
                            style: TextStyle(color: colors.mutedFg),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, i) =>
                            _ChatBubble(message: messages[i]),
                      );
                    },
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
    final colors = context.colors;
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
                color: mine ? colors.primary : colors.card,
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
                  color: mine ? Colors.white : colors.text,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message.formattedTime,
            style: TextStyle(fontSize: 12, color: colors.mutedFg),
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
   
    final colors = context.colors;
    return Container(
      color: colors.card,
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
            decoration: BoxDecoration(
              color: colors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.attach_file,
              color: colors.mutedFg,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(21),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.messageHint,
                  hintStyle: TextStyle(color: colors.mutedFg, fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: TextStyle(fontSize: 15, color: colors.text),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primary,
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