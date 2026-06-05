// Location: C:\Development\batak\lib\ui\routine\routine_composer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/composer_day_card.dart';

// --- THE DRAFT STATE MODEL ---
class DraftDay {
  String title;
  bool isRestDay;
  List<String> exercises;

  DraftDay({required this.title, this.isRestDay = false, this.exercises = const []});
}

class RoutineComposer extends ConsumerStatefulWidget {
  const RoutineComposer({super.key});

  @override
  ConsumerState<RoutineComposer> createState() => _RoutineComposerState();
}

class _RoutineComposerState extends ConsumerState<RoutineComposer> {
  int? _expandedIndex = 0; // Default to opening the first day
  String _routineName = "";
  
  // The temporary dynamic list of days
  final List<DraftDay> _draftDays = [
    DraftDay(title: "Heavy Push"),
  ];

  void _toggleExpand(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  void _addDay() {
    setState(() {
      _draftDays.add(DraftDay(title: "New Day"));
      _expandedIndex = _draftDays.length - 1; // Auto-expand the fresh day
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        title: const Text(
          "ROUTINE COMPOSER",
          style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFCAC6BB)),
            onPressed: () {
              // Cancel logic will go here
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Main Scrollable Content
          ListView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120), // Extra bottom padding for the footer
            children: [
              // Routine Name Input
              const Text(
                "ROUTINE DESIGNATION",
                style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (val) => _routineName = val,
                style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 16),
                decoration: InputDecoration(
                  hintText: "E.g., Tactical Hypertrophy PPL",
                  hintStyle: TextStyle(color: const Color(0xFFCAC6BB).withOpacity(0.5)),
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF49473F)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFEF8E5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic List of Accordion Cards
              ..._draftDays.asMap().entries.map((entry) {
                final index = entry.key;
                final draft = entry.value;

                return ComposerDayCard(
                  index: index,
                  dayNumber: index + 1,
                  initialTitle: draft.title,
                  isRestDay: draft.isRestDay,
                  exercises: draft.exercises,
                  isExpanded: _expandedIndex == index,
                  onToggleExpand: () => _toggleExpand(index),
                  onTitleChanged: (newTitle) {
                    _draftDays[index].title = newTitle;
                  },
                  onAddExercise: () {
                    // Trigger exercise selection sheet
                  },
                );
              }),

              const SizedBox(height: 16),

              // The Dynamic Add Day Button
              TextButton.icon(
                onPressed: _addDay,
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE1C19F)),
                label: const Text(
                  "ADD ANOTHER DAY",
                  style: TextStyle(color: Color(0xFFE1C19F), letterSpacing: 1.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Fixed Bottom Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF131313),
                border: Border(top: BorderSide(color: Color(0xFF353535))),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Print to terminal so we can verify the state works
                  print("Saving Routine: $_routineName");
                  print("Days in loop: ${_draftDays.length}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF8E5),
                  foregroundColor: const Color(0xFF131313),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "SAVE & PUBLISH ROUTINE",
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
