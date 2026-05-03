import 'study_room_model.dart';

//a class to store the current filter selections
//reduces clutter in screen and filter sheet widgets
//one object can now pass around all filter selections instead of multiple individual variables
class StudyRoomFilters {
  final String? campus;
  final String? building;
  final int minCapacity;
  final bool notFull;
  final bool reservableOnly;

  const StudyRoomFilters({
    this.campus,
    this.building,
    this.minCapacity = 0,
    this.notFull = false,
    this.reservableOnly = false,
  });


  //helper methods to assist with filter logic
  bool get hasActiveFilters {
    return campus != null || building != null || minCapacity > 0 || notFull || reservableOnly;
  }

  //this method returns true if the given room matches the current filter selections
  bool matches(StudyRoom room) {
    if (campus != null && room.campus != campus) {
      return false;
    }

    if (building != null && room.building != building) {
      return false;
    }

    if (room.capacity < minCapacity) {
      return false;
    }

    if (notFull && room.isFull) {
      return false;
    }

    if (reservableOnly && !room.canBeSelectedForSession) {
      return false;
    }

    return true;
  }

  StudyRoomFilters copyWith({
    String? campus,
    String? building,
    int? minCapacity,
    bool? notFull,
    bool? reservableOnly,
    bool clearCampus = false,
    bool clearBuilding = false,
  }) {
    return StudyRoomFilters(
      campus: clearCampus ? null : campus ?? this.campus,
      building: clearBuilding ? null : building ?? this.building,
      minCapacity: minCapacity ?? this.minCapacity,
      notFull: notFull ?? this.notFull,
      reservableOnly: reservableOnly ?? this.reservableOnly,
    );
  }
}
