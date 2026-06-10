import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';

class ArchivedExercise {
  final String exerciseName;
  final List<SetLog> sets;
  ArchivedExercise({required this.exerciseName, required this.sets});
}

class ArchivedSession {
  final WorkoutSession session;
  final String routineDayName;
  final List<ArchivedExercise> exercises;

  ArchivedSession({
    required this.session,
    required this.routineDayName,
    required this.exercises,
  });
}

final historyTimelineProvider = FutureProvider.autoDispose<List<ArchivedSession>>((ref) async {
  final db = ref.watch(databaseProvider);

  final sessionRows = await (db.select(db.workoutSessions).join([
    drift.leftOuterJoin(db.workoutTemplates, db.workoutTemplates.id.equalsExp(db.workoutSessions.templateId))
  ])..orderBy([drift.OrderingTerm.desc(db.workoutSessions.startTime)])).get();

  List<ArchivedSession> timeline = [];

  for (final row in sessionRows) {
    final session = row.readTable(db.workoutSessions);
    final template = row.readTableOrNull(db.workoutTemplates);

    final setRows = await (db.select(db.setLogs).join([
      drift.innerJoin(db.exercises, db.exercises.id.equalsExp(db.setLogs.exerciseId))
    ])
      ..where(db.setLogs.sessionId.equals(session.id))
      ..orderBy([drift.OrderingTerm.asc(db.setLogs.timestamp)])).get();

    Map<int, ArchivedExercise> groupedExercises = {};
    for (final sRow in setRows) {
      final setLog = sRow.readTable(db.setLogs);
      final exercise = sRow.readTable(db.exercises);
      
      if (!groupedExercises.containsKey(exercise.id)) {
        groupedExercises[exercise.id] = ArchivedExercise(exerciseName: exercise.name, sets: []);
      }
      groupedExercises[exercise.id]!.sets.add(setLog);
    }

    timeline.add(ArchivedSession(
      session: session,
      routineDayName: template?.name ?? "Custom Workout",
      exercises: groupedExercises.values.toList(),
    ));
  }

  return timeline;
});
