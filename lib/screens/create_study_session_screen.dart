import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_group_model.dart';
import 'package:focus_n_flow/models/study_session_model.dart';
import 'package:focus_n_flow/services/study_session_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class CreateStudySessionScreen extends StatefulWidget {
  final StudyGroup group;
  final StudySession? session;

  const CreateStudySessionScreen({
    super.key,
    required this.group,
    this.session,
  });

  bool get isEditing => session != null;

  @override
  State<CreateStudySessionScreen> createState() =>
      _CreateStudySessionScreenState();
}

class _CreateStudySessionScreenState extends State<CreateStudySessionScreen> {
  final StudySessionService _sessionService = StudySessionService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _startsAt;
  late DateTime _endsAt;

  String? _courseId;
  String? _courseCode;
  String? _roomId;
  String? _roomName;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final session = widget.session;
    final now = DateTime.now();

    _titleController = TextEditingController(text: session?.title ?? '');
    _descriptionController = TextEditingController(
      text: session?.description ?? '',
    );

    _startsAt = session?.startsAt ?? now.add(const Duration(hours: 1));
    _endsAt = session?.endsAt ?? now.add(const Duration(hours: 2));

    _courseId = session?.courseId;
    _courseCode = session?.courseCode;
    _roomId = session?.roomId;
    _roomName = session?.roomName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDateTime() async {
    final picked = await _pickDateTime(initialDateTime: _startsAt);

    if (picked == null) return;

    setState(() {
      _startsAt = picked;

      if (!_endsAt.isAfter(_startsAt)) {
        _endsAt = _startsAt.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEndDateTime() async {
    final picked = await _pickDateTime(initialDateTime: _endsAt);

    if (picked == null) return;

    setState(() {
      _endsAt = picked;
    });
  }

  Future<DateTime?> _pickDateTime({required DateTime initialDateTime}) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime.isBefore(now) ? now : initialDateTime,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Future<void> _chooseRoomPlaceholder() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room finder selection mode will be wired in next.'),
      ),
    );

    //##TODO build out choosing a study room as part of study session creation
  }

  void _chooseCoursePlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course picker will be wired in later.')),
    );

    //##TODO build out choosing a course as part of study session creation
  }

  void _clearRoom() {
    setState(() {
      _roomId = null;
      _roomName = null;
    });
  }

  void _clearCourse() {
    setState(() {
      _courseId = null;
      _courseCode = null;
    });
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final result = widget.isEditing
        ? await _sessionService.updateSession(
            session: widget.session!,
            title: _titleController.text,
            description: _descriptionController.text,
            startsAt: _startsAt,
            endsAt: _endsAt,
            courseId: _courseId,
            courseCode: _courseCode,
            roomId: _roomId,
            roomName: _roomName,
          )
        : await _sessionService.createSession(
            groupId: widget.group.id,
            groupName: widget.group.name,
            title: _titleController.text,
            description: _descriptionController.text,
            startsAt: _startsAt,
            endsAt: _endsAt,
            courseId: _courseId,
            courseCode: _courseCode,
            roomId: _roomId,
            roomName: _roomName,
          );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? 'Edit Study Session'
        : 'Create Study Session';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            _GroupContextHeader(
              groupName: widget.group.name,
              isEditing: widget.isEditing,
            ),

            AppSpacing.gapXl,

            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Session title',
                prefixIcon: Icon(Icons.event_note_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a session title.';
                }

                return null;
              },
            ),

            AppSpacing.gapLg,

            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),

            AppSpacing.gapXl,

            _DateTimeTile(
              title: 'Starts',
              value: _formatDateTime(_startsAt),
              icon: Icons.schedule,
              onTap: _pickStartDateTime,
            ),

            AppSpacing.gapMd,

            _DateTimeTile(
              title: 'Ends',
              value: _formatDateTime(_endsAt),
              icon: Icons.schedule_outlined,
              onTap: _pickEndDateTime,
            ),

            AppSpacing.gapXl,

            _OptionalSelectionCard(
              title: 'Course',
              subtitle: _courseCode ?? 'No course selected',
              icon: Icons.school_outlined,
              iconColor: context.appColors.task,
              actionLabel: _courseCode == null ? 'Choose Course' : 'Change',
              onPressed: _chooseCoursePlaceholder,
              onClear: _courseCode == null ? null : _clearCourse,
            ),

            AppSpacing.gapMd,

            _OptionalSelectionCard(
              title: 'Study Room',
              subtitle: _roomName ?? 'No room selected',
              icon: Icons.meeting_room_outlined,
              iconColor: context.appColors.studyRoom,
              actionLabel: _roomName == null ? 'Choose Room' : 'Change',
              onPressed: _chooseRoomPlaceholder,
              onClear: _roomName == null ? null : _clearRoom,
            ),

            AppSpacing.gapXxl,

            FilledButton.icon(
              onPressed: _isSaving ? null : _saveSession,
              icon: _isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.onPrimary,
                      ),
                    )
                  : Icon(widget.isEditing ? Icons.save_outlined : Icons.add),
              label: Text(widget.isEditing ? 'Save Changes' : 'Create Session'),
            ),
          ],
        ),
      ),
    );
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
}

class _GroupContextHeader extends StatelessWidget {
  final String groupName;
  final bool isEditing;

  const _GroupContextHeader({required this.groupName, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.card,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: context.appColors.group.withValues(alpha: 0.15),
              foregroundColor: context.appColors.group,
              child: const Icon(Icons.groups_outlined),
            ),

            AppSpacing.horizontalGapMd,

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  AppSpacing.gapXs,

                  Text(
                    isEditing
                        ? 'Update the session details below.'
                        : 'Schedule a study session for this group.',
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
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: AppSpacing.listTilePadding,
        leading: Icon(icon, color: context.appColors.planner),
        title: Text(
          title,
          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          value,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.edit_calendar_outlined,
          color: context.colors.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _OptionalSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String actionLabel;
  final VoidCallback onPressed;
  final VoidCallback? onClear;

  const _OptionalSelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.actionLabel,
    required this.onPressed,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = onClear != null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.compactTilePadding,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.12),
              foregroundColor: iconColor,
              child: Icon(icon),
            ),

            AppSpacing.horizontalGapMd,

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  AppSpacing.gapXs,

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: hasSelection
                          ? context.colors.onSurface
                          : context.colors.onSurfaceVariant,
                      fontWeight: hasSelection ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),

            if (onClear != null)
              IconButton(
                tooltip: 'Clear $title',
                onPressed: onClear,
                icon: Icon(Icons.close, color: context.colors.onSurfaceVariant),
              ),

            TextButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
