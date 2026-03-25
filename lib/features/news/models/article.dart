class Article {
  final String category;
  final String headline;
  final String summary;
  final String source;
  final String imageUrl;
  final List<String> highlights;
  final String? audioUrl;
  final String url;

  const Article({
    this.category = 'General',
    required this.headline,
    required this.summary,
    required this.source,
    required this.imageUrl,
    this.highlights = const [],
    this.audioUrl,
    this.url = 'https://google.com',
  });

  factory Article.fromMap(Map<String, String> map) {
    return Article(
      category: map['category'] ?? 'General',
      headline: map['headline'] ?? '',
      summary: map['summary'] ?? '',
      source: map['source'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      highlights: [map['summary']?.split('.').first ?? ''], // Simple heuristic for now
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Dummy audio
      url: map['url'] ?? 'https://google.com',
    );
  }
}
