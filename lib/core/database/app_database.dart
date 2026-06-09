import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  IntColumn get currentSequenceIndex =>
      integer().withDefault(const Constant(1))();
}

class WorkoutTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().references(Routines, #id)();
  TextColumn get name => text()();
  IntColumn get sequenceOrder => integer()();
}

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  
  TextColumn get stickyNote => text().nullable()();
  
  TextColumn get vectorId => text()(); 
}

class SetLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  
  TextColumn get setTag => text().withDefault(const Constant('N'))();
  
  DateTimeColumn get timestamp => dateTime()();
}

class WorkoutExercises extends Table {
  IntColumn get workoutTemplateId =>
      integer().references(WorkoutTemplates, #id)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get displayOrder => integer()();

  @override
  Set<Column> get primaryKey => {workoutTemplateId, exerciseId};
}

@DriftDatabase(tables: [
  Routines,
  WorkoutTemplates,
  Exercises,
  SetLogs,
  WorkoutExercises,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'batak_db'));

  @override
  int get schemaVersion => 1;
}

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
