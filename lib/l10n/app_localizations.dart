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

  /// Text show at bounty section on character detail screen with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {Affiliation} =1 {Affiliation} other {Affiliations}}'**
  String affiliation(num count);

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

  /// Text show at occupation section on character detail screen with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {Occupation} =1 {Occupation} other {Occupations}}'**
  String occupation(num count);

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

  /// Title for featured character section on home screen
  ///
  /// In en, this message translates to:
  /// **'Featured Character'**
  String get featuredCharacter;

  /// Button text to load a random character
  ///
  /// In en, this message translates to:
  /// **'Random Character'**
  String get randomCharacter;

  /// Button text to refresh content
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Title for details section
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get statistics;

  /// Label for my characters
  ///
  /// In en, this message translates to:
  /// **'My Characters'**
  String get myCharacters;

  /// Label for total characters statistic
  ///
  /// In en, this message translates to:
  /// **'Total Characters'**
  String get totalCharacters;

  /// Label for highest bounty statistic
  ///
  /// In en, this message translates to:
  /// **'Highest Bounty'**
  String get highestBounty;

  /// Label for crews statistic
  ///
  /// In en, this message translates to:
  /// **'Crews'**
  String get crews;

  /// Loading message when searching for YouTube video
  ///
  /// In en, this message translates to:
  /// **'Searching AMV video...'**
  String get searchingVideo;

  /// Error message when character fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading character'**
  String get loadingError;

  /// Button text to retry an action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// General loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Text shown when character image cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Image\nUnavailable'**
  String get imageUnavailable;

  /// Button text to open character selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Character'**
  String get selectCharacter;

  /// Label for zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Zodiac Sign'**
  String get signo;

  /// Label for status when devil fruit is not available
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Button text to edit an item
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button text to delete an item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Text shown when no image is available
  ///
  /// In en, this message translates to:
  /// **'No Image'**
  String get noImage;

  /// Title for create custom character screen
  ///
  /// In en, this message translates to:
  /// **'Create Custom Character'**
  String get createCustomCharacterTitle;

  /// Subtitle for create custom character screen
  ///
  /// In en, this message translates to:
  /// **'Fill in the information below to create your unique character in the One Piece world!'**
  String get createCustomCharacterSubtitle;

  /// Section title for basic character information
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// Label for character name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Validation message for required name field
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get nameRequired;

  /// Hint text for name field
  ///
  /// In en, this message translates to:
  /// **'Ex: Monkey D. Luffy'**
  String get nameHint;

  /// Label for character nickname field
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// Hint text for nickname field
  ///
  /// In en, this message translates to:
  /// **'Ex: Luffy, Straw Hat'**
  String get nicknameHint;

  /// Label for character age field
  ///
  /// In en, this message translates to:
  /// **'Idade'**
  String get age;

  /// Label for character birth date field
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// Hint text for birth date field
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get birthDateHint;

  /// Section title for character powers
  ///
  /// In en, this message translates to:
  /// **'Powers'**
  String get powers;

  /// Hint text for devil fruit field
  ///
  /// In en, this message translates to:
  /// **'Ex: Gomu Gomu no Mi'**
  String get devilFruitHint;

  /// Label for haki types selection
  ///
  /// In en, this message translates to:
  /// **'Haki Types'**
  String get hakiTypes;

  /// Option for Haoshoku Haki
  ///
  /// In en, this message translates to:
  /// **'Haoshoku Haki (King\'s Haki)'**
  String get haoshokuHaki;

  /// Option for Busoshoku Haki
  ///
  /// In en, this message translates to:
  /// **'Busoshoku Haki (Armament Haki)'**
  String get busoshokuHaki;

  /// Option for Kenbunshoku Haki
  ///
  /// In en, this message translates to:
  /// **'Kenbunshoku Haki (Observation Haki)'**
  String get kenbunshokuHaki;

  /// Section title for character background
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// Hint text for crew field
  ///
  /// In en, this message translates to:
  /// **'Ex: Straw Hat Pirates'**
  String get crewHint;

  /// Validation message for required bounty field
  ///
  /// In en, this message translates to:
  /// **'Please enter a bounty'**
  String get bountyRequired;

  /// Hint text for bounty field
  ///
  /// In en, this message translates to:
  /// **'Ex: 3,000,000,000 Berries'**
  String get bountyHint;

  /// Label for character image URL field
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// Hint text for image URL field
  ///
  /// In en, this message translates to:
  /// **'Ex: https://example.com/image.jpg'**
  String get imageUrlHint;

  /// Status option for alive character
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get captured;

  /// Status option for alive character
  ///
  /// In en, this message translates to:
  /// **'Alive'**
  String get alive;

  /// Status option for dead character
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get dead;

  /// Unknown value
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Label for affiliations selection
  ///
  /// In en, this message translates to:
  /// **'Affiliations'**
  String get affiliations;

  /// Affiliation option for Marines
  ///
  /// In en, this message translates to:
  /// **'Marines'**
  String get marines;

  /// Affiliation option for Revolutionaries
  ///
  /// In en, this message translates to:
  /// **'Revolutionaries'**
  String get revolutionaries;

  /// Affiliation option for Yonkou
  ///
  /// In en, this message translates to:
  /// **'Yonkou'**
  String get yonkou;

  /// Affiliation option for Shichibukai
  ///
  /// In en, this message translates to:
  /// **'Shichibukai'**
  String get shichibukai;

  /// Affiliation option for independent character
  ///
  /// In en, this message translates to:
  /// **'Independent'**
  String get independent;

  /// Occupation option for pirate
  ///
  /// In en, this message translates to:
  /// **'Pirate'**
  String get pirate;

  /// Affiliation option for pirate alliance
  ///
  /// In en, this message translates to:
  /// **'Pirate Alliance'**
  String get pirateAlliance;

  /// Label for occupations selection
  ///
  /// In en, this message translates to:
  /// **'Occupations'**
  String get occupations;

  /// Occupation option for captain
  ///
  /// In en, this message translates to:
  /// **'Captain'**
  String get captain;

  /// Occupation option for admiral
  ///
  /// In en, this message translates to:
  /// **'Admiral'**
  String get admiral;

  /// Occupation option for vice admiral
  ///
  /// In en, this message translates to:
  /// **'Vice Admiral'**
  String get viceAdmiral;

  /// Occupation option for revolutionary
  ///
  /// In en, this message translates to:
  /// **'Revolutionary'**
  String get revolutionary;

  /// Occupation option for merchant
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// Occupation option for doctor
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// Occupation option for navigator
  ///
  /// In en, this message translates to:
  /// **'Navigator'**
  String get navigator;

  /// Occupation option for cook
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cook;

  /// Occupation option for sniper
  ///
  /// In en, this message translates to:
  /// **'Sniper'**
  String get sniper;

  /// Occupation option for swordsman
  ///
  /// In en, this message translates to:
  /// **'Swordsman'**
  String get swordsman;

  /// Occupation option for carpenter
  ///
  /// In en, this message translates to:
  /// **'Carpenter'**
  String get carpenter;

  /// Occupation option for archaeologist
  ///
  /// In en, this message translates to:
  /// **'Archaeologist'**
  String get archaeologist;

  /// Occupation option for sharpshooter
  ///
  /// In en, this message translates to:
  /// **'Sharpshooter'**
  String get sharpshooter;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label for character story field
  ///
  /// In en, this message translates to:
  /// **'Character Story'**
  String get characterStory;

  /// Hint text for character story field
  ///
  /// In en, this message translates to:
  /// **'Tell the story of your custom character...'**
  String get characterStoryHint;

  /// Button text to create character
  ///
  /// In en, this message translates to:
  /// **'Create Character'**
  String get createCharacter;

  /// Button text to cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Success dialog title
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// Success message when character is created
  ///
  /// In en, this message translates to:
  /// **'Custom character created successfully!'**
  String get characterCreatedSuccess;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Error message when character creation fails
  ///
  /// In en, this message translates to:
  /// **'Error creating character: {message}'**
  String characterCreationError(String message);

  /// Button text for OK action
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Label for devil fruit
  ///
  /// In en, this message translates to:
  /// **'Devil Fruit'**
  String get devilFruit;

  /// Label for crew with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {Crew} =1 {Crew} other {Crews}}'**
  String crew(num count);

  /// Aries zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Aries'**
  String get ariesSign;

  /// Taurus zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Taurus'**
  String get taurusSign;

  /// Gemini zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get geminiSign;

  /// Cancer zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get cancerSign;

  /// Leo zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get leoSign;

  /// Virgo zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Virgo'**
  String get virgoSign;

  /// Libra zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Libra'**
  String get libraSign;

  /// Scorpio zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Scorpio'**
  String get scorpioSign;

  /// Sagittarius zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Sagittarius'**
  String get sagittariusSign;

  /// Capricorn zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get capricornSign;

  /// Aquarius zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Aquarius'**
  String get aquariusSign;

  /// Pisces zodiac sign
  ///
  /// In en, this message translates to:
  /// **'Pisces'**
  String get piscesSign;

  /// Welcome greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcome;

  /// Welcome message for login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to OpFan'**
  String get welcomeToOpfan;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Loading text when signing in
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// Authentication error title
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authenticationError;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// Clear data button text
  ///
  /// In en, this message translates to:
  /// **'Clear data and continue'**
  String get clearDataAndContinue;

  /// Search input placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search by roman or japanese name...'**
  String get searchPlaceholder;

  /// Filter by type button text
  ///
  /// In en, this message translates to:
  /// **'Filter by type'**
  String get filterByType;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Clear filters button text
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No fruit found message
  ///
  /// In en, this message translates to:
  /// **'No fruit found'**
  String get noFruitFound;

  /// No devil fruit available message
  ///
  /// In en, this message translates to:
  /// **'No Devil Fruit available'**
  String get noDevilFruitAvailable;

  /// Suggestion text when no results found
  ///
  /// In en, this message translates to:
  /// **'Try adjusting the filters or search for other terms'**
  String get adjustFiltersOrSearch;

  /// Error loading content message
  ///
  /// In en, this message translates to:
  /// **'Error loading content'**
  String get errorLoadingContent;

  /// Searching loading text
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// Skip login button text
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Subtitle shown on the login screen to invite users to explore One Piece characters.
  ///
  /// In en, this message translates to:
  /// **'Explore the world of One Piece and discover your favorite characters'**
  String get loginWelcomeSubtitle;

  /// version word.
  ///
  /// In en, this message translates to:
  /// **'version'**
  String get version;

  /// Profile menu item in user drawer
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings menu item in user drawer
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Logout menu item in user drawer
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Create character'**
  String get createCustomCharacter;

  /// Tooltip for create new crew
  ///
  /// In en, this message translates to:
  /// **'Create new crew'**
  String get createCrew;

  /// Snackbar message when viewing a character
  ///
  /// In en, this message translates to:
  /// **'Viewing {characterName}'**
  String viewingCharacter(String characterName);

  /// Snackbar message when editing a character
  ///
  /// In en, this message translates to:
  /// **'Editing {characterName}'**
  String editingCharacter(String characterName);
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
