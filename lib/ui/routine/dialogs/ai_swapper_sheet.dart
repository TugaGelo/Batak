import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/ai/ai_swapper_service.dart';
import '../../../core/state/workout_state.dart';
import 'exercise_sheet_row.dart';

class AiSwapperSheet extends ConsumerWidget {
  final int exerciseIndex;
  final Exercise currentExercise;

  const AiSwapperSheet({
    super.key,
    required this.exerciseIndex,
    required this.currentExercise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiSwapper = ref.watch(aiSwapperProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF353535))),
      ),
      child: Column(
        children: [
          // Drag Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(width: 48, height: 6, decoration: BoxDecoration(color: const Color(0xFF353535), borderRadius: BorderRadius.circular(4))),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AI ALTERNATIVES ENGINE",
                      style: TextStyle(color: Color(0xFFE1C19F), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Station Occupied: ${currentExercise.name.toTitleCase()}",
                      style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFCAC6BB)),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(color: Color(0xFF262626)),

          Expanded(
            child: FutureBuilder<List<SwapperRecommendation>>(
              future: aiSwapper.getAlternatives(currentExercise),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F)));
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No biomechanical variations found matching target.", style: TextStyle(color: Color(0xFFCAC6BB))),
                  );
                }

                final alternatives = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: alternatives.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final recommendation = alternatives[index];
                    final ex = recommendation.exercise;
                    final matchPercentage = (recommendation.matchScore * 100).toInt();

                    return InkWell(
                      onTap: () {
                        ref.read(activeSessionProvider.notifier).executeAiSwap(
                          exerciseIndex,
                          ex,
                          (oldWeight) => aiSwapper.calculateNewTargetWeight(
                            oldWeight,
                            currentExercise.equipment,
                            ex.equipment,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1F1F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF353535)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name.toTitleCase(),
                                    style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${ex.equipment.toUpperCase()}  •  ${recommendation.translationNote}",
                                    style: const TextStyle(color: Color(0xFFCAC6BB), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Match Accuracy Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131313),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF412D15)),
                              ),
                              child: Text(
                                "$matchPercentage% MATCH",
                                style: const TextStyle(color: Color(0xFFE1C19F), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
