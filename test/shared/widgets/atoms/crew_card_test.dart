import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/crews/data/models/crew_model.dart';
import 'package:opfan/shared/widgets/atoms/crew_card.dart';

import '../../../testable_widget.dart';

void main() {
  group('CrewCard behaviour', () {
    Future<void> pumpCard(WidgetTester tester, CrewModel crew) => tester
        .pumpWidget(getTestableWidget(Scaffold(body: CrewCard(crew: crew))));

    testWidgets('hides the captain row once the captain was removed', (
      tester,
    ) async {
      await pumpCard(
        tester,
        CrewModel(
          name: 'Straw Hats',
          userId: 'alice',
          captain: '',
          viceCaptain: 'Zoro',
        ),
      );

      expect(find.text('Vice Captain: Zoro'), findsOneWidget);
      expect(find.text('Captain: '), findsNothing);
    });

    testWidgets('shows neither row when both were removed', (tester) async {
      await pumpCard(
        tester,
        CrewModel(
          name: 'Straw Hats',
          userId: 'alice',
          captain: '',
          viceCaptain: '',
        ),
      );

      expect(find.textContaining('Captain'), findsNothing);
    });
  });
}
