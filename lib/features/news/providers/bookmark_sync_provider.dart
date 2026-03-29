import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/article.dart';
import '../../../services/news_service.dart';

enum OutboxAction { add, remove }

class OutboxEntry {
  final String id; // Client-side idempotency key
  final String articleId; // The backend article ID or external_id
  final OutboxAction action;
  final Map<String, dynamic> payload; // Backend-compatible payload
  final Map<String, dynamic>? articleJson; // Full Article JSON for internal UI reconstruction
  final DateTime createdAt;

  OutboxEntry({
    required this.id,
    required this.articleId,
    required this.action,
    required this.payload,
    this.articleJson,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'articleId': articleId,
        'action': action.name,
        'payload': payload,
        'articleJson': articleJson,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OutboxEntry.fromJson(Map<dynamic, dynamic> json) => OutboxEntry(
        id: json['id'],
        articleId: json['articleId'],
        action: OutboxAction.values.byName(json['action']),
        payload: Map<String, dynamic>.from(json['payload']),
        articleJson: json['articleJson'] != null ? Map<String, dynamic>.from(json['articleJson']) : null,
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class BookmarkSyncState {
  final bool isSyncing;
  final Map<String, Article> pendingAddArticles;
  final Set<String> pendingRemoves;

  BookmarkSyncState({
    this.isSyncing = false,
    this.pendingAddArticles = const {},
    this.pendingRemoves = const {},
  });

  Set<String> get allPendingIds => {...pendingAddArticles.keys, ...pendingRemoves};

  BookmarkSyncState copyWith({
    bool? isSyncing,
    Map<String, Article>? pendingAddArticles,
    Set<String>? pendingRemoves,
  }) {
    return BookmarkSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingAddArticles: pendingAddArticles ?? this.pendingAddArticles,
      pendingRemoves: pendingRemoves ?? this.pendingRemoves,
    );
  }
}

class BookmarkSyncNotifier extends StateNotifier<BookmarkSyncState> {
  final NewsService _newsService = NewsService();
  final Box _box = Hive.box('bookmark_outbox');
  final _uuid = const Uuid();
  StreamSubscription? _connectivitySub;

  BookmarkSyncNotifier() : super(BookmarkSyncState()) {
    _loadInitialState();
    _setupConnectivityListener();
  }

  void _loadInitialState() {
    _updatePendingIds();
    // Attempt an initial sync
    sync();
  }

  void _setupConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.mobile) || 
          results.contains(ConnectivityResult.wifi)) {
        sync();
      }
    });
  }

  Future<void> toggleBookmark(Article article, bool isCurrentlyBookmarked) async {
    final articleId = article.id ?? article.externalId ?? article.url;
    final action = isCurrentlyBookmarked ? OutboxAction.remove : OutboxAction.add;
    
    // 1. Reconcile: If there's an opposite action for this article already in the box, remove it instead of adding a new one.
    final existingIndex = _box.values.toList().indexWhere(
      (e) => OutboxEntry.fromJson(e as Map).articleId == articleId
    );

    if (existingIndex != -1) {
      final existingEntry = OutboxEntry.fromJson(_box.getAt(existingIndex));
      if (existingEntry.action != action) {
        // Cancel out
        await _box.deleteAt(existingIndex);
        _updatePendingIds();
        return;
      }
    }

    // 2. Add to outbox with timestamp and idempotency key
    final entry = OutboxEntry(
      id: _uuid.v4(),
      articleId: articleId,
      action: action,
      payload: article.toBookmarkPayload(),
      articleJson: article.toJson(),
      createdAt: DateTime.now(),
    );

    await _box.add(entry.toJson());
    _updatePendingIds();

    // 3. Trigger immediate sync attempt
    sync();
  }

  void _updatePendingIds() {
    final addArticles = <String, Article>{};
    final removes = <String>{};
    
    for (final v in _box.values) {
      final entry = OutboxEntry.fromJson(v as Map);
      if (entry.action == OutboxAction.add) {
        if (entry.articleJson != null) {
          addArticles[entry.articleId] = Article.fromJson(entry.articleJson!);
        }
      } else {
        removes.add(entry.articleId);
      }
    }
    
    state = state.copyWith(
      pendingAddArticles: addArticles,
      pendingRemoves: removes,
    );
  }

  Future<void> sync() async {
    if (state.isSyncing || _box.isEmpty) return;
    
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    state = state.copyWith(isSyncing: true);

    try {
      // Process entries one by one to handle partial failures
      final keys = List.from(_box.keys);
      for (final key in keys) {
        final entry = OutboxEntry.fromJson(_box.get(key));
        print('Syncing ${entry.action.name} for ${entry.articleId} (idempotency key: ${entry.id})...');
        
        try {
          if (entry.action == OutboxAction.add) {
            await _newsService.bookmarkArticle({
              ...entry.payload,
              'client_id': entry.id, 
              'created_at': entry.createdAt.toIso8601String(),
            });
          } else {
            await _newsService.unbookmark(entry.articleId);
          }
          
          print('Successfully synced ${entry.id}');
          await _box.delete(key);
        } catch (e) {
          print('Sync FAILED for ${entry.id}: $e');
          if (e.toString().contains('SocketException') || e.toString().contains('Connectivity')) {
            print('Network error — stopping sync loop.');
            break;
          }
        }
      }
    } finally {
      _updatePendingIds();
      state = state.copyWith(isSyncing: false);
    }
  }

  bool isPending(String articleId) {
    return state.allPendingIds.contains(articleId);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}

final bookmarkSyncProvider =
    StateNotifierProvider<BookmarkSyncNotifier, BookmarkSyncState>((ref) {
  return BookmarkSyncNotifier();
});
