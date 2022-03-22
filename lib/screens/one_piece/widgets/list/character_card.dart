// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/core/one_piece/models/character.dart';
import 'package:simple_app/screens/one_piece/widgets/details/character_details_screen.dart';
import 'package:simple_app/shared/constants.dart';

class CharacterCard extends StatefulWidget {
  final Character character;

  const CharacterCard({Key? key, required this.character}) : super(key: key);

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  late NetworkImage image;

  @override
  void didChangeDependencies() {
    precacheImage(
        NetworkImage(
          widget.character.image,
        ),
        context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    image = NetworkImage(widget.character.image);
  }

  @override
  Widget build(BuildContext context) => Hero(
        tag: widget.character.image,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) =>
                      CharacterDetailsScreen(character: widget.character)),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(Constants.margin * 2)),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.margin * 2),
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: image,
                    ),
                  ),
                ),
                Text(widget.character.name,
                    style: Theme.of(context).textTheme.caption!.merge(TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .appBarTheme
                            .titleTextStyle!
                            .color))),
              ],
            ),
          ),
        ),
      );
}
