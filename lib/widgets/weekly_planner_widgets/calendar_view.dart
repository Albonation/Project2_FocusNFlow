import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/time_slot_model.dart';
import 'package:focus_n_flow/services/planner_service.dart';

class CalendarView extends StatelessWidget {
  final PlannerController controller;

  const CalendarView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final plan = controller.currentPlan;

    if (plan == null) {
      return const Center(child: Text("No plan selected"));
    }

    final days = plan.slots.keys.toList()..sort();

    return Row(
      children: days.map((day) {
        final slots = plan.slots[day] ?? [];

        return Expanded(
          child: Column(
            children: [
              Text("${day.month}/${day.day}"),
              const Divider(),

              Expanded(
                child: Stack(
                  children: [
                    // background hour grid (optional later)
                    
                    ...slots.map((slot) {
                      return Positioned(
                        top: _minutesFromStart(slot.start).toDouble(),
                        left: 8,
                        right: 8,
                        child: Draggable<TimeSlot>(
                          data: slot,
                          feedback: Material(
                            child: _SlotCard(slot: slot),
                          ),
                          child: _SlotCard(slot: slot),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  double _minutesFromStart(DateTime time) {
    return (time.hour * 60 + time.minute).toDouble();
  }
}
class _SlotCard extends StatelessWidget {
  final TimeSlot slot;

  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(slot.task.task.title),
    );
  }
}