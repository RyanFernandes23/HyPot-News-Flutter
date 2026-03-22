class Article {
  final String id;
  final String title;
  final String? urlToImage;
  final String? urlToHdImage;
  final String? headlineHlsBaseUrl;
  final String? summaryHlsBaseUrl;
  final String category;
  final int? durationSeconds;
  final List<String> availableVoices;
  final List<String> availableSpeeds;
  final String? fullContent;
  final String? summarizedContent;
  final String? sourceName;
  final String? publishedAt;
  final List<Article> relatedArticles;

  const Article({
    required this.id,
    required this.title,
    this.urlToImage,
    this.urlToHdImage,
    this.headlineHlsBaseUrl,
    this.summaryHlsBaseUrl,
    required this.category,
    this.durationSeconds,
    this.availableVoices = const [],
    this.availableSpeeds = const [],
    this.fullContent,
    this.summarizedContent,
    this.sourceName,
    this.publishedAt,
    this.relatedArticles = const [],
  });

  factory Article.fromJson(Map<String, dynamic> j) => Article(
    id:                 j['id'] as String,
    title:              j['title'] as String,
    urlToImage:         j['url_to_image'] as String?,
    urlToHdImage:       j['url_to_hd_image'] as String?,
    headlineHlsBaseUrl: j['headline_hls_base_url'] as String?,
    summaryHlsBaseUrl:  j['summary_hls_base_url'] as String?,
    category:           (j['category'] as String?) ?? '',
    durationSeconds:    j['duration_seconds'] as int?,
    availableVoices:    List<String>.from(j['available_voices'] ?? []),
    availableSpeeds:    List<String>.from(j['available_speeds'] ?? []),
    fullContent:        j['content'] as String?,
    summarizedContent:  j['summarized_content'] as String?,
    sourceName:         j['source_name'] as String?,
    publishedAt:        j['published_at'] as String?,
    relatedArticles:    (j['related_articles'] as List<dynamic>? ?? [])
                          .map((e) => Article.fromJson(e))
                          .toList(),
  );

  // Builds the final HLS URL from base + voice + speed
  String? hlsUrl({
    required String type,   // 'headline' or 'summary'
    required String voice,  // 'male_anchor' or 'female_assistant'
    required String speed,  // '0.75', '1.0', '1.25', '1.5', '2.0'
  }) {
    final base = type == 'headline'
        ? headlineHlsBaseUrl
        : summaryHlsBaseUrl;
    if (base == null) return null;
    return '$base/$voice/$speed/index.m3u8';
  }
}
