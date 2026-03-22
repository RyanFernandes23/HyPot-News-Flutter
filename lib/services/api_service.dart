import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/user_prefs.dart';

class ApiService {
  static const _base = 'https://YOUR_FASTAPI_URL/api/v1';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));

    // Auto-attach Supabase JWT to every request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final session =
            Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] =
              'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Log errors — handle 402 (bookmark limit) specially
        handler.next(error);
      },
    ));
  }

  // ── News ──────────────────────────────────────────────────────────────────

  Future<List<Article>> getBriefing(String genre, int volume) async {
    final res = await _dio.get('/news/briefing',
      queryParameters: {'genre': genre, 'volume': volume});
    return (res.data as List)
        .map((e) => Article.fromJson(e))
        .toList();
  }

  Future<Article> getArticle(String id) async {
    final res = await _dio.get('/news/$id');
    return Article.fromJson(res.data);
  }

  // ── User ──────────────────────────────────────────────────────────────────

  Future<UserPrefs> getUserPrefs() async {
    final userId =
        Supabase.instance.client.auth.currentUser!.id;
    final res = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return UserPrefs.fromJson(res);
  }

  Future<void> updatePrefs(Map<String, dynamic> prefs) async {
    await _dio.patch('/user/preferences', data: prefs);
  }

  Future<void> addBookmark(String articleId) async {
    await _dio.post('/user/bookmarks',
        data: {'article_id': articleId});
  }

  Future<void> removeBookmark(String articleId) async {
    await _dio.delete('/user/bookmarks/$articleId');
  }

  Future<List<Article>> getBookmarks() async {
    final res = await _dio.get('/user/bookmarks');
    return (res.data as List).map((e) {
      final articleJson =
          e['news_articles'] as Map<String, dynamic>;
      return Article.fromJson(articleJson);
    }).toList();
  }
}
