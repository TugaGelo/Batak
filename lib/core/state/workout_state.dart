// Location: C:\Development\batak\lib\core\state\workout_state.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../ai/ai_swapper_service.dart';
import '../database/app_database.dart'; 
import '../database/set_logs_repository.dart'; 
import '../loop/loop_engine.dart' hide databaseProvider; 

class ActiveSet {
  final double? weight, previousWeight;
  final int? reps, previousReps, logId;
  final bool isCompleted;
  final String tag;

  ActiveSet({this.weight, this.reps, this.isCompleted = false, this.tag = 'N', this.logId, this.previousWeight, this.previousReps});

  ActiveSet copyWith({double? weight, int? reps, bool? isCompleted, String? tag, int? logId, double? previousWeight, int? previousReps}) =>
    ActiveSet(
      weight: weight ?? this.weight, reps: reps ?? this.reps, isCompleted: isCompleted ?? this.isCompleted,
      tag: tag ?? this.tag, logId: logId ?? this.logId, previousWeight: previousWeight ?? this.previousWeight, previousReps: previousReps ?? this.previousReps
    );
}

class ExerciseSession {
  final Exercise exercise;
  final List<ActiveSet> sets;
  ExerciseSession({required this.exercise, required this.sets});
  ExerciseSession copyWith({Exercise? exercise, List<ActiveSet>? sets}) => ExerciseSession(exercise: exercise ?? this.exercise, sets: sets ?? this.sets);
}

class ActiveSessionState {
  final List<ExerciseSession> exercises; 
  final bool isRestMode; 

  ActiveSessionState({required this.exercises, this.isRestMode = false});
  
  ActiveSessionState copyWith({List<ExerciseSession>? exercises, bool? isRestMode}) => 
    ActiveSessionState(exercises: exercises ?? this.exercises, isRestMode: isRestMode ?? this.isRestMode);
}

class ActiveSessionNotifier extends StateNotifier<ActiveSessionState> {
  final SetLogsRepository _logsRepo;
  ActiveSessionNotifier(this._logsRepo) : super(ActiveSessionState(exercises: []));

  void clearSession() => state = ActiveSessionState(exercises: []);

  void lockIntoRestMode() => state = state.copyWith(exercises: [], isRestMode: true);

  void addSet(int exIdx) {
    final s = state.exercises[exIdx];
    final hasPrev = s.sets.isNotEmpty && s.sets.first.previousWeight != null;
    final updated = s.copyWith(sets: [...s.sets, ActiveSet(previousWeight: hasPrev ? s.sets.first.previousWeight : null, previousReps: hasPrev ? s.sets.first.previousReps : null)]);
    state = state.copyWith(exercises: [...state.exercises]..[exIdx] = updated);
  }

  void updateSetInputs(int exIdx, int setIdx, {double? weight, int? reps}) {
    final s = state.exercises[exIdx];
    final updatedSets = [...s.sets]..[setIdx] = s.sets[setIdx].copyWith(weight: weight, reps: reps);
    state = state.copyWith(exercises: [...state.exercises]..[exIdx] = s.copyWith(sets: updatedSets));
  }

  Future<void> toggleSetLogging(int exIdx, int setIdx) async {
    final s = state.exercises[exIdx], target = s.sets[setIdx], updatedSets = [...s.sets];

    if (!target.isCompleted) {
      final w = target.weight ?? target.previousWeight ?? 0.0, r = target.reps ?? target.previousReps ?? 0;
      final id = await _logsRepo.insertLog(exerciseId: s.exercise.id, weight: w, reps: r, setTag: target.tag);
      updatedSets[setIdx] = target.copyWith(weight: w, reps: r, isCompleted: true, logId: id);
    } else {
      if (target.logId == null) return;
      await _logsRepo.deleteLog(target.logId!);
      updatedSets[setIdx] = target.copyWith(isCompleted: false, logId: null);
    }
    state = state.copyWith(exercises: [...state.exercises]..[exIdx] = s.copyWith(sets: updatedSets));
  }

