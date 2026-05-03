import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/task_model.dart';

class TaskCard extends StatefulWidget {
  final PlannedTask task;
  final Task? fullTask;
  final int totalUnits;

  const TaskCard({
    super.key,
    required this.task,
    required this.fullTask,
    required this.totalUnits,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _collapsedView(),
            secondChild: _expandedView(),
          ),
        ),
      ),
    );
  }

  Widget _collapsedView() {
    return Row(
      children: [
        const Icon(Icons.book, size: 18),
        const SizedBox(width: 8),
        Text(
          "${widget.fullTask?.title ?? "Task"} "
          "Session ${widget.task.unitIndex + 1}/${widget.totalUnits}",
        ),
      ],
    );
  }

  Widget _expandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Task Title: ${widget.fullTask?.title ?? "Unknown"}"),
        Text("Study Session #${widget.task.unitIndex + 1}"),
        const SizedBox(height: 6),
        Text("Scheduled: ${widget.task.date.month}/${widget.task.date.day}"),
        const SizedBox(height: 6),
        Text("Week Start: ${widget.task.weekStart.month}/${widget.task.weekStart.day}"),
      ],
    );
  }
}