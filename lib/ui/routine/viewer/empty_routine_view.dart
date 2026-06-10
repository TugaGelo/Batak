import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routine_screen.dart';

class EmptyRoutineView extends ConsumerWidget {
  const EmptyRoutineView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF353535)),
            ),
            child: const Icon(Icons.edit_calendar, size: 32, color: Color(0xFFCAC6BB)),
          ),
          const SizedBox(height: 24),
          const Text(
            "NO ACTIVE SEQUENCE", 
            style: TextStyle(fontFamily: 'Epilogue', color: Color(0xFFFEF8E5), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "You haven't assigned a training loop yet. Build a new profile to begin tracking.", 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Color(0xFF949187), fontSize: 14)
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(editingRoutineTargetProvider.notifier).state = null; 
              ref.read(isComposingProvider.notifier).state = true; 
            },
            icon: const Icon(Icons.add, color: Color(0xFFE1C19F)),
            label: const Text("BUILD NEW PROFILE", style: TextStyle(color: Color(0xFFE1C19F), fontWeight: FontWeight.bold, letterSpacing: 1)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF49473F)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }
}
