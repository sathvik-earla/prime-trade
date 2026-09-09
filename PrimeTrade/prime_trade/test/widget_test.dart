// Basic smoke test for the Prime Trade app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:prime_trade/config.dart';
import 'package:prime_trade/main.dart';

void main() {
  testWidgets('Prime Trade app renders workspace smoke test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PrimeTradeFramework());
    await tester.pump();

    // Verify the app bar title and key section headers render.
    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.text('LIVE ASSET MATRIX'), findsOneWidget);
  });
}
