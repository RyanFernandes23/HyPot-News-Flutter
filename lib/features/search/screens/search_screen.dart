import 'package:flutter/material.dart';
import '../../bookmarks/screens/bookmarks_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search news, topics...',
                    hintStyle: TextStyle(color: colorScheme.secondary),
                    prefixIcon: Icon(Icons.search, color: colorScheme.secondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // SAVED BUTTON (Moved here from main navigation)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookmarksScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bookmark_outline_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trending Topics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTrendingChip(context, '#Technology'),
                _buildTrendingChip(context, '#GlobalEconomy'),
                _buildTrendingChip(context, '#AIRevolution'),
                _buildTrendingChip(context, '#SpaceX'),
                _buildTrendingChip(context, '#ClimateAction'),
                _buildTrendingChip(context, '#HealthyLiving'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingChip(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Chip(
      label: Text(label),
      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      labelStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }
}
