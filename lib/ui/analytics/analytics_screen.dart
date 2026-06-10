import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/state/history_state.dart';
import 'widgets/kpi_cards.dart';
import 'widgets/volume_chart_card.dart';
import 'widgets/heatmap_anchor_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyTimelineProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          const Text(
            "TRAINING INTELLIGENCE",
            style: TextStyle(
              color: Color(0xFFFEF8E5), 
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Comprehensive breakdown of your physiological load and performance metrics over time.",
            style: TextStyle(
              color: Color(0xFFCAC6BB), 
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          const Row(
            children: [
              Expanded(child: VolumeKpiCard()),
              SizedBox(width: 16),
              Expanded(child: StreakKpiCard()),
            ],
          ),
          const SizedBox(height: 32),

          const VolumeChartCard(),
          const SizedBox(height: 32),

          const HeatmapAnchorCard(),
          const SizedBox(height: 48), 

          const Text(
            "SESSION ARCHIVE", 
            style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.0)
          ),
          const SizedBox(height: 16),

          historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
            error: (err, stack) => Center(child: Text("Error loading archive: $err", style: const TextStyle(color: Colors.redAccent))),
            data: (sessions) {
              if (sessions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      "NO SESSIONS ARCHIVED YET\nComplete a workout to see your history.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF949187), height: 1.5, letterSpacing: 1.0),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final archive = sessions[index];
                  final dateString = DateFormat('MMM d, yyyy • h:mm a').format(archive.session.startTime);
                  
                  String durationStr = "--";
                  if (archive.session.endTime != null) {
                    final diff = archive.session.endTime!.difference(archive.session.startTime);
                    durationStr = "${diff.inMinutes}m";
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      border: Border.all(color: const Color(0xFF353535)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      collapsedIconColor: const Color(0xFF949187),
                      iconColor: const Color(0xFFE1C19F),
                      title: Text(archive.routineDayName.toUpperCase(), style: const TextStyle(color: Color(0xFFFEF8E5), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Color(0xFF949187)),
                            const SizedBox(width: 6),
                            Text(dateString, style: const TextStyle(color: Color(0xFF949187), fontSize: 12)),
                            const Spacer(),
                            const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF949187)),
                            const SizedBox(width: 4),
                            Text(durationStr, style: const TextStyle(color: Color(0xFF949187), fontSize: 12)),
                          ],
                        ),
                      ),
                      children: [
                        const Divider(color: Color(0xFF353535), height: 1),
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF181818),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("VOLUME: ${archive.session.volumeGenerated?.toInt() ?? 0} KGS", style: const TextStyle(color: Color(0xFFE1C19F), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              const SizedBox(height: 16),
                              ...archive.exercises.map((ex) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ex.exerciseName, style: const TextStyle(color: Color(0xFFCAC6BB), fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      ...ex.sets.asMap().entries.map((entry) {
                                        final setIdx = entry.key + 1;
                                        final log = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 60, child: Text("Set $setIdx", style: const TextStyle(color: Color(0xFF5E462B), fontSize: 12))),
                                              Text("${log.weight.toInt()} kg  ×  ${log.reps}", style: const TextStyle(color: Color(0xFF949187), fontSize: 14)),
                                              if (log.setTag != 'N') ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                  decoration: BoxDecoration(color: const Color(0xFF412D15), borderRadius: BorderRadius.circular(4)),
                                                  child: Text(log.setTag, style: const TextStyle(color: Color(0xFFE1C19F), fontSize: 10, fontWeight: FontWeight.bold)),
                                                )
                                              ]
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 64), 
        ],
      ),
    );
  }
}
