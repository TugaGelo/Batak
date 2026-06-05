// Location: C:\Development\batak\lib\ui\routine\widgets\composer_day_card.dart

import 'package:flutter/material.dart';

class ComposerDayCard extends StatefulWidget {
  final int index;
  final int dayNumber;
  final String initialTitle;
  final bool isRestDay;
  final List<String> exercises;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onAddExercise;

  const ComposerDayCard({
    super.key,
    required this.index,
    required this.dayNumber,
    required this.initialTitle,
    this.isRestDay = false,
    this.exercises = const [],
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onTitleChanged,
    required this.onAddExercise,
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
    final borderColor = widget.isExpanded ? const Color(0xFFE1C19F) : const Color(0xFF353535);

    return GestureDetector(
      onTap: widget.onToggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: widget.isRestDay && !widget.isExpanded ? const Color(0xFF1B1B1B) : const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: widget.isExpanded ? 2 : 1),
          boxShadow: widget.isExpanded 
            ? [const BoxShadow(color: Color(0x26412D15), blurRadius: 24, offset: Offset(0, 4))] 
            : [],
        ),
        child: Column(
          children: [
            // Header Row (Always visible)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isExpanded ? const Color(0xFFE1C19F) : const Color(0xFF49473F),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${widget.dayNumber}",
                        style: TextStyle(
                          color: widget.isExpanded ? const Color(0xFFE1C19F) : const Color(0xFFCAC6BB),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: widget.isExpanded
                        ? TextField(
                            controller: _titleController,
                            onChanged: widget.onTitleChanged,
                            style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              hintText: "Day Title (e.g. Push Focus)",
                              hintStyle: TextStyle(color: const Color(0xFFCAC6BB).withOpacity(0.5)),
                              border: InputBorder.none,
                            ),
                          )
                        : Text(
                            "Day ${widget.dayNumber}: ${widget.initialTitle}",
                            style: const TextStyle(
                              color: Color(0xFFE2E2E2),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.isExpanded ? const Color(0xFFFEF8E5) : const Color(0xFF949187),
                  ),
                ],
              ),
            ),

            // Expanded Content Body
            if (widget.isExpanded)
              Container(
                color: const Color(0xFF1B1B1B), 
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...widget.exercises.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1F1F),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF49473F)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("EXERCISE ${entry.key + 1}", style: const TextStyle(color: Color(0xFFE1C19F), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(entry.value, style: const TextStyle(color: Color(0xFFE2E2E2), fontSize: 14)),
                                ],
                              ),
                              const Icon(Icons.more_vert, color: Color(0xFFCAC6BB), size: 20),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 8),
                    
                    OutlinedButton(
                      onPressed: widget.onAddExercise,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF49473F), style: BorderStyle.solid), 
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        foregroundColor: const Color(0xFFE1C19F),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 18),
                          const SizedBox(width: 8),
                          Text("ADD EXERCISE TO DAY ${widget.dayNumber}", style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
