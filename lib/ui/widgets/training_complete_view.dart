import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/workout_state.dart';

class TrainingCompleteView extends ConsumerWidget {
  const TrainingCompleteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFE1C19F), size: 80),
          const SizedBox(height: 24),
          const Text("TRAINING COMPLETE", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          const Text("You have successfully archived a session today.\nTake time to recover, adapt, and grow.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF949187), fontSize: 16, height: 1.5)),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: () => ref.read(bypassSameDayWorkoutProvider.notifier).state = true,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF412D15), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            child: const Text("START NEXT DAY ANYWAY", style: TextStyle(color: Color(0xFFE1C19F), fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          )
        ],
      ),
    );
  }
}
