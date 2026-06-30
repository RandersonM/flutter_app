import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';

class CircleAvatarAtom extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData? fallbackIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CircleAvatarAtom({
    super.key,
    this.imageUrl,
    this.radius = 20.0,
    this.fallbackIcon = PhosphorIconsRegular.user,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      foregroundColor:
          foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null ? Icon(fallbackIcon) : null,
    );
  }
}
