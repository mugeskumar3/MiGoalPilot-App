import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/main.dart';

void main() {
  testWidgets('App startup and onboarding navigation test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MiGoalPilotApp(),
      ),
    );

    // Initial state is splash screen, wait for splash delay to complete
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    // Verify Onboarding Screen 1 is loaded
    expect(find.text('Your goals deserve\na clear destination.'), findsOneWidget);

    // Tap Next to navigate to Onboarding 2
    final nextBtn = find.widgetWithText(ElevatedButton, 'Next');
    expect(nextBtn, findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    // Verify Onboarding Screen 2 is loaded
    expect(find.text('Know exactly where\nyour savings stand.'), findsOneWidget);
  });
}
