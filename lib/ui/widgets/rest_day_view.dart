import 'package:flutter/material.dart';

class RestDayView extends StatelessWidget {
  const RestDayView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.bedtime, color: Color(0xFF412D15), size: 80),
          SizedBox(height: 24),
          Text("REST DAY", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFEF8E5), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          SizedBox(height: 12),
          Text("No exercises scheduled for today's sequence.\nEnjoy the recovery, or add exercises via the Routine tab.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF949187), fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}
