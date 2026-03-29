import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/screens/home_screen.dart';
import '../../news/screens/news_view_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../news/screens/daily_briefing_screen.dart';
import '../../news/providers/daily_briefing_provider.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final List<Widget> screens = [
      const NewsViewScreen(topic: 'For You', isTab: true),
      const HomeScreen(),
      const Scaffold(body: Center(child: Text('Daily Briefing Tab'))),
      const SearchScreen(),
      const ProfileScreen(isTab: true),
    ];

    final selectedIndex = navigationState.selectedIndex >= screens.length
        ? screens.length - 1
        : navigationState.selectedIndex;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: selectedIndex,
            children: screens,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                if (index == 2) {
                  // Start briefing from backend
                  ref.read(dailyBriefingProvider.notifier).startBriefingFromBackend();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DailyBriefingScreen()),
                  );
                } else {
                  ref.read(navigationProvider.notifier).setIndex(index);
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: colorScheme.brightness == Brightness.dark ? Colors.white : Colors.black,
              unselectedItemColor: colorScheme.secondary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.article_outlined),
                  activeIcon: Icon(Icons.article),
                  label: 'Feed',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  activeIcon: Icon(Icons.grid_view_rounded),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_rounded),
                  activeIcon: Icon(Icons.auto_awesome_rounded),
                  label: 'Briefing',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  activeIcon: Icon(Icons.search_rounded),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
