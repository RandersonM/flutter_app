import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// Text show at bounty section on character detail screen
  ///
  /// In en, this message translates to:
  /// **'Affiliation'**
  String get affiliation;

  /// Filter label on search section one piece
  ///
  /// In en, this message translates to:
  /// **'Beasts Pirates'**
  String get beastsPirates;

  /// Filter label on search section one piece
  ///
  /// In en, this message translates to:
  /// **'Big Mom Pirates'**
  String get bigMomPirates;

  /// Text show at bounty section on character detail screen
  ///
  /// In en, this message translates to:
  /// **'Bounty'**
  String get bounty;

  /// Shows title for Calculator screen
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculatorTitle;

  /// Shows title for Counter screen
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counterTitle;

  /// Text shown at character detail screen
  ///
  /// In en, this message translates to:
  /// **'User of'**
  String get devilFruitUserPrefix;

  /// Filter label on search section one piece
  ///
  /// In en, this message translates to:
  /// **'Four Emperors'**
  String get emperors;

  /// Text show at haki section on character details
  ///
  /// In en, this message translates to:
  /// **'Haki'**
  String get haki;

  /// Home text
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Text shown at counter screen.
  ///
  /// In en, this message translates to:
  /// **'You have pushed the button this many times:'**
  String get howManyPushPhrase;

  /// Text shown at search screen when there were no research done yet at search bar after one or filters have been applied
  ///
  /// In en, this message translates to:
  /// **'No research done yet.'**
  String get noResearchYet;

  /// Text shown at search screen when there were no results found at search bar after one or more filters have been applied
  ///
  /// In en, this message translates to:
  /// **'No results found for'**
  String get noResultsFound;

  /// Text show at occupation section on character detail screen
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// Subtitle for bottom menu one piece option
  ///
  /// In en, this message translates to:
  /// **'One Piece'**
  String get onePiece;

  /// Text shown on the result section on calculator screen
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// Text shown at search section
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter label on search section one piece
  ///
  /// In en, this message translates to:
  /// **'Super Rookie'**
  String get superRookie;

  /// Filter label on search section one piece
  ///
  /// In en, this message translates to:
  /// **'Straw Hat Pirates'**
  String get strawHat;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
