import 'package:phosphor_flutter/phosphor_flutter.dart';
// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import '../atoms/circle_avatar.dart';

class ClickableAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData? fallbackIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;

  const ClickableAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20.0,
    this.fallbackIcon = PhosphorIconsRegular.user,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatarAtom(
        imageUrl: imageUrl,
        radius: radius,
        fallbackIcon: fallbackIcon,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }
}

class AvatarDrawer extends StatelessWidget {
  final Widget child;
  final Widget drawerContent;

  const AvatarDrawer({
    super.key,
    required this.child,
    required this.drawerContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0.0,
        child: drawerContent,
      ),
    );
  }
}
