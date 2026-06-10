import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_body_heatmap/flutter_body_heatmap.dart';
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

final heatmapDataProvider = FutureProvider.autoDispose<Map<Muscle, MuscleData>>((ref) async {
  final db = ref.watch(databaseProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  final query = db.select(db.setLogs).join([
    drift.innerJoin(db.workoutSessions, db.workoutSessions.id.equalsExp(db.setLogs.sessionId)),
    drift.innerJoin(db.exercises, db.exercises.id.equalsExp(db.setLogs.exerciseId)),
  ])..where(db.workoutSessions.startTime.isBiggerOrEqualValue(sevenDaysAgo));

  final results = await query.get();

  Map<Muscle, double> rawVolume = {};
  double maxVolume = 0;

  for (final row in results) {
    final log = row.readTable(db.setLogs);
    final ex = row.readTable(db.exercises);
    final volume = log.weight * log.reps;

    final search = "${ex.name} ${ex.vectorId}".toLowerCase();
    List<Muscle> hitMuscles = [];

    if (search.contains('bench') || search.contains('chest') || search.contains('pec')) { hitMuscles.addAll([Muscle.chest, Muscle.triceps]); }
    if (search.contains('overhead') || search.contains('military') || search.contains('shoulder') || search.contains('press')) { hitMuscles.addAll([Muscle.deltoids, Muscle.triceps]); }
    if (search.contains('deadlift')) { hitMuscles.addAll([Muscle.gluteal, Muscle.hamstring, Muscle.lowerBack]); }
    if (search.contains('squat')) { hitMuscles.addAll([Muscle.quadriceps, Muscle.gluteal]); }
    if (search.contains('row') || search.contains('pull') || search.contains('chin') || search.contains('lat')) { hitMuscles.addAll([Muscle.upperBack, Muscle.biceps]); }
    if (search.contains('curl') || search.contains('bicep')) { hitMuscles.add(Muscle.biceps); }
    if (search.contains('extension') || search.contains('tricep')) { hitMuscles.add(Muscle.triceps); }
    if (search.contains('leg') && search.contains('curl')) { hitMuscles.add(Muscle.hamstring); }
    if (search.contains('leg') && search.contains('ext')) { hitMuscles.add(Muscle.quadriceps); }
    if (search.contains('calf') || search.contains('calves')) { hitMuscles.add(Muscle.calves); }
    if (search.contains('abs') || search.contains('core') || search.contains('crunch')) { hitMuscles.add(Muscle.abs); }

    if (hitMuscles.isEmpty) {
      final scrubbedId = ex.vectorId.toLowerCase().trim().replaceAll('-', '').replaceAll('_', '');
      for (var m in Muscle.values) {
        if (m.name.toLowerCase() == scrubbedId) {
          hitMuscles.add(m);
          break;
        }
      }
    }

    for (var m in hitMuscles) {
      rawVolume[m] = (rawVolume[m] ?? 0) + volume;
      if (rawVolume[m]! > maxVolume) {
        maxVolume = rawVolume[m]!;
      }
    }
  }

  Map<Muscle, MuscleData> heatmapMap = {};
  if (maxVolume > 0) {
    rawVolume.forEach((muscle, volume) {
      double intensity = 0.2 + (0.8 * (volume / maxVolume));
      heatmapMap[muscle] = MuscleData(intensity: intensity);
    });
  }

  return heatmapMap;
});
