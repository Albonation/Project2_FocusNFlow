import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';

class PlannerFirestoreRepository {
  // SAVE PLAN
  Future<void> savePlan(
    String uid,
    DateTime weekStart,
    List<PlannedTask> plan) async {

    final weekId = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    ).toIso8601String();

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('weekly_plans')
        .doc(weekId)
        .collection('planned_tasks');

    final batch = FirebaseFirestore.instance.batch();

    for (final task in plan) {
      final docRef = ref.doc(); // generate ID once

      batch.set(docRef, task.toMap());
    }

    await batch.commit();
  }

  Stream<List<PlannedTask>> getWeeklyPlan(
  String uid,
  DateTime weekStart,
  ) {
    final weekId = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    ).toIso8601String();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('weekly_plans')
        .doc(weekId)
        .collection('planned_tasks')
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return PlannedTask(
              id: doc.id,
              taskId: data['task_id'],
              date: (data['date'] as Timestamp).toDate(),
              unitIndex: data['unit_index'],
              weekStart: (data['week_start'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }

  Future<void> clearWeekPlan(String uid, DateTime weekStart) async {
    final weekId = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    ).toIso8601String();

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('weekly_plans')
        .doc(weekId)
        .collection('planned_tasks');

    final snapshot = await ref.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}