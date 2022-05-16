// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_app/ui/screens/counter/counter_screen.dart';

import '../../testable_widget.dart';

void main() {
  testWidgets('Counter increments and Bottom Navigation',
      (WidgetTester tester) async {
    Widget counterScreen = const CounterScreen();

    await tester.pumpWidget(getTestableWidget(counterScreen));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    expect(find.byType(Icon), findsNWidgets(4));
  });
}
