import 'package:focus_n_flow/models/planned_task_model.dart';

class Plan {
  final String id;
  final String name;
  final DateTime createdAt;
  final Map<DateTime, List<PlannedTask>> days;

  Plan({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.days,
  });

  Plan copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Map<DateTime, List<PlannedTask>>? days,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      days: days ?? this.days,
    );
  }
}
