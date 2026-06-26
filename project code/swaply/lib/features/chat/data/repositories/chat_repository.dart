import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final FirebaseFirestore _db;

  ChatRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('conversations');

  Stream<List<Conversation>> watchConversations({
    required String currentUserId,
  }) {
    return _conversations
        .where('members', arrayContains: currentUserId)
        .snapshots()
        .map((snap) {
          final conversations = snap.docs
              .map(
                (doc) => Conversation.fromFirestore(
                  doc,
                  currentUserId: currentUserId,
                ),
              )
              .toList();

          // Sort in memory by updatedAt descending (newest first)
          conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return conversations;
        });
  }

  Stream<List<ChatMessage>> watchMessages({
    required String conversationId,
    required String currentUserId,
  }) {
    final messages = _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false);

    return messages.snapshots().map(
      (snap) => snap.docs
          .map(
            (doc) =>
                ChatMessage.fromFirestore(doc, currentUserId: currentUserId),
          )
          .toList(),
    );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final messageRef = _conversations
        .doc(conversationId)
        .collection('messages')
        .doc();

    final now = DateTime.now();

    await messageRef.set({
      'senderId': senderId,
      'text': text,
      'createdAt': Timestamp.fromDate(now),
    });

    await _conversations.doc(conversationId).update({
      'lastMessage': text,
      'updatedAt': Timestamp.fromDate(now),
      'unreadCounts': FieldValue.increment(1),
    });
  }

  Future<String> createConversation({
    required List<String> members,
    required String name,
    required String initialMessage,
    required String creatorId,
  }) async {
    final now = DateTime.now();
    final ref = _conversations.doc();

    await ref.set({
      'name': name,
      'members': members,
      'lastMessage': initialMessage,
      'updatedAt': Timestamp.fromDate(now),
      'online': true,
      'unreadCounts': {for (final id in members) id: id == creatorId ? 0 : 1},
    });

    await ref.collection('messages').add({
      'senderId': creatorId,
      'text': initialMessage,
      'createdAt': Timestamp.fromDate(now),
    });

    return ref.id;
  }

  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    final doc = _conversations.doc(conversationId);
    final snapshot = await doc.get();
    final unreadCounts =
        (snapshot.data()?['unreadCounts'] as Map<String, dynamic>?) ?? {};
    if (unreadCounts[userId] == null) return;

    await doc.update({'unreadCounts.$userId': 0});
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages in the conversation
      final messagesSnapshot = await _conversations
          .doc(conversationId)
          .collection('messages')
          .get();

      for (final doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the conversation document
      await _conversations.doc(conversationId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
