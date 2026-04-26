import '../models/study_room_model.dart';
import '../repositories/study_room_repository.dart';

class StudyRoomService {
  final StudyRoomRepository _repository;

  StudyRoomService({StudyRoomRepository? repository})
    : _repository = repository ?? StudyRoomRepository();

  Stream<List<StudyRoom>> watchStudyRooms() {
    return _repository.watchStudyRooms();
  }

  Future<List<StudyRoom>> getStudyRooms() {
    return _repository.getStudyRooms();
  }

  Stream<List<StudyRoom>> watchRoomsByBuilding(String building) {
    return _repository.watchRoomsByBuilding(building);
  }

  Future<StudyRoom?> getStudyRoomById(String roomId) {
    return _repository.getStudyRoomById(roomId);
  }

  Future<List<StudyRoom>> getAvailableRooms() async {
    return _repository.getAvailableStudyRooms();
  }

  Stream<List<StudyRoom>> watchAvailableRooms() {
    return _repository.watchAvailableStudyRooms();
  }

  Future<bool> joinRoom({
    required String roomId,
    required String userId,
  }) async {
    _validateIds(roomId: roomId, userId: userId);

    return _repository.joinRoom(roomId: roomId, userId: userId);
  }

  Future<bool> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    _validateIds(roomId: roomId, userId: userId);

    return _repository.leaveRoom(roomId: roomId, userId: userId);
  }

  Future<bool> isUserInRoom({
    required String roomId,
    required String userId,
  }) async {
    _validateIds(roomId: roomId, userId: userId);

    return _repository.isUserInRoom(roomId: roomId, userId: userId);
  }

  Future<void> addStudyRoom(StudyRoom room) {
    return _repository.addStudyRoom(room);
  }

  Future<void> updateStudyRoom(StudyRoom room) {
    return _repository.updateStudyRoom(room);
  }

  Future<void> deactivateStudyRoom(String roomId) {
    return _repository.deactivateStudyRoom(roomId);
  }

  void _validateIds({required String roomId, required String userId}) {
    if (roomId.trim().isEmpty) {
      throw ArgumentError.value(roomId, 'roomId', 'roomId cannot be empty.');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty.');
    }
  }
}
