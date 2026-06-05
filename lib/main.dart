import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:batak/core/ai/ai_swapper_service.dart';
import 'package:batak/core/loop/loop_engine.dart';
import 'package:batak/ui/shell/app_shell.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF131313),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF131313),
          primary: Color(0xFFFEF8E5),
          secondary: Color(0xFFE1C19F),
          onSurface: Color(0xFFE2E2E2),
          onSurfaceVariant: Color(0xFFCAC6BB), 
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF131313),
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 4.8, 
            color: Color(0xFFFEF8E5),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF131313),
          selectedItemColor: Color(0xFFFEF8E5),
          unselectedItemColor: Color(0xFFCAC6BB),
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: const BatakShell(),
    );
  }
}
