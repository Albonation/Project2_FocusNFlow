import 'package:flutter/material.dart';

class PlannerOverviewCard extends StatefulWidget {
  const PlannerOverviewCard({super.key});

  @override
  State<PlannerOverviewCard> createState() =>
      _PlannerOverviewCardState();
}

class _PlannerOverviewCardState extends State<PlannerOverviewCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Row(
              children: const [
                Icon(Icons.info_outline),
                SizedBox(width: 8),
                Text(
                  "How your weekly plan works",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text(
                      "How your weekly plan works",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Text(
                  "• Tasks are automatically broken into study sessions based on estimated hours.",
                ),
                SizedBox(height: 6),

                Text(
                  "• Higher priority tasks (closer deadlines, higher weight) are scheduled first.",
                ),
                SizedBox(height: 6),

                Text(
                  "• Sessions are distributed across the week to balance workload.",
                ),
                SizedBox(height: 6),

                Text(
                  "• Completed tasks are automatically removed from your plan.",
                ),
                SizedBox(height: 6),

                Text(
                  "• Each item shows your progress as Session X / Total Sessions for that day.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}