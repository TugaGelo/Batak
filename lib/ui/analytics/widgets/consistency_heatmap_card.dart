import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/history_state.dart';

class ConsistencyHeatmapCard extends ConsumerWidget {
  const ConsistencyHeatmapCard({super.key});

  Color _getCellColor(int setsCompleted) {
    if (setsCompleted == 0) return const Color(0xFF353535);
    if (setsCompleted <= 5) return const Color(0xFF5B452B);
    if (setsCompleted <= 12) return const Color(0xFFE1C19F).withOpacity(0.6);
    return const Color(0xFFE1C19F);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(consistencyHeatmapProvider);

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("CONSISTENCY", style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Text("LAST 28 DAYS", style: TextStyle(color: Color(0xFFE1C19F), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            ],
          ),
          const Spacer(),
          heatmapAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
            error: (err, _) => const Center(child: Text("Data Error", style: TextStyle(color: Colors.redAccent))),
            data: (dayCounts) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              
              final List<DateTime> last28Days = List.generate(28, (index) {
                return today.subtract(Duration(days: 27 - index));
              });

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: 28,
                itemBuilder: (context, index) {
                  final cellDate = last28Days[index];
                  final setsCompleted = dayCounts[cellDate] ?? 0;
                  final isToday = index == 27;

                  return Container(
                    decoration: BoxDecoration(
                      color: _getCellColor(setsCompleted),
                      borderRadius: BorderRadius.circular(4),
                      border: isToday ? Border.all(color: const Color(0xFFFEF8E5), width: 1.5) : null,
                      boxShadow: setsCompleted > 12 
                          ? [const BoxShadow(color: Color(0x66E1C19F), blurRadius: 4, spreadRadius: 0)] 
                          : null,
                    ),
                  );
                },
              );
            },
          ),
          const Spacer(),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Rest", style: TextStyle(color: Color(0xFF949187), fontSize: 10)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF353535), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF5B452B), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFE1C19F).withOpacity(0.6), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFE1C19F), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              const Text("Max", style: TextStyle(color: Color(0xFF949187), fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}
