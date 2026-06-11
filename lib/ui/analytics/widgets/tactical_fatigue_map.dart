import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_body_heatmap/flutter_body_heatmap.dart';
import '../../../core/state/history_state.dart';

class TacticalFatigueMap extends ConsumerStatefulWidget {
  const TacticalFatigueMap({super.key});

  @override
  ConsumerState<TacticalFatigueMap> createState() => _TacticalFatigueMapState();
}

class _TacticalFatigueMapState extends ConsumerState<TacticalFatigueMap> {
  BodyGender _selectedGender = BodyGender.male;

  void _toggleGender() {
    setState(() {
      _selectedGender = _selectedGender == BodyGender.male ? BodyGender.female : BodyGender.male;
    });
  }

  @override
  Widget build(BuildContext context) {
    final heatmapAsync = ref.watch(heatmapDataProvider);

    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "LOCALIZED FATIGUE MAP",
                style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              // The Gender Toggle Button!
              InkWell(
                onTap: _toggleGender,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _selectedGender == BodyGender.male ? Icons.male : Icons.female, 
                    color: const Color(0xFF949187), 
                    size: 20
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: heatmapAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
              error: (err, _) => Center(child: Text("Error loading body map: $err", style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
              data: (heatmapData) {
                if (heatmapData.isEmpty) {
                  return const Center(
                    child: Text("NO RECENT MUSCLE FATIGUE\nLog workouts to populate map data.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF949187), fontSize: 11, height: 1.5)),
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: BodyHeatmap(
                        side: BodySide.front,
                        gender: _selectedGender, // Uses dynamic state
                        data: heatmapData,
                        bodyColor: const Color(0xFF131313),
                        borderColor: const Color(0xFF353535),
                        colors: const [Color(0xFFE1C19F), Color(0xFF93000a)],
                      ),
                    ),
                    Expanded(
                      child: BodyHeatmap(
                        side: BodySide.back,
                        gender: _selectedGender,
                        data: heatmapData,
                        bodyColor: const Color(0xFF131313),
                        borderColor: const Color(0xFF353535),
                        colors: const [Color(0xFFE1C19F), Color(0xFF93000a)],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF93000a), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text("High Fatigue", style: TextStyle(color: Color(0xFF949187), fontSize: 10)),
              const SizedBox(width: 12),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE1C19F), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text("Recovering", style: TextStyle(color: Color(0xFF949187), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
