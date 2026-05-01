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

  Future<void> _generateAIPlan() async {
    setState(() => _loading = true);

    widget.controller.generateAIPlan();

    setState(() => _loading = false);

    // optional: switch to calendar view handled outside this widget
  }

  void _createManualPlan() {
    widget.controller.createEmptyPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Planner Console",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // AI GENERATE BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _generateAIPlan,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Generate AI Plan"),
            ),
          ),

          const SizedBox(height: 12),

          // MANUAL MODE
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _createManualPlan,
              child: const Text("Start Manual Plan"),
            ),
          ),
        ],
      ),
    );
  }
}