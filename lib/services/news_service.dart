import 'package:dio/dio.dart';
import 'api_service.dart';

/// Handles all news-related API calls: briefings, live feed, bookmarks, read tracking.
class NewsService {
  final ApiService _api = ApiService();

  // ── Daily Briefing ─────────────────────────────────────────────────

  /// Fetch paginated daily briefing articles based on user interests.
  Future<Map<String, dynamic>> fetchBriefing({
    int limit = 5,
    int offset = 0,
    List<String>? interests,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (interests != null && interests.isNotEmpty) {
        queryParams['interests'] = interests;
      }

      final response = await _api.dio.get('/news/briefing',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ── Live Feed ──────────────────────────────────────────────────────

  /// Fetch live RSS news for a category. Uses cursor-based pagination.
  Future<Map<String, dynamic>> fetchLiveNews({
    required String category,
    int limit = 20,
    String? before,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'category': category,
        'limit': limit,
      };

      if (before != null) {
        queryParams['before'] = before;
      }

      final response = await _api.dio.get('/news/live',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ── Category News (DB) ─────────────────────────────────────────────

  /// Fetch processed news articles from DB by category.
  Future<Map<String, dynamic>> fetchNewsByCategory({
    required String category,
    int limit = 10,
  }) async {
    try {
      final response = await _api.dio.get('/news', queryParameters: {
        'category': category,
        'limit': limit,
      });
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ── Read Tracking ──────────────────────────────────────────────────

  /// Mark an article as read.
  Future<void> markAsRead(String externalId) async {
    try {
      await _api.dio.post('/news/read', data: {
        'external_id': externalId,
      });
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ── Bookmarks ──────────────────────────────────────────────────────

  /// Bookmark an article. Sends the full article data for RSS entries.
  Future<Map<String, dynamic>> bookmarkArticle(Map<String, dynamic> articleData) async {
    try {
      final response = await _api.dio.post('/news/bookmark', data: articleData);
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Remove a bookmark by article ID.
  Future<void> unbookmark(String articleId) async {
    try {
      final encodedId = Uri.encodeComponent(articleId);
      await _api.dio.delete('/news/bookmark/$encodedId');
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Get all bookmarked articles for the current user.
  Future<Map<String, dynamic>> getBookmarks() async {
    try {
      final response = await _api.dio.get('/news/bookmarks');
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Fetch all bookmarks for the authenticated user.
  Future<Map<String, dynamic>> fetchBookmarks() async {
    try {
      final response = await _api.dio.get('/news/bookmarks');
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ── User Interests ─────────────────────────────────────────────────

  /// Update user interest categories.
  Future<Map<String, dynamic>> updateInterests(List<String> interests) async {
    try {
      final response = await _api.dio.put('/news/interests', data: {
        'interests': interests,
      });
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['detail']?.toString() ?? 'An error occurred';
    }
    return e.message ?? 'Network error';
  }
}
