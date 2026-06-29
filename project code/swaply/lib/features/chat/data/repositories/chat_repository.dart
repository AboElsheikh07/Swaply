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

    final conversationRef = _conversations.doc(conversationId);
    final snapshot = await conversationRef.get();
    final data = snapshot.data() ?? {};
    final members = List<String>.from(data['members'] ?? <String>[]);
    final unreadCounts = <String, int>{};

    for (final member in members) {
      if (member == senderId) {
        unreadCounts[member] = 0;
      } else {
        final existingCount =
            (data['unreadCounts'] as Map<String, dynamic>?)?[member] as int? ??
            0;
        unreadCounts[member] = existingCount + 1;
      }
    }

    await conversationRef.update({
      'lastMessage': text,
      'updatedAt': Timestamp.fromDate(now),
      'unreadCounts': unreadCounts,
    });
  }

  Future<String?> findConversationId({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final snapshot = await _conversations
        .where('members', arrayContains: currentUserId)
        .get();

    for (final doc in snapshot.docs) {
      final members = List<String>.from(doc.data()['members'] ?? <String>[]);
      if (members.contains(otherUserId) && members.length == 2) {
        return doc.id;
      }
    }

    return null;
  }

  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
  }) async {
    final existingId = await findConversationId(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
    );

    if (existingId != null) {
      return existingId;
    }

    return createConversation(
      members: [currentUserId, otherUserId],
      name: otherUserName,
      initialMessage: '',
      creatorId: currentUserId,
    );
  }

  Future<Conversation> fetchConversation({
    required String conversationId,
    required String currentUserId,
  }) async {
    final doc = await _conversations.doc(conversationId).get();
    return Conversation.fromFirestore(doc, currentUserId: currentUserId);
  }

  Future<String> createConversation({
    required List<String> members,
    required String name,
    String initialMessage = '',
    required String creatorId,
  }) async {
    final now = DateTime.now();
    final ref = _conversations.doc();
    final unreadCounts = <String, int>{for (final id in members) id: 0};

    if (initialMessage.isNotEmpty) {
      for (final id in members) {
        unreadCounts[id] = id == creatorId ? 0 : 1;
      }
    }

    await ref.set({
      'name': name,
      'members': members,
      'lastMessage': initialMessage,
      'updatedAt': Timestamp.fromDate(now),
      'online': true,
      'unreadCounts': unreadCounts,
    });

    if (initialMessage.isNotEmpty) {
      await ref.collection('messages').add({
        'senderId': creatorId,
        'text': initialMessage,
        'createdAt': Timestamp.fromDate(now),
      });
    }

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
