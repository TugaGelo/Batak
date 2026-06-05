import 'package:flutter/material.dart';
import 'widgets/exercise_card.dart';
import 'widgets/floating_rest_timer.dart';

class WorkoutFloorScreen extends StatelessWidget {
  const WorkoutFloorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: const [
            Center(
              child: Text(
                "DAY 1: HEAVY PUSH",
                style: TextStyle(
                  color: Color(0xFFE1C19F),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                "Tactical Push/Pull/Legs",
                style: TextStyle(
                  color: Color(0xFFFEF8E5),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 32),
            
            ExerciseCard(),
            
            SizedBox(height: 100),
          ],
        ),

        const FloatingRestTimer(),
      ],
    );
  }
}
