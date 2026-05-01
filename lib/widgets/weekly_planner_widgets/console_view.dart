import 'package:flutter/material.dart';
import 'package:focus_n_flow/services/planner_service.dart';

class PlannerConsole extends StatefulWidget {
  final PlannerController controller;

  const PlannerConsole({
    super.key,
    required this.controller,
  });

  @override
  State<PlannerConsole> createState() => _PlannerConsoleState();
}

class _PlannerConsoleState extends State<PlannerConsole> {
  bool _loading = false;

  Future<void> _generateAI() async {
    setState(() => _loading = true);

    widget.controller.generateAIPlan();

    setState(() => _loading = false);
  }

  void _createManual() {
    widget.controller.createEmptyPlan();
  }

  void _clearPlan() {
    widget.controller.currentPlan = null;
    widget.controller.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.controller.currentPlan;
    final taskCount = widget.controller.tasks.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Planner Console",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // -------------------
          // STATUS PANEL
          // -------------------
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tasks Loaded: $taskCount"),
                Text("Plan Active: ${plan != null ? 'Yes' : 'No'}"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // -------------------
          // ACTIONS
          // -------------------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _generateAI,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Generate AI Plan"),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _createManual,
              child: const Text("Create Manual Plan"),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _clearPlan,
              child: const Text("Clear Plan"),
            ),
          ),

          const SizedBox(height: 20),

          // -------------------
          // OPTIONAL PREVIEW
          // -------------------
          if (plan != null)
            Expanded(
              child: ListView(
                children: plan.days.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key.toString()),
                    subtitle: Text("${entry.value.length} tasks"),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}