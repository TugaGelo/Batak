import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import 'exercise_sheet_row.dart'; 
import 'exercise_search_bar.dart';
import 'exercise_filter_row.dart';

final availableExercisesProvider = FutureProvider.autoDispose<List<Exercise>>((ref) async {
  final db = ref.read(databaseProvider);
  var exercises = await db.select(db.exercises).get();
  
  if (exercises.isEmpty) {
    final String response = await rootBundle.loadString('assets/data/exercises_vectors.json');
    final List<dynamic> data = json.decode(response);

    await db.batch((batch) {
      for (var item in data) {
        batch.insert(
          db.exercises,
          ExercisesCompanion.insert(
            name: item["name"] ?? "Unknown Exercise",
            bodyPart: item["body_part"] ?? "other",
            equipment: item["equipment"] ?? "other",
            target: item["target"] ?? "other",
            gifUrl: item["gif_url"] ?? "",
            instructions: item["instructions"] != null ? (item["instructions"]["en"] ?? "") : "",
          ),
        );
      }
    });
    exercises = await db.select(db.exercises).get(); 
  }
  
  exercises.sort((a, b) => a.name.compareTo(b.name));
  return exercises;
});

final selectedBodyPartProvider = StateProvider<String?>((ref) => null);
final selectedEquipmentProvider = StateProvider<String?>((ref) => null);

class ExerciseSelectionSheet extends ConsumerStatefulWidget {
  final Function(Exercise) onSelect;
  final Function(Exercise) onRemove; 
  final List<int> excludedExerciseIds;

  const ExerciseSelectionSheet({
    super.key, 
    required this.onSelect,
    required this.onRemove, 
    this.excludedExerciseIds = const [],
  });

  @override
  ConsumerState<ExerciseSelectionSheet> createState() => _ExerciseSelectionSheetState();
}

class _ExerciseSelectionSheetState extends ConsumerState<ExerciseSelectionSheet> {
  String _searchQuery = "";
  late Set<int> _localExcludedIds;

  @override
  void initState() {
    super.initState();
    _localExcludedIds = Set.from(widget.excludedExerciseIds);
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(availableExercisesProvider);
    final activeBodyPart = ref.watch(selectedBodyPartProvider);
    final activeEquipment = ref.watch(selectedEquipmentProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("DISCOVER MOVEMENTS", style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                IconButton(icon: const Icon(Icons.close, color: Color(0xFFCAC6BB)), onPressed: () => Navigator.pop(context))
              ],
            ),
          ),

          ExerciseSearchBar(onSearchChanged: (val) => setState(() => _searchQuery = val.toLowerCase())),

          const SizedBox(height: 6),
          ExerciseFilterRow(
            items: const ['back', 'cardio', 'chest', 'lower arms', 'lower legs', 'neck', 'shoulders', 'upper arms', 'upper legs', 'waist'],
            activeItem: activeBodyPart,
            isEquipment: false,
            onSelect: (val) => ref.read(selectedBodyPartProvider.notifier).state = val,
          ),
          const SizedBox(height: 6),
          ExerciseFilterRow(
            items: const ['body weight', 'dumbbell', 'cable', 'barbell', 'leverage machine', 'band', 'smith machine', 'kettlebell'],
            activeItem: activeEquipment,
            isEquipment: true,
            onSelect: (val) => ref.read(selectedEquipmentProvider.notifier).state = val,
          ),
          const SizedBox(height: 10),
          
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
              error: (err, stack) => Center(child: Text('Error initializing database: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (exercises) {
                final filteredExercises = exercises.where((ex) {
                  final matchesSearch = ex.name.toLowerCase().contains(_searchQuery);
                  final matchesMuscle = activeBodyPart == null || ex.bodyPart == activeBodyPart;
                  final matchesEquip = activeEquipment == null || ex.equipment == activeEquipment;
                  return matchesSearch && matchesMuscle && matchesEquip;
                }).toList();
                
                if (filteredExercises.isEmpty) {
                  return const Center(child: Text("No exercises match your filter criteria.", style: TextStyle(color: Color(0xFFCAC6BB))));
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 40),
                  itemCount: filteredExercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final ex = filteredExercises[index];
                    final isSelected = _localExcludedIds.contains(ex.id);

                    return ExerciseSheetRow(
                      exercise: ex,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _localExcludedIds.remove(ex.id);
                            widget.onRemove(ex);
                          } else {
                            _localExcludedIds.add(ex.id);
                            widget.onSelect(ex);
                          }
                        });
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
