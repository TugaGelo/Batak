import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/state/history_state.dart';

class SessionArchiveList extends ConsumerWidget {
  const SessionArchiveList({super.key});

  Widget _buildTagBadge(String tag) {
    if (tag == 'W') return const _TagBadge(label: "WARMUP", bgColor: Color(0xFF353535), textColor: Color(0xFFCAC6BB));
    if (tag == 'F') return const _TagBadge(label: "FAILURE", bgColor: Color(0xFF93000A), textColor: Color(0xFFFFB4AB));
    if (tag == 'D') return const _TagBadge(label: "DROP SET", bgColor: Color(0xFF5B452B), textColor: Color(0xFFE1C19F));
    return const SizedBox.shrink(); 
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyTimelineProvider);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE1C19F))),
      error: (err, stack) => Center(child: Text("Error loading archive: $err", style: const TextStyle(color: Colors.redAccent))),
      data: (sessions) {
        if (sessions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Text(
                "NO SESSIONS ARCHIVED YET",
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
            final dateString = DateFormat('MMM dd, yyyy').format(archive.session.startTime);
            
            String durationStr = "--m";
            if (archive.session.endTime != null) {
              final diff = archive.session.endTime!.difference(archive.session.startTime);
              durationStr = "${diff.inMinutes}m";
            }

            final volumeFmt = NumberFormat('#,###').format(archive.session.volumeGenerated?.toInt() ?? 0);

            return Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  border: Border.all(color: const Color(0xFF353535)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  iconColor: const Color(0xFFCAC6BB),
                  collapsedIconColor: const Color(0xFFCAC6BB),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        archive.routineDayName.toUpperCase(), 
                        style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: Color(0xFF949187)),
                          const SizedBox(width: 4),
                          Text(dateString, style: const TextStyle(color: Color(0xFF949187), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF949187)),
                      const SizedBox(width: 4),
                      Text(durationStr, style: const TextStyle(color: Color(0xFF949187), fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF5B452B), borderRadius: BorderRadius.circular(4)),
                        child: Text("$volumeFmt KGS", style: const TextStyle(color: Color(0xFFE1C19F), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.expand_more, size: 20),
                    ],
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF181818),
                        border: Border(top: BorderSide(color: Color(0xFF353535))),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: archive.exercises.map((ex) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex.exerciseName, style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 12),
                                ...ex.sets.asMap().entries.map((entry) {
                                  final setIdx = entry.key + 1;
                                  final log = entry.value;
                                  
                                  return Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    decoration: BoxDecoration(
                                      // FIXED: Replaced .withOpacity with explicit ARGB hex to satisfy strict const rules
                                      border: setIdx > 1 ? const Border(top: BorderSide(color: Color(0x80353535))) : null,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 60, child: Text("Set $setIdx", style: const TextStyle(color: Color(0xFF949187), fontSize: 12))),
                                        Expanded(
                                          child: Center(
                                            child: Text("${log.weight.toInt()} kg  ×  ${log.reps}", style: const TextStyle(color: Color(0xFFE2E2E2), fontSize: 13)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80, 
                                          child: Align(
                                            alignment: Alignment.centerRight, 
                                            child: _buildTagBadge(log.setTag),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _TagBadge({required this.label, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}
