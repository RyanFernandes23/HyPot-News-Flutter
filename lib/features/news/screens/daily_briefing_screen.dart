import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/daily_briefing_provider.dart';
import '../../../core/providers/audio_provider.dart';

class DailyBriefingScreen extends ConsumerStatefulWidget {
  const DailyBriefingScreen({super.key});

  @override
  ConsumerState<DailyBriefingScreen> createState() => _DailyBriefingScreenState();
}

class _DailyBriefingScreenState extends ConsumerState<DailyBriefingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final briefingState = ref.read(dailyBriefingProvider);
    _pageController = PageController(initialPage: briefingState.currentArticleIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final briefingState = ref.watch(dailyBriefingProvider);
    final audioState = ref.watch(audioProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7);
    final dimTextColor = isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4);
    final accentColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final headerFooterBgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9);
    final stickyShadowColor = Colors.black.withOpacity(isDark ? 0.4 : 0.05);

    if (!briefingState.isActive) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Briefing Ended',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back', style: TextStyle(color: textColor.withOpacity(0.6))),
              ),
            ],
          ),
        ),
      );
    }

    final totalArticles = briefingState.sessionArticles.length;
    final currentArticle = briefingState.sessionArticles[briefingState.currentArticleIndex];

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Static Header with Elevation
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
                        'STORY ${briefingState.currentArticleIndex + 1} OF $totalArticles',
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
                            value: (briefingState.currentArticleIndex + 1) / totalArticles,
                            backgroundColor: accentColor,
                            valueColor: AlwaysStoppedAnimation<Color>(textColor),
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textColor),
                    onPressed: () {
                      ref.read(dailyBriefingProvider.notifier).stopBriefing();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Swipable Content Area
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalArticles,
              onPageChanged: (index) {
                if (index > briefingState.currentArticleIndex) {
                  ref.read(dailyBriefingProvider.notifier).nextArticle();
                } else if (index < briefingState.currentArticleIndex) {
                  ref.read(dailyBriefingProvider.notifier).previousArticle();
                }
              },
              itemBuilder: (context, index) {
                final article = briefingState.sessionArticles[index];
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
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              article.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: isDark ? Colors.grey[800] : Colors.grey[200],
                                child: Icon(Icons.broken_image, color: textColor, size: 32),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: accentColor,
                          ),
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
                      const SizedBox(height: 8),
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
                      )).toList(),
                      const SizedBox(height: 16),
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
                            onTap: () async {
                              final url = Uri.parse(article.url);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accentColor,
                                ),
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
                      const SizedBox(height: 24), // Bottom padding for content
                    ],
                  ),
                );
              },
            ),
          ),

          // Static Footer controls with Elevation
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
                  IconButton(
                    icon: Icon(Icons.skip_previous_rounded, color: textColor),
                    iconSize: 44,
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  const SizedBox(width: 36),
                  GestureDetector(
                    onTap: () => ref.read(audioProvider.notifier).playArticle(currentArticle),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: textColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        audioState.isPlaying && audioState.currentArticle?.headline == currentArticle.headline
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: bgColor,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                  IconButton(
                    icon: Icon(Icons.skip_next_rounded, color: textColor),
                    iconSize: 44,
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
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
