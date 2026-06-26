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
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => Conversation.fromFirestore(
                  doc,
                  currentUserId: currentUserId,
                ),
              )
              .toList(),
        );
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

  Future<void> markConversationRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    final doc = _conversations.doc(conversationId);
    final snapshot = await doc.get();
    final unreadCounts =
        (snapshot.data()?['unreadCounts'] as Map<String, dynamic>?) ?? {};
    if (unreadCounts[currentUserId] == null) return;

    await doc.update({'unreadCounts.$currentUserId': 0});
  }
}
