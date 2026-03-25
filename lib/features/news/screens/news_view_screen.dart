import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../core/providers/navigation_provider.dart';
import '../models/article.dart';
import '../providers/daily_briefing_provider.dart';
import '../widgets/category_transition_overlay.dart';

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
      'category': 'Finance',
      'headline': 'Global Markets Surge Amid New Policies',
      'summary': 'Major stock indices around the world saw significant gains today.',
      'source': 'Finance Times',
      'imageUrl': 'https://images.unsplash.com/photo-1611974714658-ff3d286121fe?q=80&w=1000',
      'url': 'https://www.ft.com',
    },
    {
      'category': 'Tech',
      'headline': 'Breakthrough in Battery Tech',
      'summary': 'Scientists unveiled a new solid-state battery.',
      'source': 'Tech Daily',
      'imageUrl': 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?q=80&w=1000',
      'url': 'https://www.techcrunch.com',
    },
    {
      'category': 'Science',
      'headline': 'Mars Rover Finds Ancient Water Signs',
      'summary': 'Perseverance rover has discovered evidence of persistent water flow.',
      'source': 'Science Journal',
      'imageUrl': 'https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?q=80&w=1000',
      'url': 'https://www.nature.com',
    },
    {
      'category': 'Tech',
      'headline': 'AI Model Achieves Human-Level Coding',
      'summary': 'A new large language model matches top engineers in logic tasks.',
      'source': 'AI Insider',
      'imageUrl': 'https://images.unsplash.com/photo-1677442136019-21780ecad995?q=80&w=1000',
      'url': 'https://www.openai.com',
    },
    {
      'category': 'Sports',
      'headline': 'Championship Finals: Underdog Victory',
      'summary': 'The city celebrated as the local team won their first title.',
      'source': 'Sports News',
      'imageUrl': 'https://images.unsplash.com/photo-1504450758481-7338eba7524a?q=80&w=1000',
      'url': 'https://www.espn.com',
    },
    {
      'category': 'Wellness',
      'headline': '10 Minutes of Zonal Presence',
      'summary': 'Researchers find that brief mindfulness sessions boost creativity.',
      'source': 'Wellness Weekly',
      'imageUrl': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1000',
      'url': 'https://www.healthline.com',
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
                    final articleMap = _dummyArticles[articleIndex];
                    final article = Article.fromMap(articleMap);
                    return NewsArticlePage(
                      article: article,
                      onNext: () {
                        if (articleIndex < _dummyArticles.length - 1) {
                          // Scroll to next article in same category
                        } else {
                          // Transition to next category
                          final nextIndex = categoryIndex + 1;
                          if (nextIndex < _topics.length) {
                            _horizontalController.animateToPage(
                              nextIndex,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      },
                    );
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
                                          ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
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
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
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
          Consumer(
            builder: (context, ref, child) {
              final briefingState = ref.watch(dailyBriefingProvider);
              if (briefingState.isTransitioning && briefingState.nextCategory != null) {
                return CategoryTransitionOverlay(categoryName: briefingState.nextCategory!);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class NewsArticlePage extends ConsumerStatefulWidget {
  final Article article;
  final VoidCallback? onNext;

  const NewsArticlePage({super.key, required this.article, this.onNext});

  @override
  ConsumerState<NewsArticlePage> createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends ConsumerState<NewsArticlePage> {
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
              widget.article.imageUrl,
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTap: () {
                      // Skip Category
                      ref.read(navigationProvider.notifier).setTopic(null); 
                    },
                    onLongPress: () {
                      // Save to read later gesture
                      setState(() => _isBookmarked = !_isBookmarked);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isBookmarked ? 'Saved to Read Later' : 'Removed from Saved'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            widget.article.headline,
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
                            widget.article.summary,
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
                                  widget.article.source,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              const Spacer(),
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
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.05),
                                    ),
                                    child: Icon(
                                      _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                      size: 20, 
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}
