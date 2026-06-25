import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';

class RoleIconMapper {
  static IconData getIconForRole(String? role) {
    if (role == null || role.isEmpty) {
      return PhosphorIconsRegular.user;
    }

    final normalizedRole = role.toLowerCase().trim();
    switch (normalizedRole) {
      case 'capitão':
      case 'capitao':
      case 'captain':
        return PhosphorIconsRegular.trophy;
      case 'vice-capitão':
      case 'vice capitao':
      case 'vice-captain':
      case 'viceCaptain':
      case 'vicecaptain':
        return PhosphorIconsRegular.star;
      case 'navegador':
      case 'navigator':
        return PhosphorIconsRegular.compass;
      case 'médico':
      case 'medico':
      case 'doctor':
        return PhosphorIconsRegular.firstAidKit;
      case 'cozinheiro':
      case 'cook':
        return PhosphorIconsRegular.forkKnife;
      case 'sharpshooter':
      case 'sniper':
        return PhosphorIconsRegular.crosshair;
      case 'lutador':
      case 'fighter':
        return PhosphorIconsRegular.personSimpleWalk;
      case 'arqueólogo':
      case 'arqueologo':
      case 'archaeologist':
        return PhosphorIconsRegular.scroll;
      case 'músico':
      case 'musico':
      case 'musician':
        return PhosphorIconsRegular.musicNote;
      case 'carpenter':
      case 'shipwright':
        return PhosphorIconsRegular.wrench;
      case 'cientista':
      case 'scientist':
        return PhosphorIconsRegular.flask;
      case 'espadachim':
      case 'swordsman':
        return PhosphorIconsRegular.fan;
      case 'guardião':
      case 'guardian':
        return PhosphorIconsRegular.shield;
      case 'observador':
      case 'lookout':
        return PhosphorIconsRegular.eye;
      case 'comerciante':
      case 'merchant':
        return PhosphorIconsRegular.storefront;
      case 'cartógrafo':
      case 'cartografo':
      case 'cartographer':
        return PhosphorIconsRegular.mapTrifold;
      case 'inventor':
        return PhosphorIconsRegular.microscope;
      case 'mecânico':
      case 'mecanico':
      case 'mechanic':
        return PhosphorIconsRegular.factory;
      default:
        return PhosphorIconsRegular.user;
    }
  }

  static Color getColorForRole(String? role, ColorScheme colorScheme) {
    if (role == null || role.isEmpty) {
      return colorScheme.primary;
    }

    final normalizedRole = role.toLowerCase().trim();

    switch (normalizedRole) {
      case 'capitão':
      case 'capitao':
      case 'captain':
        return Colors.amber;
      case 'vice-capitão':
      case 'vice capitao':
      case 'vice-captain':
      case 'vicecaptain':
        return Colors.orange;
      case 'navegador':
      case 'navigator':
        return Colors.blue;
      case 'médico':
      case 'medico':
      case 'doctor':
        return Colors.red;
      case 'cozinheiro':
      case 'cook':
        return Colors.orange;
      case 'atirador':
      case 'sniper':
        return Colors.purple;
      case 'lutador':
      case 'fighter':
        return Colors.red;
      case 'arqueólogo':
      case 'arqueologo':
      case 'archaeologist':
        return Colors.brown;
      case 'músico':
      case 'musico':
      case 'musician':
        return Colors.pink;
      case 'carpinteiro':
      case 'shipwright':
        return Colors.brown;
      case 'cientista':
      case 'scientist':
        return Colors.cyan;
      case 'espadachim':
      case 'swordsman':
        return Colors.grey;
      case 'guardião':
      case 'guardian':
        return Colors.indigo;
      case 'observador':
      case 'lookout':
        return Colors.teal;
      case 'comerciante':
      case 'merchant':
        return Colors.green;
      case 'cartógrafo':
      case 'cartografo':
      case 'cartographer':
        return Colors.blue;
      case 'inventor':
        return Colors.deepPurple;
      case 'mecânico':
      case 'mecanico':
      case 'mechanic':
        return Colors.blueGrey;
      default:
        return colorScheme.primary;
    }
  }
}
