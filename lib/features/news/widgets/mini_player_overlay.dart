import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/audio_provider.dart';

class MiniPlayerOverlay extends ConsumerWidget {
  const MiniPlayerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (!audioState.isMiniPlayerVisible || audioState.currentArticle == null) {
      return const SizedBox.shrink();
    }

    final article = audioState.currentArticle!;
    final progress = audioState.duration.inSeconds > 0 
        ? audioState.position.inSeconds / audioState.duration.inSeconds 
        : 0.0;

    return Positioned(
      bottom: 8, 
      left: 20, 
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            article.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[800],
                              child: const Icon(Icons.broken_image, size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.headline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.replay_10_rounded, size: 20),
                          onPressed: () => ref.read(audioProvider.notifier).skipBackward(),
                        ),
                        const SizedBox(width: 8),
                        audioState.isLoading
                            ? SizedBox(
                                width: 28,
                                height: 28,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              )
                            : IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  audioState.isPlaying 
                                      ? Icons.pause_rounded 
                                      : Icons.play_arrow_rounded,
                                  color: colorScheme.primary,
                                  size: 28,
                                ),
                                onPressed: () => ref.read(audioProvider.notifier).togglePlay(),
                              ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.forward_10_rounded, size: 20),
                          onPressed: () => ref.read(audioProvider.notifier).skipForward(),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => ref.read(audioProvider.notifier).setMiniPlayerVisible(false),
                        ),
                      ],
                    ),
                  ),
                ),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: colorScheme.onSurface.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  minHeight: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
