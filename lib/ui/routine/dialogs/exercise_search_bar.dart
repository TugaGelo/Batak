import 'package:flutter/material.dart';

class ExerciseSearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  const ExerciseSearchBar({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F), 
          borderRadius: BorderRadius.circular(8), 
          border: Border.all(color: const Color(0xFF353535))
        ),
        child: TextField(
          onChanged: onSearchChanged,
          style: const TextStyle(color: Color(0xFFE2E2E2), fontSize: 14),
          decoration: const InputDecoration(
            hintText: "Search 1,324 exercises...",
            hintStyle: TextStyle(color: Color(0xFFCAC6BB)),
            prefixIcon: Icon(Icons.search, color: Color(0xFFCAC6BB)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
