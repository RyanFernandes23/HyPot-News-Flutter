import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/news/models/article.dart';
import '../../features/news/providers/daily_briefing_provider.dart';
import 'dart:async';

class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final Article? currentArticle;
  final Duration position;
  final Duration duration;
  final bool isMiniPlayerVisible;
  final double playbackSpeed;

  AudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentArticle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isMiniPlayerVisible = false,
    this.playbackSpeed = 1.0,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Article? currentArticle,
    Duration? position,
    Duration? duration,
    bool? isMiniPlayerVisible,
    double? playbackSpeed,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentArticle: currentArticle ?? this.currentArticle,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isMiniPlayerVisible: isMiniPlayerVisible ?? this.isMiniPlayerVisible,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

class AudioNotifier extends StateNotifier<AudioState> {
  final AudioPlayer _player = AudioPlayer();
  final Ref _ref;

  ConcatenatingAudioSource? _briefingPlaylist;
  List<Article>? _trackToArticleMap;

  AudioNotifier(this._ref) : super(AudioState()) {
    _init();
  }

  void _init() {
    // Load persisted speed
    final box = Hive.box('settings');
    double savedSpeed = box.get('playback_speed', defaultValue: 1.0) as double;
    
    // Migrate deprecated speeds
    if (savedSpeed == 0.8) {
      savedSpeed = 0.9;
      box.put('playback_speed', 0.9);
    } else if (savedSpeed == 1.2) {
      savedSpeed = 1.0;
      box.put('playback_speed', 1.0);
    }

    state = state.copyWith(playbackSpeed: savedSpeed);
    _player.setSpeed(savedSpeed);

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

    _player.currentIndexStream.listen((index) {
      if (index != null && _trackToArticleMap != null && index < _trackToArticleMap!.length) {
        final newArticle = _trackToArticleMap![index];
        final currentArticle = state.currentArticle;
        
        if (currentArticle?.headline != newArticle.headline) {
          this.state = this.state.copyWith(currentArticle: newArticle);
          _syncBriefingIndex(newArticle);
        }
      }
    });

    _player.processingStateStream.listen((state) {
      this.state = this.state.copyWith(
        isLoading: state == ProcessingState.loading || state == ProcessingState.buffering,
      );
      if (state == ProcessingState.completed) {
        _handleAudioCompletion();
      }
    });
  }

  void _syncBriefingIndex(Article activeArticle) {
    try {
      final briefingNotifier = _ref.read(dailyBriefingProvider.notifier);
      final briefingState = briefingNotifier.state;
      if (briefingState.isActive) {
        final index = briefingState.sessionArticles.indexWhere((a) => a.headline == activeArticle.headline);
        if (index != -1 && index != briefingState.currentArticleIndex) {
          // Tell the swiper to move to this article, but don't ask it to seek the audio again
          Future.microtask(() => briefingNotifier.goToArticle(index, updateAudio: false));
        }
      }
    } catch (_) {}
  }

  void _handleAudioCompletion() {
    try {
      final briefingNotifier = _ref.read(dailyBriefingProvider.notifier);
      final briefingState = briefingNotifier.state;
      if (briefingState.isActive && _player.currentIndex == _trackToArticleMap?.length) {
        // We reached the actual end of the loaded queue, let provider know to move on/stop
        briefingNotifier.nextArticle();
      }
    } catch (_) {}
  }

  String? _resolveAudioUrlFromPath(String? path) {
    if (path == null || path.isEmpty) return null;
    var baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    if (path.startsWith('articles/')) {
      final proxyPath = path.replaceFirst('articles/', '/audio/');
      return '$baseUrl$proxyPath';
    }
    final leadingSlash = path.startsWith('/') ? '' : '/';
    return '$baseUrl$leadingSlash$path';
  }

