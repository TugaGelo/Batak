import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/workout_state.dart';

class SetLogRow extends ConsumerWidget {
  final int index;
  final ActiveSet activeSet;

  const SetLogRow({super.key, required this.index, required this.activeSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerSeconds = ref.watch(restTimerProvider);
    final isTimerRunning = timerSeconds > 0;

    final isCheckmarkDisabled = activeSet.isCompleted || 
                                activeSet.weight == null || 
                                activeSet.reps == null || 
                                (!activeSet.isCompleted && isTimerRunning);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              "${index + 1}",
              style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                enabled: !activeSet.isCompleted,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: activeSet.isCompleted ? const Color(0xFF949187) : const Color(0xFFFEF8E5),
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  hintText: "--",
                  hintStyle: TextStyle(color: Color(0xFF412D15)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF412D15))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFEF8E5))),
                  disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                ),
                onChanged: (val) => ref.read(activeSessionProvider.notifier).updateSet(index, weight: double.tryParse(val)),
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                enabled: !activeSet.isCompleted,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: activeSet.isCompleted ? const Color(0xFF949187) : const Color(0xFFFEF8E5),
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  hintText: "--",
                  hintStyle: TextStyle(color: Color(0xFF412D15)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF412D15))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFEF8E5))),
                  disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                ),
                onChanged: (val) => ref.read(activeSessionProvider.notifier).updateSet(index, reps: int.tryParse(val)),
              ),
            ),
          ),
          
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(
                activeSet.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                color: activeSet.isCompleted ? const Color(0xFFE1C19F) : const Color(0xFF949187),
              ),
              onPressed: isCheckmarkDisabled
                  ? null
                  : () {
                      ref.read(activeSessionProvider.notifier).completeSet(index);
                      ref.read(restTimerProvider.notifier).startTimer(90);
                    },
            ),
          ),
        ],
      ),
    );
  }
}
