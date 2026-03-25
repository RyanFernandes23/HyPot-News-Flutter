import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

class DailyBriefingState {
  final bool isActive;
  final List<Article> sessionArticles;
  final int currentArticleIndex;
  final Duration remainingTime;
  final bool isTransitioning;
  final String? nextCategory;

  DailyBriefingState({
    this.isActive = false,
    this.sessionArticles = const [],
    this.currentArticleIndex = 0,
    this.remainingTime = Duration.zero,
    this.isTransitioning = false,
    this.nextCategory,
  });

  DailyBriefingState copyWith({
    bool? isActive,
    List<Article>? sessionArticles,
    int? currentArticleIndex,
    Duration? remainingTime,
    bool? isTransitioning,
    String? nextCategory,
  }) {
    return DailyBriefingState(
      isActive: isActive ?? this.isActive,
      sessionArticles: sessionArticles ?? this.sessionArticles,
      currentArticleIndex: currentArticleIndex ?? this.currentArticleIndex,
      remainingTime: remainingTime ?? this.remainingTime,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      nextCategory: nextCategory ?? this.nextCategory,
    );
  }
}

class DailyBriefingNotifier extends StateNotifier<DailyBriefingState> {
  Timer? _sessionTimer;

  DailyBriefingNotifier() : super(DailyBriefingState());

  void startBriefing(List<Article> articles) {
    _sessionTimer?.cancel();
    state = DailyBriefingState(
      isActive: true,
      sessionArticles: articles,
      currentArticleIndex: 0,
      remainingTime: const Duration(minutes: 8), // Default 8 min session
    );

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime.inSeconds > 0) {
        state = state.copyWith(remainingTime: state.remainingTime - const Duration(seconds: 1));
      } else {
        stopBriefing();
      }
    });
  }

  void stopBriefing() {
    _sessionTimer?.cancel();
    state = state.copyWith(isActive: false);
  }

  void nextArticle() {
    if (state.currentArticleIndex < state.sessionArticles.length - 1) {
      state = state.copyWith(currentArticleIndex: state.currentArticleIndex + 1);
    } else {
      stopBriefing();
    }
  }

  void previousArticle() {
    if (state.currentArticleIndex > 0) {
      state = state.copyWith(currentArticleIndex: state.currentArticleIndex - 1);
    }
  }

  Future<void> triggerTransition(String category) async {
    state = state.copyWith(
      isTransitioning: true,
      nextCategory: category,
    );
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isTransitioning: false);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}

final dailyBriefingProvider = StateNotifierProvider<DailyBriefingNotifier, DailyBriefingState>((ref) {
  return DailyBriefingNotifier();
});
