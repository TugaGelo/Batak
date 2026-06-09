import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';
import '../routine_screen.dart';
import '../routine_composer.dart'; 

class ComposerActionFooter extends ConsumerWidget {
  final String routineName;
  final List<DraftDay> draftDays;

  const ComposerActionFooter({
    super.key,
    required this.routineName,
    required this.draftDays,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        border: Border(top: BorderSide(color: Color(0xFF353535))),
      ),
      child: ElevatedButton(
        onPressed: () async {
          final db = ref.read(databaseProvider); 
          
          await db.delete(db.workoutExercises).go();
          await db.delete(db.workoutTemplates).go();
          await db.delete(db.routines).go();

          final newRoutineId = await db.into(db.routines).insert(
            RoutinesCompanion.insert(
              name: routineName.trim().isEmpty ? "Custom Split" : routineName.trim(),
              currentSequenceIndex: const drift.Value(1), 
            ),
          );

          for (int i = 0; i < draftDays.length; i++) {
            final draft = draftDays[i];
            
            final templateId = await db.into(db.workoutTemplates).insert(
              WorkoutTemplatesCompanion.insert(
                routineId: newRoutineId,
                name: draft.title.trim().isEmpty ? "Day ${i+1}" : draft.title.trim(),
                sequenceOrder: i + 1,
              ),
            );

            for (int j = 0; j < draft.exercises.length; j++) {
                final exercise = draft.exercises[j];
                await db.into(db.workoutExercises).insert(
                    WorkoutExercisesCompanion.insert(
                        workoutTemplateId: templateId,
                        exerciseId: exercise.id,
                        displayOrder: j + 1,
                    ),
                );
            }
          }

          ref.invalidate(routineDataProvider);
          ref.read(isComposingProvider.notifier).state = false;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEF8E5),
          foregroundColor: const Color(0xFF131313),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "SAVE & PUBLISH ROUTINE",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
    );
  }
}
