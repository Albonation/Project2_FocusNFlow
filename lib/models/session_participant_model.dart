import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionParticipantStatus { joined, left }

extension SessionParticipantStatusX on SessionParticipantStatus {
  String get value {
    switch (this) {
      case SessionParticipantStatus.joined:
        return 'joined';
      case SessionParticipantStatus.left:
        return 'left';
    }
  }

  static SessionParticipantStatus fromString(String? value) {
    switch (value) {
      case 'left':
        return SessionParticipantStatus.left;
      case 'joined':
      default:
        return SessionParticipantStatus.joined;
    }
  }
}

class SessionParticipant {
  //user's firebase user id for the participant document id
  final String userId;
  final String displayName;
  final String email;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final SessionParticipantStatus status;

  const SessionParticipant({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.joinedAt,
    required this.leftAt,
    required this.status,
  });

  factory SessionParticipant.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return SessionParticipant(
      userId: data['userId'] as String? ?? doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      joinedAt: _dateTimeFromTimestamp(data['joinedAt']),
      leftAt: _dateTimeFromTimestamp(data['leftAt']),
      status: SessionParticipantStatusX.fromString(data['status'] as String?),
    );
  }

  Map<String, dynamic> toJoinMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'joinedAt': FieldValue.serverTimestamp(),
      'leftAt': null,
      'status': SessionParticipantStatus.joined.value,
    };
  }

  Map<String, dynamic> toLeaveMap() {
    return {
      'leftAt': FieldValue.serverTimestamp(),
      'status': SessionParticipantStatus.left.value,
    };
  }

  static DateTime? _dateTimeFromTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
