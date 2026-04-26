import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_room_filters.dart';
import 'package:focus_n_flow/models/study_room_model.dart';
import 'package:focus_n_flow/services/study_room_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/study_room_widgets/study_room_card.dart';
import 'package:focus_n_flow/widgets/study_room_widgets/study_room_filter_sheet.dart';

//stateful widget to display list of study rooms with filtering options
//changing filters requires rebuilding the screen with a new filtered room list
class StudyRoomsScreen extends StatefulWidget {
  const StudyRoomsScreen({super.key});

  @override
  State<StudyRoomsScreen> createState() => _StudyRoomsScreenState();
}

class _StudyRoomsScreenState extends State<StudyRoomsScreen> {
  final StudyRoomService _service = StudyRoomService();

  StudyRoomFilters _filters = const StudyRoomFilters();

  @override
  Widget build(BuildContext context) {
    //screen owns userId since it's needed for all room cards and filters
    //this is passed on to the card child widget
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: AppSpacing.screen,
            child: Text(
              'No user logged in',
              textAlign: TextAlign.center,
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final stream = _filters.notFull
        ? _service.watchAvailableRooms()
        : _service.watchStudyRooms();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Rooms'),
        actions: [
          IconButton(
            tooltip: 'Filter rooms',
            color: _filters.hasActiveFilters
                ? context.appColors.brand
                : context.colors.onSurfaceVariant,
            icon: Icon(
              _filters.hasActiveFilters
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _service.watchCurrentJoinedRoomId(userId),
        builder: (context, membershipSnapshots) {
          final currentRoomId = membershipSnapshots.data;

          return StreamBuilder<List<StudyRoom>>(
            stream: stream,
            builder: (context, snapshot) {
              //handle loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              //handle error state
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: AppSpacing.screen,
                    child: Text(
                      'Something went wrong loading study rooms.',
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                  ),
                );
              }

              //apply local filters
              final rooms = snapshot.data ?? [];
              final filteredRooms = rooms.where(_filters.matches).toList();

              //handle empty state
              if (filteredRooms.isEmpty) {
                return Center(
                  child: Padding(
                    padding: AppSpacing.screen,
                    child: Text(
                      'No rooms match the selected filters.',
                      textAlign: TextAlign.center,
                      style: context.text.bodyLarge?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              //display list of rooms
              return ListView.builder(
                padding: AppSpacing.screen,
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];

                  return Padding(
                    padding: AppSpacing.rowPadding,
                    child: StudyRoomCard(
                      room: room,
                      userId: userId,
                      service: _service,
                      isUserInRoom: currentRoomId == room.id,
                      isUserInAnotherRoom:
                          currentRoomId != null && currentRoomId != room.id,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  //helper method to open the filter sheet and update filters
  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<StudyRoomFilters>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StudyRoomFilterSheet(initialFilters: _filters);
      },
    );

    if (result != null) {
      setState(() {
        _filters = result;
      });
    }
  }
}
