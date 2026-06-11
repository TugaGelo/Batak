import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/state/history_state.dart';

class VolumeRadarCard extends ConsumerWidget {
  const VolumeRadarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radarAsync = ref.watch(volumeRadarProvider);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "INTENSITY RADAR",
            style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: radarAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
              error: (err, _) => const Center(child: Text("Error loading radar", style: TextStyle(color: Colors.redAccent))),
              data: (volumeMap) {
                final safeMap = volumeMap.isEmpty 
                    ? {'Chest': 0.0, 'Shoulders': 0.0, 'Arms': 0.0, 'Glutes': 0.0, 'Legs': 0.0, 'Back': 0.0, 'Core': 0.0} 
                    : volumeMap;

                double maxVol = 100.0;
                for (var v in safeMap.values) {
                  if (v > maxVol) maxVol = v;
                }

                final axisTitles = ['Chest', 'Shoulders', 'Arms', 'Glutes', 'Legs', 'Back', 'Core'];

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFFE1DCC9).withOpacity(0.05), blurRadius: 40, spreadRadius: 10)],
                      ),
                    ),
                    RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        tickCount: 3,
                        ticksTextStyle: const TextStyle(color: Colors.transparent), // Hide numbers
                        gridBorderData: const BorderSide(color: Color(0xFF353535), width: 1),
                        tickBorderData: const BorderSide(color: Color(0xFF353535), width: 1),
                        borderData: FlBorderData(show: false),
                        titlePositionPercentageOffset: 0.15,
                        getTitle: (index, angle) {
                          return RadarChartTitle(
                            text: axisTitles[index],
                            angle: 0,
                          );
                        },
                        titleTextStyle: const TextStyle(color: Color(0xFF949187), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        dataSets: [
                          RadarDataSet(
                            fillColor: const Color(0xFFE1C19F).withOpacity(0.2),
                            borderColor: const Color(0xFFE1C19F),
                            borderWidth: 2,
                            entryRadius: 3,
                            dataEntries: axisTitles.map((title) {
                              return RadarEntry(value: safeMap[title] ?? 0.0);
                            }).toList(),
                          ),
                        ],
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 600),
                      swapAnimationCurve: Curves.easeOutQuart,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
