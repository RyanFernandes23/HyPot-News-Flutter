import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../../../services/news_service.dart';
import '../providers/bookmark_sync_provider.dart';
import '../../../core/providers/audio_provider.dart';

class DailyBriefingState {
  final bool isActive;
  final List<Article> sessionArticles;
  final int currentArticleIndex;
  final Duration remainingTime;
  final bool isTransitioning;
  final String? nextCategory;
  final bool isLoadingMore;
  final bool hasMore;
  final int totalOffset;
  final Set<String> bookmarkedIds;
  final bool isFinished; // All briefings done — show "That's all"

  DailyBriefingState({
    this.isActive = false,
    this.sessionArticles = const [],
    this.currentArticleIndex = 0,
    this.remainingTime = Duration.zero,
    this.isTransitioning = false,
    this.nextCategory,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.totalOffset = 0,
    this.bookmarkedIds = const {},
    this.isFinished = false,
  });

  DailyBriefingState copyWith({
    bool? isActive,
    List<Article>? sessionArticles,
    int? currentArticleIndex,
    Duration? remainingTime,
    bool? isTransitioning,
    String? nextCategory,
    bool? isLoadingMore,
    bool? hasMore,
    int? totalOffset,
    Set<String>? bookmarkedIds,
    bool? isFinished,
  }) {
    return DailyBriefingState(
      isActive: isActive ?? this.isActive,
      sessionArticles: sessionArticles ?? this.sessionArticles,
      currentArticleIndex: currentArticleIndex ?? this.currentArticleIndex,
      remainingTime: remainingTime ?? this.remainingTime,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      nextCategory: nextCategory ?? this.nextCategory,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      totalOffset: totalOffset ?? this.totalOffset,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class DailyBriefingNotifier extends StateNotifier<DailyBriefingState> {
  Timer? _sessionTimer;
  final Ref _ref;
  final NewsService _newsService = NewsService();
  static const int _chunkSize = 5;

  DailyBriefingNotifier(this._ref) : super(DailyBriefingState());

  /// Start briefing by loading the first chunk from the backend.
  Future<void> startBriefingFromBackend() async {
    _sessionTimer?.cancel();
    state = DailyBriefingState(isActive: true, isLoadingMore: true);

    try {
      // 1. Fetch briefing articles
      final data = await _newsService.fetchBriefing(
        limit: _chunkSize,
        offset: 0,
      );
      final articlesList = (data['articles'] as List);
      final articles = <Article>[];
      
      for (final json in articlesList) {
        try {
          articles.add(Article.fromJson(json as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Error parsing briefing article: $e');
          // Skip malformed articles
        }
      }
      final playableArticles = articles.where(_isPlayableArticle).toList();

      // 2. Fetch current bookmarks to initialize state
      final Map<String, dynamic> bookmarksData = await _newsService.fetchBookmarks();
      final List bookmarkJsonList = (bookmarksData['articles'] as List? ?? []);
      final bookmarkIds = <String>{};
      
      for (final json in bookmarkJsonList) {
        try {
          final art = Article.fromJson(json as Map<String, dynamic>);
          final id = art.id ?? art.externalId ?? art.url;
          bookmarkIds.add(id);
        } catch (e) {
          debugPrint('Error parsing bookmark: $e');
        }
      }

      state = DailyBriefingState(
        isActive: true,
        sessionArticles: playableArticles,
        currentArticleIndex: 0,
        hasMore: playableArticles.length >= _chunkSize,
        totalOffset: articles.length,
        bookmarkedIds: bookmarkIds,
        isLoadingMore: false,
      );

      // Start playing the first article automatically
      if (playableArticles.isNotEmpty) {
        _ref.read(audioProvider.notifier).playArticle(playableArticles[0]);
      }
    } catch (e) {
      state = DailyBriefingState(isActive: false);
    }
  }

  /// Legacy: start with pre-loaded articles (for fallback/testing).
  void startBriefing(List<Article> articles) {
    _sessionTimer?.cancel();
    state = DailyBriefingState(
      isActive: true,
      sessionArticles: articles,
      currentArticleIndex: 0,
      hasMore: false,
    );
  }

  void stopBriefing() {
    _sessionTimer?.cancel();
    state = state.copyWith(isActive: false, isFinished: true);
  }

  void nextArticle() {
    if (state.currentArticleIndex < state.sessionArticles.length - 1) {
      goToArticle(state.currentArticleIndex + 1);
    } else if (!state.hasMore) {
      // All articles consumed — mark as finished
      stopBriefing();
    }
  }

  void previousArticle() {
    if (state.currentArticleIndex > 0) {
      goToArticle(state.currentArticleIndex - 1);
    }
  }

  void goToArticle(int newIndex) {
    if (newIndex >= 0 && newIndex < state.sessionArticles.length) {
      state = state.copyWith(currentArticleIndex: newIndex);

      // Trigger audio playback for the new article
      _ref.read(audioProvider.notifier).playArticle(state.sessionArticles[newIndex]);

      // Mark as read
      _markCurrentAsRead(newIndex);

      // Prefetch when near the end (k-2 threshold)
      if (state.hasMore &&
          !state.isLoadingMore &&
          newIndex >= state.sessionArticles.length - 2) {
        _fetchMoreArticles();
      }
    }
  }

  /// Fetch the next chunk of briefing articles.
  Future<void> _fetchMoreArticles() async {
    if (state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final data = await _newsService.fetchBriefing(
        limit: _chunkSize,
        offset: state.totalOffset,
      );

      final newArticles = (data['articles'] as List)
          .map((json) => Article.fromJson(json))
          .where(_isPlayableArticle)
          .toList();

      if (newArticles.isEmpty) {
        state = state.copyWith(hasMore: false, isLoadingMore: false);
        return;
      }

      state = state.copyWith(
        sessionArticles: [...state.sessionArticles, ...newArticles],
        totalOffset: state.totalOffset + newArticles.length,
        hasMore: newArticles.length >= _chunkSize,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  bool _isPlayableArticle(Article article) {
    if (article.audioStatus != 'ready') return false;
    return (article.headlineHlsBaseUrl?.isNotEmpty ?? false) ||
        (article.summaryHlsBaseUrl?.isNotEmpty ?? false) ||
        (article.audioUrl?.isNotEmpty ?? false);
  }

  /// Mark an article as read on the backend.
  void _markCurrentAsRead(int index) {
    final article = state.sessionArticles[index];
    final externalId = article.externalId ?? article.id;
    if (externalId != null) {
      _newsService.markAsRead(externalId).catchError((_) {});
    }
  }

  /// Toggle bookmark for an article using the robust sync provider.
  Future<void> toggleBookmark(Article article) async {
    final articleId = article.id ?? article.externalId ?? '';
    final isCurrentlyBookmarked = state.bookmarkedIds.contains(articleId);
    
    // 1. Optimistic UI update in the briefing state
    final newBookmarks = Set<String>.from(state.bookmarkedIds);
    if (isCurrentlyBookmarked) {
      newBookmarks.remove(articleId);
    } else {
      newBookmarks.add(articleId);
    }
    state = state.copyWith(bookmarkedIds: newBookmarks);

    // 2. Delegate to the robust sync provider (handles outbox, retries, etc.)
    await _ref.read(bookmarkSyncProvider.notifier).toggleBookmark(
      article, 
      isCurrentlyBookmarked, // Passing the OLD state to determine the toggle action
    );
  }

  Future<void> triggerTransition(String category) async {
    state = state.copyWith(
      isTransitioning: true,
      nextCategory: category,
    );
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isTransitioning: false);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}

final dailyBriefingProvider =
    StateNotifierProvider<DailyBriefingNotifier, DailyBriefingState>((ref) {
  return DailyBriefingNotifier(ref);
});
