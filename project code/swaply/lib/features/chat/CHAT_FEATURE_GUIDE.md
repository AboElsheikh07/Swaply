# Swaply Chat & Messaging Feature - Firestore Integration Guide

## Overview
The messaging and chat features are now fully integrated with Firestore. This document explains the Firestore data structure, how to use the feature, and how to extend it.

---

## Firestore Collection Structure

### 1. **conversations** Collection
Stores all conversations/chats between users.

**Document Structure:**
```
conversations/
├── {conversationId}/
│   ├── name: "Chat Name" (string)
│   ├── members: ["userId1", "userId2", ...] (array)
│   ├── lastMessage: "Last message text" (string)
│   ├── updatedAt: Timestamp (timestamp)
│   ├── online: true/false (boolean)
│   ├── unreadCounts: {
│   │   "userId1": 2,
│   │   "userId2": 0
│   │ } (map)
│   └── messages/ (subcollection)
│       └── {messageId}/
│           ├── senderId: "userId" (string)
│           ├── text: "Message content" (string)
│           └── createdAt: Timestamp (timestamp)
```

**Firestore Security Rules (recommended):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /conversations/{conversationId} {
      allow read, write: if request.auth.uid in resource.data.members;
      
      match /messages/{messageId} {
        allow read: if request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.members;
        allow create: if request.auth.uid == request.resource.data.senderId && 
                        request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.members;
      }
    }
  }
}
```

---

## How to Use the Chat Feature

### 1. **Load Conversations Screen**
The conversations are automatically loaded when the user navigates to the messages screen:

```dart
BlocBuilder<ChatCubit, ChatState>(
  builder: (context, state) {
    if (state is ConversationsLoaded) {
      // Display list of conversations
    }
  },
)
```

### 2. **Send a Message**
```dart
await context.read<ChatCubit>().sendMessage(
  conversationId: 'conv_id',
  text: 'Hello!',
);
```

### 3. **Create a New Conversation**
```dart
final conversationId = await context.read<ChatCubit>().createConversation(
  members: ['userId1', 'userId2'],
  name: 'John Doe',
  initialMessage: 'Hi! Interested in a session?',
);
```

### 4. **Mark Messages as Read**
```dart
await context.read<ChatCubit>().markAsRead(conversationId);
```

### 5. **Delete a Conversation**
```dart
await context.read<ChatCubit>().deleteConversation(conversationId);
```

---

## File Structure

```
lib/features/chat/
├── data/
│   ├── models/
│   │   └── chat_models.dart       # Conversation & ChatMessage models
│   └── repositories/
│       └── chat_repository.dart   # Firestore operations
├── presentation/
│   ├── controllers/
│   │   ├── chat_cubit.dart        # State management
│   │   └── chat_state.dart        # BLoC states
│   └── screens/
│       ├── chat_screen.dart       # Individual chat conversation
│       ├── messages_screen.dart   # List of conversations
│       ├── video_call_screen.dart # Video call screen (future)
│       └── voice_call_screen.dart # Voice call screen (future)
```

---

## State Management (BLoC/Cubit)

### ChatCubit States:
- **ChatInitial**: Initial state
- **ChatLoading**: Loading data
- **ConversationsLoaded**: List of conversations loaded
- **MessagesLoaded**: Messages for a conversation loaded
- **ChatError**: An error occurred

### ChatCubit Methods:
```dart
// Load all conversations for current user
loadConversations()

// Load messages for a specific conversation
loadMessages(conversationId)

// Send a message
sendMessage({required conversationId, required text})

// Create a new conversation
createConversation({required members, required name, required initialMessage})

// Mark messages as read
markAsRead(conversationId)

// Delete a conversation
deleteConversation(conversationId)
```

---

## Integrating with Your App

The ChatCubit is already provided in `main.dart`:

```dart
BlocProvider(
  create: (_) => ChatCubit(
    repository: ChatRepository(),
    currentUserId: uuid!,
  ),
),
```

---

## Data Models

### Conversation Model
```dart
class Conversation {
  final String id;           // Document ID
  final String name;         // Chat name/user name
  final String lastMessage;  // Last message preview
  final DateTime updatedAt;  // Last update timestamp
  final int unread;          // Unread count for current user
  final bool online;         // User online status
}
```

### ChatMessage Model
```dart
class ChatMessage {
  final String id;           // Message ID
  final String senderId;     // Who sent it
  final String text;         // Message content
  final DateTime createdAt;  // When it was sent
  final bool isMine;         // Is it from current user?
}
```

---

## Advanced Features (To Implement)

1. **Message Typing Indicator**: Show "typing..." status
2. **Message Read Receipts**: Show "read" status
3. **File/Image Sharing**: Send media files
4. **Voice Messages**: Record and send audio
5. **Video/Voice Calls**: Real-time communication using Agora or Twilio
6. **Message Search**: Find conversations and messages
7. **User Blocking**: Block users from messaging
8. **Message Reactions**: Add emoji reactions to messages

---

## Troubleshooting

### Issue: "Unread counts not working"
**Solution**: Ensure the `unreadCounts` field is properly initialized in Firestore when creating a conversation.

### Issue: "Messages not appearing"
**Solution**: Check Firestore security rules and ensure the current user ID is in the conversation's members array.

### Issue: "BlocBuilder not rebuilding"
**Solution**: Make sure the ChatCubit is provided in the BlocProvider in `main.dart`.

---

## Future Enhancements

- [ ] Implement real-time typing indicators
- [ ] Add message reactions
- [ ] Support media uploads (images, files)
- [ ] Implement voice messages
- [ ] Add message search functionality
- [ ] Implement message editing/deletion
- [ ] Add group chat support
- [ ] Push notifications for new messages
- [ ] Message archiving

---

## Contact & Support

For questions or issues related to the chat feature, please refer to the Firestore documentation or contact the development team.
