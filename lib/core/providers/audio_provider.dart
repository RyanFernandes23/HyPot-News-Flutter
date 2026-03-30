import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import '../../features/news/models/article.dart';
import '../../features/news/providers/daily_briefing_provider.dart';

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
  final Ref _ref;

  AudioNotifier(this._ref) : super(AudioState()) {
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
        _handleAudioCompletion();
      }
    });
  }

  void _handleAudioCompletion() {
    // Check if we have access to daily briefing provider and are in a briefing context
    try {
      final briefingNotifier = _ref.read(dailyBriefingProvider.notifier);
      final briefingState = briefingNotifier.state;

      // Only auto-advance if we're actively in a briefing session
      if (briefingState.isActive) {
        // Try to advance to next article
        briefingNotifier.nextArticle();
      }
    } catch (e) {
      // If we can't access the briefing provider or any other error, just do nothing
      // This allows the audio player to work outside briefing context too
    }
  }

  String? _resolveAudioUrlFromPath(String? path) {
    if (path == null || path.isEmpty) return null;
    var baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // The DB stores paths like articles/{id}/{type}/{file}
    // The backend proxy is at /api/v1/audio/{id}/{type}/{file}
    if (path.startsWith('articles/')) {
      final proxyPath = path.replaceFirst('articles/', '/audio/');
      return '$baseUrl$proxyPath';
    }
    
    // Fallback for any other path formats
    final leadingSlash = path.startsWith('/') ? '' : '/';
    return '$baseUrl$leadingSlash$path';
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

      final headlineUrl = _resolveAudioUrlFromPath(article.headlineHlsBaseUrl);
      final summaryUrl = _resolveAudioUrlFromPath(article.summaryHlsBaseUrl);
      
      final List<AudioSource> sources = [];
      if (headlineUrl != null) sources.add(AudioSource.uri(Uri.parse(headlineUrl)));
      if (summaryUrl != null) sources.add(AudioSource.uri(Uri.parse(summaryUrl)));
      
      // Fallback to legacy audioUrl
      if (sources.isEmpty && article.audioUrl != null) {
        sources.add(AudioSource.uri(Uri.parse(article.audioUrl!)));
      }

      if (sources.isEmpty) {
        state = state.copyWith(isPlaying: false);
        return;
      }

      final playlist = ConcatenatingAudioSource(children: sources);
      await _player.setAudioSource(playlist);
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
  return AudioNotifier(ref);
});
