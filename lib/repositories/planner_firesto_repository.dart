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

      final taskWithId = task.copyWith(id: docRef.id);

      batch.set(docRef, taskWithId.toMap());
    }

    await batch.commit();
  }

   Future<bool> isPlanGenerated(String uid, String weekId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('weekly_plans')
        .doc(weekId)
        .get();

    return doc.exists && (doc.data()?['generated'] == true);
  }

  Future<void> markGenerated(String uid, String weekId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('weekly_plans')
        .doc(weekId)
        .set({
          'generated': true,
          'generatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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
            return PlannedTask.fromMap(
              doc.data(),
              doc.id, 
            );
          }).toList();
        });
  }

  Future<void> updatePlannedTaskCompletion({
    required String userId,
    required DateTime weekStart,
    required String plannedTaskId,
    required bool isCompleted,
  }) async {
    final weekId = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    ).toIso8601String();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('weekly_plans')
        .doc(weekId)
        .collection('planned_tasks')
        .doc(plannedTaskId)
        .update({
      'is_completed': isCompleted,
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