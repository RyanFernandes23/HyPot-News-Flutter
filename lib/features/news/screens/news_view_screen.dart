import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../core/providers/navigation_provider.dart';

class NewsViewScreen extends ConsumerStatefulWidget {
  final String topic;
  final bool isTab;

  const NewsViewScreen({super.key, required this.topic, this.isTab = false});

  @override
  ConsumerState<NewsViewScreen> createState() => _NewsViewScreenState();
}

class _NewsViewScreenState extends ConsumerState<NewsViewScreen> {
  late PageController _horizontalController;
  late ScrollController _navbarScrollController;
  late String _currentTopic;
  late List<GlobalKey> _topicKeys;
  bool _isScrollingVertical = false;

  final List<String> _topics = [
    'For You', 'International', 'Finance', 'Healthcare', 'Good News', 
    'Technology', 'Sports', 'Entertainment', 'Science', 'Business', 
    'Travel', 'Lifestyle'
  ];

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.topic;
    final initialIndex = _topics.indexOf(_currentTopic);
    _horizontalController = PageController(initialPage: initialIndex != -1 ? initialIndex : 0);
    _navbarScrollController = ScrollController();
    _topicKeys = List.generate(_topics.length, (index) => GlobalKey());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialIndex != -1) {
        _scrollToCategory(initialIndex);
      }
    });
  }

  void _scrollToCategory(int index) {
    if (index < 0 || index >= _topicKeys.length) return;
    
    final keyContext = _topicKeys[index].currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _navbarScrollController.dispose();
    super.dispose();
  }

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
    ref.listen<NavigationState>(navigationProvider, (previous, next) {
      if (next.selectedTopic != null && next.selectedTopic != _currentTopic) {
        final index = _topics.indexOf(next.selectedTopic!);
        if (index != -1) {
          _horizontalController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentTopic = next.selectedTopic!;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToCategory(index);
          });
        }
      }
    });

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          PageView.builder(
            controller: _horizontalController,
            physics: _isScrollingVertical 
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentTopic = _topics[index];
              });
              _scrollToCategory(index); 
            },
            itemCount: _topics.length,
            itemBuilder: (context, categoryIndex) {
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification && notification.metrics.axis == Axis.vertical) {
                    if (!_isScrollingVertical) {
                      setState(() => _isScrollingVertical = true);
                    }
                  } else if (notification is ScrollEndNotification && notification.metrics.axis == Axis.vertical) {
                    if (_isScrollingVertical) {
                      setState(() => _isScrollingVertical = false);
                    }
                  }
                  return false;
                },
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _dummyArticles.length,
                  itemBuilder: (context, articleIndex) {
                    final article = _dummyArticles[articleIndex];
                    return NewsArticlePage(article: article);
                  },
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.7),
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.onSurface.withOpacity(0.05),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      controller: _navbarScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: _topics.map((topic) {
                          final isSelected = topic == _currentTopic;
                          final index = _topics.indexOf(topic);
                          return GestureDetector(
                            key: _topicKeys[index], 
                            onTap: () {
                              _horizontalController.animateToPage(
                                index, 
                                duration: const Duration(milliseconds: 300), 
                                curve: Curves.easeInOut,
                              );
                              setState(() {
                                _currentTopic = topic;
                              });
                              _scrollToCategory(index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 20), 
                              color: Colors.transparent, 
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      color: isSelected 
                                          ? colorScheme.primary 
                                          : colorScheme.onSurface.withOpacity(0.4),
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                    child: Text(topic), 
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 2,
                                    width: isSelected ? 16 : 0,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!widget.isTab)
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
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

class NewsArticlePage extends StatefulWidget {
  final Map<String, String> article;

  const NewsArticlePage({super.key, required this.article});

  @override
  State<NewsArticlePage> createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends State<NewsArticlePage> {
  bool _isPlaying = false;
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 90),
        Expanded(
          flex: 2,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              widget.article['imageUrl']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Stack(
            clipBehavior: Clip.none, 
            children: [
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        widget.article['headline']!,
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.article['summary']!,
                        style: TextStyle(
                          fontSize: 14, 
                          color: colorScheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.onSurface.withOpacity(0.05),
                              ),
                            ),
                            child: Text(
                              widget.article['source']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // PLAY BUTTON (Matched to bookmark size)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isPlaying = !_isPlaying;
                                });
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black, // Sleek black
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 20, // Increased to 24 for matching
                                  color: Colors.white, // White icon
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // BOOKMARK BUTTON
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isBookmarked = !_isBookmarked;
                                });
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black, // Sleek black
                                ),
                                child: Icon(
                                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                  size: 20, 
                                  color: Colors.white, // White icon
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
