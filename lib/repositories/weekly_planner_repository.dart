import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/planning_model.dart';

class WeeklyPlannerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getPlanRef(String userId, String weekId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('weekly_plans')
        .doc(weekId)
        .collection('tasks');
  }

  /// SAVE (create full plan)
  Future<void> savePlan(
    String userId,
    String weekId,
    List<PlannedTask> plan,
  ) async {
    final data = plan.map((p) => {
      'taskId': p.taskId,
      'plannedDate': p.plannedDate.toIso8601String(),
      'hoursForDay': p.hoursForDay,
    }).toList();

    // store full weekly plan
    await _firestore
        .collection('plans')
        .doc('$userId-$weekId')
        .set({'items': data});
  }

  /// STREAM PLAN (REAL TIME CALENDAR)
  Stream<List<PlannedTask>> getPlan(
    String userId,
    String weekId,
  ) {
    return _getPlanRef(userId, weekId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PlannedTask.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// UPDATE SINGLE EVENT (DRAG & DROP READY)
  Future<void> updatePlannedTaskDate(
    String userId,
    String weekId,
    String taskDocId,
    DateTime newDate,
  ) {
    return _getPlanRef(userId, weekId)
        .doc(taskDocId)
        .update({
      'planned_date': Timestamp.fromDate(newDate),
    });
  }

  Future<void> movePlannedTask(
    String userId,
    String weekId,
    String taskId,
    DateTime newDate,
  ) async {

    final normalized = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
    );

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('weekly_plans')
        .doc(weekId)
        .collection('tasks');

    final snapshot =
        await ref.where('task_id', isEqualTo: taskId).get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'planned_date': Timestamp.fromDate(normalized),
      });
    }
  }

  /// DELETE EVENT (for reschedule replace logic)
  Future<void> deletePlannedTask(
    String userId,
    String weekId,
    String taskDocId,
  ) {
    return _getPlanRef(userId, weekId)
        .doc(taskDocId)
        .delete();
  }

  Stream<List<PlannedTask>> getPlanStream(
    String userId,
    String weekId,
  ) {
    return _firestore
        .collection('plans')
        .doc('$userId-$weekId')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return [];

      final list = (doc.data()?['items'] as List);

      return list.map((e) {
        return PlannedTask(
          taskId: e['taskId'],
          plannedDate: DateTime.parse(e['plannedDate']),
          hoursForDay: (e['hoursForDay'] as num).toDouble(),
        );
      }).toList();
    });
  }
}