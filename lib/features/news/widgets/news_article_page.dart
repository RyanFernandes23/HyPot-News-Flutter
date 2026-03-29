import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../providers/bookmark_sync_provider.dart';
import '../providers/bookmarks_state_provider.dart';

class NewsArticlePage extends ConsumerStatefulWidget {
  final Article article;
  final VoidCallback? onNext;

  const NewsArticlePage({super.key, required this.article, this.onNext});

  @override
  ConsumerState<NewsArticlePage> createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends ConsumerState<NewsArticlePage> {
  void _toggleBookmark() async {
    final articleId = widget.article.id ?? widget.article.externalId ?? widget.article.url;
    if (articleId.isEmpty) return;

    final isCurrentlyBookmarked = ref.read(bookmarkedIdsProvider).contains(articleId);

    try {
      if (mounted) {
        final isOffline = ref.read(bookmarkSyncProvider.notifier).isPending(articleId);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!isCurrentlyBookmarked 
              ? (isOffline ? 'Saved locally (offline)' : 'Saved to bookmarks')
              : 'Removed from bookmarks'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      await ref.read(bookmarkSyncProvider.notifier).toggleBookmark(
        widget.article, 
        isCurrentlyBookmarked,
      );
    } catch (_) {
      // Revert not strictly needed here as we watch a global provider that will update
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookmarkedIds = ref.watch(bookmarkedIdsProvider);
    final isBookmarked = bookmarkedIds.contains(widget.article.id ?? '') || 
                         bookmarkedIds.contains(widget.article.externalId ?? '') ||
                         bookmarkedIds.contains(widget.article.url);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Content starts below the navbar area (if any)
        const SizedBox(height: 90),
        Expanded(
          flex: 2,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.article.imageUrl.isNotEmpty
                ? Image.network(
                    widget.article.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  )
                : Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: Icon(Icons.article_outlined, size: 50, color: Colors.grey[400]),
                    ),
                  ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.article.headline,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.article.summary ?? widget.article.summarizedContent ?? '',
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.onSurface.withOpacity(0.05),
                              ),
                            ),
                            child: Text(
                              widget.article.source,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // BOOKMARK BUTTON
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleBookmark,
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isBookmarked
                                      ? const Color(0xFF4D7CFF).withOpacity(0.15)
                                      : Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.05),
                                ),
                                child: Icon(
                                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                  size: 20,
                                  color: isBookmarked
                                      ? const Color(0xFF4D7CFF)
                                      : Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
