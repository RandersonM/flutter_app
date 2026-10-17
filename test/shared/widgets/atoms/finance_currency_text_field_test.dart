import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/shared/widgets/atoms/finance_currency_text_field.dart';

import '../../../testable_widget.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pumpField(WidgetTester tester) => tester.pumpWidget(
    getTestableWidget(
      Scaffold(
        body: FinanceCurrencyTextField(label: 'Amount', controller: controller),
      ),
    ),
  );

  group('FinanceCurrencyTextField behaviour', () {
    testWidgets('formats typed digits as cents', (tester) async {
      await pumpField(tester);

      await tester.enterText(find.byType(TextFormField), '123456');

      expect(controller.text, '1.234,56');
    });

    testWidgets('keeps the last valid amount when a huge number is pasted', (
      tester,
    ) async {
      await pumpField(tester);
      await tester.enterText(find.byType(TextFormField), '1500');

      await tester.enterText(find.byType(TextFormField), '9' * 40);

      expect(tester.takeException(), isNull);
      expect(controller.text, '15,00');
    });
  });
}
