import 'package:flutter/material.dart';
import 'features/onboarding/screens/onboarding_config_screen.dart';

class HypotApp extends StatelessWidget {
  const HypotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingConfigScreen(),
    );
  }
}
