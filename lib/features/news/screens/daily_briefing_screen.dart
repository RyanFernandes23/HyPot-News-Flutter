import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/article_web_view_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/navigation_provider.dart';
import '../providers/daily_briefing_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../navigation/screens/main_navigation_screen.dart';
import '../widgets/news_audio_player.dart';
import '../widgets/daily_briefing_shimmer.dart';

class DailyBriefingScreen extends ConsumerStatefulWidget {
  const DailyBriefingScreen({super.key});

  @override
  ConsumerState<DailyBriefingScreen> createState() =>
      _DailyBriefingScreenState();
}

class _DailyBriefingScreenState extends ConsumerState<DailyBriefingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final briefingState = ref.read(dailyBriefingProvider);
    _pageController =
        PageController(initialPage: briefingState.currentArticleIndex);
    // Auto-start briefing if not already loading
    if (!briefingState.isActive && briefingState.sessionArticles.isEmpty) {
      Future.microtask(() =>
          ref.read(dailyBriefingProvider.notifier).startBriefingFromBackend());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(
      dailyBriefingProvider.select((s) => s.currentArticleIndex),
      (previous, next) {
        if (previous != null && next != previous) {
          if (_pageController.hasClients && _pageController.page?.round() != next) {
            _pageController.animateToPage(
              next,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        }
      },
    );

    final briefingState = ref.watch(dailyBriefingProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor =
        isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7);
    final dimTextColor =
        isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);
    final accentColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final headerFooterBgColor =
        isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9);
    final stickyShadowColor = Colors.black.withOpacity(isDark ? 0.4 : 0.05);

    // ── Briefing completed screen ──────────────────────────────────────
    if (briefingState.isFinished ||
        (!briefingState.isActive && briefingState.sessionArticles.isNotEmpty)) {
      // Mark briefing as seen when completed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).markBriefingAsSeen();
      });

      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D7CFF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF4D7CFF),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  "That's all for now",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You\'re all caught up on today\'s briefing.\nNew stories will be ready for you tomorrow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Feed tab and mark briefing as seen
                      ref.read(authProvider.notifier).markBriefingAsSeen();
                      ref.read(navigationProvider.notifier).setIndex(0);
                      // Pop the briefing screen to return to main navigation
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                      // Push main navigation screen to ensure clean state
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D7CFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.article_outlined, size: 20),
                    label: const Text(
                      'Continue to Feed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: () {
                    // Mark briefing as seen even when closing
                    ref.read(authProvider.notifier).markBriefingAsSeen();
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MainNavigationScreen()),
                    );
                  },
                  icon:
                      Icon(Icons.close_rounded, color: dimTextColor, size: 18),
                  label: Text(
                    'Close',
                    style: TextStyle(
                      color: dimTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Loading state ────────────────────────────────────────────────
    if (briefingState.isLoadingMore && briefingState.sessionArticles.isEmpty) {
      return const DailyBriefingShimmerLoading();
    }

    // ── Empty / Preparing state ──────────────────────────────────────
    if (briefingState.sessionArticles.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D7CFF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.audio_file_outlined,
                    color: Color(0xFF4D7CFF),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Finishing up...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "We're currently processing your latest audio briefing. Check back in a few minutes!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(dailyBriefingProvider.notifier)
                          .startBriefingFromBackend();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D7CFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text(
                      'Check Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to Feed tab and mark briefing as seen
                    ref.read(authProvider.notifier).markBriefingAsSeen();
                    ref.read(navigationProvider.notifier).setIndex(0);
                    // Pop the briefing screen to return to main navigation
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    // Push main navigation screen to ensure clean state
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MainNavigationScreen()),
                    );
                  },
                  icon: Icon(
                    Icons.explore_outlined,
                    color: subTextColor,
                    size: 18,
                  ),
                  label: Text(
                    "Back to Feed",
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalArticles = briefingState.sessionArticles.length;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Static Header ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              color: headerFooterBgColor,
              boxShadow: [
                BoxShadow(
                  color: stickyShadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY BRIEFING',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5.0,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'STORY ${briefingState.currentArticleIndex + 1} OF $totalArticles${briefingState.hasMore ? '+' : ''}',
                        style: TextStyle(
                          color: dimTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: (briefingState.currentArticleIndex + 1) /
                                totalArticles,
                            backgroundColor: accentColor,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(textColor),
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: textColor),
                        onPressed: () {
                          // Allow the briefing to continue playing in the background
                          // ref.read(dailyBriefingProvider.notifier).stopBriefing();
                          
                          ref.read(authProvider.notifier).markBriefingAsSeen();
                          ref.read(navigationProvider.notifier).setIndex(0);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MainNavigationScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Swipable Content ────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalArticles,
              onPageChanged: (index) {
                final currentIndex =
                    ref.read(dailyBriefingProvider).currentArticleIndex;
                if (index != currentIndex) {
                  ref.read(dailyBriefingProvider.notifier).goToArticle(index);
                }
              },
              itemBuilder: (context, index) {
                final article = briefingState.sessionArticles[index];
                final id = article.id ?? article.externalId ?? article.url;
                final isBookmarked = briefingState.bookmarkedIds.contains(id);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Media Container
                      Center(
                        child: Container(
                          height: 160,
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isDark ? 0.3 : 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: article.imageUrl.isNotEmpty
                                ? Image.network(
                                    article.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      child: Icon(Icons.broken_image,
                                          color: textColor, size: 32),
                                    ),
                                  )
                                : Container(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    child: Icon(Icons.article_outlined,
                                        color: textColor, size: 32),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category + Bookmark row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              article.category.toUpperCase(),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          // ── Bookmark Button ──
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                final wasBookmarked = isBookmarked;
                                ref
                                    .read(dailyBriefingProvider.notifier)
                                    .toggleBookmark(article);
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(!wasBookmarked
                                          ? 'Saved to bookmarks'
                                          : 'Removed from bookmarks'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isBookmarked
                                      ? const Color(0xFF4D7CFF)
                                          .withOpacity(0.15)
                                      : accentColor,
                                ),
                                child: Icon(
                                  isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_outline_rounded,
                                  size: 20,
                                  color: isBookmarked
                                      ? const Color(0xFF4D7CFF)
                                      : textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Headline
                      Text(
                        article.headline,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Highlights
                      ...article.highlights.map((highlight) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: textColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    highlight,
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),

                      // Source + Read More
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            article.source.toUpperCase(),
                            style: TextStyle(
                              color: dimTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.1,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleWebViewScreen(
                                    url: article.url,
                                    title: article.source,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'READ MORE',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.8),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    color: textColor.withOpacity(0.8),
                                    size: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Loading indicator for more articles
                      if (briefingState.isLoadingMore &&
                          index >= briefingState.sessionArticles.length - 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: dimTextColor,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Static Footer ──────────────────────────────────────────
          Container(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: headerFooterBgColor,
              boxShadow: [
                BoxShadow(
                  color: stickyShadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: NewsAudioPlayer(
                      isMini: false,
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
