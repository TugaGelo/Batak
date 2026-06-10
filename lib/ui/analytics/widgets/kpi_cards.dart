import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/state/history_state.dart';

class VolumeKpiCard extends ConsumerWidget {
  const VolumeKpiCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyTimelineProvider);

    double weeklyVolume = 0;
    historyAsync.whenData((sessions) {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      for (var s in sessions) {
        if (s.session.startTime.isAfter(sevenDaysAgo)) {
          weeklyVolume += (s.session.volumeGenerated ?? 0);
        }
      }
    });

    final formattedVolume = NumberFormat('#,##0').format(weeklyVolume.toInt());

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "7-DAY VOLUME",
            style: TextStyle(color: Color(0xFFE1C19F), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formattedVolume,
                style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Text(
                "KGS",
                style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StreakKpiCard extends ConsumerWidget {
  const StreakKpiCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyTimelineProvider);
    
    int totalSessions = 0;
    historyAsync.whenData((sessions) => totalSessions = sessions.length);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "TOTAL SESSIONS",
            style: TextStyle(color: Color(0xFFE1C19F), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text("🔥", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                "$totalSessions",
                style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Text(
                "LOGGED",
                style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
