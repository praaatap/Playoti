import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';

class FocusTimerState {
  final Task? task;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isFinished;

  const FocusTimerState({
    this.task,
    this.totalSeconds = 25 * 60,
    this.remainingSeconds = 25 * 60,
    this.isRunning = false,
    this.isFinished = false,
  });

  bool get isActive => task != null;
  double get progress =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  FocusTimerState copyWith({
    Task? task,
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isFinished,
  }) =>
      FocusTimerState(
        task: task ?? this.task,
        totalSeconds: totalSeconds ?? this.totalSeconds,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        isRunning: isRunning ?? this.isRunning,
        isFinished: isFinished ?? this.isFinished,
      );
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  Timer? _ticker;

  FocusTimerNotifier() : super(const FocusTimerState());

  void startFocus(Task task, {int minutes = 25}) {
    _ticker?.cancel();
    final secs = minutes * 60;
    state = FocusTimerState(
      task: task,
      totalSeconds: secs,
      remainingSeconds: secs,
      isRunning: true,
    );
    _tick();
  }

  void _tick() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isRunning) return;
      if (state.remainingSeconds <= 1) {
        _ticker?.cancel();
        state = state.copyWith(
            remainingSeconds: 0, isRunning: false, isFinished: true);
        return;
      }
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    });
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resume() {
    if (!state.isActive || state.isFinished) return;
    state = state.copyWith(isRunning: true);
    _tick();
  }

  void stop() {
    _ticker?.cancel();
    state = const FocusTimerState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>(
  (ref) => FocusTimerNotifier(),
);
