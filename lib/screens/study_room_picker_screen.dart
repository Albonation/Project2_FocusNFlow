import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_room_filters.dart';
import 'package:focus_n_flow/models/study_room_model.dart';
import 'package:focus_n_flow/services/study_room_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/study_room_widgets/study_room_card.dart';
import 'package:focus_n_flow/widgets/study_room_widgets/study_room_filter_sheet.dart';

class StudyRoomPickerScreen extends StatefulWidget {
  final DateTime startsAt;
  final DateTime endsAt;
  final String? selectedRoomId;

  const StudyRoomPickerScreen({
    super.key,
    required this.startsAt,
    required this.endsAt,
    this.selectedRoomId,
  });

  @override
  State<StudyRoomPickerScreen> createState() => _StudyRoomPickerScreenState();
}

class _StudyRoomPickerScreenState extends State<StudyRoomPickerScreen> {
  final StudyRoomService _roomService = StudyRoomService();

  StudyRoomFilters _filters = const StudyRoomFilters();

  Future<void> _showFilters() async {
    final updatedFilters = await showModalBottomSheet<StudyRoomFilters>(
      context: context,
      showDragHandle: true,
      builder: (_) => StudyRoomFilterSheet(initialFilters: _filters),
    );

    if (updatedFilters == null || !mounted) return;

    setState(() {
      _filters = updatedFilters;
    });
  }

  void _clearFilters() {
    setState(() {
      _filters = const StudyRoomFilters();
    });
  }

  void _selectRoom(StudyRoom room) {
    Navigator.pop(context, room);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Study Room'),
        actions: [
          if (_filters.hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear'),
            ),
          IconButton(
            tooltip: 'Filter rooms',
            onPressed: _showFilters,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<List<StudyRoom>>(
        stream: _roomService.watchSelectableStudyRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: AppSpacing.screen,
              child: Text(
                'Unable to load study rooms: ${snapshot.error}',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
            );
          }

          final rooms = snapshot.data ?? [];
          final filteredRooms = rooms.where(_filters.matches).toList();

          return Column(
            children: [
              _PickerHeader(
                startsAt: widget.startsAt,
                endsAt: widget.endsAt,
                roomCount: filteredRooms.length,
              ),

              Expanded(
                child: filteredRooms.isEmpty
                    ? _EmptyRoomPickerState(
                  hasFilters: _filters.hasActiveFilters,
                  onClearFilters: _clearFilters,
                )
                    : ListView.separated(
                  padding: AppSpacing.screen,
                  itemCount: filteredRooms.length,
                  separatorBuilder: (_, __) => AppSpacing.gapMd,
                  itemBuilder: (context, index) {
                    final room = filteredRooms[index];

                    return StudyRoomCard(
                      room: room,
                      selectionMode: true,
                      isSelected: room.id == widget.selectedRoomId,
                      onSelect: () => _selectRoom(room),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PickerHeader extends StatelessWidget {
  final DateTime startsAt;
  final DateTime endsAt;
  final int roomCount;

  const _PickerHeader({
    required this.startsAt,
    required this.endsAt,
    required this.roomCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screen.copyWith(bottom: 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: context.appColors.studyRoom.withValues(
                  alpha: 0.15,
                ),
                foregroundColor: context.appColors.studyRoom,
                child: const Icon(Icons.meeting_room_outlined),
              ),

              AppSpacing.horizontalGapMd,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select a room for this session',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      '${_formatDateTime(startsAt)} → ${_formatTime(endsAt)}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      '$roomCount room${roomCount == 1 ? '' : 's'} available',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRoomPickerState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyRoomPickerState({
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasFilters
                ? 'No rooms match your filters.'
                : 'No selectable study rooms found.',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          AppSpacing.gapSm,

          Text(
            hasFilters
                ? 'Try clearing filters or lowering the minimum capacity.'
                : 'Make sure rooms are active and reservable in Firestore.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          if (hasFilters) ...[
            AppSpacing.gapLg,
            FilledButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${_formatTime(dateTime)}';
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0
      ? 12
      : hour > 12
      ? hour - 12
      : hour;

  return '$displayHour:$minute $period';
}