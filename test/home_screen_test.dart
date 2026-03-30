import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hypot_news/features/discovery/screens/discovery_screen.dart';
import 'package:hypot_news/features/onboarding/screens/onboarding_config_screen.dart';

void main() {
  testWidgets('DiscoveryScreen renders with topics', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DiscoveryScreen()));
    
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('For You'), findsOneWidget);
    expect(find.text('International'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
  });
  
  testWidgets('Navigation from Onboarding to Discovery works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingConfigScreen()));
    
    final saveButton = find.text('Save Configuration');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    
    expect(find.byType(DiscoveryScreen), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
  });
}
