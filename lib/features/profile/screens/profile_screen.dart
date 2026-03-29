import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../bookmarks/screens/bookmarks_screen.dart';
import '../../news/models/article.dart';
import 'edit_interests_screen.dart';
import '../../news/providers/bookmarks_provider.dart';
import '../../news/screens/news_detail_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final bool isTab;
  const ProfileScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isTab ? null : IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Alex Johnson',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'alex.johnson@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Interests Section
            _buildSectionHeader(context, 'My Interests'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInterestChip(context, 'For You', true),
                _buildInterestChip(context, 'Technology', true),
                _buildInterestChip(context, 'Science', true),
                _buildInterestChip(context, 'International', false),
              ],
            ),
            const SizedBox(height: 40),
            
            // Bookmarks Section
            _buildSectionHeader(context, 'Bookmarks'),
            const SizedBox(height: 16),
            ref.watch(bookmarksProvider).when(
              data: (articles) {
                if (articles.isEmpty) {
                  return Container(
                    height: 140,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('No bookmarks yet', style: TextStyle(color: colorScheme.secondary)),
                  );
                }
                return SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: (articles.length > 5) ? 5 : articles.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsArticleDetailScreen(
                                articles: articles,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: _buildBookmarkCard(context, article),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox(height: 140, child: Center(child: Text('Error loading bookmarks'))),
            ),
            const SizedBox(height: 40),

            // Settings Section
            _buildSectionHeader(context, 'Settings'),
            const SizedBox(height: 16),
            _buildSettingsItem(context, ref, Icons.person_outline, 'Edit Profile'),
            _buildSettingsItem(context, ref, Icons.notifications_none, 'Notifications'),
            _buildSettingsItem(
              context, 
              ref, 
              Icons.dark_mode_outlined, 
              'Dark Mode', 
              isSwitch: true,
              switchValue: isDarkMode,
              onSwitchChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme(value);
              },
            ),
            _buildSettingsItem(context, ref, Icons.privacy_tip_outlined, 'Privacy Policy'),
            _buildSettingsItem(context, ref, Icons.help_outline, 'Help & Support'),
            const SizedBox(height: 32),
            
            // Logout
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        if (title == 'My Interests' || title == 'Bookmarks')
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => title == 'My Interests' 
                    ? const EditInterestsScreen() 
                    : const BookmarksScreen(),
                ),
              );
            },
            child: Text(
              title == 'My Interests' ? 'Edit' : 'View All',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
  Widget _buildInterestChip(BuildContext context, String label, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Chip(
      label: Text(label),
      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      labelStyle: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected 
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, 
    WidgetRef ref,
    IconData icon, 
    String title, 
    {bool isSwitch = false, bool? switchValue, ValueChanged<bool>? onSwitchChanged}
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.secondary),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isSwitch 
          ? Switch(
              value: switchValue ?? false, 
              onChanged: onSwitchChanged, 
              activeColor: colorScheme.primary,
            )
          : Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.2)),
        onTap: () {},
      ),
    );
  }

  Widget _buildBookmarkCard(BuildContext context, Article article) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article.imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                article.headline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
