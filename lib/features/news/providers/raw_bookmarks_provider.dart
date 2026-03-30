import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../../../services/news_service.dart';

/// The raw bookmarks fetched from the backend. 
/// We keep this separate so it doesn't re-fetch every time we toggle a bookmark locally.
final rawBookmarksProvider = FutureProvider<List<Article>>((ref) async {
  final newsService = NewsService();
  final response = await newsService.fetchBookmarks();
  final List<dynamic> articlesJson = response['articles'] ?? [];
  return articlesJson.map((json) => Article.fromJson(json)).toList();
});
