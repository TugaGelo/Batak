import 'package:flutter/material.dart';

class HeatmapAnchorCard extends StatelessWidget {
  const HeatmapAnchorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.accessibility_new, size: 80, color: Color(0xFF353535)),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 8,
                height: 8,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE1C19F)),
              ),
              SizedBox(width: 12),
              Text(
                "3D MUSCLE HEATMAP INITIALIZING...",
                style: TextStyle(
                  color: Color(0xFFE1C19F),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
