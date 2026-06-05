import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:batak/core/ai/ai_swapper_service.dart';
import 'package:batak/core/loop/loop_engine.dart';
import 'package:batak/ui/workout_floor.dart';

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

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

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

class BatakShell extends ConsumerStatefulWidget {
  const BatakShell({super.key});

  @override
  ConsumerState<BatakShell> createState() => _BatakShellState();
}

class _BatakShellState extends ConsumerState<BatakShell> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(bottomNavIndexProvider));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BATAK'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        children: const [
          WorkoutFloorScreen(),
          RoutinePlaceholder(),
          AnalyticsPlaceholder(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF353535), width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
            
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.fitness_center),
              ),
              label: 'Workout Floor',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.sync),
              ),
              label: 'My Routine',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.bar_chart),
              ),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutFloorPlaceholder extends StatelessWidget {
  const WorkoutFloorPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_view, size: 64, color: Color(0xFF49473F)),
          SizedBox(height: 16),
          Text(
            'Workout Floor Canvas',
            style: TextStyle(color: Color(0xFF49473F), fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            '← Swipe left or right to change panels →',
            style: TextStyle(color: Color(0xFF49473F), fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class RoutinePlaceholder extends StatelessWidget {
  const RoutinePlaceholder({super.key});

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

class AnalyticsPlaceholder extends StatelessWidget {
  const AnalyticsPlaceholder({super.key});

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
