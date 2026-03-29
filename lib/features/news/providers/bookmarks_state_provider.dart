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
  
  // 1. Remove IDs that are pending deletion
  optimisticIds.removeAll(syncState.pendingRemoves);
  
  // 2. Add IDs that are pending addition
  optimisticIds.addAll(syncState.pendingAddArticles.keys);

  return optimisticIds;
});
