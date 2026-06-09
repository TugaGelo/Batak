import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../routine_screen.dart';

final allRoutinesProvider = FutureProvider.autoDispose<List<Routine>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.select(db.routines).get();
});

class RoutineLibrarySheet extends ConsumerWidget {
  final Function(Routine) onEditRequested;

  const RoutineLibrarySheet({super.key, required this.onEditRequested});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(allRoutinesProvider);
    final activeId = ref.watch(selectedRoutineIdProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
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
                const Text("ROUTINE PROFILES", style: TextStyle(fontFamily: 'Epilogue', color: Color(0xFFFEF8E5), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(isComposingProvider.notifier).state = true;
                  },
                  icon: const Icon(Icons.add, color: Color(0xFFE1C19F), size: 18),
                  label: const Text("NEW", style: TextStyle(color: Color(0xFFE1C19F), fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          Expanded(
            child: routinesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (routines) {
                if (routines.isEmpty) {
                  return const Center(child: Text("No saved routines found.", style: TextStyle(color: Color(0xFF949187))));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: routines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    final isActive = routine.id == activeId;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isActive ? const Color(0xFFE1C19F) : const Color(0xFF353535)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ref.read(selectedRoutineIdProvider.notifier).state = routine.id;
                                ref.invalidate(routineDataProvider);
                                Navigator.pop(context);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(routine.name, style: TextStyle(color: isActive ? const Color(0xFFE1C19F) : const Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(isActive ? "ACTIVE TARGET" : "STANDBY POOL", style: TextStyle(color: isActive ? const Color(0xFFE1C19F) : const Color(0xFF949187), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFFCAC6BB), size: 20),
                                onPressed: () {
                                  Navigator.pop(context);
                                  onEditRequested(routine);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () async {
                                  final db = ref.read(databaseProvider);
                                  final templates = await (db.select(db.workoutTemplates)..where((t) => t.routineId.equals(routine.id))).get();
                                  for (var t in templates) {
                                    await (db.delete(db.workoutExercises)..where((we) => we.workoutTemplateId.equals(t.id))).go();
                                  }
                                  await (db.delete(db.workoutTemplates)..where((t) => t.routineId.equals(routine.id))).go();
                                  await (db.delete(db.routines)..where((r) => r.id.equals(routine.id))).go();
                                  
                                  if (isActive) {
                                    ref.read(selectedRoutineIdProvider.notifier).state = null;
                                  }
                                  ref.invalidate(allRoutinesProvider);
                                  ref.invalidate(routineDataProvider);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
