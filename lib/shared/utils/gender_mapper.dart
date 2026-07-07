import 'package:opfan/l10n/app_localizations.dart';

class GenderMapper {
  static const String male = 'male';
  static const String female = 'female';

  static String getInternalValue(String localizedValue, AppLocalizations loc) {
    if (localizedValue == loc.workout_gender_male) {
      return male;
    } else if (localizedValue == loc.workout_gender_female) {
      return female;
    }
    return localizedValue; // fallback
  }

  static String getLocalizedValue(String internalValue, AppLocalizations loc) {
    switch (internalValue) {
      case male:
        return loc.workout_gender_male;
      case female:
        return loc.workout_gender_female;
      default:
        return internalValue; // fallback
    }
  }

  static List<String> getLocalizedOptions(AppLocalizations loc) {
    return [loc.workout_gender_male, loc.workout_gender_female];
  }

  static List<String> getInternalOptions() {
    return [male, female];
  }
}
