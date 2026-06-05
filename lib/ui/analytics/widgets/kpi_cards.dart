import 'package:flutter/material.dart';

class VolumeKpiCard extends StatelessWidget {
  const VolumeKpiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "WEEKLY VOLUME",
            style: TextStyle(color: Color(0xFFE1C19F), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "14,250",
                style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4),
              Text(
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

class StreakKpiCard extends StatelessWidget {
  const StreakKpiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "CONSISTENCY STREAK",
            style: TextStyle(color: Color(0xFFE1C19F), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("🔥", style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                "4",
                style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4),
              Text(
                "WEEKS",
                style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
