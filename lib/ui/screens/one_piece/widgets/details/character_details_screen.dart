// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:simple_app/core/models/one_piece/character.dart';
import 'package:simple_app/shared/app_bar/default_app_bar.dart';
import 'package:simple_app/shared/bottom_navigation/bottom_navigation.dart';
import 'package:simple_app/shared/constants.dart';

import 'fields/details_affiliation.dart';
import 'fields/details_bounty.dart';
import 'fields/details_haki.dart';
import 'fields/details_image.dart';
import 'fields/details_name.dart';
import 'fields/details_occupation.dart';

class CharacterDetailsScreen extends StatelessWidget {
  const CharacterDetailsScreen({Key? key, required this.character})
      : super(key: key);

  final Character character;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: DefaultAppBar(
          title: Text(character.nickname ?? character.name),
        ),
        body: CustomScrollView(slivers: <Widget>[
          DetailsImage(image: character.image),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
            child: DetailsName(
              name: character.name,
              nickname: character.nickname,
              devilFruit: character.devilFruit,
            ),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.only(
                top: Constants.margin * 2, bottom: Constants.margin),
            child: DetailsBounty(bounty: character.bounty),
          )),
          SliverToBoxAdapter(
            child: DetailsAffiliation(affiliations: character.affiliations),
          ),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Constants.margin * 2),
            child: DetailsOccupation(occupations: character.occupation),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.only(bottom: Constants.margin * 2),
            child: DetailsHaki(haki: character.haki),
          ))
        ]),
        bottomNavigationBar:
            const BottomNavigation(BottomNavigationPages.onePiece),
      );
}
