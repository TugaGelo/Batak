import 'package:flutter/material.dart';
import 'widgets/kpi_cards.dart';
import 'widgets/consistency_heatmap_card.dart';
import 'widgets/volume_radar_card.dart';
import 'widgets/tactical_fatigue_map.dart';
import 'widgets/session_archive_list.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313), 
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: const [
          Row(
            children: [
              Expanded(child: VolumeKpiCard()),
            ],
          ),
          SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: VolumeRadarCard(), 
              ),
              SizedBox(width: 16),
              Expanded(
                child: ConsistencyHeatmapCard(),
              ),
            ],
          ),
          SizedBox(height: 20),

          TacticalFatigueMap(),
          SizedBox(height: 48),

          Text(
            "SESSION ARCHIVE", 
            style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)
          ),
          SizedBox(height: 16),

          SessionArchiveList(),
          
          SizedBox(height: 64), 
        ],
      ),
    );
  }
}
