import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/workout_state.dart';
import '../../core/ai/ai_swapper_service.dart';
import 'set_log_row.dart';

class ExerciseCard extends ConsumerWidget {
  final int exerciseIndex;
  const ExerciseCard({super.key, required this.exerciseIndex});

  void _openAiSwapper(
    BuildContext context,
    WidgetRef ref,
    String currentExerciseId,
  ) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(activeSessionProvider);
    final exSession = sessionState.exercises[exerciseIndex];
    final exercise = exSession.exercise;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F150C),
        border: Border.all(color: const Color(0xFF412D15), width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF412D15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      exercise.vectorId.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFE1DCC9),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Color(0xFFFEF8E5),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.more_horiz, color: Color(0xFF949187)),
            ],
          ),
          const SizedBox(height: 24),

          const Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  "SET",
                  style: TextStyle(
                    color: Color(0xFF949187),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "KGS",
                    style: TextStyle(
                      color: Color(0xFF949187),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "REPS",
                    style: TextStyle(
                      color: Color(0xFF949187),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    "DONE",
                    style: TextStyle(
                      color: Color(0xFF949187),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF412D15), height: 16),

          ...exSession.sets.asMap().entries.map((entry) {
            return SetLogRow(
              exerciseIndex: exerciseIndex,
              setIndex: entry.key,
              activeSet: entry.value,
            );
          }),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => ref.read(activeSessionProvider.notifier).addSet(exerciseIndex),
                icon: const Icon(Icons.add, color: Color(0xFF949187), size: 18),
                label: const Text(
                  "ADD SET",
                  style: TextStyle(
                    color: Color(0xFF949187),
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    _openAiSwapper(context, ref, exercise.id.toString()),
                icon: const Icon(Icons.warning_amber_rounded, size: 16),
                label: const Text(
                  "MACHINE TAKEN",
                  style: TextStyle(fontSize: 10, letterSpacing: 1),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE1C19F),
                  side: const BorderSide(color: Color(0xFF412D15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
