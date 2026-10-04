// Basic smoke test for the DevSnap app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:devsnap/main.dart';

void main() {
  testWidgets('App launches and shows the puzzle sandbox', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DevSnapTwoApp());

    // The initial view shows the starting stats.
    expect(find.text('5'), findsOneWidget); // hearts
    expect(find.text('150'), findsOneWidget); // coins

    // Selecting the correct answer and checking it awards coins.
    await tester.tap(find.text('print'));
    await tester.pump();
    await tester.tap(find.text('CHECK'));
    await tester.pump();

    expect(find.text('Correct!'), findsOneWidget);
  });
}
