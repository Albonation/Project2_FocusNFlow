import 'package:flutter/material.dart';
import 'package:focus_n_flow/services/planner_service.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/weekly_planner_widget.dart';

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
  final TextEditingController _input = TextEditingController();
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);

    final aiPlan = await widget.controller.engine.generateFromPrompt(
      _input.text,
      widget.controller.tasks,
    );

    widget.controller.setCurrentPlan(aiPlan);

    setState(() => _loading = false);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlannerScreen(), // or toggle state
        ),
      );
    }
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

          const SizedBox(height: 12),

          TextField(
            controller: _input,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Type a schedule request...\nExample: "
                  "Build me a study plan for finals week",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              ElevatedButton(
                onPressed: _loading ? null : _generate,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Generate AI Plan"),
              ),

              const SizedBox(width: 12),

              OutlinedButton(
                onPressed: () {
                  widget.controller.createEmptyPlan();
                  setState(() {});
                },
                child: const Text("Start Manual Plan"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}