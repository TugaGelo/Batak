import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/loop/loop_engine.dart' hide databaseProvider;
import '../../core/database/app_database.dart';
import 'composer/routine_composer.dart';
import 'viewer/active_routine_view.dart';
import 'viewer/empty_routine_view.dart';

final isComposingProvider = StateProvider<bool>((ref) => false);
final selectedRoutineIdProvider = StateProvider<int?>((ref) => null);
final editingRoutineTargetProvider = StateProvider<Routine?>((ref) => null);

final routineDataProvider = FutureProvider.autoDispose((ref) async {
  final activeId = ref.watch(selectedRoutineIdProvider);
  final engine = ref.watch(loopEngineProvider);
  final db = ref.read(databaseProvider);
  
  Routine? routine;
  if (activeId != null) {
    routine = await (db.select(db.routines)..where((r) => r.id.equals(activeId))).getSingleOrNull();
  }
  
  if (routine == null) {
    routine = await engine.getActiveRoutine();
    if (routine != null) {
      Future.microtask(() => ref.read(selectedRoutineIdProvider.notifier).state = routine!.id);
    }
  }
  
  if (routine == null) return null;

  final templates = await (db.select(db.workoutTemplates)..where((t) => t.routineId.equals(routine!.id))).get();
      
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
    final editTarget = ref.watch(editingRoutineTargetProvider);

    if (isComposing) {
      return RoutineComposer(targetRoutine: editTarget);
    }

    final routineDataAsync = ref.watch(routineDataProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: routineDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (data) {
          if (data == null || (data['templates'] as List).isEmpty) {
            return const EmptyRoutineView();
          }

          final Routine routine = data['routine'] as Routine;
          final List<WorkoutTemplate> templates = data['templates'] as List<WorkoutTemplate>;
          final Map<int, List<Exercise>> exercisesMap = data['exercisesMap'] as Map<int, List<Exercise>>;
          templates.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

          return ActiveRoutineView(
            routine: routine,
            templates: templates,
            exercisesMap: exercisesMap,
          );
        },
      ),
    );
  }
}
