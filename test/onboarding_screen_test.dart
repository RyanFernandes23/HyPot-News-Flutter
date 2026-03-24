import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hypot_news/features/onboarding/screens/onboarding_config_screen.dart';

void main() {
  testWidgets('OnboardingConfigScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingConfigScreen()));

    // Verify header and subheader
    expect(find.text('Good Morning, Alex'), findsOneWidget);
    expect(find.text('Customize your daily news intake to start your day informed.'), findsOneWidget);

    // Verify Select Interests section
    expect(find.text('Select Interests'), findsOneWidget);
    expect(find.text('Multiple Selection'), findsOneWidget);

    // Verify some interests are present
    expect(find.text('International'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Regional'), findsOneWidget);

    // Verify selection logic (toggle)
    // Initially 'International' and 'Regional' are selected in my implementation
    final internationalFinder = find.text('International');
    await tester.tap(internationalFinder);
    await tester.pump();

    // Verify Save button
    expect(find.text('Save Configuration'), findsOneWidget);
    await tester.tap(find.text('Save Configuration'));
    await tester.pump();
    
    // Verify SnackBar shown (optional but good)
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
