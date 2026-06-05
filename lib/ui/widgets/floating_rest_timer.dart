import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/workout_state.dart';

class FloatingRestTimer extends ConsumerWidget {
  const FloatingRestTimer({super.key});

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerSeconds = ref.watch(restTimerProvider);

    if (timerSeconds <= 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF8E5),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, color: Colors.black, size: 20),
              const SizedBox(width: 12),
              Text(
                _formatTime(timerSeconds),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => ref.read(restTimerProvider.notifier).addTime(30),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
