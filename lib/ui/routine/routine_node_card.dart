import 'package:flutter/material.dart';

enum NodeStatus { completed, current, upcoming }

class RoutineNodeCard extends StatelessWidget {
  final int dayNumber;
  final String templateName;
  final NodeStatus status;
  final VoidCallback? onBegin;

  const RoutineNodeCard({
    super.key,
    required this.dayNumber,
    required this.templateName,
    required this.status,
    this.onBegin,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = status == NodeStatus.current;
    final bool isCompleted = status == NodeStatus.completed;

    final double cardWidth = isCurrent ? 224.0 : 192.0;
    final double cardHeight = isCurrent ? 288.0 : 256.0;
    
    final double contentOpacity = status == NodeStatus.upcoming ? 0.4 : 1.0;

    final Color borderColor = isCurrent ? const Color(0xFFE1C19F) : Colors.transparent;
    final String statusLabel = isCurrent ? "CURRENT FOCUS" : (isCompleted ? "COMPLETED" : "UPCOMING");
    final Color statusLabelColor = isCurrent ? const Color(0xFFE1C19F) : const Color(0xFFCAC6BB);
    final Color dayTitleColor = isCurrent ? const Color(0xFFFEF8E5) : const Color(0xFFE2E2E2);

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: isCurrent ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.5),
            blurRadius: isCurrent ? 32 : 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Opacity(
        opacity: contentOpacity,
        child: Stack(
          children: [
            if (isCurrent)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1C19F).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(100)),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusLabel, style: TextStyle(color: statusLabelColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text("Day $dayNumber", style: TextStyle(color: dayTitleColor, fontSize: isCurrent ? 28 : 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(templateName, style: TextStyle(color: isCurrent ? const Color(0xFFE1DCC9) : const Color(0xFFCAC6BB), fontSize: 16)),
                    ],
                  ),

                  if (isCurrent)
                    ElevatedButton(
                      onPressed: onBegin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B452B),
                        foregroundColor: const Color(0xFFFEF8E5),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("BEGIN", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF131313),
                        shape: BoxShape.circle,
                        border: isCompleted ? null : Border.all(color: const Color(0xFF353535)),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle : Icons.lock,
                        color: isCompleted ? const Color(0xFFCAC6BB) : const Color(0xFF353535),
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
