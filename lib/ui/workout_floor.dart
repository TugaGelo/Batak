import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/state/workout_state.dart';
import 'widgets/exercise_card.dart';
import 'widgets/floating_rest_timer.dart';
import 'widgets/rest_day_view.dart';
import 'widgets/training_complete_view.dart';
import 'widgets/finish_workout_button.dart';

class WorkoutFloorScreen extends ConsumerWidget {
  const WorkoutFloorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaderAsync = ref.watch(workoutSessionLoaderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: loaderAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
          error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
          data: (_) {
            final sessionState = ref.watch(activeSessionProvider);

            if (sessionState.isRestMode) return const TrainingCompleteView();
            if (sessionState.exercises.isEmpty) return const RestDayView();

            return Stack(
              children: [
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120), 
                  itemCount: sessionState.exercises.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    if (index == sessionState.exercises.length) {
                      return const FinishWorkoutButton();
                    }
                    return ExerciseCard(exerciseIndex: index); 
                  },
                ),
                const Positioned(bottom: 20, left: 0, right: 0, child: FloatingRestTimer()),
              ],
            );
          },
        ),
      ),
    );
  }
}
