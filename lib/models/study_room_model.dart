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
  });

  factory StudyRoom.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return StudyRoom(
      id: doc.id,
      name: data['name'] ?? '',
      building: data['building'] ?? '',
      campus: data['campus'] ?? '',
      floor: data['floor'] ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      currentOccupancy: (data['currentOccupancy'] as num?)?.toInt() ?? 0,
      hasWhiteboard: data['hasWhiteboard'] ?? false,
      hasMonitor: data['hasMonitor'] ?? false,
      isReservable: data['isReservable'] ?? false,
      notes: data['notes'],
      isActive: data['isActive'] ?? true,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isFull => currentOccupancy >= capacity;

  int get availableSeats {
    final seats = capacity - currentOccupancy;
    return seats < 0 ? 0 : seats;
  }
}
