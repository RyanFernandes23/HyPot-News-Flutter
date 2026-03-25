import 'dart:ui';
import 'package:flutter/material.dart';

class CategoryTransitionOverlay extends StatelessWidget {
  final String categoryName;

  const CategoryTransitionOverlay({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black45,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 24),
                Text(
                  'Switching to',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categoryName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
