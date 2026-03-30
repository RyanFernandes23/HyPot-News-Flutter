import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import 'bookmark_sync_provider.dart';
import 'raw_bookmarks_provider.dart';

/// The optimistic bookmarks provider that combines backend data with local pending syncs.

/// The optimistic bookmarks provider that combines backend data with local pending syncs.
/// Watching this provider will NOT trigger a backend fetch when a local bookmark is toggled.
final bookmarksProvider = Provider<AsyncValue<List<Article>>>((ref) {
  final rawAsync = ref.watch(rawBookmarksProvider);
  final syncState = ref.watch(bookmarkSyncProvider);

  return rawAsync.whenData((articles) {
    var result = List<Article>.from(articles);
    final hiddenIds = {
      ...syncState.pendingRemoves,
      ...syncState.activeRemoveTombstones,
    };

    // 1. Remove articles that are pending deletion
    result = result.where((a) {
      final ids = _articleIdentifiers(a);
      return ids.every((id) => !hiddenIds.contains(id));
    }).toList();

    // 2. Add articles that are pending addition
    final existingIds = <String>{};
    for (final article in result) {
      existingIds.addAll(_articleIdentifiers(article));
    }
    for (final pending in syncState.pendingAddArticles.values) {
      final pendingIds = _articleIdentifiers(pending);
      if (pendingIds.every((id) => !existingIds.contains(id))) {
        result.insert(0, pending);
        existingIds.addAll(pendingIds);
      }
    }

    return result;
  });
});

Set<String> _articleIdentifiers(Article article) {
  return {
    if (article.id != null && article.id!.isNotEmpty) article.id!,
    if (article.externalId != null && article.externalId!.isNotEmpty)
      article.externalId!,
    if (article.url.isNotEmpty) article.url,
  };
}
