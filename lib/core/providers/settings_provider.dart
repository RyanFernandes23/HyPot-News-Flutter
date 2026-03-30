import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final bool notificationsEnabled;

  SettingsState({required this.notificationsEnabled});

  SettingsState copyWith({bool? notificationsEnabled}) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const String _notificationsKey = 'notifications_enabled';
  late final Box _box;

  SettingsNotifier() : super(SettingsState(notificationsEnabled: true)) {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box('settings');
    final enabled = _box.get(_notificationsKey, defaultValue: true);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> toggleNotifications(bool value) async {
    await _box.put(_notificationsKey, value);
    state = state.copyWith(notificationsEnabled: value);
  }
}
