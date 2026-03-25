import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'edit_interests_screen.dart';

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
        if (title == 'My Interests')
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF4D7CFF)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditInterestsScreen(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInterestChip(BuildContext context, String label, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : colorScheme.secondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
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
}
