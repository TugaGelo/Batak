import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_body_heatmap/flutter_body_heatmap.dart';
import '../../../core/state/history_state.dart';

final heatmapGenderProvider = StateProvider<BodyGender>((ref) => BodyGender.male);

class HeatmapAnchorCard extends ConsumerWidget {
  const HeatmapAnchorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(heatmapDataProvider);
    final currentGender = ref.watch(heatmapGenderProvider);

    return Container(
      height: 420, 
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "7-DAY FATIGUE MAP",
                style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  currentGender == BodyGender.male ? Icons.male : Icons.female, 
                  color: const Color(0xFFE1C19F), 
                  size: 20
                ),
                onPressed: () {
                  ref.read(heatmapGenderProvider.notifier).state = 
                    currentGender == BodyGender.male ? BodyGender.female : BodyGender.male;
                },
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: heatmapAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
              error: (err, stack) => const Center(child: Text("Error loading telemetry stream.", style: TextStyle(color: Colors.redAccent))),
              data: (muscleData) {
                if (muscleData.isEmpty) {
                  return const Center(
                    child: Text(
                      "ALL PHYSIOLOGICAL SYSTEMS RESTED\nLog completed sets to illuminate fatigue maps.", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(color: Color(0xFF949187), fontSize: 13, height: 1.5)
                    ),
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: BodyHeatmap(
                        side: BodySide.front,
                        gender: currentGender,
                        data: muscleData,
                        colors: const [Color(0xFF353535), Color(0xFFE1C19F), Color(0xFFFEF8E5)],
                        bodyColor: const Color(0xFF131313),
                        borderColor: const Color(0xFF353535),
                      ),
                    ),
                    Expanded(
                      child: BodyHeatmap(
                        side: BodySide.back,
                        gender: currentGender,
                        data: muscleData,
                        colors: const [Color(0xFF353535), Color(0xFFE1C19F), Color(0xFFFEF8E5)],
                        bodyColor: const Color(0xFF131313),
                        borderColor: const Color(0xFF353535),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
