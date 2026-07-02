import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swaply/services/onesignal_push_service.dart';
import 'package:swaply/features/user/data/repositories/user_repository.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final FirebaseFirestore _db;
  final UserRepository _userRepository;

  ChatRepository({FirebaseFirestore? db, UserRepository? userRepository})
    : _db = db ?? FirebaseFirestore.instance,
      _userRepository = userRepository ?? UserRepository();

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

    // ── Push notification to everyone else in the conversation ──
    _notifyRecipients(
      members: members,
      senderId: senderId,
      text: text,
      conversationId: conversationId,
    );
  }

  /// Fire-and-forget: fetches the sender's display name, then pushes to
  /// every other member. Doesn't block sendMessage or surface failures
  /// to the UI — a failed push shouldn't stop the message from sending.
  Future<void> _notifyRecipients({
    required List<String> members,
    required String senderId,
    required String text,
    required String conversationId,
  }) async {
    try {
      final sender = await _userRepository.fetchUser(senderId);
      final senderName = sender?.username ?? 'New message';

      for (final memberId in members) {
        if (memberId == senderId) continue;
        await OneSignalPushService.sendToUser(
          externalUserId: memberId,
          title: senderName,
          body: text,
          data: {'conversationId': conversationId, 'type': 'chat_message'},
        );
      }
    } catch (_) {
      // non-critical — message already sent successfully regardless
    }
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
