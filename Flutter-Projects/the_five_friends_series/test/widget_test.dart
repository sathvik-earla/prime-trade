// Basic smoke tests for the BookVerse app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_five_friends_series/main.dart';

/// Logs in as an owner and waits for the app to settle.
Future<void> _logIn(
  WidgetTester tester, {
  String email = 'earlasathvik.rs@gmail.com',
  String password = 'RTS590',
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('App requires owner login before showing any content',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BookVerseApp());

    expect(find.text('Owner Login Required'), findsOneWidget);
    expect(find.text('Featured Books'), findsNothing);
  });

  testWidgets('Login rejects non-owner credentials',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BookVerseApp());

    await _logIn(tester,
        email: 'not-an-owner@gmail.com', password: 'wrongpass');

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('Owner Login Required'), findsOneWidget);
  });

  testWidgets('Both owners can log in and reach the home page',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BookVerseApp());
    await _logIn(tester, email: 'earlasathvik.rs@gmail.com');

    expect(find.text('📚 BookVerse'), findsOneWidget);
    expect(find.text('Featured Books'), findsOneWidget);
    // The title appears twice: once on the cover art, once as the caption.
    expect(find.text('Mystery of Room 13'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    expect(find.text('Owner Login Required'), findsOneWidget);

    await tester.pumpWidget(const BookVerseApp());
    await _logIn(tester, email: 'weakongames83@gmail.com');
    expect(find.text('📚 BookVerse'), findsOneWidget);
  });

  testWidgets('Navigating to My Library shows empty state',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BookVerseApp());
    await _logIn(tester);

    await tester.tap(find.widgetWithText(TextButton, 'My Library'));
    await tester.pumpAndSettle();

    expect(find.text('❤️ My Library'), findsOneWidget);
    expect(find.text('Your library is empty. Add some books!'),
        findsOneWidget);
  });

  testWidgets('Publish form validates required fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BookVerseApp());
    await _logIn(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Publish'));
    await tester.pumpAndSettle();

    final publishButton = find.widgetWithText(ElevatedButton, 'Publish Book');
    await tester.ensureVisible(publishButton);
    await tester.tap(publishButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please enter author name'), findsOneWidget);
    expect(find.text('Please enter a description'), findsOneWidget);
  });

  testWidgets('Logging out returns to the login gate',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BookVerseApp());
    await _logIn(tester);

    expect(find.text('📚 BookVerse'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Owner Login Required'), findsOneWidget);
  });
}
