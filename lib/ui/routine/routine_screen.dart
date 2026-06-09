// Location: C:\Development\batak\lib\ui\routine\routine_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/loop/loop_engine.dart' hide databaseProvider;
import '../../core/database/app_database.dart';
import 'routine_node_card.dart';
import '../shell/app_shell.dart';
import 'routine_composer.dart';

final isComposingProvider = StateProvider<bool>((ref) => false);

final routineDataProvider = FutureProvider.autoDispose((ref) async {
  final engine = ref.watch(loopEngineProvider);
  final routine = await engine.getActiveRoutine();
  if (routine == null) return null;

  final db = ref.read(databaseProvider);
  final templates = await (db.select(db.workoutTemplates)
        ..where((t) => t.routineId.equals(routine.id)))
      .get();

  return {'routine': routine, 'templates': templates};
});

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isComposing = ref.watch(isComposingProvider);

    if (isComposing) {
      return const RoutineComposer();
    }

    final routineDataAsync = ref.watch(routineDataProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth / 2) - 112;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: routineDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
        error: (err, stack) => Center(child: Text('Database Error: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (data) {
          if (data == null) {
            Future.microtask(() => ref.read(isComposingProvider.notifier).state = true);
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F)));
          }

          final Routine routine = data['routine'] as Routine;
          final List<WorkoutTemplate> templates = data['templates'] as List<WorkoutTemplate>;
          
          templates.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Active Sequence",
                      style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_box_outlined, color: Color(0xFFCAC6BB)),
                      onPressed: () {
                        ref.read(isComposingProvider.notifier).state = true;
                      },
                    )
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.25,
                      left: 0, right: 0,
                      child: Container(height: 2, color: const Color(0xFF353535)),
                    ),

                    if (templates.isEmpty)
                      const Center(child: Text("⚠️ 0 days are assigned.", style: TextStyle(color: Color(0xFFE1C19F))))
                    else
                      SizedBox(
                        height: 320,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: templates.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 32),
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            
                            NodeStatus status;
                            if (template.sequenceOrder < routine.currentSequenceIndex) {
                              status = NodeStatus.completed;
                            } else if (template.sequenceOrder == routine.currentSequenceIndex) {
                              status = NodeStatus.current;
                            } else {
                              status = NodeStatus.upcoming;
                            }

                            return Center(
                              child: RoutineNodeCard(
                                dayNumber: template.sequenceOrder,
                                templateName: template.name,
                                status: status,
                                onBegin: () {
                                  ref.read(bottomNavIndexProvider.notifier).state = 0;
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: OutlinedButton(
                  onPressed: templates.isEmpty ? null : () async {
                    await ref.read(loopEngineProvider).completeTodaySequence(routine);
                    ref.invalidate(routineDataProvider);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF49473F)),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    foregroundColor: const Color(0xFFCAC6BB),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.skip_next, size: 20),
                      SizedBox(width: 8),
                      Text("MANUAL ADVANCE SEQUENCE", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
