import 'package:flutter/material.dart';
import '../models/article.dart';
import '../widgets/news_article_page.dart';

class NewsArticleDetailScreen extends StatefulWidget {
  final List<Article> articles;
  final int initialIndex;
  final bool isFromBookmarks;

  const NewsArticleDetailScreen({
    super.key,
    required this.articles,
    this.initialIndex = 0,
    this.isFromBookmarks = false,
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
          // Top Header UI (Back Button + Optional Centered Bookmarks Label)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isFromBookmarks)
                    const Text(
                      'BOOKMARKS',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5.0,
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, 
                          color: Colors.black, 
                          size: 22
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
