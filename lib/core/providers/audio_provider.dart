import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../features/news/models/article.dart';

class AudioState {
  final bool isPlaying;
  final Article? currentArticle;
  final Duration position;
  final Duration duration;
  final bool isMiniPlayerVisible;

  AudioState({
    this.isPlaying = false,
    this.currentArticle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isMiniPlayerVisible = false,
  });

  AudioState copyWith({
    bool? isPlaying,
    Article? currentArticle,
    Duration? position,
    Duration? duration,
    bool? isMiniPlayerVisible,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentArticle: currentArticle ?? this.currentArticle,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isMiniPlayerVisible: isMiniPlayerVisible ?? this.isMiniPlayerVisible,
    );
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _player = AudioPlayer();

  AudioNotifier() : super(AudioState()) {
    _init();
  }

  void _init() {
    _player.playerStateStream.listen((state) {
      this.state = this.state.copyWith(isPlaying: state.playing);
    });

    _player.positionStream.listen((position) {
      this.state = this.state.copyWith(position: position);
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        this.state = this.state.copyWith(duration: duration);
      }
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // Handle completion
      }
    });
  }

  Future<void> playArticle(Article article) async {
    if (state.currentArticle?.headline == article.headline) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    try {
      state = state.copyWith(
        currentArticle: article,
        isMiniPlayerVisible: true,
        position: Duration.zero,
      );
      
      // Using a reliable sample audio URL or asset
      final url = article.audioUrl ?? 'https://sample-videos.com/audio/mp3/crowd-cheering.mp3'; // More reliable?
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      print('Error playing audio: $e');
      // Set playing to false to avoid infinite loading UI
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> skipForward() async {
    final newPosition = _player.position + const Duration(seconds: 10);
    if (newPosition < (_player.duration ?? Duration.zero)) {
      await _player.seek(newPosition);
    }
  }

  Future<void> skipBackward() async {
    final newPosition = _player.position - const Duration(seconds: 10);
    await _player.seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  void setMiniPlayerVisible(bool visible) {
    state = state.copyWith(isMiniPlayerVisible: visible);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});
