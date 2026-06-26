import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/chat_models.dart';
import '../../data/repositories/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  final String currentUserId;

  ChatCubit({required this.repository, required this.currentUserId})
    : super(const ChatInitial());

  /// Load all conversations for the current user
  Future<void> loadConversations() async {
    try {
      emit(const ChatLoading());
      repository
          .watchConversations(currentUserId: currentUserId)
          .listen((conversations) {
            emit(ConversationsLoaded(conversations: conversations));
          })
          .onError((error) {
            emit(ChatError(message: error.toString()));
          });
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  /// Load messages for a specific conversation
  void loadMessages(String conversationId) {
    try {
      repository
          .watchMessages(
            conversationId: conversationId,
            currentUserId: currentUserId,
          )
          .listen((messages) {
            emit(MessagesLoaded(messages: messages));
          })
          .onError((error) {
            emit(ChatError(message: error.toString()));
          });
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  /// Send a message in a conversation
  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      if (text.isEmpty) return;
      await repository.sendMessage(
        conversationId: conversationId,
        senderId: currentUserId,
        text: text,
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  /// Create a new conversation
  Future<String?> createConversation({
    required List<String> members,
    required String name,
    required String initialMessage,
  }) async {
    try {
      final conversationId = await repository.createConversation(
        members: members,
        name: name,
        initialMessage: initialMessage,
        creatorId: currentUserId,
      );
      return conversationId;
    } catch (e) {
      emit(ChatError(message: e.toString()));
      return null;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String conversationId) async {
    try {
      await repository.markMessagesAsRead(
        conversationId: conversationId,
        userId: currentUserId,
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await repository.deleteConversation(conversationId);
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }
}
