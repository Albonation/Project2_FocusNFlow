import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/shared_timer_state_model.dart';
import 'package:focus_n_flow/services/shared_timer_service.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class SharedTimerCard extends StatefulWidget {
  final String sessionId;

  const SharedTimerCard({super.key, required this.sessionId});

  @override
  State<SharedTimerCard> createState() => _SharedTimerCardState();
}

class _SharedTimerCardState extends State<SharedTimerCard> {
  final SharedTimerService _timerService = SharedTimerService();

  Timer? _localTicker;
  DateTime _now = DateTime.now();

  SharedTimerState? _latestState;

  bool _isWorking = false;
  bool _hasRequestedInitialization = false;
  bool _hasRequestedCompletion = false;

  @override
  void initState() {
    super.initState();

    _initializeTimerIfMissing();
    _startLocalTicker();
  }

  @override
  void dispose() {
    _localTicker?.cancel();
    super.dispose();
  }

  Future<void> _initializeTimerIfMissing() async {
    if (_hasRequestedInitialization) return;

    _hasRequestedInitialization = true;

    final result = await _timerService.initializeTimerIfMissing(
      widget.sessionId,
    );

    if (!mounted || result.success) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  void _startLocalTicker() {
    _localTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = _latestState;

      if (state == null) {
        return;
      }

      final displayRemaining = state.calculateDisplayRemainingSeconds(
        DateTime.now(),
      );

      if (state.status == SharedTimerStatus.running &&
          displayRemaining <= 0 &&
          !_hasRequestedCompletion) {
        _hasRequestedCompletion = true;
        _completeTimerSilently();
      }

      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  Future<void> _completeTimerSilently() async {
    await _timerService.completeTimer(widget.sessionId);
  }

  Future<void> _runTimerAction(
    Future<SharedTimerActionResult> Function() action,
  ) async {
    if (_isWorking) return;

    setState(() {
      _isWorking = true;
    });

    final result = await action();

    if (!mounted) return;

    setState(() {
      _isWorking = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _startTimer() async {
    _hasRequestedCompletion = false;
    await _runTimerAction(() => _timerService.startTimer(widget.sessionId));
  }

  Future<void> _pauseTimer(SharedTimerState state) async {
    final remainingSeconds = state.calculateDisplayRemainingSeconds(
      DateTime.now(),
    );

    await _runTimerAction(
      () => _timerService.pauseTimer(
        sessionId: widget.sessionId,
        remainingSeconds: remainingSeconds,
      ),
    );
  }

  Future<void> _resetTimer() async {
    _hasRequestedCompletion = false;
    await _runTimerAction(() => _timerService.resetTimer(widget.sessionId));
  }

  Future<void> _changeMode(SharedTimerMode mode) async {
    _hasRequestedCompletion = false;

    await _runTimerAction(
      () => _timerService.changeMode(sessionId: widget.sessionId, mode: mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SharedTimerState?>(
      stream: _timerService.watchTimerState(widget.sessionId),
      builder: (context, snapshot) {
        final timerState = snapshot.data;
        _latestState = timerState;

        if (snapshot.connectionState == ConnectionState.waiting &&
            timerState == null) {
          return const Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.card,
              child: Text(
                'Unable to load shared timer: ${snapshot.error}',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          );
        }

        if (timerState == null) {
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.card,
              child: Text(
                'Preparing shared timer...',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        final displayRemainingSeconds = timerState
            .calculateDisplayRemainingSeconds(_now);

        final safeRemainingSeconds = displayRemainingSeconds < 0
            ? 0
            : displayRemainingSeconds;

        final progress = timerState.durationSeconds <= 0
            ? 0.0
            : safeRemainingSeconds / timerState.durationSeconds;

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SharedTimerHeader(timerState: timerState),

                AppSpacing.gapLg,

                Center(
                  child: Text(
                    _formatTimer(safeRemainingSeconds),
                    style: context.text.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                AppSpacing.gapMd,

                ClipRRect(
                  borderRadius: BorderRadius.circular(AppCorners.pill),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 10,
                  ),
                ),

                AppSpacing.gapMd,

                Center(
                  child: Text(
                    '${timerState.mode.label} • ${timerState.status.label}',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (timerState.updatedByName.trim().isNotEmpty) ...[
                  AppSpacing.gapXs,
                  Center(
                    child: Text(
                      'Last updated by ${timerState.updatedByName}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],

                AppSpacing.gapLg,

                _TimerModeSelector(
                  selectedMode: timerState.mode,
                  isWorking: _isWorking || timerState.isRunning,
                  onModeSelected: _changeMode,
                ),

                AppSpacing.gapLg,

                _TimerControls(
                  timerState: timerState,
                  isWorking: _isWorking,
                  onStart: _startTimer,
                  onPause: () => _pauseTimer(timerState),
                  onReset: _resetTimer,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _SharedTimerHeader extends StatelessWidget {
  final SharedTimerState timerState;

  const _SharedTimerHeader({required this.timerState});

  @override
  Widget build(BuildContext context) {
    final color = timerState.isRunning
        ? context.appColors.success
        : context.appColors.focus;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          child: const Icon(Icons.timer_outlined),
        ),

        AppSpacing.horizontalGapMd,

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shared Study Timer',
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              AppSpacing.gapXs,

              Text(
                'Synced for everyone in this session.',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerModeSelector extends StatelessWidget {
  final SharedTimerMode selectedMode;
  final bool isWorking;
  final void Function(SharedTimerMode mode) onModeSelected;

  const _TimerModeSelector({
    required this.selectedMode,
    required this.isWorking,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final modes = [
      SharedTimerMode.focus,
      SharedTimerMode.shortBreak,
      SharedTimerMode.longBreak,
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: modes.map((mode) {
        final isSelected = mode == selectedMode;

        return ChoiceChip(
          selected: isSelected,
          label: Text(mode.label),
          onSelected: isWorking
              ? null
              : (_) {
                  if (!isSelected) {
                    onModeSelected(mode);
                  }
                },
        );
      }).toList(),
    );
  }
}

class _TimerControls extends StatelessWidget {
  final SharedTimerState timerState;
  final bool isWorking;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  const _TimerControls({
    required this.timerState,
    required this.isWorking,
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final canPause = timerState.status == SharedTimerStatus.running;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (canPause)
          FilledButton.icon(
            onPressed: isWorking ? null : onPause,
            icon: const Icon(Icons.pause_outlined),
            label: const Text('Pause'),
          )
        else
          FilledButton.icon(
            onPressed: isWorking ? null : onStart,
            icon: const Icon(Icons.play_arrow_outlined),
            label: Text(
              timerState.status == SharedTimerStatus.paused
                  ? 'Resume'
                  : 'Start',
            ),
          ),

        OutlinedButton.icon(
          onPressed: isWorking ? null : onReset,
          icon: const Icon(Icons.restart_alt_outlined),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}
