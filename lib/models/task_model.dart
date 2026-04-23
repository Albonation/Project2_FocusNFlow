class Task {
  final String title;
  final DateTime deadline;
  final int effort;
  final int courseWeight;
  bool isCompleted;

  Task({
    required this.title,
    required this.deadline,
    required this.effort,
    required this.courseWeight,
    this.isCompleted = false,
  });
}