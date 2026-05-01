import 'package:focus_n_flow/models/task_model.dart';

class Plan{
  final String id;
  final String name;
  final DateTime createdAt;
  final List<PlannedTask> items;

  Plan({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.items,
  });
}
