import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.sandboxclub.hypotnews.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('bookmark_outbox');
  await Hive.openBox('settings');

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    // Request permission for push notifications (initial)
    await FirebaseMessaging.instance.requestPermission();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(
    const ProviderScope(
      child: HypotApp(),
    ),
  );
}
