import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/history_state.dart';

final activeStreakProvider = Provider.autoDispose<int>((ref) {
  final heatmapAsync = ref.watch(consistencyHeatmapProvider);
  
  return heatmapAsync.maybeWhen(
    data: (dayCounts) {
      int streak = 0;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (int i = 0; i < 28; i++) {
        final date = today.subtract(Duration(days: i));
        if ((dayCounts[date] ?? 0) > 0) {
          streak++;
        } else if (i == 0) {
          continue;
        } else {
          break;
        }
      }
      return streak;
    },
    orElse: () => 0,
  );
});

class GlobalStreakBadge extends ConsumerWidget {
  const GlobalStreakBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStreak = ref.watch(activeStreakProvider);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF353535)), 
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            currentStreak > 0 ? Icons.local_fire_department : Icons.local_fire_department_outlined, 
            color: currentStreak > 0 ? const Color(0xFFE1C19F) : const Color(0xFF949187), 
            size: 16
          ),
          const SizedBox(width: 6),
          Text(
            "$currentStreak",
            style: TextStyle(
              color: currentStreak > 0 ? const Color(0xFFE1DCC9) : const Color(0xFF949187), 
              fontSize: 12, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