  List<AudioSource> _createSources(Article article) {
    final headlineUrl = _resolveAudioUrlFromPath(article.headlineHlsBaseUrl);
    final summaryUrl = _resolveAudioUrlFromPath(article.summaryHlsBaseUrl);
    final sources = <AudioSource>[];
    
    if (headlineUrl != null) {
      sources.add(AudioSource.uri(
        Uri.parse(headlineUrl),
        tag: MediaItem(
          id: 'headline_${article.headline}',
          album: article.category,
          title: article.headline,
          artist: article.source,
          artUri: article.imageUrl.isNotEmpty ? Uri.parse(article.imageUrl) : null,
        ),
      ));
    }
    if (summaryUrl != null) {
      sources.add(AudioSource.uri(
        Uri.parse(summaryUrl),
        tag: MediaItem(
          id: 'summary_${article.headline}',
          album: article.category,
          title: '${article.headline} - Summary',
          artist: article.source,
          artUri: article.imageUrl.isNotEmpty ? Uri.parse(article.imageUrl) : null,
        ),
      ));
    }
    if (sources.isEmpty && article.audioUrl != null) {
      sources.add(AudioSource.uri(
        Uri.parse(article.audioUrl!),
        tag: MediaItem(
          id: 'audio_${article.headline}',
          album: article.category,
          title: article.headline,
          artist: article.source,
          artUri: article.imageUrl.isNotEmpty ? Uri.parse(article.imageUrl) : null,
        ),
      ));
    }
    return sources;
  }

  /// Pushes the entire daily briefing playlist
  Future<void> setBriefingPlaylist(List<Article> articles, Article startArticle) async {
    final List<AudioSource> allSources = [];
    final trackMap = <Article>[];
    int? initialTrackIndex;

    for (final article in articles) {
      final sources = _createSources(article);
      for (var _ in sources) {
        trackMap.add(article);
      }
      if (initialTrackIndex == null && sources.isNotEmpty && article.headline == startArticle.headline) {
        initialTrackIndex = allSources.length;
      }
      allSources.addAll(sources);
    }

    _trackToArticleMap = trackMap;
    _briefingPlaylist = ConcatenatingAudioSource(children: allSources);

    state = state.copyWith(
      currentArticle: startArticle,
      isMiniPlayerVisible: true,
      position: Duration.zero,
    );

    try {
      if (allSources.isNotEmpty) {
        await _player.setAudioSource(_briefingPlaylist!, initialIndex: initialTrackIndex ?? 0);
        await _player.play();
      }
    } catch (e) {
      state = state.copyWith(isPlaying: false);
    }
  }

  /// Appends more articles sequentially as they paginate in
  Future<void> appendBriefingArticles(List<Article> newArticles) async {
    if (_briefingPlaylist == null || _trackToArticleMap == null) return;
    
    final sources = <AudioSource>[];
    for (final article in newArticles) {
      final articleSources = _createSources(article);
      for (var _ in articleSources) {
        _trackToArticleMap!.add(article);
      }
      sources.addAll(articleSources);
    }
    
    await _briefingPlaylist!.addAll(sources);
  }

  /// Force seeks to the specific article (when user manually swipes the slider)
  Future<void> seekToArticle(Article article) async {
    if (_trackToArticleMap == null || _briefingPlaylist == null) {
      // Fallback if not using a playlist
      return playArticle(article);
    }
    
    final index = _trackToArticleMap!.indexWhere((a) => a.headline == article.headline);
    if (index != -1) {
      state = state.copyWith(currentArticle: article);
      try {
        await _player.seek(Duration.zero, index: index);
        if (!_player.playing) {
          await _player.play();
        }
      } catch (_) {}
    }
  }

  /// Legacy play for singular non-briefing articles
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

      final sources = _createSources(article);
      if (sources.isEmpty) {
        state = state.copyWith(isPlaying: false);
        return;
      }

      _briefingPlaylist = ConcatenatingAudioSource(children: sources);
      
      // Temporary map for legacy
      _trackToArticleMap = List.filled(sources.length, article);

      await _player.setAudioSource(_briefingPlaylist!);
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
    } else {
      await _player.seekToNext();
    }
  }

  Future<void> skipBackward() async {
    final newPosition = _player.position - const Duration(seconds: 10);
    await _player.seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  void setMiniPlayerVisible(bool visible) {
    state = state.copyWith(isMiniPlayerVisible: visible);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _player.setSpeed(speed);
    state = state.copyWith(playbackSpeed: speed);
    final box = Hive.box('settings');
    await box.put('playback_speed', speed);
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
