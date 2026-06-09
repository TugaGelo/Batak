import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';
import '../routine_screen.dart';
import 'composer_day_card.dart';
import 'composer_action_footer.dart';
import '../dialogs/exercise_selection_sheet.dart';

class DraftDay {
  String title;
  bool isRestDay;
  List<Exercise> exercises;

  DraftDay({required this.title, this.isRestDay = false, this.exercises = const []});
}

class RoutineComposer extends ConsumerStatefulWidget {
  final Routine? targetRoutine;
  const RoutineComposer({super.key, this.targetRoutine});

  @override
  ConsumerState<RoutineComposer> createState() => _RoutineComposerState();
}

class _RoutineComposerState extends ConsumerState<RoutineComposer> {
  int? _expandedIndex = 0; 
  String _routineName = "";
  List<DraftDay> _draftDays = [];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      if (widget.targetRoutine != null) {
        _routineName = widget.targetRoutine!.name;
        _loadRoutineDataForEditing();
      } else {
        _draftDays = [DraftDay(title: "Lower Core Integration", exercises: [])];
      }
      _isInitialized = true;
    }
  }

  Future<void> _loadRoutineDataForEditing() async {
    final db = ref.read(databaseProvider);
    final templates = await (db.select(db.workoutTemplates)
          ..where((t) => t.routineId.equals(widget.targetRoutine!.id)))
        .get();
    
    templates.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));
    List<DraftDay> steps = [];

    for (var t in templates) {
      final query = db.select(db.workoutExercises).join([
        drift.innerJoin(db.exercises, db.exercises.id.equalsExp(db.workoutExercises.exerciseId)),
      ])..where(db.workoutExercises.workoutTemplateId.equals(t.id));
      
      final results = await query.get();
      final exercises = results.map((row) => row.readTable(db.exercises)).toList();
      steps.add(DraftDay(title: t.name, exercises: exercises));
    }

    setState(() {
      _draftDays = steps;
      _expandedIndex = steps.isNotEmpty ? 0 : null;
    });
  }

  void _toggleExpand(int index) => setState(() => _expandedIndex = _expandedIndex == index ? null : index);
  void _addDay() => setState(() { _draftDays.add(DraftDay(title: "New Sequence", exercises: [])); _expandedIndex = _draftDays.length - 1; });
  void _removeExercise(int dIdx, int exIdx) => setState(() => _draftDays[dIdx].exercises.removeAt(exIdx));

  void _removeDay(int index) {
    setState(() {
      _draftDays.removeAt(index);
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else if (_expandedIndex != null && _expandedIndex! > index) {
        _expandedIndex = _expandedIndex! - 1;
      }
    });
  }

  void _openExerciseSelector(int dayIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseSelectionSheet(
        onSelect: (ex) => setState(() => _draftDays[dayIndex].exercises = [..._draftDays[dayIndex].exercises, ex]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF131313),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 120), 
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFE1C19F), size: 28),
                    onPressed: () => ref.read(isComposingProvider.notifier).state = false,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.targetRoutine != null ? "EDIT PROFILE" : "SEQUENCE ARCHITECTURE",
                style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _routineName,
                onChanged: (val) => _routineName = val,
                style: const TextStyle(color: Color(0xFFE2E2E2), fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Enter Routine Name...",
                  hintStyle: const TextStyle(color: Color(0xFFCAC6BB)),
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF353535))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE1DCC9))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 32),

              ..._draftDays.asMap().entries.map((entry) {
                final index = entry.key;
                final draft = entry.value;
                return ComposerDayCard(
                  index: index,
                  dayNumber: index + 1,
                  initialTitle: draft.title,
                  exercises: draft.exercises,
                  isExpanded: _expandedIndex == index,
                  onToggleExpand: () => _toggleExpand(index),
                  onTitleChanged: (newTitle) => _draftDays[index].title = newTitle,
                  onAddExercise: () => _openExerciseSelector(index), 
                  onRemoveExercise: (exIndex) => _removeExercise(index, exIndex),
                  onRemoveDay: () => _removeDay(index),
                );
              }),

              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _addDay,
                icon: const Icon(Icons.add, color: Color(0xFFE1C19F)),
                label: const Text("ADD ANOTHER DAY", style: TextStyle(color: Color(0xFFE1C19F), letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ComposerActionFooter(
              routineName: _routineName,
              draftDays: _draftDays,
              editingRoutineId: widget.targetRoutine?.id,
            ),
          ),
        ],
      ),
    );
  }
}
