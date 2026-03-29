/// Unified Article model matching the FastAPI backend response schema.
class Article {
  final String? id;
  final String? externalId;
  final String category;
  final String headline;
  final String? summarizedContent;
  final String? summary; // Alias for backward compat
  final String source;
  final String? author;
  final String imageUrl;
  final String url;
  final String? publishedAt;
  final String? headlineHlsBaseUrl;
  final String? summaryHlsBaseUrl;
  final double? durationSeconds;
  final String? audioStatus;
  final List<String> highlights;
  final String? audioUrl;

  const Article({
    this.id,
    this.externalId,
    this.category = 'General',
    required this.headline,
    this.summarizedContent,
    this.summary,
    required this.source,
    this.author,
    required this.imageUrl,
    this.url = 'https://google.com',
    this.publishedAt,
    this.headlineHlsBaseUrl,
    this.summaryHlsBaseUrl,
    this.durationSeconds,
    this.audioStatus,
    this.highlights = const [],
    this.audioUrl,
  });

  /// Construct from backend JSON response (news_articles table format).
  factory Article.fromJson(Map<String, dynamic> json) {
    // Parse summarized_content into highlight bullets
    final rawSummary = json['summarized_content'] as String? ?? '';
    final highlights = rawSummary.isNotEmpty
        ? rawSummary
            .split(RegExp(r'[.\n]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && s.length > 10)
            .toList()
        : <String>[];

    return Article(
      id: json['id']?.toString(),
      externalId: json['external_id'] as String?,
      category: json['category'] as String? ?? 'General',
      headline: json['headline'] as String? ?? '',
      summarizedContent: rawSummary,
      summary: rawSummary.length > 120 ? '${rawSummary.substring(0, 120)}...' : rawSummary,
      source: json['source_name'] as String? ?? '',
      author: json['author'] as String?,
      imageUrl: json['url_to_image'] as String? ?? '',
      url: json['source_url'] as String? ?? 'https://google.com',
      publishedAt: json['published_at'] as String?,
      headlineHlsBaseUrl: json['headline_hls_base_url'] as String?,
      summaryHlsBaseUrl: json['summary_hls_base_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
      audioStatus: json['audio_status'] as String?,
      highlights: highlights,
    );
  }

  /// Construct from a simple map (legacy / RSS entry format).
  factory Article.fromMap(Map<String, String> map) {
    return Article(
      category: map['category'] ?? 'General',
      headline: map['headline'] ?? '',
      summary: map['summary'] ?? '',
      summarizedContent: map['summary'] ?? '',
      source: map['source'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      highlights: [map['summary']?.split('.').first ?? ''],
      url: map['url'] ?? 'https://google.com',
    );
  }

  /// Convert to JSON for local persistence (Hive outbox).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'external_id': externalId,
      'category': category,
      'headline': headline,
      'summarized_content': summarizedContent,
      'source_name': source,
      'author': author,
      'url_to_image': imageUrl,
      'source_url': url,
      'published_at': publishedAt,
      'headline_hls_base_url': headlineHlsBaseUrl,
      'summary_hls_base_url': summaryHlsBaseUrl,
      'duration_seconds': durationSeconds,
      'audio_status': audioStatus,
    };
  }

  /// Convert to a Map for sending to bookmark endpoint (RSS entry format).
  Map<String, dynamic> toBookmarkPayload() {
    return {
      'id': externalId ?? url,
      'link': url,
      'title': headline,
      'summary': summarizedContent ?? summary ?? '',
      'published': publishedAt ?? '',
      'source': {'title': source},
      'media_content': [{'url': imageUrl}],
      'category': category,
    };
  }
}
