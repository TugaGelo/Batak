import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../workout_floor.dart';
import '../routine/routine_screen.dart';
import '../analytics/analytics_screen.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

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
          RoutineScreen(),
          AnalyticsScreen(),
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
