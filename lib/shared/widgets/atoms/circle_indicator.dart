// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

class CircleIndicator extends StatelessWidget {
  const CircleIndicator({
    super.key,
    required this.isActive,
    this.activeColor,
    this.inactiveColor,
    this.size = 8.0,
    this.margin,
  });

  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 4),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? (activeColor ?? theme.primaryColor)
            : (inactiveColor ?? Colors.grey[300]),
      ),
    );
  }
}
