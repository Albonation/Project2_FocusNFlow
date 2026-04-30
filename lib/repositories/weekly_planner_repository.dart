import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/planning_model.dart';

class WeeklyPlannerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getPlanRef(String userId, String weekId){
    return _firestore
      .collection('users')
      .doc(userId)
      .collection('weekly_plans')
      .doc(weekId)
      .collection('tasks');
  }

  Future<void> savePlan(
    String userId, 
    String weekId,
    List<PlannedTask> tasks,
  ) async {
    final batch = _firestore.batch();

    final ref = _getPlanRef(userId, weekId);

    for (final task in tasks){
      final doc = ref.doc();
      batch.set(doc, task.toMap());
    }

    await batch.commit();
  }

  Stream<List<PlannedTask>> getPlan(
    String userId,
    String weekId,
  ) {
    return _getPlanRef(userId, weekId)
      .snapshots()
      .map((snapshot)=>
        snapshot.docs.map((doc) => 
        PlannedTask.fromMap(doc.data() 
        as Map<String, dynamic>)).toList());
  }
}