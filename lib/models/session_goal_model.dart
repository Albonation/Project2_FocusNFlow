import 'package:cloud_firestore/cloud_firestore.dart';

class SessionGoal {
  final String id;
  final String text;
  final String createdBy;
  final String createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isCompleted;
  final String? completedBy;
  final String? completedByName;
  final DateTime? completedAt;

  const SessionGoal({
    required this.id,
    required this.text,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
    required this.completedBy,
    required this.completedByName,
    required this.completedAt,
  });

  factory SessionGoal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return SessionGoal(
      id: doc.id,
      text: data['text'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? '',
      createdAt: _dateTimeFromTimestamp(data['createdAt']),
      updatedAt: _dateTimeFromTimestamp(data['updatedAt']),
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedBy: data['completedBy'] as String?,
      completedByName: data['completedByName'] as String?,
      completedAt: _dateTimeFromTimestamp(data['completedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isCompleted': isCompleted,
      'completedBy': completedBy,
      'completedByName': completedByName,
      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!),
    };
  }

  static DateTime? _dateTimeFromTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
