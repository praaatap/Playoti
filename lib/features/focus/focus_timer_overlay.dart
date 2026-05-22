import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/focus_timer_provider.dart';
import '../../providers/task_provider.dart';

class FocusTimerOverlay extends ConsumerWidget {
  const FocusTimerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(focusTimerProvider);
    if (!focus.isActive) return const SizedBox.shrink();

    final primary = Theme.of(context).colorScheme.primary;

    return Positioned(
      bottom: 12,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _TimerDial(focus: focus, primary: primary),
              const SizedBox(width: 14),
              Expanded(child: _TaskInfo(focus: focus)),
              const SizedBox(width: 10),
              if (focus.isFinished)
                _MarkDoneButton(
                  onTap: () {
                    ref
                        .read(taskNotifierProvider.notifier)
                        .toggleComplete(focus.task!.id);
                    ref.read(focusTimerProvider.notifier).stop();
                  },
                )
              else
                _PauseResumeButton(
                  isRunning: focus.isRunning,
                  onTap: () {
                    if (focus.isRunning) {
                      ref.read(focusTimerProvider.notifier).pause();
                    } else {
                      ref.read(focusTimerProvider.notifier).resume();
                    }
                  },
                ),
              const SizedBox(width: 8),
              _IconButton(
                icon: CupertinoIcons.xmark,
                onTap: () => ref.read(focusTimerProvider.notifier).stop(),
              ),
            ],
          ),
        ),
      ).animate().slideY(
            begin: 1.5,
            duration: 320.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class _TimerDial extends StatelessWidget {
  final FocusTimerState focus;
  final Color primary;

  const _TimerDial({required this.focus, required this.primary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: focus.isFinished ? 1.0 : (1.0 - focus.progress),
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(
              focus.isFinished ? AppColors.success : primary,
            ),
            strokeWidth: 3.5,
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: focus.isFinished
                ? const Icon(
                    CupertinoIcons.checkmark_alt,
                    color: AppColors.success,
                    size: 22,
                  )
                : Text(
                    focus.formattedTime,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TaskInfo extends StatelessWidget {
  final FocusTimerState focus;

  const _TaskInfo({required this.focus});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          focus.isFinished ? 'Session complete!' : 'Focusing on',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          focus.task!.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _PauseResumeButton extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const _PauseResumeButton({required this.isRunning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _IconButton(
      icon: isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
      onTap: onTap,
    );
  }
}

class _MarkDoneButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MarkDoneButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Mark done',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}
