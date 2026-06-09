import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/loop/loop_engine.dart' hide databaseProvider;
import '../../core/database/app_database.dart';
import 'routine_composer.dart';
import 'widgets/routine_timeline_node.dart';

final isComposingProvider = StateProvider<bool>((ref) => false);

final routineDataProvider = FutureProvider.autoDispose((ref) async {
  final engine = ref.watch(loopEngineProvider);
  final routine = await engine.getActiveRoutine();
  if (routine == null) return null;

  final db = ref.read(databaseProvider);
  
  final templates = await (db.select(db.workoutTemplates)
        ..where((t) => t.routineId.equals(routine.id)))
      .get();
      
  Map<int, List<Exercise>> templateExercises = {};
  for (final t in templates) {
    final exercisesQuery = db.select(db.workoutExercises).join([
      drift.innerJoin(db.exercises, db.exercises.id.equalsExp(db.workoutExercises.exerciseId)),
    ])..where(db.workoutExercises.workoutTemplateId.equals(t.id));
    
    final results = await exercisesQuery.get();
    templateExercises[t.id] = results.map((row) => row.readTable(db.exercises)).toList();
  }

  return {'routine': routine, 'templates': templates, 'exercisesMap': templateExercises};
});

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isComposing = ref.watch(isComposingProvider);

    if (isComposing) {
      return const RoutineComposer();
    }

    final routineDataAsync = ref.watch(routineDataProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: routineDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (data) {
          if (data == null) {
            Future.microtask(() => ref.read(isComposingProvider.notifier).state = true);
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F)));
          }

          final Routine routine = data['routine'] as Routine;
          final List<WorkoutTemplate> templates = data['templates'] as List<WorkoutTemplate>;
          final Map<int, List<Exercise>> exercisesMap = data['exercisesMap'] as Map<int, List<Exercise>>;
          
          templates.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 160),
                children: [
                  const Text("Active Training Sequence", style: TextStyle(fontFamily: 'Epilogue', color: Color(0xFFFEF8E5), fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Your current mesocycle loop. Stay grounded, stay focused.", style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 14)),
                  const SizedBox(height: 32),

                  Stack(
                    children: [
                      Positioned(
                        top: 20, bottom: 0, left: 27,
                        child: Container(width: 2, color: const Color(0xFF353535)),
                      ),
                      Column(
                        children: templates.map((template) {
                          return RoutineTimelineNode(
                            dayNumber: template.sequenceOrder,
                            title: template.name,
                            isCompleted: template.sequenceOrder < routine.currentSequenceIndex,
                            isCurrent: template.sequenceOrder == routine.currentSequenceIndex,
                            exercises: exercisesMap[template.id] ?? [],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),

              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [const Color(0xFF131313), const Color(0xFF131313).withOpacity(0.0)],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                          onPressed: templates.isEmpty ? null : () async {
                            await ref.read(loopEngineProvider).completeTodaySequence(routine);
                            ref.invalidate(routineDataProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE1DCC9),
                            foregroundColor: const Color(0xFF1D1C10),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("MANUAL ADVANCE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () => ref.read(isComposingProvider.notifier).state = true,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF49473F)),
                            backgroundColor: const Color(0xFF1F1F1F), // Solid background so line doesn't show through
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.edit, color: Color(0xFFE1C19F)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
