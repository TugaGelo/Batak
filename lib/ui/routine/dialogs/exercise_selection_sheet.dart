import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import 'exercise_sheet_row.dart'; 

final availableExercisesProvider = FutureProvider.autoDispose<List<Exercise>>((ref) async {
  final db = ref.read(databaseProvider);
  var exercises = await db.select(db.exercises).get();
  
  if (exercises.isEmpty) {
    await db.into(db.exercises).insert(ExercisesCompanion.insert(name: "Barbell Bench Press", vectorId: "chest"));
    await db.into(db.exercises).insert(ExercisesCompanion.insert(name: "Conventional Deadlift", vectorId: "back"));
    await db.into(db.exercises).insert(ExercisesCompanion.insert(name: "Overhead Press", vectorId: "shoulders"));
    await db.into(db.exercises).insert(ExercisesCompanion.insert(name: "Bulgarian Split Squat", vectorId: "legs"));
    await db.into(db.exercises).insert(ExercisesCompanion.insert(name: "Weighted Pull-Up", vectorId: "back"));
    exercises = await db.select(db.exercises).get(); 
  }
  
  return exercises;
});

class ExerciseSelectionSheet extends ConsumerStatefulWidget {
  final Function(Exercise) onSelect;
  const ExerciseSelectionSheet({super.key, required this.onSelect});

  @override
  ConsumerState<ExerciseSelectionSheet> createState() => _ExerciseSelectionSheetState();
}

class _ExerciseSelectionSheetState extends ConsumerState<ExerciseSelectionSheet> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(availableExercisesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.60, 
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF353535))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(width: 48, height: 6, decoration: BoxDecoration(color: const Color(0xFF353535), borderRadius: BorderRadius.circular(4))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("SELECT TARGET MOVEMENT", style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                IconButton(icon: const Icon(Icons.close, color: Color(0xFFCAC6BB)), onPressed: () => Navigator.pop(context))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: const Color(0xFF1F1F1F), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF353535))),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                style: const TextStyle(color: Color(0xFFE2E2E2), fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Search exercises...",
                  hintStyle: TextStyle(color: Color(0xFFCAC6BB)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFCAC6BB)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (exercises) {
                final filteredExercises = exercises.where((ex) => ex.name.toLowerCase().contains(_searchQuery)).toList();
                return ListView.separated(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 40),
                  itemCount: filteredExercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ex = filteredExercises[index];
                    return ExerciseSheetRow(
                      exercise: ex,
                      onTap: () {
                        widget.onSelect(ex); 
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
