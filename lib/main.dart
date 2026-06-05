// Location: C:\Development\batak\lib\main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:batak/core/database/app_database.dart';
import 'package:batak/core/ai/ai_swapper_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  final aiService = container.read(aiSwapperProvider);
  await aiService.initialize();

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

class DashboardPlaceholder extends ConsumerWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiService = ref.read(aiSwapperProvider);
    
    final recommendations = aiService.getAlternatives('leg_press');

    return Scaffold(
      appBar: AppBar(title: const Text('Batak Tactical Gym')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Leg Press is taken.", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            const Text("AI Suggested Alternatives:", style: TextStyle(color: Color(0xFF00ADB5))),
            const SizedBox(height: 10),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${rec.exercise.name} (Match: ${(rec.matchScore * 100).toStringAsFixed(1)}%)",
                style: const TextStyle(fontSize: 18),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
