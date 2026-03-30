import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/audio_provider.dart';

class NewsAudioPlayer extends ConsumerWidget {
  final bool isMini;

  const NewsAudioPlayer({
    super.key,
    required this.isMini,
  });

  String _formatDuration(Duration duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMini ? 12 : 24,
        vertical: isMini ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.3)
            : Colors.grey[200]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(audioState.position),
                style: TextStyle(
                  fontSize: isMini ? 10 : 12,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ' / ',
                style: TextStyle(
                  fontSize: isMini ? 10 : 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDuration(audioState.duration),
                style: TextStyle(
                  fontSize: isMini ? 10 : 12,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Timeline slider
          if (!isMini) ...[
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
                activeTrackColor: isDark ? Colors.white : Colors.black,
                inactiveTrackColor: isDark ? Colors.white38 : Colors.black38,
                thumbColor: isDark ? Colors.white : Colors.black,
              ),
              child: Slider(
                value: audioState.position.inSeconds.toDouble(),
                max: audioState.duration.inSeconds
                    .toDouble()
                    .clamp(0.0, double.maxFinite),
                onChanged: (value) {
                  // Update position while dragging (optional: for better UX)
                  // We could update state here but it's better to do it on change end
                },
                onChangeEnd: (value) {
                  // Seek to new position when done dragging
                  ref.read(audioProvider.notifier).seek(
                        Duration(seconds: value.round()),
                      );
                },
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Play/pause controls
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  iconSize: isMini ? 32 : 48,
                  icon: Icon(
                    audioState.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    final article = audioState.currentArticle;
                    if (article != null && article.audioStatus != 'ready') {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Audio is still generating for this article!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    ref.read(audioProvider.notifier).togglePlay();
                  },
                ),
                Positioned(
                  right: isMini ? 0 : 16,
                  child: PopupMenuButton<double>(
                    initialValue: audioState.playbackSpeed,
                    onSelected: (speed) {
                      ref.read(audioProvider.notifier).setPlaybackSpeed(speed);
                    },
                    color: isDark ? Colors.grey[850] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      0.25,
                      0.5,
                      0.8,
                      1.0,
                      1.2,
                      1.5,
                      2.0,
                    ].map((speed) {
                      return PopupMenuItem<double>(
                        value: speed,
                        child: Text(
                          '${speed}x',
                          style: TextStyle(
                            fontWeight: audioState.playbackSpeed == speed
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: isMini ? 8 : 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${audioState.playbackSpeed}x',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: isMini ? 10 : 12,
                        ),
                      ),
                    ),
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
