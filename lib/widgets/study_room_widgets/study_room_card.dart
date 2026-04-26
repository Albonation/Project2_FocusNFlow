import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_room_model.dart';
import 'package:focus_n_flow/services/study_room_service.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

//stateful widget to account for the async membership check and button state management
class StudyRoomCard extends StatefulWidget {
  final StudyRoom room;
  final String userId;
  final StudyRoomService service;

  const StudyRoomCard({
    super.key,
    required this.room,
    required this.userId,
    required this.service,
  });

  @override
  State<StudyRoomCard> createState() => _StudyRoomCardState();
}

class _StudyRoomCardState extends State<StudyRoomCard> {
  late Future<bool> _membershipFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _membershipFuture = _loadMembership();
  }

  //this method will check if the user is in the room and update the membership future
  //if the room changes or occupancy changes
  //flutter calls this for us when the widget is rebuilt with new data
  @override
  void didUpdateWidget(covariant StudyRoomCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.room.id != widget.room.id ||
        oldWidget.room.currentOccupancy != widget.room.currentOccupancy) {
      _membershipFuture = _loadMembership();
    }
  }

  //helper method to check if the user is in the room
  Future<bool> _loadMembership() {
    return widget.service.isUserInRoom(
      roomId: widget.room.id,
      userId: widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StudyRoomHeader(room: widget.room),
            AppSpacing.gapSm,
            _OccupancyBadge(room: widget.room),
            _StudyRoomDetails(room: widget.room),
            AppSpacing.gapMd,
            FutureBuilder<bool>(
              future: _membershipFuture,
              builder: (context, snapshot) {
                final isUserInRoom = snapshot.data ?? false;

                return _StudyRoomActions(
                  isUserInRoom: isUserInRoom,
                  isRoomFull: widget.room.isFull,
                  isSubmitting: _isSubmitting,
                  onJoinSolo: _joinSolo,
                  onLeaveRoom: _leaveRoom,
                  onJoinGroup: _showGroupMessage,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //helper method to join the room on button press
  Future<void> _joinSolo() async {
    setState(() {
      _isSubmitting = true;
    });

    final joined = await widget.service.joinRoom(
      roomId: widget.room.id,
      userId: widget.userId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _membershipFuture = _loadMembership();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          joined
              ? 'Joined ${widget.room.name}'
              : 'Unable to join ${widget.room.name}',
        ),
      ),
    );
  }

  //helper method to leave the room on button press
  Future<void> _leaveRoom() async {
    setState(() {
      _isSubmitting = true;
    });

    final left = await widget.service.leaveRoom(
      roomId: widget.room.id,
      userId: widget.userId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _membershipFuture = _loadMembership();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          left
              ? 'Left ${widget.room.name}'
              : 'You are not checked into ${widget.room.name}',
        ),
      ),
    );
  }

  void _showGroupMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group join for ${widget.room.name} is coming soon!'),
      ),
    );
  }
}

//sub-widgets for the study room card
class _StudyRoomHeader extends StatelessWidget {
  final StudyRoom room;

  const _StudyRoomHeader({required this.room});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          room.name,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.gapXs,
        Text(
          '${room.campus} • ${room.building} • ${room.floor}',
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StudyRoomDetails extends StatelessWidget {
  final StudyRoom room;

  const _StudyRoomDetails({required this.room});

  @override
  Widget build(BuildContext context) {
    final features = _featuresText(room);
    final notes = room.notes?.trim();

    if (features.isEmpty && (notes == null || notes.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (features.isNotEmpty) ...[
          AppSpacing.gapSm,
          Text(
            features,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
        if (notes != null && notes.isNotEmpty) ...[
          AppSpacing.gapXs,
          Text(
            notes,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _featuresText(StudyRoom room) {
    final features = <String>[];

    if (room.hasWhiteboard) {
      features.add('Whiteboard');
    }

    if (room.hasMonitor) {
      features.add('Monitor');
    }

    if (room.isReservable) {
      features.add('Reservable');
    }

    if (room.isFull) {
      features.add('Full');
    }

    return features.join(' • ');
  }
}

class _StudyRoomActions extends StatelessWidget {
  final bool isUserInRoom;
  final bool isRoomFull;
  final bool isSubmitting;
  final VoidCallback onJoinSolo;
  final VoidCallback onLeaveRoom;
  final VoidCallback onJoinGroup;

  const _StudyRoomActions({
    required this.isUserInRoom,
    required this.isRoomFull,
    required this.isSubmitting,
    required this.onJoinSolo,
    required this.onLeaveRoom,
    required this.onJoinGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (isUserInRoom)
          FilledButton(
            onPressed: isSubmitting ? null : onLeaveRoom,
            child: const Text('Leave Room'),
          )
        else
          FilledButton(
            onPressed: isRoomFull || isSubmitting ? null : onJoinSolo,
            child: const Text('Join Solo'),
          ),
        OutlinedButton(
          onPressed: isSubmitting ? null : onJoinGroup,
          child: const Text('Join as Group'),
        ),
      ],
    );
  }
}

class _OccupancyBadge extends StatelessWidget {
  final StudyRoom room;

  const _OccupancyBadge({required this.room});

  @override
  Widget build(BuildContext context) {
    final isFull = room.isFull;

    return Container(
      padding: AppSpacing.badge,
      decoration: BoxDecoration(
        color: isFull
            ? context.appColors.danger.withValues(alpha: 0.12)
            : context.appColors.success.withValues(alpha: 0.12),
        border: Border.all(
          color: isFull ? context.appColors.danger : context.appColors.success,
        ),
        borderRadius: BorderRadius.circular(AppCorners.pill),
      ),
      child: Text(
        'Seats: ${room.currentOccupancy}/${room.capacity}',
        style: context.text.labelSmall?.copyWith(
          color: isFull ? context.appColors.danger : context.appColors.success,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
