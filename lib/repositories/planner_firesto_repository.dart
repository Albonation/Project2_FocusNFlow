import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';

class PlannerFirestoreRepository {
  // SAVE PLAN
  Future<void> savePlan(
    String uid,
    DateTime weekStart,
    List<PlannedTask> plan,
  ) async {

    final weekId = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    ).toIso8601String();

    final weekRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('weekly_plans')
        .doc(weekId)
        .collection('planned_tasks');

    final old = await weekRef.get();
    for (final doc in old.docs) {
      await doc.reference.delete();
    }

    final batch = FirebaseFirestore.instance.batch();

    for (final task in plan) {
      final docRef = weekRef.doc();

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
              taskId: data['task_id'],
              title: data['title'],
              courseId: data['course_id'],
              date: (data['date'] as Timestamp).toDate(),
              unitIndex: data['unit_index'],
            );
          }).toList();
        });
  }

  

  Future<void> removeTaskFromWeeklyPlans({
    required String userId,
    required String taskId,
  }) async {
    final weeksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('weekly_plans');

    final weeks = await weeksRef.get();

    for (final weekDoc in weeks.docs) {
      final tasksRef = weekDoc.reference.collection('planned_tasks');

      final snapshot = await tasksRef
          .where('task_id', isEqualTo: taskId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
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