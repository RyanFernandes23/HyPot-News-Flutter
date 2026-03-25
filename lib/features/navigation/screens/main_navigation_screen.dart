import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/screens/home_screen.dart';
import '../../news/screens/news_view_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../news/screens/daily_briefing_screen.dart';
import '../../news/providers/daily_briefing_provider.dart';
import '../../news/models/article.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final List<Widget> screens = [
      const NewsViewScreen(topic: 'For You', isTab: true),
      const HomeScreen(),
      const Scaffold(body: Center(child: Text('Daily Briefing Tab'))), // Placeholder if tab
      const SearchScreen(),
      const ProfileScreen(isTab: true),
    ];

    // Ensure selectedIndex is within bounds after removing a tab
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
                  // Direct to Daily Briefing logic - maybe show screen or just switch
                  // For now, let's trigger the briefing logic or navigate
                  final dummyArticles = [
                    const Article(
                      category: 'Finance',
                      headline: 'Global Markets Surge Amid New Policies',
                      summary: 'Major stock indices around the world saw significant gains today.',
                      source: 'Finance Times',
                      imageUrl: 'https://images.unsplash.com/photo-1611974714658-ff3d286121fe?q=80&w=1000',
                      url: 'https://www.ft.com',
                      highlights: [
                        'Stock indices saw significant gains globally.',
                        'Central banks announced major stimulus packages.',
                        'Consumer confidence reached a 3-year high.',
                        'Unemployment rates dropped in primary markets.',
                        'Tech sector leading the recovery with 12% growth.',
                        'Commodity prices stabilized after recent volatility.',
                        'New trade agreements reached in Southeast Asia.',
                        'Investment in green energy tripled this quarter.'
                      ],
                    ),
                    const Article(
                      category: 'Tech',
                      headline: 'Breakthrough in Battery Tech',
                      summary: 'Scientists unveiled a new solid-state battery.',
                      source: 'Tech Daily',
                      imageUrl: 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?q=80&w=1000',
                      url: 'https://www.techcrunch.com',
                      highlights: ['Solid-state battery stores 3x more energy.', 'Accelerates EV transition.'],
                    ),
                    const Article(
                      category: 'Science',
                      headline: 'Mars Rover Finds Ancient Water Signs',
                      summary: 'Perseverance rover has discovered evidence of persistent water flow.',
                      source: 'Science Journal',
                      imageUrl: 'https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?q=80&w=1000',
                      url: 'https://www.nature.com',
                      highlights: ['Evidence of ancient river delta found.', 'Supports theory of habitable past.'],
                    ),
                    const Article(
                      category: 'Tech',
                      headline: 'AI Model Achieves Human-Level Coding',
                      summary: 'A new large language model matches top engineers in logic tasks.',
                      source: 'AI Insider',
                      imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?q=80&w=1000',
                      url: 'https://www.openai.com',
                      highlights: ['Model solves 90% of complex test cases.', 'Ethics board raises automation concerns.'],
                    ),
                    const Article(
                      category: 'Sports',
                      headline: 'Championship Finals: Underdog Victory',
                      summary: 'The city celebrated as the local team won their first title.',
                      source: 'Sports News',
                      imageUrl: 'https://images.unsplash.com/photo-1504450758481-7338eba7524a?q=80&w=1000',
                      url: 'https://www.espn.com',
                      highlights: ['Victory secured in the final 10 seconds.', 'Record-breaking viewership numbers.'],
                    ),
                    const Article(
                      category: 'Wellness',
                      headline: '10 Minutes of Zonal Presence',
                      summary: 'Researchers find that brief mindfulness sessions boost creativity.',
                      source: 'Wellness Weekly',
                      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1000',
                      url: 'https://www.healthline.com',
                      highlights: ['Alpha waves increase after 10 min session.', 'Creative problem solving improved by 30%.'],
                    ),
                  ];
                  ref.read(dailyBriefingProvider.notifier).startBriefing(dummyArticles);
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
