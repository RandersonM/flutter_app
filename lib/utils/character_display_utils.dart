import 'package:opfan/l10n/app_localizations.dart';

class CharacterDisplayUtils {
  static String getStatusDisplay(String? statusKey, AppLocalizations l10n) {
    if (statusKey == null) return '';
    switch (statusKey) {
      case 'alive' || 'living':
        return l10n.alive;
      case 'dead' || 'deceased':
        return l10n.dead;
      case 'captured':
        return l10n.captured;
      case 'unknown':
        return l10n.unknown;
      default:
        return statusKey;
    }
  }

  static String getOccupationDisplay(String occupationKey, AppLocalizations l10n) {
    switch (occupationKey) {
      case 'captain':
        return l10n.captain;
      case 'pirate':
        return l10n.pirate;
      case 'admiral':
        return l10n.admiral;
      case 'viceAdmiral':
        return l10n.viceAdmiral;
      case 'revolutionary':
        return l10n.revolutionary;
      case 'merchant':
        return l10n.merchant;
      case 'doctor':
        return l10n.doctor;
      case 'navigator':
        return l10n.navigator;
      case 'cook':
        return l10n.cook;
      case 'sniper':
        return l10n.sniper;
      case 'swordsman':
        return l10n.swordsman;
      case 'carpenter':
        return l10n.carpenter;
      case 'archaeologist':
        return l10n.archaeologist;
      case 'sharpshooter':
        return l10n.sharpshooter;
      case 'vicecaptain':
      case 'vice-captain':
        return l10n.viceCaptain;
      default:
        return occupationKey;
    }
  }

  static String getAffiliationDisplay(String affiliationKey, AppLocalizations l10n) {
    switch (affiliationKey) {
      case 'marines':
        return l10n.marines;
      case 'revolutionaries':
        return l10n.revolutionaries;
      case 'yonkou':
        return l10n.yonkou;
      case 'shichibukai':
        return l10n.shichibukai;
      case 'independent':
        return l10n.independent;
      case 'pirate':
        return l10n.pirate;
      case 'pirateAlliance':
        return l10n.pirateAlliance;
      default:
        return affiliationKey;
    }
  }


  static List<String> getOccupationsDisplay(List<String> occupationKeys, AppLocalizations l10n) {
    return occupationKeys.map((key) => getOccupationDisplay(key, l10n)).toList();
  }

  static List<String> getAffiliationsDisplay(List<String> affiliationKeys, AppLocalizations l10n) {
    return affiliationKeys.map((key) => getAffiliationDisplay(key, l10n)).toList();
  }
} 