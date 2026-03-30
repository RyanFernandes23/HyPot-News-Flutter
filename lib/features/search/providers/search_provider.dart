import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/news_service.dart';
import '../../news/models/article.dart';

class SearchState {
  final String query;
  final AsyncValue<List<Article>> results;
  final List<String> history;

  SearchState({
    this.query = '',
    this.results = const AsyncValue.data([]),
    this.history = const [],
  });

  SearchState copyWith({
    String? query,
    AsyncValue<List<Article>>? results,
    List<String>? history,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      history: history ?? this.history,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final NewsService _newsService = NewsService();
  Timer? _debounceTimer;

  SearchNotifier() : super(SearchState());

  void updateQuery(String query) {
    if (state.query == query) return;
    
    state = state.copyWith(query: query);

    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      state = state.copyWith(results: const AsyncValue.data([]));
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(results: const AsyncValue.loading());

    try {
      final response = await _newsService.searchNews(query);
      final List<dynamic> articlesJson = response['articles'] ?? [];
      
      final articles = articlesJson.map((json) {
        // Map RSS search results (enriched with descriptor_source) to Article model
        return Article(
          externalId: (json['id'] ?? json['link'])?.toString(),
          category: 'Search',
          headline: json['title']?.toString() ?? '',
          summary: json['summary']?.toString() ?? '',
          summarizedContent: json['summary']?.toString() ?? '',
          source: json['descriptor_source']?.toString() ?? 
                  (json['source'] is Map ? json['source']['title'] : json['source'])?.toString() ?? 
                  'RSS',
          imageUrl: _extractImageUrl(json),
          url: json['link']?.toString() ?? '',
        );
      }).toList();

      state = state.copyWith(results: AsyncValue.data(articles));
      
      // Add to history if successful and not already there
      if (articles.isNotEmpty && !state.history.contains(query)) {
        final newHistory = [query, ...state.history].take(10).toList();
        state = state.copyWith(history: newHistory);
      }
    } catch (e, st) {
      state = state.copyWith(results: AsyncValue.error(e, st));
    }
  }

  String _extractImageUrl(dynamic json) {
    if (json is! Map) return '';
    
    // Logic from news_view_screen.dart
    final mediaContent = json['media_content'];
    if (mediaContent is List && mediaContent.isNotEmpty) {
      final media = mediaContent[0];
      if (media is Map && media['url'] != null) return media['url'].toString();
    } else if (mediaContent is Map) {
      return mediaContent['url']?.toString() ?? '';
    }

    final summary = json['summary']?.toString() ?? '';
    if (summary.contains('<img')) {
      final match = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(summary);
      if (match != null && match.groupCount >= 1) {
        return match.group(1) ?? '';
      }
    }
    return '';
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(query: '', results: const AsyncValue.data([]));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
