import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMember {
  static const String ownerRole = 'owner';
  static const String memberRole = 'member';

  final String userId;
  final String displayName;
  final String email;
  final String role;
  final DateTime joinedAt;

  const GroupMember({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  factory GroupMember.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return GroupMember(
      userId: data['userId'] ?? doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? memberRole,
      joinedAt: _dateFromTimestamp(data['joinedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  GroupMember copyWith({
    String? userId,
    String? displayName,
    String? email,
    String? role,
    DateTime? joinedAt,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
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
}
