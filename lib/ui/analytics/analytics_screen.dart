import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights, size: 64, color: Color(0xFF49473F)),
          SizedBox(height: 16),
          Text(
            'Analytics Canvas',
            style: TextStyle(color: Color(0xFF49473F), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
