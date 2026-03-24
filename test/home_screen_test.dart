import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hypot_news/features/home/screens/home_screen.dart';
import 'package:hypot_news/features/onboarding/screens/onboarding_config_screen.dart';

void main() {
  testWidgets('HomeScreen renders with topics', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Your Personalized Hub'), findsOneWidget);
    expect(find.text('For You'), findsOneWidget);
    expect(find.text('International'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
  });

  testWidgets('Navigation from Onboarding to Home works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingConfigScreen()));

    final saveButton = find.text('Save Configuration');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Your Personalized Hub'), findsOneWidget);
  });
}
