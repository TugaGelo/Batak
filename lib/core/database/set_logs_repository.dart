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

  Future<Map<DateTime, int>> getSetCountsLast28Days() async {
    final now = DateTime.now();
    final twentyEightDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 27));

    final logs = await (_db.select(_db.setLogs)
          ..where((tbl) => tbl.timestamp.isBiggerOrEqualValue(twentyEightDaysAgo)))
        .get();

    Map<DateTime, int> dayCounts = {};
    for (var log in logs) {
      final day = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    return dayCounts;
  }

  Future<Map<String, double>> getVolumeByMuscleLast7Days() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    final query = _db.select(_db.setLogs).join([
      drift.innerJoin(_db.exercises, _db.exercises.id.equalsExp(_db.setLogs.exerciseId)),
    ])..where(_db.setLogs.timestamp.isBiggerOrEqualValue(sevenDaysAgo));

    final results = await query.get();
    Map<String, double> volumeMap = {};

    for (final row in results) {
      final log = row.readTable(_db.setLogs);
      final ex = row.readTable(_db.exercises);
      
      final volume = log.weight * log.reps;
      
      String radarCategory = _mapTargetToRadarAxis(ex.target);
      volumeMap[radarCategory] = (volumeMap[radarCategory] ?? 0) + volume;
    }

    return volumeMap;
  }

  String _mapTargetToRadarAxis(String target) {
    final t = target.toLowerCase();
    if (t.contains('pectoral')) return 'Chest';
    if (t.contains('deltoid') || t.contains('trap')) return 'Shoulders';
    if (t.contains('bicep') || t.contains('tricep') || t.contains('forearm')) return 'Arms';
    if (t.contains('glute')) return 'Glutes'; // NEW: Explicit Glute mapping
    if (t.contains('quad') || t.contains('hamstring') || t.contains('calf')) return 'Legs';
    if (t.contains('lats') || t.contains('back')) return 'Back';
    return 'Core'; // Fallback for abs/waist
  }
}

final setLogsRepositoryProvider = Provider<SetLogsRepository>((ref) {
  return SetLogsRepository(ref.watch(databaseProvider));
});
