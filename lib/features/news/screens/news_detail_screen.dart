import 'package:flutter/material.dart';
import '../models/article.dart';
import '../widgets/news_article_page.dart';

class NewsArticleDetailScreen extends StatefulWidget {
  final List<Article> articles;
  final int initialIndex;

  const NewsArticleDetailScreen({
    super.key,
    required this.articles,
    this.initialIndex = 0,
  });

  @override
  State<NewsArticleDetailScreen> createState() => _NewsArticleDetailScreenState();
}

class _NewsArticleDetailScreenState extends State<NewsArticleDetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.articles.length,
            itemBuilder: (context, index) {
              return NewsArticlePage(article: widget.articles[index]);
            },
          ),
          // Back Button UI
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
