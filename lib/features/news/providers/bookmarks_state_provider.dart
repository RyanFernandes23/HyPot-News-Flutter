import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bookmarks_provider.dart';
import 'bookmark_sync_provider.dart';

/// Provides a Set of all bookmarked article IDs (internal UUIDs and external IDs/URLs)
/// for O(1) lookups across the app.
final bookmarkedIdsProvider = Provider<Set<String>>((ref) {
  final bookmarksAsync = ref.watch(bookmarksProvider);
  final syncState = ref.watch(bookmarkSyncProvider);
  
  final ids = bookmarksAsync.when(
    data: (articles) {
      final s = <String>{};
      for (final a in articles) {
        if (a.id != null) s.add(a.id!);
        if (a.externalId != null) s.add(a.externalId!);
        // Also include URL as a fallback ID for RSS entries
        s.add(a.url);
      }
      return s;
    },
    loading: () => <String>{},
    error: (_, __) => <String>{},
  );

  // Apply optimistic updates from the sync outbox
  // Note: We create a new Set to avoid modifying the one from the provider cache if it were shared
  final optimisticIds = Set<String>.from(ids);
  final hiddenIds = {
    ...syncState.pendingRemoves,
    ...syncState.activeRemoveTombstones,
  };
  
  // 1. Remove IDs that are pending deletion
  optimisticIds.removeAll(hiddenIds);
  
  // 2. Add IDs that are pending addition
  for (final article in syncState.pendingAddArticles.values) {
    if (article.id != null && article.id!.isNotEmpty) optimisticIds.add(article.id!);
    if (article.externalId != null && article.externalId!.isNotEmpty) {
      optimisticIds.add(article.externalId!);
    }
    if (article.url.isNotEmpty) optimisticIds.add(article.url);
  }

  return optimisticIds;
});
