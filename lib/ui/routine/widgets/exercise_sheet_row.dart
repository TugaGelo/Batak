import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';

class ExerciseSheetRow extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseSheetRow({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F), 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131313),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center, color: Color(0xFFCAC6BB), size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      exercise.vectorId.toUpperCase(), 
                      style: const TextStyle(color: Color(0xFFCAC6BB), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF5B452B), 
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Color(0xFFE1C19F), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
