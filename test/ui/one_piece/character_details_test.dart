import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opfan/features/custom_character/data/models/custom_character_model.dart';



import 'package:opfan/features/one_piece/presentation/widgets/details/character_details_screen.dart';
import 'package:opfan/shared/widgets/molecules/default_app_bar.dart';

import '../../testable_widget.dart';

void main() {
  group('Character Details Screen', () {
    const Key charactersKey = Key('charactersKey');
    File file = File('test/fixtures/character_list.json');
    List<CustomCharacterModel> characters =
        (jsonDecode(file.readAsStringSync())['characters'] as List)
            .map((e) => CustomCharacterModel.fromJson(e))
            .toList();

    Widget charactersDetails = CharacterDetailsScreen(
      key: charactersKey,
      character: characters.first,
    );

    testWidgets('Assert fields are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(getTestableWidget(charactersDetails));
      await tester.pump();
      expect(find.byType(Card), findsAtLeastNWidgets(1));
      expect(find.byType(DefaultAppBar), findsOneWidget);
    });

    testWidgets('Assert fields are filled', (WidgetTester tester) async {
      await tester.pumpWidget(getTestableWidget(charactersDetails));
      await tester.pump();
      expect(find.text('Gol D. Roger'), findsWidgets);
      expect(find.text('Pirate King'), findsWidgets);
    });
  });
}
