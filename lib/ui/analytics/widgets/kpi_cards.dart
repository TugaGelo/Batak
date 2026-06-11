import 'package:flutter/material.dart';

class VolumeKpiCard extends StatelessWidget {
  const VolumeKpiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353535)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE1C19F).withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "7-DAY VOLUME",
                style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("24,500", style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1.0)),
                  SizedBox(width: 8),
                  Text("KGS", style: TextStyle(color: Color(0xFFCAC6BB), fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B452B).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Color(0xFFE1C19F), size: 16),
                    SizedBox(width: 8),
                    Text("+12% vs last week", style: TextStyle(color: Color(0xFFE1C19F), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
