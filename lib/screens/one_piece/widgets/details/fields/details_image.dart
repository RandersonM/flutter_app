// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:simple_app/shared/constants.dart';

class DetailsImage extends StatelessWidget {
  const DetailsImage({Key? key, required this.image}) : super(key: key);

  final String image;
  @override
  Widget build(BuildContext context) => SliverAppBar(
        leading: Container(),
        forceElevated: true,
        backgroundColor: Colors.white,
        expandedHeight: MediaQuery.of(context).size.height / 3,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            margin: const EdgeInsets.all(Constants.margin),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                    Radius.circular(Constants.margin * 3)),
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                      image,
                    ))),
          ),
        ),
      );
}
