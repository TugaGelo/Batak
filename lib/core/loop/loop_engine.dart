import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

class LoopEngine {
  final AppDatabase db;

  LoopEngine(this.db);

  Future<Routine?> getActiveRoutine() async {
    final routines = await db.select(db.routines).get();
    if (routines.isEmpty) return null;
    return routines.first; 
  }

  Future<WorkoutTemplate?> getTodayTemplate(Routine routine) async {
    final query = db.select(db.workoutTemplates)
      ..where((t) => t.routineId.equals(routine.id))
      ..where((t) => t.sequenceOrder.equals(routine.currentSequenceIndex));
    
    return await query.getSingleOrNull();
  }

  Future<void> completeTodaySequence(Routine routine) async {
    final totalDaysQuery = db.select(db.workoutTemplates)
      ..where((t) => t.routineId.equals(routine.id));
    final totalDays = (await totalDaysQuery.get()).length;

    if (totalDays == 0) return;

    int nextIndex = routine.currentSequenceIndex + 1;
    
    if (nextIndex > totalDays) {
      nextIndex = 1;
    }

    await (db.update(db.routines)..where((r) => r.id.equals(routine.id))).write(
      RoutinesCompanion(
        currentSequenceIndex: Value(nextIndex),
      ),
    );
  }

  Future<void> seedDummyRoutineIfEmpty() async {
    final routines = await db.select(db.routines).get();
    if (routines.isEmpty) {
      final routineId = await db.into(db.routines).insert(
        RoutinesCompanion.insert(name: 'Tactical Push/Pull/Legs')
      );
      
      await db.into(db.workoutTemplates).insert(WorkoutTemplatesCompanion.insert(routineId: routineId, name: 'Heavy Push', sequenceOrder: 1));
      await db.into(db.workoutTemplates).insert(WorkoutTemplatesCompanion.insert(routineId: routineId, name: 'Heavy Pull', sequenceOrder: 2));
      await db.into(db.workoutTemplates).insert(WorkoutTemplatesCompanion.insert(routineId: routineId, name: 'Legs & Core', sequenceOrder: 3));
      await db.into(db.workoutTemplates).insert(WorkoutTemplatesCompanion.insert(routineId: routineId, name: 'Active Rest', sequenceOrder: 4));
      
      print("✅ [LOOP ENGINE] Seeded Dummy Routine with 4-Day Sequence.");
    }
  }
}

final loopEngineProvider = Provider<LoopEngine>((ref) {
  final db = ref.watch(databaseProvider);
  return LoopEngine(db);
});