  void loadDailyContext(List<ExerciseSession> dailyExercises) {
    if (state.exercises.isNotEmpty && dailyExercises.isNotEmpty && 
        state.exercises.map((e) => e.exercise.id).join(',') == dailyExercises.map((e) => e.exercise.id).join(',')) return;
    state = state.copyWith(exercises: dailyExercises, isRestMode: false);
  }
}

final activeSessionProvider = StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState>((ref) => ActiveSessionNotifier(ref.watch(setLogsRepositoryProvider)));

class RestTimerNotifier extends StateNotifier<int> {
  RestTimerNotifier() : super(0);
  Timer? _timer;
  void startTimer(int sec) {
    _timer?.cancel(); state = sec;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => state > 0 ? state-- : t.cancel());
  }
  void addTime(int sec) => state += sec;
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
}

final restTimerProvider = StateNotifierProvider<RestTimerNotifier, int>((ref) => RestTimerNotifier());

final bypassSameDayWorkoutProvider = StateProvider<bool>((ref) => false);

final workoutSessionLoaderProvider = FutureProvider<void>((ref) async {
  final engine = ref.watch(loopEngineProvider), db = ref.watch(databaseProvider), logsRepo = ref.watch(setLogsRepositoryProvider);
  final bypass = ref.watch(bypassSameDayWorkoutProvider);

  if (!bypass) {
    final alreadyWorkedOutToday = await logsRepo.hasCompletedSessionToday();
    if (alreadyWorkedOutToday) {
      ref.read(activeSessionProvider.notifier).lockIntoRestMode();
      return; 
    }
  }

  final routine = await engine.getActiveRoutine();
  if (routine == null) {
    ref.read(activeSessionProvider.notifier).clearSession();
    return;
  }
  
  final template = await engine.getTodayTemplate(routine);
  if (template == null) {
    ref.read(activeSessionProvider.notifier).clearSession();
    return;
  }
  
  final results = await (db.select(db.workoutExercises).join([drift.innerJoin(db.exercises, db.exercises.id.equalsExp(db.workoutExercises.exerciseId))])
    ..where(db.workoutExercises.workoutTemplateId.equals(template.id))..orderBy([drift.OrderingTerm.asc(db.workoutExercises.displayOrder)])).get();
  
  List<ExerciseSession> dailyExercises = [];
  
  for (var row in results) {
    final ex = row.readTable(db.exercises);
    final today = await logsRepo.getLogsForExerciseToday(ex.id);
    
    final lastLog = await (db.select(db.setLogs)
          ..where((tbl) => tbl.exerciseId.equals(ex.id))
          ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.timestamp)])
          ..limit(1))
        .getSingleOrNull();

    List<SetLog> past = [];
    if (lastLog != null) {
      past = await (db.select(db.setLogs)
            // FIXED: Added '?? 0' to enforce a non-nullable int pass
            ..where((tbl) => tbl.exerciseId.equals(ex.id) & tbl.sessionId.equals(lastLog.sessionId ?? 0))
            ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.timestamp)]))
          .get();
    }

    List<ActiveSet> sessionSets = [];

    if (today.isNotEmpty) {
      sessionSets = List.generate(today.length, (i) {
        return ActiveSet(
          weight: today[i].weight, reps: today[i].reps, isCompleted: true, 
          tag: today[i].setTag, logId: today[i].id, 
          previousWeight: i < past.length ? past[i].weight : null, previousReps: i < past.length ? past[i].reps : null
        );
      });
      sessionSets.add(ActiveSet(
        previousWeight: past.isNotEmpty ? past.last.weight : null, previousReps: past.isNotEmpty ? past.last.reps : null
      ));
    } else {
      if (past.isNotEmpty) {
        sessionSets = past.map((p) => ActiveSet(
          weight: p.weight, 
          reps: p.reps,     
          previousWeight: p.weight,
          previousReps: p.reps,
          isCompleted: false 
        )).toList();
      } else {
        sessionSets = [ActiveSet()];
      }
    }

    dailyExercises.add(ExerciseSession(exercise: ex, sets: sessionSets));
  }
  
  ref.read(activeSessionProvider.notifier).loadDailyContext(dailyExercises);
});
