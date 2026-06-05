import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai/ai_swapper_service.dart';

class ActiveSet {
  final double? weight;
  final int? reps;
  final bool isCompleted;
  final String tag;

  ActiveSet({this.weight, this.reps, this.isCompleted = false, this.tag = 'N'});

  ActiveSet copyWith({double? weight, int? reps, bool? isCompleted, String? tag}) {
    return ActiveSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
      tag: tag ?? this.tag,
    );
  }
}

class ActiveSessionState {
  final String exerciseId;
  final String exerciseName;
  final String primaryMuscle;
  final List<ActiveSet> sets;

  ActiveSessionState({
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscle,
    required this.sets,
  });

  ActiveSessionState copyWith({
    String? exerciseId,
    String? exerciseName,
    String? primaryMuscle,
    List<ActiveSet>? sets,
  }) {
    return ActiveSessionState(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      sets: sets ?? this.sets,
    );
  }
}

class ActiveSessionNotifier extends StateNotifier<ActiveSessionState> {
  ActiveSessionNotifier()
      : super(ActiveSessionState(
          exerciseId: 'barbell_bench_press',
          exerciseName: 'Barbell Bench Press',
          primaryMuscle: 'CHEST',
          sets: [ActiveSet()],
        ));

  void addSet() {
    state = state.copyWith(sets: [...state.sets, ActiveSet()]);
  }

  void updateSet(int index, {double? weight, int? reps}) {
    final updatedSets = List<ActiveSet>.from(state.sets);
    updatedSets[index] = updatedSets[index].copyWith(
      weight: weight ?? updatedSets[index].weight,
      reps: reps ?? updatedSets[index].reps,
    );
    state = state.copyWith(sets: updatedSets);
  }

  void completeSet(int index) {
    final updatedSets = List<ActiveSet>.from(state.sets);
    updatedSets[index] = updatedSets[index].copyWith(isCompleted: true);
    state = state.copyWith(sets: updatedSets);
  }

  void swapExercise(ExerciseVector newExercise) {
    state = ActiveSessionState(
      exerciseId: newExercise.id,
      exerciseName: newExercise.name,
      primaryMuscle: newExercise.primaryMuscle.toUpperCase(),
      sets: [ActiveSet()],
    );
  }
}

final activeSessionProvider = StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState>((ref) {
  return ActiveSessionNotifier();
});

class RestTimerNotifier extends StateNotifier<int> {
  RestTimerNotifier() : super(0);
  Timer? _timer;

  void startTimer(int seconds) {
    _timer?.cancel();
    state = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state--;
      } else {
        timer.cancel();
      }
    });
  }

  void addTime(int seconds) {
    state += seconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final restTimerProvider = StateNotifierProvider<RestTimerNotifier, int>((ref) {
  return RestTimerNotifier();
});
