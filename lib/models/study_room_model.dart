import 'package:cloud_firestore/cloud_firestore.dart';

class StudyRoom {
  static const Object _unset = Object();

  final String id;
  final String name;
  final String building;
  final String campus;
  final String floor;
  final int capacity;
  final int currentOccupancy;
  final bool hasWhiteboard;
  final bool hasMonitor;
  final bool isReservable;
  final String? notes;
  final bool isActive;
  final DateTime? updatedAt;

  //fields for study session lifecycle actions
  final String? activeSessionId;
  final String? activeSessionTitle;
  final String? activeGroupId;
  final String? activeGroupName;

  const StudyRoom({
    required this.id,
    required this.name,
    required this.building,
    required this.campus,
    required this.floor,
    required this.capacity,
    required this.currentOccupancy,
    required this.hasWhiteboard,
    required this.hasMonitor,
    required this.isReservable,
    this.notes,
    required this.isActive,
    this.updatedAt,

    //fields for study session lifecycle actions
    this.activeSessionId,
    this.activeSessionTitle,
    this.activeGroupId,
    this.activeGroupName,
  });

  factory StudyRoom.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return StudyRoom(
      id: doc.id,
      name: data['name'] as String? ?? '',
      building: data['building'] as String? ?? '',
      campus: data['campus'] as String? ?? '',
      floor: data['floor'] as String? ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      currentOccupancy: (data['currentOccupancy'] as num?)?.toInt() ?? 0,
      hasWhiteboard: data['hasWhiteboard'] as bool? ?? false,
      hasMonitor: data['hasMonitor'] as bool? ?? false,
      isReservable: data['isReservable'] as bool? ?? false,
      notes: data['notes'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      activeSessionId: data['activeSessionId'] as String?,
      activeSessionTitle: data['activeSessionTitle'] as String?,
      activeGroupId: data['activeGroupId'] as String?,
      activeGroupName: data['activeGroupName'] as String?,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'building': building,
      'campus': campus,
      'floor': floor,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'hasWhiteboard': hasWhiteboard,
      'hasMonitor': hasMonitor,
      'isReservable': isReservable,
      'notes': notes,
      'isActive': isActive,
      'isFull': isFull,
      'activeSessionId': activeSessionId,
      'activeSessionTitle': activeSessionTitle,
      'activeGroupId': activeGroupId,
      'activeGroupName': activeGroupName,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  StudyRoom copyWith({
    String? id,
    String? name,
    String? building,
    String? campus,
    String? floor,
    int? capacity,
    int? currentOccupancy,
    bool? hasWhiteboard,
    bool? hasMonitor,
    bool? isReservable,
    Object? notes = _unset,
    bool? isActive,
    Object? activeSessionId = _unset,
    Object? activeSessionTitle = _unset,
    Object? activeGroupId = _unset,
    Object? activeGroupName = _unset,
    DateTime? updatedAt,
  }) {
    return StudyRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      campus: campus ?? this.campus,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      hasWhiteboard: hasWhiteboard ?? this.hasWhiteboard,
      hasMonitor: hasMonitor ?? this.hasMonitor,
      isReservable: isReservable ?? this.isReservable,
      notes: notes == _unset ? this.notes : notes as String?,
      isActive: isActive ?? this.isActive,
      activeSessionId: activeSessionId == _unset
          ? this.activeSessionId
          : activeSessionId as String?,
      activeSessionTitle: activeSessionTitle == _unset
          ? this.activeSessionTitle
          : activeSessionTitle as String?,
      activeGroupId: activeGroupId == _unset
          ? this.activeGroupId
          : activeGroupId as String?,
      activeGroupName: activeGroupName == _unset
          ? this.activeGroupName
          : activeGroupName as String?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isFull => capacity > 0 && currentOccupancy >= capacity;

  bool get isInUseByActiveSession {
    return activeSessionId != null && activeSessionId!.trim().isNotEmpty;
  }

  bool get canBeSelectedForSession {
    return isActive && isReservable;
  }

  int get availableSeats {
    final seats = capacity - currentOccupancy;
    return seats < 0 ? 0 : seats;
  }
}
