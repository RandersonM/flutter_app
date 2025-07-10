// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/widgets/atoms/clickable_image.dart';

class DetailsImage extends StatelessWidget {
  final String image;
  const DetailsImage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClickableImage(
      imageUrl: image,
      width: double.infinity,
      height: 320,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.zero,
      showTitleInDialog: false,
    );
  }
}
