import 'package:flutter/material.dart';

class NewsViewScreen extends StatefulWidget {
  final String topic;

  const NewsViewScreen({super.key, required this.topic});

  @override
  State<NewsViewScreen> createState() => _NewsViewScreenState();
}

class _NewsViewScreenState extends State<NewsViewScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> _dummyArticles = [
    {
      'headline': 'Global Markets Surge Amid New Economic Policies',
      'summary': 'Major stock indices around the world saw significant gains today as investors reacted positively to the latest round of economic stimulus measures announced by central banks. Analysts suggest this could be the start of a long-term recovery trend for international trade.',
      'source': 'Finance Times • 2h ago',
      'imageUrl': 'https://images.unsplash.com/photo-1611974714658-ff3d286121fe?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'headline': 'Breakthrough in Renewable Energy Storage Technology',
      'summary': 'Scientists have unveiled a new type of solid-state battery that can store three times as much energy as current lithium-ion models. This breakthrough is expected to accelerate the transition to electric vehicles and improve the efficiency of solar power grids.',
      'source': 'Tech Daily • 5h ago',
      'imageUrl': 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'headline': 'New Study Reveals Surprising Benefits of Mindful Living',
      'summary': 'A comprehensive 10-year study involving thousands of participants has found that just 10 minutes of daily mindfulness practice can significantly lower stress levels and improve cardiovascular health. The findings are being hailed as a major milestone in preventive medicine.',
      'source': 'Health Watch • 8h ago',
      'imageUrl': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1000&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: _dummyArticles.length,
            itemBuilder: (context, index) {
              final article = _dummyArticles[index];
              return NewsArticlePage(article: article);
            },
          ),
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsArticlePage extends StatelessWidget {
  final Map<String, String> article;

  const NewsArticlePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Media Section
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
              decoration: BoxDecoration(
                color: Colors.black, // Background for letterboxing
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Center(
                    child: Image.network(
                      article['imageUrl']!,
                      fit: BoxFit.contain, // Keep aspect ratio
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Minimal overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content Section
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['headline']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article['summary']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4F566B),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Source component
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article['source']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF697386),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
