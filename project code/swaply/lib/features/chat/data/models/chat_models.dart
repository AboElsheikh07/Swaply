import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime updatedAt;
  final int unread;
  final bool online;
  final List<String> memberIds;
  final String otherUserId;

  const Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.updatedAt,
    this.unread = 0,
    this.online = false,
    required this.memberIds,
    required this.otherUserId,
  });

  String get formattedTime => DateFormat('h:mm a').format(updatedAt);

  factory Conversation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String currentUserId,
  }) {
    final data = doc.data() ?? {};
    final unreadCounts = data['unreadCounts'] as Map<String, dynamic>?;
    final members = List<String>.from(data['members'] ?? <String>[]);

    final otherUserId = members.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );

    return Conversation(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown',
      lastMessage: data['lastMessage'] as String? ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unread: (unreadCounts?[currentUserId] as int?) ?? 0,
      online: data['online'] as bool? ?? false,
      memberIds: members,
      otherUserId: otherUserId,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isMine;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.isMine,
  });

  String get formattedTime => DateFormat('h:mm a').format(createdAt);

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String currentUserId,
  }) {
    final data = doc.data() ?? {};
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: createdAt,
      isMine: data['senderId'] == currentUserId,
    );
  }
}
