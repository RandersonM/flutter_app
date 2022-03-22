// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_app/screens/counter/counter_screen.dart';

import '../../testable_widget.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    Widget howToWidget = const CounterScreen();

    await tester.pumpWidget(getTestableWidget(howToWidget));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
