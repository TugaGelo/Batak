import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/workout_state.dart';

class SetLogRow extends ConsumerWidget {
  final int exerciseIndex;
  final int setIndex;
  final ActiveSet activeSet;

  const SetLogRow({super.key, required this.exerciseIndex, required this.setIndex, required this.activeSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerSeconds = ref.watch(restTimerProvider);
    final isTimerRunning = timerSeconds > 0;

    final hasWeightInput = activeSet.weight != null || activeSet.previousWeight != null;
    final hasRepsInput = activeSet.reps != null || activeSet.previousReps != null;
    final isCheckmarkDisabled = !activeSet.isCompleted && (!hasWeightInput || !hasRepsInput || isTimerRunning);

    final weightController = TextEditingController(text: activeSet.weight != null ? (activeSet.weight == activeSet.weight!.toInt() ? activeSet.weight!.toInt().toString() : activeSet.weight.toString()) : "");
    final repsController = TextEditingController(text: activeSet.reps != null ? activeSet.reps.toString() : "");

    weightController.selection = TextSelection.fromPosition(TextPosition(offset: weightController.text.length));
    repsController.selection = TextSelection.fromPosition(TextPosition(offset: repsController.text.length));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text("${setIndex + 1}", style: const TextStyle(color: Color(0xFFFEF8E5), fontSize: 16, fontWeight: FontWeight.bold))),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: weightController,
                enabled: !activeSet.isCompleted,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                textAlign: TextAlign.center,
                style: TextStyle(color: activeSet.isCompleted ? const Color(0xFF949187) : const Color(0xFFFEF8E5), fontSize: 18),
                decoration: InputDecoration(
                  hintText: activeSet.previousWeight != null ? "${activeSet.previousWeight}" : "--",
                  hintStyle: const TextStyle(color: Color(0xFF5E462B)), 
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF412D15))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFEF8E5))),
                  disabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                ),
                onChanged: (val) => ref.read(activeSessionProvider.notifier).updateSetInputs(exerciseIndex, setIndex, weight: double.tryParse(val)),
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: repsController,
                enabled: !activeSet.isCompleted,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: TextStyle(color: activeSet.isCompleted ? const Color(0xFF949187) : const Color(0xFFFEF8E5), fontSize: 18),
                decoration: InputDecoration(
                  hintText: activeSet.previousReps != null ? "${activeSet.previousReps}" : "--",
                  hintStyle: const TextStyle(color: Color(0xFF5E462B)), 
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF412D15))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFEF8E5))),
                  disabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                ),
                onChanged: (val) => ref.read(activeSessionProvider.notifier).updateSetInputs(exerciseIndex, setIndex, reps: int.tryParse(val)),
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
                  : () async {
                      final wasCompleted = activeSet.isCompleted;
                      await ref.read(activeSessionProvider.notifier).toggleSetLogging(exerciseIndex, setIndex);
                      if (!wasCompleted) {
                        ref.read(restTimerProvider.notifier).startTimer(90);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
