import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  /// Build full audio URL from the article's HLS base URL.
  String? _resolveAudioUrl(Article article) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    // Prefer headline audio, fallback to summary audio
    final hlsPath = article.headlineHlsBaseUrl ?? article.summaryHlsBaseUrl;
    if (hlsPath != null && hlsPath.isNotEmpty) {
      // The backend returns paths like /api/v1/audio/{id}/{type}/{file}
      // API_BASE_URL already includes /api/v1, so strip that prefix if present
      if (hlsPath.startsWith('/api/v1/')) {
        return '$baseUrl${hlsPath.substring(7)}'; // Remove /api/v1 since baseUrl has it
      }
      return '$baseUrl$hlsPath';
    }

    return article.audioUrl;
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

      final url = _resolveAudioUrl(article);
      if (url == null || url.isEmpty) {
        state = state.copyWith(isPlaying: false);
        return;
      }

      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
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
