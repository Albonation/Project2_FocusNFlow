import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/group_chat_message_model.dart';

class GroupChatRepository {
  final FirebaseFirestore _firestore;

  GroupChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _groupsRef {
    return _firestore.collection('study_groups');
  }

  CollectionReference<Map<String, dynamic>> _messagesRef(String groupId) {
    return _groupsRef.doc(groupId).collection('messages');
  }

  //stream non-deleted messages for a specific study group
  Stream<List<GroupChatMessage>> watchMessages(String groupId) {
    _validateGroupId(groupId);

    return _messagesRef(groupId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    GroupChatMessage.fromFirestore(groupId: groupId, doc: doc),
              )
              .toList(),
        );
  }

  //send a new message to a study group's messages subcollection
  Future<String> sendMessage({
    required String groupId,
    required GroupChatMessage message,
  }) async {
    try {
      _validateGroupId(groupId);
      _validateMessage(message);
      _validateMessageBelongsToGroup(groupId: groupId, message: message);

      final messageRef = _messagesRef(groupId).doc();
      final messageWithId = message.copyWith(id: messageRef.id);

      await messageRef.set(messageWithId.toFirestore());

      return messageRef.id;
    } catch (error) {
      debugPrint('Error sending group chat message: $error');
      rethrow;
    }
  }

  //soft-delete a message instead of removing the document
  //to keep chat history and gives us the option to show
  //"message deleted" placeholders later
  Future<void> softDeleteMessage({
    required String groupId,
    required String messageId,
    required String userId,
  }) async {
    try {
      _validateGroupId(groupId);
      _validateMessageId(messageId);
      _validateUserId(userId);

      final messageRef = _messagesRef(groupId).doc(messageId);

      await _firestore.runTransaction((transaction) async {
        final messageSnapshot = await transaction.get(messageRef);

        if (!messageSnapshot.exists || messageSnapshot.data() == null) {
          throw Exception('Message no longer exists.');
        }

        final message = GroupChatMessage.fromFirestore(
          groupId: groupId,
          doc: messageSnapshot,
        );

        _validateMessageBelongsToGroup(groupId: groupId, message: message);

        if (message.senderId != userId) {
          throw Exception('You can only delete your own messages.');
        }

        if (message.isDeleted) {
          throw Exception('Message is already deleted.');
        }

        transaction.update(messageRef, {
          'isDeleted': true,
          'text': '',
          'editedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      debugPrint('Error deleting group chat message: $error');
      rethrow;
    }
  }

  //helper methods to validate various things
  void _validateGroupId(String groupId) {
    if (groupId.trim().isEmpty) {
      throw Exception('Invalid study group.');
    }
  }

  void _validateMessageId(String messageId) {
    if (messageId.trim().isEmpty) {
      throw Exception('Invalid message.');
    }
  }

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception('Invalid user.');
    }
  }

  void _validateMessage(GroupChatMessage message) {
    _validateUserId(message.senderId);

    if (message.text.trim().isEmpty) {
      throw Exception('Message cannot be empty.');
    }

    _validateMessageType(message.type);
  }

  void _validateMessageType(String type) {
    const allowedTypes = {
      GroupChatMessage.textType,
      GroupChatMessage.fileType,
      GroupChatMessage.systemType,
    };

    if (!allowedTypes.contains(type)) {
      throw Exception('Invalid message type');
    }
  }

  void _validateMessageBelongsToGroup({
    required String groupId,
    required GroupChatMessage message,
  }) {
    if (message.groupId != groupId) {
      throw Exception('Message group does not match target group.');
    }
  }
}
