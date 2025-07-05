// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:opfan/core/models/one_piece/character.dart';
import 'package:opfan/screens/one_piece/widgets/list/character_card.dart';
import 'package:opfan/utils/constants.dart';

class CharacterGridList extends StatelessWidget {
  const CharacterGridList({
    Key? key,
    required this.characters,
    this.controller,
  }) : super(key: key);

  final List<Character> characters;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) => GridView.count(
      controller: controller,
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      padding: const EdgeInsets.all(Constants.margin),
      mainAxisSpacing: Constants.margin,
      crossAxisSpacing: Constants.margin,
      children: characters
          .map((Character character) => CharacterCard(
                character: character,
              ))
          .toList());
}
