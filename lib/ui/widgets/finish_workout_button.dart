import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/workout_state.dart';
import '../../core/database/set_logs_repository.dart';
import '../../core/loop/loop_engine.dart';
import '../routine/routine_screen.dart';

class FinishWorkoutButton extends ConsumerWidget {
  const FinishWorkoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          final engine = ref.read(loopEngineProvider);
          final repo = ref.read(setLogsRepositoryProvider);
          
          final routine = await engine.getActiveRoutine();
          if (routine == null) return;
          final template = await engine.getTodayTemplate(routine);
          if (template == null) return;

          final sessionId = await repo.finalizeSession(template.id);

          if (!context.mounted) return; 

          if (sessionId == -1) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No completed sets to save! Please check off at least one set.')));
             return;
          }

          await engine.completeTodaySequence(routine);

          ref.read(bypassSameDayWorkoutProvider.notifier).state = false;
          ref.read(activeSessionProvider.notifier).clearSession();
          
          ref.invalidate(routineDataProvider);
          ref.invalidate(workoutSessionLoaderProvider);

          if (!context.mounted) return;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1F1F1F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF412D15))),
              title: const Text("🔥 Workout Complete", style: TextStyle(color: Color(0xFFE1C19F), fontWeight: FontWeight.bold)),
              content: const Text("Session securely archived.\nYour routine sequence has advanced.", style: TextStyle(color: Color(0xFFFEF8E5), height: 1.5)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("DONE", style: TextStyle(color: Color(0xFFE1DCC9), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                )
              ]
            )
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE1DCC9),
          foregroundColor: const Color(0xFF1D1C10),
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, size: 24),
            SizedBox(width: 12),
            Text("FINISH WORKOUT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
          ],
        ),
      ),
    );
  }
}
