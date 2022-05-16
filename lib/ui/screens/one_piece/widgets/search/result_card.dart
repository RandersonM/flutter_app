// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/core/models/one_piece/character.dart';

import '../details/character_details_screen.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({Key? key, required this.character}) : super(key: key);

  final Character character;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.onSecondary,
        child: ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) =>
                    CharacterDetailsScreen(character: character)),
          ),
          leading: CircleAvatar(
              radius: 24, backgroundImage: NetworkImage(character.image)),
          title: Text(character.name),
          subtitle: Text(character.nickname ?? character.bounty),
        ),
      );
}
