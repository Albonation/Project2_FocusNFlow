import '../models/study_room_model.dart';
import '../repositories/study_room_repository.dart';

//this service layer abstracts the repository
//and provides higher level methods for the UI to interact with study rooms
class StudyRoomService {
  final StudyRoomRepository _repository;

  StudyRoomService({StudyRoomRepository? repository})
    : _repository = repository ?? StudyRoomRepository();

  //streams all study rooms
  Stream<List<StudyRoom>> watchStudyRooms() {
    return _repository.watchStudyRooms();
  }

  //fetches all study rooms once
  Future<List<StudyRoom>> getStudyRooms() {
    return _repository.getStudyRooms();
  }

  //streams study rooms filtered by building
  Stream<List<StudyRoom>> watchRoomsByBuilding(String building) {
    return _repository.watchRoomsByBuilding(building);
  }

  //streams the user's global study room membership document
  Stream<String?> watchCurrentJoinedRoomId(String userId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }
    return _repository.watchCurrentJoinedRoomId(userId);
  }

  //fetches a single study room by ID
  Future<StudyRoom?> getStudyRoomById(String roomId) {
    return _repository.getStudyRoomById(roomId);
  }

  //fetches all study rooms that are not full and are active
  Future<List<StudyRoom>> getAvailableRooms() async {
    return _repository.getAvailableStudyRooms();
  }

  //streams all study rooms that are not full and are active
  Stream<List<StudyRoom>> watchAvailableRooms() {
    return _repository.watchAvailableStudyRooms();
  }

  //allows a user to join a room, returns true if successful
  Future<bool> joinRoom({
    required String roomId,
    required String userId,
  }) async {
    _validateIds(roomId: roomId, userId: userId);

    return _repository.joinRoom(roomId: roomId, userId: userId);
  }

  //allows a user to leave a room, returns true if successful
  Future<bool> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    _validateIds(roomId: roomId, userId: userId);

    return _repository.leaveRoom(roomId: roomId, userId: userId);
  }

  //checks if a user is currently in a room, returns true if they are
  Future<bool> isUserInRoom({
    required String roomId,
    required String userId,
  }) async {
    _validateIds(roomId: roomId, userId: userId);

    return _repository.isUserInRoom(roomId: roomId, userId: userId);
  }

  //create and update study rooms
  Future<void> addStudyRoom(StudyRoom room) {
    return _repository.addStudyRoom(room);
  }

  Future<void> updateStudyRoom(StudyRoom room) {
    return _repository.updateStudyRoom(room);
  }

  //deactivates a study room so it no longer appears in the UI
  //i would rather not delete the study rooms, it was a lot of work getting them there
  //from the GSU website
  Future<void> deactivateStudyRoom(String roomId) {
    return _repository.deactivateStudyRoom(roomId);
  }

  //helper method to validate that roomId and userId are not empty or just whitespace
  void _validateIds({required String roomId, required String userId}) {
    if (roomId.trim().isEmpty) {
      throw ArgumentError.value(roomId, 'roomId', 'roomId cannot be empty.');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty.');
    }
  }
}
