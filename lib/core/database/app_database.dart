import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get currentSequenceIndex => integer().withDefault(const Constant(1))();
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
  
  TextColumn get bodyPart => text()();    
  TextColumn get equipment => text()();   
  TextColumn get target => text()();      
  TextColumn get gifUrl => text()();      
  TextColumn get instructions => text()(); 
}

class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId => integer().references(WorkoutTemplates, #id)(); 
  DateTimeColumn get startTime => dateTime()(); 
  DateTimeColumn get endTime => dateTime().nullable()(); 
  RealColumn get volumeGenerated => real().nullable()(); 
}

class SetLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get sessionId => integer().nullable().references(WorkoutSessions, #id)();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  TextColumn get setTag => text().withDefault(const Constant('N'))();
  DateTimeColumn get timestamp => dateTime()();
}

class WorkoutExercises extends Table {
  IntColumn get workoutTemplateId => integer().references(WorkoutTemplates, #id)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get displayOrder => integer()();

  @override
  Set<Column> get primaryKey => {workoutTemplateId, exerciseId};
}

@DriftDatabase(tables: [
  Routines,
  WorkoutTemplates,
  Exercises,
  WorkoutSessions,
  SetLogs,
  WorkoutExercises,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'batak_db'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(workoutSessions);
          await m.addColumn(setLogs, setLogs.sessionId);
        }
      },
    );
  }
}

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
