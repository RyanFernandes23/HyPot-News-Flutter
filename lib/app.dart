import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// placeholder screens — you'll replace these one by one
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/briefing/screens/home_screen.dart';
import 'features/briefing/screens/briefing_screen.dart';
import 'features/article/screens/article_screen.dart';
import 'features/settings/screens/settings_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isAuthRoute = state.matchedLocation == '/login'
                     || state.matchedLocation == '/signup';
    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/',         builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup',   builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/briefing', builder: (_, __) => const BriefingScreen()),
    GoRoute(
      path: '/article/:id',
      builder: (_, state) =>
          ArticleScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);

class HypotApp extends StatelessWidget {
  const HypotApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HyPot News',
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
