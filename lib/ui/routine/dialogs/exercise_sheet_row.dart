import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import 'icon_mapper.dart'; 

extension StringCasingExtension on String {
  String toTitleCase() {
    if (trim().isEmpty) return '';
    return split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}

class ExerciseSheetRow extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  const ExerciseSheetRow({
    super.key,
    required this.exercise,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dynamicIcon = IconMapper.getEquipmentIcon(exercise.equipment);

    return Material(
      color: const Color(0xFF1F1F1F), 
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFFE1C19F).withOpacity(0.3),
        highlightColor: Colors.transparent,
        child: Opacity(
          opacity: isSelected ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131313),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(dynamicIcon, color: const Color(0xFFCAC6BB), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name.toTitleCase(),
                              style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.w600),
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${exercise.target.toUpperCase()}  •  ${exercise.equipment.toUpperCase()}", 
                              style: const TextStyle(color: Color(0xFFCAC6BB), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE1C19F) : const Color(0xFF5B452B), 
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.add, 
                    color: isSelected ? const Color(0xFF131313) : const Color(0xFFE1C19F), 
                    size: 20
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
