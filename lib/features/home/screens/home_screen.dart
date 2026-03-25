import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/navigation_provider.dart';

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
