import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class ComposerDayCard extends StatefulWidget {
  final int index;
  final int dayNumber;
  final String initialTitle;
  final List<Exercise> exercises;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onAddExercise;
  final Function(int) onRemoveExercise;
  final VoidCallback onRemoveDay;

  const ComposerDayCard({
    super.key,
    required this.index,
    required this.dayNumber,
    required this.initialTitle,
    this.exercises = const [],
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onTitleChanged,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onRemoveDay,
  });

  @override
  State<ComposerDayCard> createState() => _ComposerDayCardState();
}

class _ComposerDayCardState extends State<ComposerDayCard> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.isExpanded ? const Color(0xFFE1C19F) : const Color(0xFF353535), width: 1),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.onToggleExpand,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: widget.isExpanded ? const BorderRadius.vertical(top: Radius.circular(7)) : BorderRadius.circular(7),
                border: Border(bottom: BorderSide(color: widget.isExpanded ? const Color(0xFF353535) : Colors.transparent)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: widget.isExpanded
                        ? TextField(
                            controller: _titleController,
                            onChanged: widget.onTitleChanged,
                            style: const TextStyle(color: Color(0xFFE1C19F), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: "DAY TITLE",
                              hintStyle: TextStyle(color: Color(0xFF949187)),
                              border: InputBorder.none,
                            ),
                          )
                        : Text(
                            "DAY ${widget.dayNumber}: ${widget.initialTitle.toUpperCase()}",
                            style: const TextStyle(color: Color(0xFFCAC6BB), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                  ),
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.isExpanded ? const Color(0xFFE1C19F) : const Color(0xFFCAC6BB),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: widget.isExpanded
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ...widget.exercises.asMap().entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E0E0E),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF353535)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.value.name, style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                    const Text("Sets & Reps TBA", style: TextStyle(color: Color(0xFF949187), fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFF949187), size: 18),
                                onPressed: () => widget.onRemoveExercise(entry.key),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      // Attach Movement Button
                      GestureDetector(
                        onTap: widget.onAddExercise,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          margin: const EdgeInsets.only(top: 4, bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF353535)), 
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Color(0xFFCAC6BB), size: 16),
                              SizedBox(width: 8),
                              Text("ATTACH MOVEMENT", style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: widget.onRemoveDay,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.8), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "REMOVE DAY", 
                              style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity, height: 0), 
          ),
        ],
      ),
    );
  }
}
