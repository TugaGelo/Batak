import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/loop/loop_engine.dart';
import '../../../core/state/workout_state.dart';
import '../routine_screen.dart';
import 'routine_timeline_node.dart';
import '../dialogs/routine_library_sheet.dart';

class ActiveRoutineView extends ConsumerStatefulWidget {
  final Routine routine;
  final List<WorkoutTemplate> templates;
  final Map<int, List<Exercise>> exercisesMap;

  const ActiveRoutineView({
    super.key,
    required this.routine,
    required this.templates,
    required this.exercisesMap,
  });

  @override
  ConsumerState<ActiveRoutineView> createState() => _ActiveRoutineViewState();
}

class _ActiveRoutineViewState extends ConsumerState<ActiveRoutineView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 160),
          children: [
            const Text("Active Training Sequence", style: TextStyle(fontFamily: 'Epilogue', color: Color(0xFFFEF8E5), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Current Cycle: ${widget.routine.name}", style: const TextStyle(color: Color(0xFFE1C19F), fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),

            Stack(
              children: [
                Positioned(
                  top: 20, bottom: 0, left: 27,
                  child: Container(width: 2, color: const Color(0xFF353535)),
                ),
                Column(
                  children: widget.templates.map((template) {
                    return RoutineTimelineNode(
                      dayNumber: template.sequenceOrder,
                      title: template.name,
                      isCompleted: template.sequenceOrder < widget.routine.currentSequenceIndex,
                      isCurrent: template.sequenceOrder == widget.routine.currentSequenceIndex,
                      exercises: widget.exercisesMap[template.id] ?? [],
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),

        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [const Color(0xFF131313), const Color(0xFF131313).withOpacity(0.0)],
                stops: const [0.7, 1.0],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: widget.templates.isEmpty ? null : () async {
                      await ref.read(loopEngineProvider).completeTodaySequence(widget.routine);
                      ref.invalidate(routineDataProvider);
                      ref.invalidate(workoutSessionLoaderProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE1DCC9),
                      foregroundColor: const Color(0xFF1D1C10),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("MANUAL ADVANCE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => RoutineLibrarySheet(
                          onEditRequested: (target) {
                            ref.read(editingRoutineTargetProvider.notifier).state = target;
                            ref.read(isComposingProvider.notifier).state = true;
                          },
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF49473F)),
                      backgroundColor: const Color(0xFF1F1F1F),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.edit_calendar, color: Color(0xFFE1C19F)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
