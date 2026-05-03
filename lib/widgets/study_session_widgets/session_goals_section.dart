import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/session_goal_model.dart';
import 'package:focus_n_flow/services/session_goal_service.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class SessionGoalsSection extends StatefulWidget {
  final String sessionId;

  const SessionGoalsSection({super.key, required this.sessionId});

  @override
  State<SessionGoalsSection> createState() => _SessionGoalsSectionState();
}

class _SessionGoalsSectionState extends State<SessionGoalsSection> {
  final SessionGoalService _goalService = SessionGoalService();

  //this is really just to help with screen flicker when adding goals and editing them
  late Stream<List<SessionGoal>> _goalsStream;

  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
    _goalsStream = _goalService.watchGoals(widget.sessionId);
  }

  //this is really just to help with screen flicker when adding goals and editing them
  @override
  void didUpdateWidget(covariant SessionGoalsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    //initState only runs once, so if the widget is reused for a different
    //session, update the cached stream to listen to that session's goals
    if (oldWidget.sessionId != widget.sessionId) {
      _goalsStream = _goalService.watchGoals(widget.sessionId);
    }
  }

  Future<void> _showAddGoalDialog() async {
    final goalText = await _showGoalTextDialog(
      title: 'Add Goal',
      confirmText: 'Add',
      initialText: '',
    );

    if (goalText == null || goalText.trim().isEmpty) return;

    await _addGoal(goalText);
  }

  Future<void> _showEditGoalDialog(SessionGoal goal) async {
    final updatedText = await _showGoalTextDialog(
      title: 'Edit Goal',
      confirmText: 'Save',
      initialText: goal.text,
    );

    if (updatedText == null || updatedText.trim().isEmpty) return;

    if (updatedText.trim() == goal.text.trim()) return;

    await _updateGoalText(goal, updatedText);
  }

  Future<String?> _showGoalTextDialog({
    required String title,
    required String confirmText,
    required String initialText,
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _GoalTextDialog(
          title: title,
          confirmText: confirmText,
          initialText: initialText,
        );
      },
    );
  }

  Future<void> _addGoal(String text) async {
    if (_isWorking) return;

    setState(() {
      _isWorking = true;
    });

    final result = await _goalService.addGoal(
      sessionId: widget.sessionId,
      text: text,
    );

    if (!mounted) return;

    setState(() {
      _isWorking = false;
    });

    _showMessage(result.message);
  }

  Future<void> _updateGoalText(SessionGoal goal, String text) async {
    if (_isWorking) return;

    setState(() {
      _isWorking = true;
    });

    final result = await _goalService.updateGoalText(
      sessionId: widget.sessionId,
      goalId: goal.id,
      text: text,
    );

    if (!mounted) return;

    setState(() {
      _isWorking = false;
    });

    _showMessage(result.message);
  }

  Future<void> _toggleGoal(SessionGoal goal) async {
    if (_isWorking) return;

    setState(() {
      _isWorking = true;
    });

    final result = await _goalService.setGoalCompletion(
      sessionId: widget.sessionId,
      goalId: goal.id,
      isCompleted: !goal.isCompleted,
    );

    if (!mounted) return;

    setState(() {
      _isWorking = false;
    });

    _showMessage(result.message);
  }

  Future<void> _confirmDeleteGoal(SessionGoal goal) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Goal?',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Delete "${goal.text}"?',
            style: context.text.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: context.appColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _deleteGoal(goal);
  }

  Future<void> _deleteGoal(SessionGoal goal) async {
    if (_isWorking) return;

    setState(() {
      _isWorking = true;
    });

    final result = await _goalService.deleteGoal(
      sessionId: widget.sessionId,
      goalId: goal.id,
    );

    if (!mounted) return;

    setState(() {
      _isWorking = false;
    });

    _showMessage(result.message);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GoalsHeader(isWorking: _isWorking, onAddGoal: _showAddGoalDialog),

        AppSpacing.gapSm,

        const Divider(),

        AppSpacing.gapSm,

        StreamBuilder<List<SessionGoal>>(
          stream: _goalsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const LinearProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(
                'Unable to load goals: ${snapshot.error}',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              );
            }

            final goals = snapshot.data ?? [];

            if (goals.isEmpty) {
              return _EmptyGoalsState(onAddGoal: _showAddGoalDialog);
            }

            return Column(
              children: goals.map((goal) {
                return Padding(
                  padding: AppSpacing.rowPadding,
                  child: Dismissible(
                    key: ValueKey(goal.id),
                    direction: DismissDirection.endToStart,
                    background: const _DeleteGoalBackground(),
                    confirmDismiss: (_) async {
                      await _confirmDeleteGoal(goal);
                      return false;
                    },
                    child: _SessionGoalTile(
                      goal: goal,
                      isWorking: _isWorking,
                      onToggle: () {
                        _toggleGoal(goal);
                      },
                      onEdit: () {
                        _showEditGoalDialog(goal);
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _GoalsHeader extends StatelessWidget {
  final bool isWorking;
  final VoidCallback onAddGoal;

  const _GoalsHeader({required this.isWorking, required this.onAddGoal});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Session Goals',
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          tooltip: 'Add goal',
          color: context.appColors.brand,
          onPressed: isWorking ? null : onAddGoal,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _EmptyGoalsState extends StatelessWidget {
  final VoidCallback onAddGoal;

  const _EmptyGoalsState({required this.onAddGoal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.verticalMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No goals yet.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          AppSpacing.gapMd,

          FilledButton.icon(
            onPressed: onAddGoal,
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Add Goal'),
          ),
        ],
      ),
    );
  }
}

class _SessionGoalTile extends StatelessWidget {
  final SessionGoal goal;
  final bool isWorking;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _SessionGoalTile({
    required this.goal,
    required this.isWorking,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final goalColor = goal.isCompleted
        ? context.appColors.success
        : context.colors.onSurfaceVariant;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: isWorking ? null : onToggle,
        onLongPress: isWorking ? null : onEdit,
        child: Padding(
          padding: AppSpacing.compactTilePadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: goal.isCompleted,
                onChanged: isWorking
                    ? null
                    : (_) {
                        onToggle();
                      },
                activeColor: context.appColors.success,
              ),

              AppSpacing.horizontalGapSm,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.text,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: goal.isCompleted
                            ? context.colors.onSurfaceVariant
                            : context.colors.onSurface,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),

                    if (goal.isCompleted &&
                        goal.completedByName != null &&
                        goal.completedByName!.trim().isNotEmpty) ...[
                      AppSpacing.gapXs,
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: goalColor,
                          ),
                          AppSpacing.horizontalGapXs,
                          Expanded(
                            child: Text(
                              'Completed by ${goal.completedByName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelSmall?.copyWith(
                                color: goalColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _GoalTextDialog extends StatefulWidget {
  final String title;
  final String confirmText;
  final String initialText;

  const _GoalTextDialog({
    required this.title,
    required this.confirmText,
    required this.initialText,
  });

  @override
  State<_GoalTextDialog> createState() => _GoalTextDialogState();
}

class _GoalTextDialogState extends State<_GoalTextDialog> {
  late final TextEditingController _controller;

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _submit() {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 120,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Goal',
          hintText: 'Example: Finish chapter review',
          prefixIcon: Icon(Icons.flag_outlined),
        ),
        onSubmitted: (_) {
          _submit();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

class _DeleteGoalBackground extends StatelessWidget {
  const _DeleteGoalBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: AppSpacing.horizontalLg,
      decoration: BoxDecoration(
        color: context.appColors.danger,
        borderRadius: BorderRadius.circular(AppCorners.lg),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}
