import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_chat_message_model.dart';
import '../repositories/group_chat_repository.dart';
import '../repositories/study_group_repository.dart';

class GroupChatService {
  final GroupChatRepository _chatRepository;
  final StudyGroupRepository _groupRepository;
  final FirebaseAuth _auth;

  GroupChatService({
    GroupChatRepository? chatRepository,
    StudyGroupRepository? groupRepository,
    FirebaseAuth? auth,
  }) : _chatRepository = chatRepository ?? GroupChatRepository(),
       _groupRepository = groupRepository ?? StudyGroupRepository(),
       _auth = auth ?? FirebaseAuth.instance;

  //stream messages for a group chat after verifying the current user is a group member
  Stream<List<GroupChatMessage>> watchMessages(String groupId) async* {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'view group messages'),
      () => _validateGroupId(groupId),
    ]);

    if (error != null) {
      yield [];
      return;
    }

    final isMember = await _groupRepository.isUserMemberOfGroup(
      groupId: groupId,
      userId: user!.uid,
    );

    if (!isMember) {
      yield [];
      return;
    }

    yield* _chatRepository.watchMessages(groupId);
  }

  //send a plain text message to a group chat
  Future<GroupChatActionResult> sendTextMessage({
    required String groupId,
    required String text,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'send a message'),
      () => _validateGroupId(groupId),
      () => _validateMessageText(text),
    ]);

    if (error != null) {
      return GroupChatActionResult.failure(error);
    }

    try {
      final isMember = await _groupRepository.isUserMemberOfGroup(
        groupId: groupId,
        userId: user!.uid,
      );

      if (!isMember) {
        return GroupChatActionResult.failure(
          'You must join this group before sending messages.',
        );
      }

      final now = DateTime.now();

      final message = GroupChatMessage(
        id: '',
        groupId: groupId,
        senderId: user.uid,
        senderName: _resolveDisplayName(user),
        text: text.trim(),
        type: GroupChatMessage.textType,
        createdAt: now,
        editedAt: null,
        isDeleted: false,
      );

      final messageId = await _chatRepository.sendMessage(
        groupId: groupId,
        message: message,
      );

      return GroupChatActionResult.success(
        'Message sent.',
        messageId: messageId,
      );
    } catch (error) {
      return GroupChatActionResult.failure(_cleanError(error));
    }
  }

  //soft-delete one of the current user's messages
  Future<GroupChatActionResult> deleteMessage({
    required String groupId,
    required String messageId,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'delete a message'),
      () => _validateGroupId(groupId),
      () => _validateMessageId(messageId),
    ]);

    if (error != null) {
      return GroupChatActionResult.failure(error);
    }

    try {
      await _chatRepository.softDeleteMessage(
        groupId: groupId,
        messageId: messageId,
        userId: user!.uid,
      );

      return GroupChatActionResult.success(
        'Message deleted.',
        messageId: messageId,
      );
    } catch (error) {
      return GroupChatActionResult.failure(_cleanError(error));
    }
  }

  //helper methods to validate various things
  User? get _currentUser => _auth.currentUser;

  String? _validateSignedIn(User? user, String action) {
    if (user == null) {
      return 'You must be signed in to $action.';
    }

    return null;
  }

  String? _validateGroupId(String? groupId) {
    if (groupId == null || groupId.trim().isEmpty) {
      return 'Invalid study group.';
    }

    return null;
  }

  String? _validateMessageId(String? messageId) {
    if (messageId == null || messageId.trim().isEmpty) {
      return 'Invalid message.';
    }

    return null;
  }

  String? _validateMessageText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Message cannot be empty.';
    }

    if (text.trim().length > 1000) {
      return 'Message must be 1000 characters or less.';
    }

    return null;
  }

  String? _runValidation(List<String? Function()> checks) {
    for (final check in checks) {
      final result = check();

      if (result != null) {
        return result;
      }
    }

    return null;
  }

  //helper method to get the display name for the user
  String _resolveDisplayName(User user) {
    final displayName = user.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email;

    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Student';
  }

  //modifies repository exceptions for display in snackbars or dialogs
  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

//result object for consistent UI feedback
class GroupChatActionResult {
  final bool success;
  final String message;
  final String? messageId;

  const GroupChatActionResult({
    required this.success,
    required this.message,
    this.messageId,
  });

  factory GroupChatActionResult.success(String message, {String? messageId}) {
    return GroupChatActionResult(
      success: true,
      message: message,
      messageId: messageId,
    );
  }

  factory GroupChatActionResult.failure(String message) {
    return GroupChatActionResult(success: false, message: message);
  }
}
