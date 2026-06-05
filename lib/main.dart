import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:batak/core/ai/ai_swapper_service.dart';
import 'package:batak/core/loop/loop_engine.dart';
import 'package:batak/core/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  
  final aiService = container.read(aiSwapperProvider);
  await aiService.initialize();

  final loopEngine = container.read(loopEngineProvider);
  await loopEngine.seedDummyRoutineIfEmpty();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BatakApp(),
    ),
  );
}

class BatakApp extends StatelessWidget {
  const BatakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batak',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF303841), 
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00ADB5), 
          surface: Color(0xFF3A4750),
        ),
      ),
      home: const DashboardPlaceholder(),
    );
  }
}

class DashboardPlaceholder extends ConsumerStatefulWidget {
  const DashboardPlaceholder({super.key});

  @override
  ConsumerState<DashboardPlaceholder> createState() => _DashboardPlaceholderState();
}

class _DashboardPlaceholderState extends ConsumerState<DashboardPlaceholder> {
  Routine? _activeRoutine;
  WorkoutTemplate? _todayTemplate;

  @override
  void initState() {
    super.initState();
    _loadCurrentSequence();
  }

  Future<void> _loadCurrentSequence() async {
    final engine = ref.read(loopEngineProvider);
    final routine = await engine.getActiveRoutine();
    
    if (routine != null) {
      final template = await engine.getTodayTemplate(routine);
      setState(() {
        _activeRoutine = routine;
        _todayTemplate = template;
      });
    }
  }

  Future<void> _advanceLoop() async {
    final engine = ref.read(loopEngineProvider);
    if (_activeRoutine != null) {
      await engine.completeTodaySequence(_activeRoutine!);
      await _loadCurrentSequence();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiService = ref.read(aiSwapperProvider);
    final recommendations = aiService.getAlternatives('leg_press');

    return Scaffold(
      appBar: AppBar(title: const Text('Batak Master Logic Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("UNIVERSAL LOOP ENGINE", style: TextStyle(color: Colors.grey, letterSpacing: 2)),
            const SizedBox(height: 10),
            Text(
              _activeRoutine?.name ?? "Loading...",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Current Position: Day ${_activeRoutine?.currentSequenceIndex ?? 0}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              "Today's Workout: ${_todayTemplate?.name ?? "Loading..."}",
              style: const TextStyle(fontSize: 20, color: Color(0xFF00ADB5)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _advanceLoop,
              icon: const Icon(Icons.check_circle),
              label: const Text("SIMULATE FINISHING WORKOUT"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ADB5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
              ),
            ),

            const SizedBox(height: 40),
            const Divider(color: Colors.grey, endIndent: 40, indent: 40),
            const SizedBox(height: 40),

            const Text("AI BIOMECHANICAL SWAPPER", style: TextStyle(color: Colors.grey, letterSpacing: 2)),
            const SizedBox(height: 10),
            const Text("Leg Press is taken.", style: TextStyle(fontSize: 18)),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "${rec.exercise.name} (${(rec.matchScore * 100).toStringAsFixed(1)}%)",
                style: const TextStyle(fontSize: 16),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
