import 'package:flutter/material.dart';

class IconMapper {
  static IconData getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'barbell':
      case 'ez barbell':
      case 'olympic barbell':
        return Icons.line_weight;
      case 'dumbbell':
        return Icons.fitness_center;
      case 'cable':
      case 'rope':
        return Icons.linear_scale;
      case 'body weight':
        return Icons.accessibility_new;
      case 'leverage machine':
      case 'smith machine':
      case 'sled machine':
        return Icons.precision_manufacturing;
      case 'band':
      case 'resistance band':
        return Icons.all_inclusive;
      case 'kettlebell':
        return Icons.monitor_weight; 
      default:
        return Icons.build_circle_outlined;
    }
  }

  static IconData getMuscleIcon(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'chest':
        return Icons.shield_outlined;
      case 'back':
        return Icons.width_wide;
      case 'shoulders':
        return Icons.change_history;
      case 'upper arms':
      case 'lower arms':
        return Icons.fitness_center;
      case 'upper legs':
      case 'lower legs':
        return Icons.directions_run;
      case 'waist':
      case 'cardio':
        return Icons.monitor_heart;
      default:
        return Icons.accessibility;
    }
  }
}
