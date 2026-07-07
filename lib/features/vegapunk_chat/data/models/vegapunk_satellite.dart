import 'package:opfan/l10n/app_localizations.dart';

enum VegapunkSatellite {
  stella,
  shaka,
  lilith,
  edison,
  pythagoras,
  atlas,
  york;

  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case VegapunkSatellite.stella:
        return l10n.vegapunkSatelliteStella;
      case VegapunkSatellite.shaka:
        return l10n.vegapunkSatelliteShaka;
      case VegapunkSatellite.lilith:
        return l10n.vegapunkSatelliteLilith;
      case VegapunkSatellite.edison:
        return l10n.vegapunkSatelliteEdison;
      case VegapunkSatellite.pythagoras:
        return l10n.vegapunkSatellitePythagoras;
      case VegapunkSatellite.atlas:
        return l10n.vegapunkSatelliteAtlas;
      case VegapunkSatellite.york:
        return l10n.vegapunkSatelliteYork;
    }
  }
}
