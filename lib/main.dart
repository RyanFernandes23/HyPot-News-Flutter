import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Background audio — must be before runApp
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.hypot.news.audio',
    androidNotificationChannelName: 'HyPot News Audio',
    androidNotificationOngoing: true,
  );

  // Supabase — use your actual URL and anon key
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
  );

  runApp(const ProviderScope(child: HypotApp()));
}
