import 'package:opfan/l10n/app_localizations.dart';

class CharacterLocalizationMapper {
  static String mapStatusToLocalized(String? status, AppLocalizations l10n) {
    switch (status?.toLowerCase()) {
      case 'alive':
        return l10n.alive;
      case 'dead':
        return l10n.dead;
      case 'unknown':
        return l10n.unknown;
      default:
        return l10n.unknown;
    }
  }

  static String mapLocalizedToStatus(String localizedStatus, AppLocalizations l10n) {
    if (localizedStatus == l10n.alive) return 'alive';
    if (localizedStatus == l10n.dead) return 'dead';
    if (localizedStatus == l10n.unknown) return 'unknown';
    return 'unknown';
  }

  static String mapAffiliationToLocalized(String affiliation, AppLocalizations l10n) {
    switch (affiliation.toLowerCase()) {
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
      case 'pirate alliance':
        return l10n.pirateAlliance;
      default:
        return affiliation;
    }
  }

  static String mapLocalizedToAffiliation(String localizedAffiliation, AppLocalizations l10n) {
    if (localizedAffiliation == l10n.marines) return 'marines';
    if (localizedAffiliation == l10n.revolutionaries) return 'revolutionaries';
    if (localizedAffiliation == l10n.yonkou) return 'yonkou';
    if (localizedAffiliation == l10n.shichibukai) return 'shichibukai';
    if (localizedAffiliation == l10n.independent) return 'independent';
    if (localizedAffiliation == l10n.pirate) return 'pirate';
    if (localizedAffiliation == l10n.pirateAlliance) return 'pirate alliance';
    return localizedAffiliation.toLowerCase(); 
  }

  static String mapOccupationToLocalized(String occupation, AppLocalizations l10n) {
    switch (occupation.toLowerCase()) {
      case 'captain':
        return l10n.captain;
      case 'admiral':
        return l10n.admiral;
      case 'vice admiral':
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
      case 'musician':
        return l10n.musician;
      case 'vicecaptain':
      case 'vice-captain':
      case 'vice captain':
        return l10n.viceCaptain;
      default:
        return occupation;
    }
  } 

  static String mapLocalizedToOccupation(String localizedOccupation, AppLocalizations l10n) {
    if (localizedOccupation == l10n.captain) return 'captain';
    if (localizedOccupation == l10n.viceCaptain) return 'vicecaptain';
    if (localizedOccupation == l10n.admiral) return 'admiral';
    if (localizedOccupation == l10n.viceAdmiral) return 'vice admiral';
    if (localizedOccupation == l10n.revolutionary) return 'revolutionary';
    if (localizedOccupation == l10n.merchant) return 'merchant';
    if (localizedOccupation == l10n.doctor) return 'doctor';
    if (localizedOccupation == l10n.navigator) return 'navigator';
    if (localizedOccupation == l10n.cook) return 'cook';
    if (localizedOccupation == l10n.sniper) return 'sniper';
    if (localizedOccupation == l10n.swordsman) return 'swordsman';
    if (localizedOccupation == l10n.carpenter) return 'carpenter';
    if (localizedOccupation == l10n.archaeologist) return 'archaeologist';
    if (localizedOccupation == l10n.sharpshooter) return 'sharpshooter';
    return localizedOccupation.toLowerCase(); // Return lowercase if no mapping found
  }

  static String mapHakiToLocalized(String haki, AppLocalizations l10n) {
    switch (haki.toLowerCase()) {
      case 'haoshoku haki (king\'s haki)':
        return l10n.haoshokuHaki;
      case 'busoshoku haki (armament haki)':
        return l10n.busoshokuHaki;
      case 'kenbunshoku haki (observation haki)':
        return l10n.kenbunshokuHaki;
      default:
        return haki;
    }
  }

  static String mapLocalizedToHaki(String localizedHaki, AppLocalizations l10n) {
    if (localizedHaki == l10n.haoshokuHaki) return 'haoshoku haki (king\'s haki)';
    if (localizedHaki == l10n.busoshokuHaki) return 'busoshoku haki (armament haki)';
    if (localizedHaki == l10n.kenbunshokuHaki) return 'kenbunshoku haki (observation haki)';
    return localizedHaki.toLowerCase(); // Return lowercase if no mapping found
  }

  static List<String> getLocalizedStatusOptions(AppLocalizations l10n) {
    return [l10n.alive, l10n.dead, l10n.unknown];
  }

  static List<String> getLocalizedAffiliationOptions(AppLocalizations l10n) {
    return [
      l10n.marines,
      l10n.revolutionaries,
      l10n.yonkou,
      l10n.shichibukai,
      l10n.independent,
      l10n.pirate,
      l10n.pirateAlliance,
    ];
  }

  static List<String> getLocalizedOccupationOptions(AppLocalizations l10n) {
    return [
      l10n.captain,
      l10n.viceCaptain,
      l10n.admiral,
      l10n.viceAdmiral,
      l10n.revolutionary,
      l10n.merchant,
      l10n.doctor,
      l10n.navigator,
      l10n.cook,
      l10n.sniper,
      l10n.swordsman,
      l10n.carpenter,
      l10n.archaeologist,
      l10n.sharpshooter,
    ];
  }

  static List<String> getLocalizedHakiOptions(AppLocalizations l10n) {
    return [
      l10n.haoshokuHaki,
      l10n.busoshokuHaki,
      l10n.kenbunshokuHaki,
    ];
  }
} 