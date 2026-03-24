import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hypot_news/features/news/screens/news_view_screen.dart';

void main() {
  testWidgets('NewsViewScreen renders first article', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewsViewScreen(topic: 'For You')));

    // Verify first article headline
    expect(find.text('Global Markets Surge Amid New Economic Policies'), findsOneWidget);
    expect(find.text('Finance Times • 2h ago'), findsOneWidget);
    
    // Verify summary is present
    expect(find.textContaining('Major stock indices'), findsOneWidget);

    // Verify back button
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('NewsViewScreen swiping changes article', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewsViewScreen(topic: 'For You')));

    // Drag up to go to next article
    await tester.drag(find.byType(PageView), const Offset(0, -500));
    await tester.pumpAndSettle();

    // Verify second article headline
    expect(find.text('Breakthrough in Renewable Energy Storage Technology'), findsOneWidget);
    expect(find.text('Tech Daily • 5h ago'), findsOneWidget);
  });
}
