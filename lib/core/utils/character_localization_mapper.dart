import 'package:opfan/l10n/app_localizations.dart';

class CharacterLocalizationMapper {
  static String mapOccupationToLocalized(
      String occupation, AppLocalizations l10n) {
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
      case 'helmsman':
        return l10n.helmsman;
      case 'boatswain':
        return l10n.boatswain;
      case 'combatent':
        return l10n.fighter;
      default:
        return occupation;
    }
  }

  static String mapLocalizedToOccupation(
      String localizedOccupation, AppLocalizations l10n) {
    if (localizedOccupation == l10n.captain) return 'captain';
    if (localizedOccupation == l10n.viceCaptain) return 'vicecaptain';
    if (localizedOccupation == l10n.admiral) return 'admiral';
    if (localizedOccupation == l10n.viceAdmiral) return 'vice admiral';
    if (localizedOccupation == l10n.revolutionary) return 'revolutionary';
    if (localizedOccupation == l10n.merchant) return 'merchant';
    if (localizedOccupation == l10n.doctor) return 'doctor';
    if (localizedOccupation == l10n.musician) return 'musician';
    if (localizedOccupation == l10n.navigator) return 'navigator';
    if (localizedOccupation == l10n.cook) return 'cook';
    if (localizedOccupation == l10n.sniper) return 'sniper';
    if (localizedOccupation == l10n.carpenter) return 'carpenter';
    if (localizedOccupation == l10n.archaeologist) return 'archaeologist';
    if (localizedOccupation == l10n.sharpshooter) return 'sharpshooter';
    return localizedOccupation
        .toLowerCase(); // Return lowercase if no mapping found
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

  static String mapLocalizedToHaki(
      String localizedHaki, AppLocalizations l10n) {
    if (localizedHaki == l10n.haoshokuHaki)
      return 'haoshoku haki (king\'s haki)';
    if (localizedHaki == l10n.busoshokuHaki)
      return 'busoshoku haki (armament haki)';
    if (localizedHaki == l10n.kenbunshokuHaki)
      return 'kenbunshoku haki (observation haki)';
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
      l10n.carpenter,
      l10n.archaeologist,
      l10n.sharpshooter,
      l10n.musician,
    ];
  }

  static List<String> getRaces() {
    return [
      'human',
      'giant',
      'fishman',
      'mermaid',
      'mink',
      'lunarian',
      'buccaneer',
      'oni',
      'skypiean',
      'longarm',
      'tonatta',
    ];
  }

  static String getRaceLabel(String race, AppLocalizations l10n) {
    final raceMapping = {
      'human': l10n.human,
      'giant': l10n.giant,
      'fishman': l10n.fishman,
      'mermaid': l10n.mermaid,
      'mink': l10n.mink,
      'lunarian': l10n.lunarian,
      'buccaneer': l10n.buccaneer,
      'oni': l10n.oni,
      'skypiean': l10n.skypiean,
      'longarm': l10n.longarm,
      'tonatta': l10n.tonatta,
    };
    return raceMapping[race] ?? race;
  }

  static List<String> getLocalizedHakiOptions(AppLocalizations l10n) {
    return [
      l10n.haoshokuHaki,
      l10n.busoshokuHaki,
      l10n.kenbunshokuHaki,
    ];
  }

  static List<String> getLocalizedRaceOptions(AppLocalizations l10n) {
    return [
      l10n.human,
      l10n.giant,
      l10n.fishman,
      l10n.mermaid,
      l10n.mink,
      l10n.lunarian,
      l10n.buccaneer,
      l10n.oni,
      l10n.skypiean,
      l10n.longarm,
      l10n.tonatta,
    ];
  }

  static List<String> getFightingTypes() {
    return [
      'devil_fruit',
      'swordsman',
      'dual-wielder',
      'sharpshooter',
      'sniper',
      'fighter',
      'taekwondo',
      'kicker',
      'archer',
      'staff',
      'other',
    ];
  }

  static String getFightingTypeLabel(String type, AppLocalizations l10n) {
    final typeMapping = {
      'devil_fruit': l10n.devilFruit,
      'swordsman': l10n.swordsman,
      'dual-wielder': l10n.dualWielder,
      'sharpshooter': l10n.sniper,
      'sniper': l10n.sniper,
      'fighter': l10n.fighter,
      'taekwondo': l10n.taekwondo,
      'kicker': l10n.kicker,
      'archer': l10n.archer,
      'staff': l10n.staff,
      'other': l10n.other,
    };
    return typeMapping[type] ?? type;
  }

  static List<String> getOccupations() {
    return [
      'captain',
      'viceCaptain',
      'navigator',
      'cook',
      'doctor',
      'sharpshooter',
      'carpenter',
      'archaeologist',
      'musician',
      'helmsman',
      'boatswain',
    ];
  }

  static String mapStatusToLocalized(String? statusKey, AppLocalizations l10n) {
    if (statusKey == null) return '';
    switch (statusKey.toLowerCase()) {
      case 'alive':
      case 'living':
        return l10n.alive;
      case 'dead':
      case 'deceased':
        return l10n.dead;
      case 'captured':
      case 'imprisoned':
        return l10n.captured;
      case 'unknown':
        return l10n.unknown;
      default:
        return statusKey;
    }
  }

  static String mapLocalizedToStatus(
      String localizedStatus, AppLocalizations l10n) {
    if (localizedStatus == l10n.alive) return 'alive';
    if (localizedStatus == l10n.dead) return 'dead';
    if (localizedStatus == l10n.captured) return 'captured';
    if (localizedStatus == l10n.unknown) return 'unknown';
    return localizedStatus.toLowerCase();
  }

  static List<String> mapAffiliationsToLocalized(
      List<String> affiliationKeys, AppLocalizations l10n) {
    return affiliationKeys
        .map((key) => mapAffiliationToLocalized(key, l10n))
        .toList();
  }

  static String mapAffiliationToLocalized(
      String affiliationKey, AppLocalizations l10n) {
    switch (affiliationKey.toLowerCase()) {
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
      case 'piratealliance':
        return l10n.pirateAlliance;
      default:
        return affiliationKey;
    }
  }

  static String mapLocalizedToAffiliation(
      String localizedAffiliation, AppLocalizations l10n) {
    if (localizedAffiliation == l10n.marines) return 'marines';
    if (localizedAffiliation == l10n.revolutionaries) return 'revolutionaries';
    if (localizedAffiliation == l10n.yonkou) return 'yonkou';
    if (localizedAffiliation == l10n.shichibukai) return 'shichibukai';
    if (localizedAffiliation == l10n.independent) return 'independent';
    if (localizedAffiliation == l10n.pirate) return 'pirate';
    if (localizedAffiliation == l10n.pirateAlliance) return 'piratealliance';
    return localizedAffiliation.toLowerCase();
  }

  static List<String> mapOccupationsToLocalized(
      List<String> occupationKeys, AppLocalizations l10n) {
    return occupationKeys
        .map((key) => mapOccupationToLocalized(key, l10n))
        .toList();
  }

  static List<String> mapHakiListToLocalized(
      List<String> hakiList, AppLocalizations l10n) {
    return hakiList.map((haki) => mapHakiToLocalized(haki, l10n)).toList();
  }
}
