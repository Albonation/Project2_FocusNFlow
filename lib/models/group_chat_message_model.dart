import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatMessage {
  //for tracking if message is a file upload or something else
  static const String textType = 'text';
  static const String fileType = 'file';
  static const String systemType = 'system';

  final String id;
  final String groupId; //mainly for local usage, not sent to firestore
  final String senderId;
  final String senderName;
  final String text;
  final String type;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isDeleted;

  const GroupChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    required this.createdAt,
    required this.editedAt,
    required this.isDeleted,
  });

  factory GroupChatMessage.fromFirestore({
    required String groupId, //for local usage
    required DocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    final data = doc.data() ?? {};

    return GroupChatMessage(
      id: doc.id,
      groupId: groupId,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Student',
      text: data['text'] ?? '',
      type: data['type'] ?? textType,
      createdAt: _dateFromTimestamp(data['createdAt']),
      editedAt: _nullableDateFromTimestamp(data['editedAt']),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'editedAt': editedAt == null ? null : Timestamp.fromDate(editedAt!),
      'isDeleted': isDeleted,
    };
  }

  GroupChatMessage copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? senderName,
    String? text,
    String? type,
    DateTime? createdAt,
    DateTime? editedAt,
    bool? clearEditedAt,
    bool? isDeleted,
  }) {
    return GroupChatMessage(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      editedAt: clearEditedAt == true ? null : editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static DateTime _dateFromTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  static DateTime? _nullableDateFromTimestamp(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
