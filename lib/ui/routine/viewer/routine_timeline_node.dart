import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../shell/app_shell.dart';

class RoutineTimelineNode extends ConsumerWidget {
  final int dayNumber;
  final String title;
  final bool isCompleted;
  final bool isCurrent;
  final List<Exercise> exercises;

  const RoutineTimelineNode({
    super.key,
    required this.dayNumber,
    required this.title,
    required this.isCompleted,
    required this.isCurrent,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconColor = isCurrent ? const Color(0xFFE1C19F) : const Color(0xFFCAC6BB);
    final circleBorder = isCurrent ? const Color(0xFFE1C19F) : const Color(0xFF49473F);
    final circleBg = isCurrent ? const Color(0xFF5B452B) : const Color(0xFF131313);
    final cardBorder = isCurrent ? const Color(0xFFE1C19F) : Colors.transparent;
    final cardBg = isCompleted ? const Color(0xFF1F1F1F).withOpacity(0.5) : const Color(0xFF1F1F1F);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
              border: Border.all(color: circleBorder, width: 2),
              boxShadow: isCurrent ? [const BoxShadow(color: Color(0x33E1C19F), blurRadius: 12)] : [],
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.fitness_center,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: GestureDetector(
              onTap: isCurrent ? () => ref.read(bottomNavIndexProvider.notifier).state = 0 : null,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: isCurrent ? 1.5 : 0),
                  boxShadow: isCurrent ? [const BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8))] : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Day $dayNumber • ${isCompleted ? 'COMPLETED' : isCurrent ? 'ACTIVE' : 'UPCOMING'}",
                      style: TextStyle(
                        color: isCurrent ? const Color(0xFFE1C19F) : const Color(0xFF949187),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Epilogue',
                        color: isCompleted ? const Color(0xFFCAC6BB) : const Color(0xFFFEF8E5),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    if (exercises.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...exercises.map((ex) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.transparent : const Color(0xFF1B1B1B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF353535).withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCompleted ? Icons.done : Icons.circle_outlined,
                                size: 16,
                                color: isCompleted ? const Color(0xFF949187) : const Color(0xFFCAC6BB),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ex.name,
                                  style: TextStyle(
                                    color: isCompleted ? const Color(0xFF949187) : const Color(0xFFE2E2E2),
                                    fontSize: 14,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
