import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'app_database.dart';

class SetLogsRepository {
  final AppDatabase _db;

  SetLogsRepository(this._db);

  Future<int> insertLog({
    required int exerciseId,
    required double weight,
    required int reps,
    String setTag = 'N',
  }) async {
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

    final query = _db.select(_db.setLogs)
      ..where((tbl) => tbl.exerciseId.equals(exerciseId))
      ..where((tbl) => tbl.timestamp.isBetweenValues(startOfDay, endOfDay));

    return await query.get();
  }

  Future<List<SetLog>> getPastSessionLogs(int exerciseId) async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day, 0, 0, 0);

    final latestLogQuery = _db.select(_db.setLogs)
      ..where((tbl) => tbl.exerciseId.equals(exerciseId))
      ..where((tbl) => tbl.timestamp.isSmallerThanValue(startOfToday))
      ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.timestamp)])
      ..limit(1);

    final latestLog = await latestLogQuery.getSingleOrNull();
    if (latestLog == null) return [];

    final targetDate = latestLog.timestamp;
    final startOfPastDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 0, 0, 0);
    final endOfPastDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

    final pastDayQuery = _db.select(_db.setLogs)
      ..where((tbl) => tbl.exerciseId.equals(exerciseId))
      ..where((tbl) => tbl.timestamp.isBetweenValues(startOfPastDay, endOfPastDay))
      ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.id)]);

    return await pastDayQuery.get();
  }
}

final setLogsRepositoryProvider = Provider<SetLogsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SetLogsRepository(db);
});
