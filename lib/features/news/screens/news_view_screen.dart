import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../core/providers/navigation_provider.dart';
import '../models/article.dart';
import '../providers/daily_briefing_provider.dart';
import '../widgets/category_transition_overlay.dart';
import '../../../services/news_service.dart';
import '../widgets/news_article_page.dart';
import '../widgets/news_article_shimmer.dart';
import '../../search/screens/search_screen.dart';

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

  final NewsService _newsService = NewsService();

  // Per-category article cache
  final Map<String, List<Article>> _categoryArticles = {};
  final Map<String, String?> _categoryCursors = {};
  final Map<String, bool> _categoryLoading = {};
  final Map<String, bool> _categoryHasMore = {};
  final Map<String, bool> _categoryHasShownAllCaughtUp = {};

  // Deduplication tracking to prevent same article in multiple categories
  final Set<String> _shownArticleIds = {};
  final Set<String> _forYouArticleIds = {};

  final List<String> _topics = [
    'For You',
    'International',
    'Finance',
    'Startups',
    'Technology',
  ];

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.topic;
    final initialIndex = _topics.indexOf(_currentTopic);
    _horizontalController =
        PageController(initialPage: initialIndex != -1 ? initialIndex : 0);
    _navbarScrollController = ScrollController();
    _topicKeys = List.generate(_topics.length, (index) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialIndex != -1) {
        _scrollToCategory(initialIndex);
      }
      _loadCategoryIfNeeded(_currentTopic);
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

  Future<void> _loadCategoryIfNeeded(String category,
      {bool forceRefresh = false}) async {
    if (_categoryArticles.containsKey(category) && !forceRefresh) return;

    // For 'For You' category, load all articles (no exclusions)
    // For other categories, exclude articles already shown in 'For You' to prevent duplicates
    if (category == 'For You') {
      await _fetchLiveNews(category);
    } else {
      await _fetchLiveNews(category, excludeIds: _forYouArticleIds);
    }
  }

  Future<void> _fetchLiveNews(String category,
      {bool loadMore = false, Set<String>? excludeIds}) async {
    if (_categoryLoading[category] == true) return;

    setState(() => _categoryLoading[category] = true);

    try {
      final data = await _newsService.fetchLiveNews(
        category: category,
        limit: 15,
        before: loadMore ? _categoryCursors[category] : null,
      );

      final articles = (data['articles'] as List? ?? const [])
          .whereType<Map>()
          .map((json) => Article.fromJson(Map<String, dynamic>.from(json)))
          .where((article) {
        final id = article.id ?? article.externalId ?? article.url;
        if (id == null || id.isEmpty) {
          return true; // Include articles without ID (safer fallback)
        }
        return !(excludeIds?.contains(id) ?? false);
      }).toList();

      setState(() {
        if (loadMore) {
          _categoryArticles[category] = [
            ...(_categoryArticles[category] ?? []),
            ...articles
          ];
        } else {
          _categoryArticles[category] = articles;
        }
        _categoryCursors[category] = data['next_cursor'] as String?;
        _categoryHasMore[category] =
            articles.isNotEmpty && data['next_cursor'] != null;
        _categoryHasShownAllCaughtUp[category] = false;
        _categoryLoading[category] = false;

        // Track shown articles for deduplication
        for (final article in articles) {
          final id = article.id ?? article.externalId ?? article.url;
          if (id != null && id.isNotEmpty) {
            _shownArticleIds.add(id);
            if (category == 'For You') {
              _forYouArticleIds.add(id);
            }
          }
        }
      });
    } catch (e) {
      setState(() => _categoryLoading[category] = false);
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _navbarScrollController.dispose();
    super.dispose();
  }

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
          _loadCategoryIfNeeded(next.selectedTopic!);
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
              _loadCategoryIfNeeded(_topics[index]);
            },
            itemCount: _topics.length,
            itemBuilder: (context, categoryIndex) {
              final category = _topics[categoryIndex];
              final articles = _categoryArticles[category] ?? [];
              final isLoading = _categoryLoading[category] == true;

              if (articles.isEmpty && isLoading) {
                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 3,
                  itemBuilder: (context, index) => const NewsArticleShimmer(),
                );
              }

              if (articles.isEmpty && !isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 48, color: colorScheme.secondary),
                      const SizedBox(height: 16),
                      Text(
                        'No stories in $category',
                        style: TextStyle(
                            color: colorScheme.secondary, fontSize: 15),
                      ),
                    ],
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification &&
                      notification.metrics.axis == Axis.vertical) {
                    if (!_isScrollingVertical) {
                      setState(() => _isScrollingVertical = true);
                    }
                  } else if (notification is ScrollEndNotification &&
                      notification.metrics.axis == Axis.vertical) {
                    if (_isScrollingVertical) {
                      setState(() => _isScrollingVertical = false);
                    }
                  } else if (notification is OverscrollNotification &&
                      notification.metrics.axis == Axis.vertical &&
                      notification.overscroll > 0) {
                    // Bottom overscroll - user pulled past the end of content
                    if (!_categoryHasMore[category]! &&
                        !_categoryHasShownAllCaughtUp[category]!) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You\'re all caught up')),
                      );
                      setState(() {
                        _categoryHasShownAllCaughtUp[category] = true;
                      });
                    }
                  }
                  return false;
                },
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: articles.length,
                  onPageChanged: (articleIndex) {
                    // Mark as read
                    final article = articles[articleIndex];
                    if (article.externalId != null) {
                      _newsService
                          .markAsRead(article.externalId!)
                          .catchError((_) {});
                    }

                    // Prefetch more when near end
                    if (_categoryHasMore[category] == true &&
                        articleIndex >= articles.length - 3) {
                      _fetchLiveNews(category, loadMore: true);
                    }
                  },
                  itemBuilder: (context, articleIndex) {
                    final article = articles[articleIndex];
                    return NewsArticlePage(
                      article: article,
                      onNext: () {
                        if (articleIndex >= articles.length - 1) {
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
          // ── Category Navbar Overlay ─────────────────────────────────
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
                    child: Row(
                      children: [
                        // ── Fading Scrollable Categories ──────────────────────
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black,
                                  Colors.black.withOpacity(0.0),
                                  Colors.black.withOpacity(0.0),
                                  Colors.black,
                                ],
                                stops: const [0.0, 0.05, 0.95, 1.0],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstOut,
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
                                      _loadCategoryIfNeeded(topic);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 25),
                                      color: Colors.transparent,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 200),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? (Theme.of(context).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black)
                                                  : colorScheme.onSurface
                                                      .withOpacity(0.4),
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
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
                                              color: Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
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
                        // ── Sticky Search Button ─────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SearchScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.search_rounded,
                                  size: 22, color: colorScheme.primary),
                            ),
                          ),
                        ),
                      ],
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
              if (briefingState.isTransitioning &&
                  briefingState.nextCategory != null) {
                return CategoryTransitionOverlay(
                    categoryName: briefingState.nextCategory!);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

// End of NewsViewScreen
