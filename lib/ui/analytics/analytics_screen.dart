import 'package:flutter/material.dart';
import 'widgets/kpi_cards.dart';
import 'widgets/volume_chart_card.dart';
import 'widgets/heatmap_anchor_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: const [
          Text(
            "TRAINING INTELLIGENCE",
            style: TextStyle(
              color: Color(0xFFFEF8E5), 
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Comprehensive breakdown of your physiological load and performance metrics over time.",
            style: TextStyle(
              color: Color(0xFFCAC6BB), 
              fontSize: 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),

          Row(
            children: [
              Expanded(child: VolumeKpiCard()),
              SizedBox(width: 16),
              Expanded(child: StreakKpiCard()),
            ],
          ),
          SizedBox(height: 32),

          VolumeChartCard(),
          SizedBox(height: 32),

          HeatmapAnchorCard(),
          SizedBox(height: 64), 
        ],
      ),
    );
  }
}
