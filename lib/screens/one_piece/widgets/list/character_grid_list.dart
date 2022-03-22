// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/screens/one_piece/widgets/list/character_card.dart';
import 'package:simple_app/shared/constants.dart';

class CharacterGridList extends StatelessWidget {
  const CharacterGridList({Key? key, required this.characters})
      : super(key: key);

  final List<Character> characters;

  @override
  Widget build(BuildContext context) => GridView.count(
      crossAxisCount: 2,
      children: characters
          .map((Character character) => Padding(
                padding: const EdgeInsets.all(Constants.margin),
                child: CharacterCard(
                  character: character,
                ),
              ))
          .toList());
}
