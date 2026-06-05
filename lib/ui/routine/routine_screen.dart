import 'package:flutter/material.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree, size: 64, color: Color(0xFF49473F)),
          SizedBox(height: 16),
          Text(
            'Routine Loop Canvas',
            style: TextStyle(color: Color(0xFF49473F), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
