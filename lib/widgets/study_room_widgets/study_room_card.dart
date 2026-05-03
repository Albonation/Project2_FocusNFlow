import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_room_model.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class StudyRoomCard extends StatelessWidget {
  final StudyRoom room;
  final bool selectionMode;
  final VoidCallback? onSelect;
  final bool isSelected;

  const StudyRoomCard({
    super.key,
    required this.room,
    this.selectionMode = false,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: selectionMode && !room.isFull ? onSelect : null,
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StudyRoomHeader(room: room),
              AppSpacing.gapSm,
              _OccupancyBadge(room: room),
              _StudyRoomDetails(room: room),
              if (selectionMode) ...[
                AppSpacing.gapMd,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: room.isFull ? null : onSelect,
                    icon: Icon(isSelected ? Icons.check_circle : Icons.check),
                    label: Text(
                      room.isFull
                          ? 'Room Full'
                          : isSelected
                          ? 'Selected'
                          : 'Select Room',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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
