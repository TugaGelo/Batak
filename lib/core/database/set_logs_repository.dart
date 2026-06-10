import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'app_database.dart';

class SetLogsRepository {
  final AppDatabase _db;

  SetLogsRepository(this._db);

  Future<int> insertLog({required int exerciseId, required double weight, required int reps, String setTag = 'N'}) async {
    return await _db.into(_db.setLogs).insert(
      SetLogsCompanion.insert(
        exerciseId: exerciseId,
        weight: weight,
        reps: reps,
        setTag: drift.Value(setTag),
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> deleteLog(int logId) async {
    await (_db.delete(_db.setLogs)..where((tbl) => tbl.id.equals(logId))).go();
  }

  Future<List<SetLog>> getLogsForExerciseToday(int exerciseId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await (_db.select(_db.setLogs)
      ..where((tbl) => tbl.exerciseId.equals(exerciseId))
      ..where((tbl) => tbl.timestamp.isBetweenValues(startOfDay, endOfDay))
      ..where((tbl) => tbl.sessionId.isNull())
    ).get();
  }

  Future<List<SetLog>> getPastSessionLogs(int exerciseId) async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0);

    final latestLog = await (_db.select(_db.setLogs)
      ..where((tbl) => tbl.exerciseId.equals(exerciseId))
      ..where((tbl) => tbl.timestamp.isSmallerThanValue(startOfToday))
      ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.timestamp)])
      ..limit(1)).getSingleOrNull();

    if (latestLog == null) return [];

    final targetDate = latestLog.timestamp;
    final startOfPastDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 0, 0, 0);
    final endOfPastDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

    return await (_db.select(_db.setLogs)
      ..where((tbl) => tbl.exerciseId.equals(exerciseId))
      ..where((tbl) => tbl.timestamp.isBetweenValues(startOfPastDay, endOfPastDay))
      ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.id)])).get();
  }

  Future<bool> hasCompletedSessionToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final query = _db.select(_db.workoutSessions)
      ..where((tbl) => tbl.endTime.isBiggerOrEqualValue(startOfDay))
      ..limit(1);
      
    final result = await query.get();
    return result.isNotEmpty;
  }

  Future<int> finalizeSession(int templateId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final looseLogs = await (_db.select(_db.setLogs)
      ..where((tbl) => tbl.timestamp.isBiggerOrEqualValue(startOfDay))
      ..where((tbl) => tbl.sessionId.isNull())
    ).get();

    if (looseLogs.isEmpty) return -1; 

    double totalVolume = 0;
    DateTime? firstSetTime;

    for (final log in looseLogs) {
      totalVolume += (log.weight * log.reps);
      if (firstSetTime == null || log.timestamp.isBefore(firstSetTime)) {
        firstSetTime = log.timestamp;
      }
    }

    final sessionId = await _db.into(_db.workoutSessions).insert(
      WorkoutSessionsCompanion.insert(
        templateId: templateId,
        startTime: firstSetTime ?? now.subtract(const Duration(minutes: 45)),
        endTime: drift.Value(now),
        volumeGenerated: drift.Value(totalVolume),
      )
    );

    await (_db.update(_db.setLogs)
      ..where((tbl) => tbl.id.isIn(looseLogs.map((l) => l.id))))
      .write(SetLogsCompanion(sessionId: drift.Value(sessionId)));

    return sessionId;
  }
}

final setLogsRepositoryProvider = Provider<SetLogsRepository>((ref) {
  return SetLogsRepository(ref.watch(databaseProvider));
});
