// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:simple_app/core/models/one_piece/character.dart';
import 'package:simple_app/shared/constants.dart';
import 'package:simple_app/shared/transitions/material_page_route_with_slide_right_transition.dart';

import '../details/character_details_screen.dart';

class CharacterCard extends StatefulWidget {
  final Character character;

  const CharacterCard({Key? key, required this.character}) : super(key: key);

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  late Image image;

  @override
  void didChangeDependencies() {
    precacheImage(image.image, context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    image = Image.network(widget.character.image, loadingBuilder:
        (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRouteWithSlideRightTransition(
              builder: (_) =>
                  CharacterDetailsScreen(character: widget.character)),
        ),
        child: Card(
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(Constants.margin * 2)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Constants.margin * 2),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: image.image,
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
      );
}
