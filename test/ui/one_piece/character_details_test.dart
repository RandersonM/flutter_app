// Developed by Randerson Mayllon
// Copyright © 2022.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_app/core/models/one_piece/character.dart';

import 'package:simple_app/ui/screens/one_piece/widgets/details/character_details_screen.dart';

import '../../testable_widget.dart';

void main() {
  setUpAll(() => HttpOverrides.global = null);

  group('Character Details Screen', () {
    const Key charactersKey = Key('charactersKey');
    File file = File('test/fixtures/character_list.json');
    List<Character> characters =
        (jsonDecode(file.readAsStringSync())['characters'] as List)
            .map((e) => Character.fromJson(e))
            .toList();

    Widget charactersDetails = CharacterDetailsScreen(
      key: charactersKey,
      character: characters.first,
    );

    testWidgets('Assert fields are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(getTestableWidget(charactersDetails));
      await tester.pump();
      expect(find.byType(Card), findsNWidgets(3));
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(ExpansionTile), findsNWidgets(2));
    });

    testWidgets('Assert fields are filled', (WidgetTester tester) async {
      await tester.pumpWidget(getTestableWidget(charactersDetails));
      await tester.pump();
      expect(find.text('Bounty'), findsOneWidget);
      expect(find.text('Affiliation'), findsOneWidget);
      expect(find.text('Occupation'), findsOneWidget);
    });
  });
}
