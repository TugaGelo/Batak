import 'package:flutter/material.dart';

class VolumeChartCard extends StatelessWidget {
  const VolumeChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF353535)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "VOLUME PROGRESSION",
                style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              Icon(Icons.more_horiz, color: Color(0xFFCAC6BB), size: 20),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar("W1", 40, false),
              _buildBar("W2", 70, false),
              _buildBar("W3", 50, false),
              _buildBar("W4", 120, true),
              _buildBar("W5", 90, false),
              _buildBar("W6", 30, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFEF8E5) : const Color(0xFFE1C19F),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            boxShadow: isActive
                ? [const BoxShadow(color: Color(0x33FEF8E5), blurRadius: 8, spreadRadius: 2)]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFFEF8E5) : const Color(0xFFCAC6BB),
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
