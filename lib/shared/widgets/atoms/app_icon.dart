import 'package:flutter/material.dart';

/// Componente atômico para gerenciamento centralizado de ícones.
/// Atualmente renderiza o [IconData] usando o widget nativo [Icon],
/// ideal para a biblioteca [phosphor_flutter].
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color, semanticLabel: semanticLabel);
  }
}
