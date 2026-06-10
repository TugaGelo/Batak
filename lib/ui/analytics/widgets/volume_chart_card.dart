import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/history_state.dart';

class VolumeChartCard extends ConsumerWidget {
  const VolumeChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyTimelineProvider);

    List<double> weeklyVolumes = List.filled(6, 0.0);

    historyAsync.whenData((sessions) {
      final now = DateTime.now();
      for (var s in sessions) {
        final daysAgo = now.difference(s.session.startTime).inDays;
        final weekIndex = daysAgo ~/ 7;
        
        if (weekIndex >= 0 && weekIndex < 6) {
          weeklyVolumes[5 - weekIndex] += (s.session.volumeGenerated ?? 0.0);
        }
      }
    });

    double maxVolume = weeklyVolumes.reduce(max);
    if (maxVolume == 0) maxVolume = 1;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "6-WEEK VOLUME PROGRESSION",
                style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              Icon(Icons.more_horiz, color: Color(0xFFCAC6BB), size: 20),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(6, (index) {
              final vol = weeklyVolumes[index];
              final scaledHeight = max(4.0, (vol / maxVolume) * 120.0);
              final isCurrentWeek = (index == 5); 
              
              return _buildBar("W${index + 1}", scaledHeight, isCurrentWeek);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFEF8E5) : const Color(0xFFE1C19F),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            boxShadow: isActive
                ? [const BoxShadow(color: Color(0x33FEF8E5), blurRadius: 8, spreadRadius: 2)]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFFEF8E5) : const Color(0xFFCAC6BB),
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
