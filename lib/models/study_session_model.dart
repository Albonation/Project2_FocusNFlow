import 'package:cloud_firestore/cloud_firestore.dart';

enum StudySessionStatus { scheduled, active, completed, cancelled }

extension StudySessionStatusX on StudySessionStatus {
  String get value {
    switch (this) {
      case StudySessionStatus.scheduled:
        return 'scheduled';
      case StudySessionStatus.active:
        return 'active';
      case StudySessionStatus.completed:
        return 'completed';
      case StudySessionStatus.cancelled:
        return 'cancelled';
    }
  }

  static StudySessionStatus fromString(String? value) {
    switch (value) {
      case 'active':
        return StudySessionStatus.active;
      case 'completed':
        return StudySessionStatus.completed;
      case 'cancelled':
        return StudySessionStatus.cancelled;
      case 'scheduled':
      default:
        return StudySessionStatus.scheduled;
    }
  }
}

class StudySession {
  final String id;
  final String groupId;
  final String groupName;
  final String title;
  final String description;
  final String? courseId;
  final String? courseCode;
  final String? roomId;
  final String? roomName;
  final String createdBy;
  final String createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime startsAt;
  final DateTime endsAt;
  final StudySessionStatus status;
  final int participantCount;
  final bool reminderSent;
  final bool isActive;
  final String? startedBy;

  const StudySession({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseCode,
    required this.roomId,
    required this.roomName,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.participantCount,
    required this.reminderSent,
    required this.isActive,
    required this.startedBy,
  });

  factory StudySession.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return StudySession(
      id: doc.id,
      groupId: data['groupId'] as String? ?? '',
      groupName: data['groupName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      courseId: data['courseId'] as String?,
      courseCode: data['courseCode'] as String?,
      roomId: data['roomId'] as String?,
      roomName: data['roomName'] as String?,
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? '',
      createdAt: _dateTimeFromTimestamp(data['createdAt']),
      updatedAt: _dateTimeFromTimestamp(data['updatedAt']),
      startsAt: _dateTimeFromTimestamp(data['startsAt']) ?? DateTime.now(),
      endsAt: _dateTimeFromTimestamp(data['endsAt']) ?? DateTime.now(),
      status: StudySessionStatusX.fromString(data['status'] as String?),
      participantCount: data['participantCount'] as int? ?? 0,
      reminderSent: data['reminderSent'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      startedBy: data['startedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'title': title,
      'description': description,
      'courseId': courseId,
      'courseCode': courseCode,
      'roomId': roomId,
      'roomName': roomName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'startsAt': Timestamp.fromDate(startsAt),
      'endsAt': Timestamp.fromDate(endsAt),
      'status': status.value,
      'participantCount': participantCount,
      'reminderSent': reminderSent,
      'isActive': isActive,
      'startedBy': startedBy,
    };
  }

  //to prevent overwriting something that really should be immutable
  //intentionally excludes some fields
  Map<String, dynamic> toUpdateFirestore() {
    return {
      'title': title,
      'description': description,
      'courseId': courseId,
      'courseCode': courseCode,
      'roomId': roomId,
      'roomName': roomName,
      'status': status.value,
      'reminderSent': reminderSent,
      'isActive': isActive,
      'startedBy': startedBy,
      'startsAt': Timestamp.fromDate(startsAt),
      'endsAt': Timestamp.fromDate(endsAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  StudySession copyWith({
    String? id,
    String? groupId,
    String? groupName,
    String? title,
    String? description,
    String? courseId,
    String? courseCode,
    String? roomId,
    String? roomName,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startsAt,
    DateTime? endsAt,
    StudySessionStatus? status,
    int? participantCount,
    bool? reminderSent,
    bool? isActive,
    String? startedBy,
  }) {
    return StudySession(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      status: status ?? this.status,
      participantCount: participantCount ?? this.participantCount,
      reminderSent: reminderSent ?? this.reminderSent,
      isActive: isActive ?? this.isActive,
      startedBy: startedBy ?? this.startedBy,
    );
  }

  static DateTime? _dateTimeFromTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
