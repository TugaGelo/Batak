import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/state/workout_state.dart';
import 'widgets/exercise_card.dart';
import 'widgets/floating_rest_timer.dart'; 

class WorkoutFloorScreen extends ConsumerWidget {
  const WorkoutFloorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaderAsync = ref.watch(workoutSessionLoaderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        title: const Text("WORKOUT FLOOR", style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: loaderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
        data: (_) {
          final sessionState = ref.watch(activeSessionProvider);

          if (sessionState.exercises.isEmpty) {
            return const Center(
              child: Text("No active sequence today.\nGo to My Routine to set up your timeline.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF949187), fontSize: 14, height: 1.5)),
            );
          }

          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                itemCount: sessionState.exercises.length,
                separatorBuilder: (context, index) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return ExerciseCard(exerciseIndex: index);
                },
              ),
              const Positioned(bottom: 20, left: 0, right: 0, child: FloatingRestTimer()),
            ],
          );
        },
      ),
    );
  }
}
