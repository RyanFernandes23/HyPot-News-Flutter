import 'package:flutter/material.dart';

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
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(0.05),
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
                _buildTrendingChip('#Technology', colorScheme),
                _buildTrendingChip('#GlobalEconomy', colorScheme),
                _buildTrendingChip('#AIRevolution', colorScheme),
                _buildTrendingChip('#SpaceX', colorScheme),
                _buildTrendingChip('#ClimateAction', colorScheme),
                _buildTrendingChip('#HealthyLiving', colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingChip(String label, ColorScheme colorScheme) {
    return Chip(
      label: Text(label),
      backgroundColor: colorScheme.onSurface.withOpacity(0.03),
      labelStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.1)),
      ),
    );
  }
}
