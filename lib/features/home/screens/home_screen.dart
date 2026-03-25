import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../news/screens/daily_briefing_screen.dart';
import '../../news/providers/daily_briefing_provider.dart';
import '../../news/models/article.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> _topics = const [
    {'name': 'For You', 'color': Color(0xFFFF4D4D), 'icon': Icons.local_fire_department},
    {'name': 'International', 'color': Color(0xFF4D7CFF), 'icon': Icons.public},
    {'name': 'Finance', 'color': Color(0xFF4DBC8C), 'icon': Icons.account_balance_wallet},
    {'name': 'Healthcare', 'color': Color(0xFF8C4DFF), 'icon': Icons.medical_services},
    {'name': 'Good News', 'color': Color(0xFFFFB34D), 'icon': Icons.sentiment_satisfied_alt},
    {'name': 'Technology', 'color': Color(0xFF4D4D4D), 'icon': Icons.science},
    {'name': 'Sports', 'color': Color(0xFF4DB3FF), 'icon': Icons.sports_basketball},
    {'name': 'Entertainment', 'color': Color(0xFFFF4DB3), 'icon': Icons.movie},
    {'name': 'Science', 'color': Color(0xFFB3FF4D), 'icon': Icons.biotech},
    {'name': 'Business', 'color': Color(0xFFFF8C4D), 'icon': Icons.business},
    {'name': 'Travel', 'color': Color(0xFF4DFFB3), 'icon': Icons.flight},
    {'name': 'Lifestyle', 'color': Color(0xFFFF4D8C), 'icon': Icons.style},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate the rows based on the 2-3-2-3 pattern
    List<Widget> rows = [];
    int index = 0;
    bool isTwo = true;

    while (index < _topics.length) {
      int count = isTwo ? 2 : 3;
      double cardHeight = isTwo ? 250.0 : 180.0;
      List<Map<String, dynamic>> chunk = [];
      for (int i = 0; i < count && index < _topics.length; i++) {
        chunk.add(_topics[index]);
        index++;
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: chunk.map((topic) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      // Switch to News Feed tab (index 0) and set the topic
                      ref.read(navigationProvider.notifier).setTopic(topic['name'] as String);
                    },
                    child: TopicCard(topic: topic, height: cardHeight),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );

      isTwo = !isTwo;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).appBarTheme.systemOverlayStyle ?? 
               (Theme.of(context).brightness == Brightness.dark 
                 ? SystemUiOverlayStyle.light 
                 : SystemUiOverlayStyle.dark),
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const DailyBriefingHero(),
            const SizedBox(height: 24),
            ...rows,
          ],
        ),
      ),
    ),
  ),
);
}
}

class TopicCard extends StatelessWidget {
  final Map<String, dynamic> topic;
  final double height;

  const TopicCard({super.key, required this.topic, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: topic['color'] as Color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (topic['color'] as Color).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (topic['color'] as Color).withOpacity(0.8),
            topic['color'] as Color,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              topic['icon'] as IconData,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  topic['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  topic['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class DailyBriefingHero extends ConsumerWidget {
  const DailyBriefingHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        // Start briefing logic
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
      },
      child: Container(
        height: 180,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: const NetworkImage('https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=1000'),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
            onError: (exception, stackTrace) => print('Hero image load failed'),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'CURATED FOR YOU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your Daily Briefing',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'A 5-10 minute session of top stories.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
