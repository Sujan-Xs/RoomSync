import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomsync/features/swipe_deck/presentation/swipe_deck_screen.dart';
import 'package:roomsync/main.dart';

void main() {
  testWidgets('RoomSyncApp loads and renders Discover screen and all 4 navigation items', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RoomSyncApp(),
      ),
    );

    // Initial load
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('RoomSync'), findsOneWidget);

    // Verify all 4 Navigation bar labels
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify Discover swipe deck is loaded
    expect(find.byType(SwipeDeckScreen), findsOneWidget);

    // Verify segmented tabs 'Flatmates' and 'Apartments'
    expect(find.text('Flatmates'), findsOneWidget);
    expect(find.text('Apartments'), findsOneWidget);

    // Tap 'Apartments' tab to toggle view
    await tester.tap(find.text('Apartments'));
    await tester.pumpAndSettle();

    // Verify Apartments screen elements
    expect(find.text('Williamsburg'), findsWidgets);
    expect(find.text('Furnished'), findsWidgets);
  });
}
