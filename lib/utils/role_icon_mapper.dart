import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RoleIconMapper {
  static IconData getIconForRole(String? role) {
    if (role == null || role.isEmpty) {
      return Icons.person;
    }

    final normalizedRole = role.toLowerCase().trim();
    switch (normalizedRole) {
      case 'capitão':
      case 'capitao':
      case 'captain':
        return Icons.emoji_events;
      case 'vice-capitão':
      case 'vice capitao':
      case 'vice-captain':
      case 'viceCaptain':
      case 'vicecaptain':
        return Icons.star;
      case 'navegador':
      case 'navigator':
        return FontAwesomeIcons.compass;
      case 'médico':
      case 'medico':
      case 'doctor':
        return FontAwesomeIcons.kitMedical;
      case 'cozinheiro':
      case 'cook':
        return Icons.restaurant;
      case 'sharpshooter':
      case 'sniper':
        return FontAwesomeIcons.personRifle;
      case 'lutador':
      case 'fighter':
        return Icons.sports_martial_arts;
      case 'arqueólogo':
      case 'arqueologo':
      case 'archaeologist':
        return Icons.history_edu;
      case 'músico':
      case 'musico':
      case 'musician':
        return Icons.music_note;
      case 'carpenter':
      case 'shipwright':
        return Icons.handyman;
      case 'cientista':
      case 'scientist':
        return Icons.science;
      case 'espadachim':
      case 'swordsman':
        return FontAwesomeIcons.fan;
      case 'guardião':
      case 'guardian':
        return Icons.shield_outlined;
      case 'observador':
      case 'lookout':
        return Icons.visibility;
      case 'comerciante':
      case 'merchant':
        return Icons.store;
      case 'cartógrafo':
      case 'cartografo':
      case 'cartographer':
        return Icons.map;
      case 'inventor':
        return FontAwesomeIcons.microscope;
      case 'mecânico':
      case 'mecanico':
      case 'mechanic':
        return Icons.precision_manufacturing;
      default:
        return Icons.person;
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