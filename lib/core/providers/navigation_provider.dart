import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int selectedIndex;
  final String? selectedTopic;

  NavigationState({this.selectedIndex = 0, this.selectedTopic});

  NavigationState copyWith({int? selectedIndex, String? selectedTopic}) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedTopic: selectedTopic ?? this.selectedTopic,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  void setIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void setTopic(String? topic) {
    state = state.copyWith(selectedTopic: topic, selectedIndex: 0); // Switch to Feed tab (index 0)
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
