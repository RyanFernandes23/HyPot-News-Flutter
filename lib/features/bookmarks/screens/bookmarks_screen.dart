import 'package:flutter/material.dart';
import '../../news/models/article.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final List<Article> bookmarkedArticles = [
      Article(
        headline: 'The Future of AI in Modern Journalism',
        summary: 'Exploring how artificial intelligence is reshaping the way news is gathered, written, and delivered to audiences worldwide.',
        source: 'Tech Insights',
        imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?q=80&w=1000&auto=format&fit=crop',
        category: 'Technology',
        url: 'https://example.com/ai-journalism',
      ),
      Article(
        headline: 'Sustainable Energy: Small Steps to Big Change',
        summary: 'Community-led initiatives are proving that local solar projects can significantly reduce carbon footprints and energy costs.',
        source: 'Green Planet',
        imageUrl: 'https://images.unsplash.com/photo-1509391366360-2e959784a276?q=80&w=1000&auto=format&fit=crop',
        category: 'Science',
        url: 'https://example.com/sustainable-energy',
      ),
      Article(
        headline: 'Global Economy: Trends to Watch in 2024',
        summary: 'Economic experts weigh in on the factors that will shape the global market in the coming year, from inflation to emerging tech.',
        source: 'Financial Times',
        imageUrl: 'https://images.unsplash.com/photo-1611974714851-48206138d731?q=80&w=1000&auto=format&fit=crop',
        category: 'Business',
        url: 'https://example.com/global-economy',
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bookmarks',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: bookmarkedArticles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final article = bookmarkedArticles[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    article.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.blue : const Color(0xFF4D7CFF)).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.blue[300] : const Color(0xFF4D7CFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${article.source}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove_rounded, color: Colors.red),
                  onPressed: () {
                    // In a real app, this would update the state
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
