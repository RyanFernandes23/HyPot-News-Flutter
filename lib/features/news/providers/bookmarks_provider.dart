import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../../../services/news_service.dart';
import 'bookmark_sync_provider.dart';

final bookmarksProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final newsService = NewsService();
  // We refresh this provider whenever a bookmark is toggled or synced
  final syncState = ref.watch(bookmarkSyncProvider); 
  
  try {
    final response = await newsService.fetchBookmarks();
    final List<dynamic> articlesJson = response['articles'] ?? [];
    var articles = articlesJson.map((json) => Article.fromJson(json)).toList();

    // Optimistic UI for the list:
    // 1. Remove articles that are pending deletion
    articles = articles.where((a) {
      final id = a.id ?? a.externalId ?? a.url;
      return !syncState.pendingRemoves.contains(id);
    }).toList();

    // 2. Add articles that are pending addition (if not already present from backend)
    final existingIds = articles.map((a) => a.id ?? a.externalId ?? a.url).toSet();
    for (final pending in syncState.pendingAddArticles.values) {
      final pid = pending.id ?? pending.externalId ?? pending.url;
      if (!existingIds.contains(pid)) {
        // Add pending ones to the top for immediate feedback
        articles.insert(0, pending);
      }
    }

    return articles;
  } catch (e) {
    // In case of error (e.g. offline), at least show the pending bookmarks from the outbox
    return syncState.pendingAddArticles.values.toList();
  }
});
