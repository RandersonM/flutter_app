// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

import 'package:opfan/core/models/one_piece/character.dart';
import 'package:opfan/screens/one_piece/widgets/details/fields/details_affiliation.dart';
import 'package:opfan/screens/one_piece/widgets/details/fields/details_bounty.dart';
import 'package:opfan/screens/one_piece/widgets/details/fields/details_haki.dart';
import 'package:opfan/screens/one_piece/widgets/details/fields/details_image.dart';
import 'package:opfan/screens/one_piece/widgets/details/fields/details_name.dart';
import 'package:opfan/screens/one_piece/widgets/details/fields/details_occupation.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/bottom_navigation.dart';
import 'package:opfan/utils/constants.dart';

class CharacterDetailsScreen extends StatefulWidget {
  const CharacterDetailsScreen({Key? key, required this.character})
      : super(key: key);

  final Character character;

  @override
  State<CharacterDetailsScreen> createState() => _CharacterDetailsScreenState();
}

class _CharacterDetailsScreenState extends State<CharacterDetailsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: DefaultAppBar(
          title: Text(widget.character.nickname ?? widget.character.name),
        ),
        body: CustomScrollView(controller: _scrollController, slivers: <Widget>[
          DetailsImage(image: widget.character.image),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
            child: DetailsName(
              name: widget.character.name,
              nickname: widget.character.nickname,
              devilFruit: widget.character.devilFruit,
            ),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.only(
                top: Constants.margin * 2, bottom: Constants.margin),
            child: DetailsBounty(bounty: widget.character.bounty),
          )),
          SliverToBoxAdapter(
            child:
                DetailsAffiliation(affiliations: widget.character.affiliations),
          ),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Constants.margin * 2),
            child: DetailsOccupation(occupations: widget.character.occupation),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.only(bottom: Constants.margin * 2),
            child: DetailsHaki(haki: widget.character.haki),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
        bottomNavigationBar:
            const BottomNavigation(BottomNavigationPages.onePiece),
      );
}
