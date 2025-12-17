import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cam_star/main.dart';
import 'package:cam_star/screens/mode_selection_screen.dart';
import 'package:cam_star/screens/server/server_screen.dart';
import 'package:cam_star/screens/client/client_screen.dart';

void main() {
  testWidgets('App loads with ModeSelectionScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const CamStarApp());

    // Verify that mode selection screen is displayed
    expect(find.text('CamStar'), findsOneWidget);
    expect(find.text('Server Mode'), findsOneWidget);
    expect(find.text('Client Mode'), findsOneWidget);
  });

  testWidgets('Selecting Server Mode navigates to ServerScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const CamStarApp());

    // Find and tap the Server Mode card
    await tester.tap(find.text('Server Mode'));
    await tester.pumpAndSettle();

    // Verify navigation to ServerScreen
    expect(find.text('Server Mode Active'), findsOneWidget);
    expect(find.byType(ServerScreen), findsOneWidget);
  });

  testWidgets('Selecting Client Mode navigates to ClientScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const CamStarApp());

    // Scroll to make Client Mode card visible and tap it
    await tester.ensureVisible(find.text('Client Mode'));
    await tester.pump();
    await tester.tap(find.text('Client Mode'));

    // Use pump with duration instead of pumpAndSettle
    // (ClientScreen has continuous animations from discovery)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify navigation to ClientScreen
    expect(find.byType(ClientScreen), findsOneWidget);
    expect(find.text('Client Mode'), findsOneWidget); // AppBar title
  });

  testWidgets('Back navigation from ServerScreen works', (WidgetTester tester) async {
    await tester.pumpWidget(const CamStarApp());

    // Navigate to Server Mode
    await tester.tap(find.text('Server Mode'));
    await tester.pumpAndSettle();

    // Tap back button
    await tester.tap(find.text('Back to Mode Selection'));
    await tester.pumpAndSettle();

    // Verify we're back at mode selection
    expect(find.text('CamStar'), findsOneWidget);
    expect(find.byType(ModeSelectionScreen), findsOneWidget);
  });

  testWidgets('Back navigation from ClientScreen works', (WidgetTester tester) async {
    await tester.pumpWidget(const CamStarApp());

    // Navigate to Client Mode
    await tester.ensureVisible(find.text('Client Mode'));
    await tester.pump();
    await tester.tap(find.text('Client Mode'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap back button in app bar
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Verify we're back at mode selection
    expect(find.text('CamStar'), findsOneWidget);
    expect(find.byType(ModeSelectionScreen), findsOneWidget);
  });
}
