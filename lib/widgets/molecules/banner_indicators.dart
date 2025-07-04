// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import '../atoms/circle_indicator.dart';

/// Molecular component - Banner indicators row using CircleIndicator atoms
class BannerIndicators extends StatelessWidget {
  const BannerIndicators({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
    this.indicatorSize = 8.0,
    this.spacing = 4.0,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final int itemCount;
  final int currentIndex;
  final Color? activeColor;
  final Color? inactiveColor;
  final double indicatorSize;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: List.generate(
        itemCount,
        (index) => CircleIndicator(
          isActive: currentIndex == index,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          size: indicatorSize,
          margin: EdgeInsets.symmetric(horizontal: spacing),
        ),
      ),
    );
  }
}
