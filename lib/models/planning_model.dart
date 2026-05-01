import 'package:focus_n_flow/models/time_slot_model.dart';

class Plan {
  final String id;
  final String name;
  final DateTime createdAt;
  final Map<DateTime, List<TimeSlot>> slots;

  Plan({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.slots,
  });

  Plan copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Map<DateTime, List<TimeSlot>>? slots,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      slots: slots ?? this.slots,
    );
  }
}