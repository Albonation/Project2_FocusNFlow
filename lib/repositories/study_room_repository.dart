import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_room_model.dart';

class StudyRoomRepository {
  final FirebaseFirestore _firestore;

  StudyRoomRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _roomsCollection {
    return _firestore.collection('studyRooms');
  }

  Stream<List<StudyRoom>> watchStudyRooms() {
    return _roomsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('building')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(StudyRoom.fromFirestore).toList();
        });
  }

  Future<List<StudyRoom>> getStudyRooms() async {
    final snapshot = await _roomsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('building')
        .orderBy('name')
        .get();

    return snapshot.docs.map(StudyRoom.fromFirestore).toList();
  }

  Stream<List<StudyRoom>> watchAvailableStudyRooms() {
    return _roomsCollection
        .where('isActive', isEqualTo: true)
        .where('isFull', isEqualTo: false)
        .orderBy('building')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(StudyRoom.fromFirestore).toList();
        });
  }

  Future<List<StudyRoom>> getAvailableStudyRooms() async {
    final snapshot = await _roomsCollection
        .where('isActive', isEqualTo: true)
        .where('isFull', isEqualTo: false)
        .orderBy('building')
        .orderBy('name')
        .get();

    return snapshot.docs.map(StudyRoom.fromFirestore).toList();
  }

  Stream<List<StudyRoom>> watchRoomsByBuilding(String building) {
    return _roomsCollection
        .where('isActive', isEqualTo: true)
        .where('building', isEqualTo: building)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(StudyRoom.fromFirestore).toList();
        });
  }

  Future<StudyRoom?> getStudyRoomById(String roomId) async {
    final doc = await _roomsCollection.doc(roomId).get();

    if (!doc.exists) {
      return null;
    }

    return StudyRoom.fromFirestore(doc);
  }

  Future<void> addStudyRoom(StudyRoom room) async {
    await _roomsCollection.add({
      ...room.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStudyRoom(StudyRoom room) async {
    await _roomsCollection.doc(room.id).update({
      ...room.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deactivateStudyRoom(String roomId) async {
    await _roomsCollection.doc(roomId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isUserInRoom({
    required String roomId,
    required String userId,
  }) async {
    final memberDoc = await _roomsCollection
        .doc(roomId)
        .collection('members')
        .doc(userId)
        .get();

    return memberDoc.exists;
  }

  Future<bool> joinRoom({
    required String roomId,
    required String userId,
  }) async {
    final roomRef = _roomsCollection.doc(roomId);
    final memberRef = roomRef.collection('members').doc(userId);

    return _firestore.runTransaction<bool>((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);

      if (!roomSnapshot.exists) {
        throw Exception('Study room not found.');
      }

      final room = StudyRoom.fromFirestore(roomSnapshot);

      if (!room.isActive) {
        throw Exception('Study room is not active.');
      }

      final memberSnapshot = await transaction.get(memberRef);
      if (memberSnapshot.exists) {
        return false;
      }

      if (room.isFull) {
        return false;
      }

      final newOccupancy = room.currentOccupancy + 1;

      transaction.set(memberRef, {'joinedAt': FieldValue.serverTimestamp()});
      transaction.update(roomRef, {
        'currentOccupancy': newOccupancy,
        'isFull': newOccupancy >= room.capacity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  Future<bool> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    final roomRef = _roomsCollection.doc(roomId);
    final memberRef = roomRef.collection('members').doc(userId);

    return _firestore.runTransaction<bool>((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);

      if (!roomSnapshot.exists) {
        throw Exception('Study room not found.');
      }

      final memberSnapshot = await transaction.get(memberRef);
      if (!memberSnapshot.exists) {
        return false;
      }

      final room = StudyRoom.fromFirestore(roomSnapshot);
      final newOccupancy = room.currentOccupancy > 0
          ? room.currentOccupancy - 1
          : 0;

      transaction.delete(memberRef);
      transaction.update(roomRef, {
        'currentOccupancy': newOccupancy,
        'isFull': newOccupancy >= room.capacity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }
}
