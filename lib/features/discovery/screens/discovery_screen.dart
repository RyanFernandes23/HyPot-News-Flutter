import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../news/screens/daily_briefing_screen.dart';
import '../../news/providers/daily_briefing_provider.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  final List<Map<String, dynamic>> _topics = const [
    {
      'name': 'For You',
      'color': Color(0xFFFF4D4D),
      'icon': Icons.local_fire_department
    },
    {'name': 'International', 'color': Color(0xFF4D7CFF), 'icon': Icons.public},
    {
      'name': 'Finance',
      'color': Color(0xFF4DBC8C),
      'icon': Icons.account_balance_wallet
    },
    {
      'name': 'Healthcare',
      'color': Color(0xFF8C4DFF),
      'icon': Icons.medical_services
    },
    {
      'name': 'Good News',
      'color': Color(0xFFFFB34D),
      'icon': Icons.sentiment_satisfied_alt
    },
    {'name': 'Technology', 'color': Color(0xFF4D4D4D), 'icon': Icons.science},
    {
      'name': 'Sports',
      'color': Color(0xFF4DB3FF),
      'icon': Icons.sports_basketball
    },
    {'name': 'Entertainment', 'color': Color(0xFFFF4DB3), 'icon': Icons.movie},
    {'name': 'Science', 'color': Color(0xFFB3FF4D), 'icon': Icons.biotech},
    {'name': 'Business', 'color': Color(0xFFFF8C4D), 'icon': Icons.business},
    {'name': 'Travel', 'color': Color(0xFF4DFFB3), 'icon': Icons.flight},
    {'name': 'Lifestyle', 'color': Color(0xFFFF4D8C), 'icon': Icons.style},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search news, topics...',
                    hintStyle: TextStyle(color: colorScheme.secondary),
                    prefixIcon:
                        Icon(Icons.search, color: colorScheme.secondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).appBarTheme.systemOverlayStyle ??
            (Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
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
                ..._buildTopicRows(ref),
                const SizedBox(height: 32),
                Text(
                  'Trending Topics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTrendingChip(context, '#Technology'),
                    _buildTrendingChip(context, '#GlobalEconomy'),
                    _buildTrendingChip(context, '#AIRevolution'),
                    _buildTrendingChip(context, '#SpaceX'),
                    _buildTrendingChip(context, '#ClimateAction'),
                    _buildTrendingChip(context, '#HealthyLiving'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTopicRows(WidgetRef ref) {
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
                      ref
                          .read(navigationProvider.notifier)
                          .setTopic(topic['name'] as String);
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

    return rows;
  }

  Widget _buildTrendingChip(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Chip(
      label: Text(label),
      backgroundColor: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.03),
      labelStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
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
        final state = ref.read(dailyBriefingProvider);
        if (!state.isActive || state.isFinished) {
          // Restart only if there isn't an active briefing session running
          ref.read(dailyBriefingProvider.notifier).startBriefingFromBackend();
        }
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
            image: const NetworkImage(
                'https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=1000'),
            fit: BoxFit.cover,
            colorFilter:
                const ColorFilter.mode(Colors.black45, BlendMode.darken),
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
