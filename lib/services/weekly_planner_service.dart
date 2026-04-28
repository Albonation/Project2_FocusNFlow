import 'package:focus_n_flow/models/task_model.dart';

class WeeklyPlannerService {

  Map<String, List<Task>> generateWeeklyPlan(List<Task> tasks) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final sorted = [...tasks];

    sorted.sort((a, b) =>
        b.priorityScore.compareTo(a.priorityScore));

    final plan = <String, List<Task>>{};

    for (int i = 0; i < sorted.length; i++) {
      final day = days[i % 7];
      plan.putIfAbsent(day, () => []);
      plan[day]!.add(sorted[i]);
    }

    return plan;
  }

  List<Task> filterTasksByData(List<Task> tasks, DateTime date){
    return tasks.where((t)=>
      t.deadline.year == date.year &&
      t.deadline.month == date.month &&
      t.deadline.day == date.day
    ).toList();
  }
}