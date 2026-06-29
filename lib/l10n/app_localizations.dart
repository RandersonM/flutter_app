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
    Locale('pt'),
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

  /// Title for financial summary section
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// Label for total income in financial summary
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// Title for expenses breakdown section
  ///
  /// In en, this message translates to:
  /// **'Expenses by category'**
  String get expensesByCategory;

  /// Title for financial history chart
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months History'**
  String get historyLast6Months;

  /// Text shown when no financial history is available
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get noHistoryAvailable;

  /// Text shown while loading financial history
  ///
  /// In en, this message translates to:
  /// **'Loading history...'**
  String get loadingHistory;

  /// Text shown when savings are good
  ///
  /// In en, this message translates to:
  /// **'Nami approves!'**
  String get namiApproves;

  /// Text shown when savings are low
  ///
  /// In en, this message translates to:
  /// **'Nami needs to review this'**
  String get namiNeedsReview;

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

  /// Action to delete something
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

  /// Label for age field.
  ///
  /// In en, this message translates to:
  /// **'Age'**
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

  /// Crew role - captain
  ///
  /// In en, this message translates to:
  /// **'Captain'**
  String get captain;

  /// Crew role - vice captain
  ///
  /// In en, this message translates to:
  /// **'Vice Captain'**
  String get viceCaptain;

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

  /// Crew role - doctor
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// Crew role - navigator
  ///
  /// In en, this message translates to:
  /// **'Navigator'**
  String get navigator;

  /// Crew role - cook
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

  /// Crew role - carpenter
  ///
  /// In en, this message translates to:
  /// **'Carpenter'**
  String get carpenter;

  /// Crew role - archaeologist
  ///
  /// In en, this message translates to:
  /// **'Archaeologist'**
  String get archaeologist;

  /// Crew role - sharpshooter
  ///
  /// In en, this message translates to:
  /// **'Sharpshooter'**
  String get sharpshooter;

  /// Label for description field
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

  /// Cancel button text
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

  /// Label for devil fruit filter
  ///
  /// In en, this message translates to:
  /// **'Devil Fruit'**
  String get devilFruit;

  /// Text shown when character has no devil fruit
  ///
  /// In en, this message translates to:
  /// **'No Devil Fruit'**
  String get noDevilFruit;

  /// Label for crew filter
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

  /// Button text to clear all filters
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
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

  /// Login banner title for unauthenticated users
  ///
  /// In en, this message translates to:
  /// **'Sign in to access exclusive features'**
  String get loginBannerTitle;

  /// Login banner subtitle for unauthenticated users
  ///
  /// In en, this message translates to:
  /// **'Create characters, participate in duels and much more'**
  String get loginBannerSubtitle;

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

  /// Title for create crew screen
  ///
  /// In en, this message translates to:
  /// **'Create Crew'**
  String get createCrew;

  /// Label for crew boat name field
  ///
  /// In en, this message translates to:
  /// **' Boat'**
  String get boat;

  /// Label for crew boat name field
  ///
  /// In en, this message translates to:
  /// **' Boat name'**
  String get crewBoatName;

  /// Label for crew role field
  ///
  /// In en, this message translates to:
  /// **'Crew Role'**
  String get crewRole;

  /// Hint text for crew role field
  ///
  /// In en, this message translates to:
  /// **'Select your role in the crew'**
  String get crewRoleHint;

  /// Crew role - helmsman
  ///
  /// In en, this message translates to:
  /// **'Helmsman'**
  String get helmsman;

  /// Crew role - musician
  ///
  /// In en, this message translates to:
  /// **'Musician'**
  String get musician;

  /// Crew role - boatswain
  ///
  /// In en, this message translates to:
  /// **'Boatswain'**
  String get boatswain;

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

  /// Title for edit custom character screen
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Character'**
  String get editCustomCharacterTitle;

  /// Subtitle for edit custom character screen
  ///
  /// In en, this message translates to:
  /// **'Modify your character\'s information'**
  String get editCustomCharacterSubtitle;

  /// Button text to update/save changes
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Success message when character is updated
  ///
  /// In en, this message translates to:
  /// **'Character updated successfully'**
  String get characterUpdatedSuccess;

  /// Error message when character update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating character: {message}'**
  String characterUpdateError(String message);

  /// Text shown for total berries in crew card
  ///
  /// In en, this message translates to:
  /// **'Berries total'**
  String get berriesTotal;

  /// Text shown for crew members count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {Member} =1 {Member} other {Members}}'**
  String members(num count);

  /// Search input placeholder for crews
  ///
  /// In en, this message translates to:
  /// **'Search crews...'**
  String get searchCrews;

  /// Filter button tooltip
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// My crews label
  ///
  /// In en, this message translates to:
  /// **'My Crews'**
  String get myCrews;

  /// All crews label
  ///
  /// In en, this message translates to:
  /// **'All Crews'**
  String get allCrews;

  /// Error message when crews fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading crews'**
  String get errorLoadingCrews;

  /// Message when no crews are found
  ///
  /// In en, this message translates to:
  /// **'No crews found'**
  String get noCrewsFound;

  /// Message encouraging user to create first crew
  ///
  /// In en, this message translates to:
  /// **'Create your first crew!'**
  String get createFirstCrew;

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDelete;

  /// Delete confirmation message for crew
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the crew \"{crewName}\"?'**
  String confirmDeleteCrew(String crewName);

  /// Snackbar message when viewing a crew
  ///
  /// In en, this message translates to:
  /// **'Viewing crew: {crewName}'**
  String viewingCrew(String crewName);

  /// Snackbar message when editing a crew
  ///
  /// In en, this message translates to:
  /// **'Editing crew: {crewName}'**
  String editingCrew(String crewName);

  /// Title for AI image generation section
  ///
  /// In en, this message translates to:
  /// **'AI Image Generation'**
  String get aiImageGeneration;

  /// Subtitle for AI image generation section
  ///
  /// In en, this message translates to:
  /// **'Generate a unique image for your character using AI'**
  String get aiImageGenerationSubtitle;

  /// Label for image prompt field
  ///
  /// In en, this message translates to:
  /// **'Image Prompt'**
  String get imagePrompt;

  /// Hint text for image prompt field
  ///
  /// In en, this message translates to:
  /// **'Describe how your character should look...'**
  String get imagePromptHint;

  /// Button text to generate image
  ///
  /// In en, this message translates to:
  /// **'Generate Image'**
  String get generateImage;

  /// Text shown while generating image
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generatingImage;

  /// Error message when image fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageLoadError;

  /// Title for edit crew screen
  ///
  /// In en, this message translates to:
  /// **'Edit Crew'**
  String get editCrewTitle;

  /// Subtitle for edit crew screen
  ///
  /// In en, this message translates to:
  /// **'Modify your crew\'s information'**
  String get editCrewSubtitle;

  /// Success message when crew is updated
  ///
  /// In en, this message translates to:
  /// **'Crew updated successfully'**
  String get crewUpdatedSuccess;

  /// Error message when crew update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating crew'**
  String get crewUpdateError;

  /// Button text to regenerate image
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerateImage;

  /// Button text to use generated image
  ///
  /// In en, this message translates to:
  /// **'Use Image'**
  String get useImage;

  /// Button text when image is confirmed
  ///
  /// In en, this message translates to:
  /// **'Image Confirmed'**
  String get imageConfirmed;

  /// Error message when prompt is required
  ///
  /// In en, this message translates to:
  /// **'Please enter a prompt'**
  String get promptRequired;

  /// Error message when image generation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to generate image. Please try again.'**
  String get imageGenerationError;

  /// Title for devil fruit selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Devil Fruit'**
  String get selectDevilFruit;

  /// Placeholder text when no devil fruit is selected
  ///
  /// In en, this message translates to:
  /// **'Select a Devil Fruit'**
  String get selectDevilFruitPlaceholder;

  /// Hint text for devil fruit search field
  ///
  /// In en, this message translates to:
  /// **'Search Devil Fruit...'**
  String get searchDevilFruit;

  /// Message when no devil fruit matches search
  ///
  /// In en, this message translates to:
  /// **'No Devil Fruit found'**
  String get noDevilFruitFound;

  /// Title for filter dialog
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// No description provided for @crewTeam.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crewTeam;

  /// Title for devil fruit filter dialog
  ///
  /// In en, this message translates to:
  /// **'Filter by Devil Fruit'**
  String get filterByDevilFruit;

  /// Title for crew filter dialog
  ///
  /// In en, this message translates to:
  /// **'Filter by Crew'**
  String get filterByCrew;

  /// Title for add tag dialog
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTag;

  /// Label for add member button
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// Message when no characters are available to add to crew
  ///
  /// In en, this message translates to:
  /// **'No characters available to add'**
  String get noCharactersAvailable;

  /// Label for tag name field
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagName;

  /// Hint text for tag name field
  ///
  /// In en, this message translates to:
  /// **'Ex: Pirates, Adventurers, etc.'**
  String get tagNameHint;

  /// Label for crew name field
  ///
  /// In en, this message translates to:
  /// **'Crew Name *'**
  String get crewName;

  /// Hint text for crew name field
  ///
  /// In en, this message translates to:
  /// **'Ex: Custom Mugiwara'**
  String get crewNameHint;

  /// Hint text for description field
  ///
  /// In en, this message translates to:
  /// **'Tell us about your crew...'**
  String get descriptionHint;

  /// Label for pirate flag URL field
  ///
  /// In en, this message translates to:
  /// **'Pirate Flag URL'**
  String get pirateFlagUrl;

  /// Hint text for pirate flag URL field
  ///
  /// In en, this message translates to:
  /// **'https://example.com/flag.jpg'**
  String get pirateFlagUrlHint;

  /// Label for ship image URL field
  ///
  /// In en, this message translates to:
  /// **'Ship Image URL'**
  String get shipImageUrl;

  /// Hint text for ship image URL field
  ///
  /// In en, this message translates to:
  /// **'https://example.com/ship.jpg'**
  String get shipImageUrlHint;

  /// Label for devil fruit name field
  ///
  /// In en, this message translates to:
  /// **'Devil fruit name'**
  String get devilFruitName;

  /// Hint text for devil fruit name field
  ///
  /// In en, this message translates to:
  /// **'Ex: Gomu Gomu no Mi'**
  String get devilFruitNameHint;

  /// Label for crew name filter field
  ///
  /// In en, this message translates to:
  /// **'Crew name'**
  String get crewNameFilter;

  /// Hint text for crew name filter field
  ///
  /// In en, this message translates to:
  /// **'Ex: Straw Hat Pirates'**
  String get crewNameFilterHint;

  /// Date format hint
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get dateFormat;

  /// Number format hint
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get numberFormat;

  /// Snackbar message when edit profile is tapped
  ///
  /// In en, this message translates to:
  /// **'Edit Profile tapped'**
  String get editProfileTapped;

  /// Snackbar message when notifications is tapped
  ///
  /// In en, this message translates to:
  /// **'Notifications tapped'**
  String get notificationsTapped;

  /// Snackbar message when language is tapped
  ///
  /// In en, this message translates to:
  /// **'Language tapped'**
  String get languageTapped;

  /// Snackbar message when theme is tapped
  ///
  /// In en, this message translates to:
  /// **'Theme tapped'**
  String get themeTapped;

  /// Snackbar message when help & support is tapped
  ///
  /// In en, this message translates to:
  /// **'Help & Support tapped'**
  String get helpSupportTapped;

  /// Snackbar message when about is tapped
  ///
  /// In en, this message translates to:
  /// **'About tapped'**
  String get aboutTapped;

  /// Success message when character is deleted
  ///
  /// In en, this message translates to:
  /// **'Character deleted successfully'**
  String get characterDeleted;

  /// Success message when crew is created
  ///
  /// In en, this message translates to:
  /// **'Crew created successfully'**
  String get crewCreated;

  /// Error message when crew creation fails
  ///
  /// In en, this message translates to:
  /// **'Error creating crew'**
  String get crewCreationError;

  /// Success message when crew is deleted
  ///
  /// In en, this message translates to:
  /// **'Crew deleted successfully'**
  String get crewDeleted;

  /// Error message when crew deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting crew'**
  String get crewDeletionError;

  /// Success message when member is added to crew
  ///
  /// In en, this message translates to:
  /// **'Member added successfully'**
  String get memberAdded;

  /// Error message when adding member fails
  ///
  /// In en, this message translates to:
  /// **'Error adding member'**
  String get memberAdditionError;

  /// Success message when member is removed from crew
  ///
  /// In en, this message translates to:
  /// **'Member removed successfully'**
  String get memberRemoved;

  /// Error message when removing member fails
  ///
  /// In en, this message translates to:
  /// **'Error removing member'**
  String get memberRemovalError;

  /// Success message when crew is updated
  ///
  /// In en, this message translates to:
  /// **'Crew updated successfully'**
  String get crewUpdated;

  /// Error message for login
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// Error message when video fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading video'**
  String get videoLoadError;

  /// Success message when video loads
  ///
  /// In en, this message translates to:
  /// **'Video loaded successfully'**
  String get videoLoadSuccess;

  /// Error message when devil fruit search fails
  ///
  /// In en, this message translates to:
  /// **'Error searching Devil Fruit: {error}'**
  String devilFruitSearchError(String error);

  /// Message when no custom characters are found
  ///
  /// In en, this message translates to:
  /// **'No custom characters found'**
  String get noCustomCharactersFound;

  /// Message encouraging user to create first custom character
  ///
  /// In en, this message translates to:
  /// **'Create your first custom character!'**
  String get createFirstCustomCharacter;

  /// Label for One Piece characters tab
  ///
  /// In en, this message translates to:
  /// **'One Piece Characters'**
  String get onePieceCharacters;

  /// Label for custom characters tab
  ///
  /// In en, this message translates to:
  /// **'Custom Characters'**
  String get customCharacters;

  /// Message when no One Piece characters are available
  ///
  /// In en, this message translates to:
  /// **'No One Piece characters available'**
  String get noOnePieceCharacters;

  /// Message when no custom characters are available
  ///
  /// In en, this message translates to:
  /// **'No custom characters available'**
  String get noCustomCharacters;

  /// Fighting type option for dual wielder
  ///
  /// In en, this message translates to:
  /// **'Dual Wielder'**
  String get dualWielder;

  /// Fighting type option for fighter
  ///
  /// In en, this message translates to:
  /// **'Fighter'**
  String get fighter;

  /// Fighting type option for taekwondo
  ///
  /// In en, this message translates to:
  /// **'Taekwondo'**
  String get taekwondo;

  /// Fighting type option for kicker
  ///
  /// In en, this message translates to:
  /// **'Kicker'**
  String get kicker;

  /// Fighting type option for archer
  ///
  /// In en, this message translates to:
  /// **'Archer'**
  String get archer;

  /// Fighting type option for staff wielder
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// Category name for other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Label for race selection
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get race;

  /// Race option for human
  ///
  /// In en, this message translates to:
  /// **'Human'**
  String get human;

  /// Race option for giant
  ///
  /// In en, this message translates to:
  /// **'Giant'**
  String get giant;

  /// Race option for fishman
  ///
  /// In en, this message translates to:
  /// **'Fishman'**
  String get fishman;

  /// Race option for mermaid
  ///
  /// In en, this message translates to:
  /// **'Mermaid'**
  String get mermaid;

  /// Race option for mink
  ///
  /// In en, this message translates to:
  /// **'Mink'**
  String get mink;

  /// Race option for lunarian
  ///
  /// In en, this message translates to:
  /// **'Lunarian'**
  String get lunarian;

  /// Race option for buccaneer
  ///
  /// In en, this message translates to:
  /// **'Buccaneer'**
  String get buccaneer;

  /// Race option for oni
  ///
  /// In en, this message translates to:
  /// **'Oni'**
  String get oni;

  /// Race option for skypiean
  ///
  /// In en, this message translates to:
  /// **'Skypiean'**
  String get skypiean;

  /// Race option for longarm
  ///
  /// In en, this message translates to:
  /// **'Longarm'**
  String get longarm;

  /// Race option for tonatta
  ///
  /// In en, this message translates to:
  /// **'Tonatta'**
  String get tonatta;

  /// Add button text.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Error message when user doesn't have permission to edit crew
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to edit this crew'**
  String get noPermissionToEdit;

  /// Error message when user doesn't have permission to delete crew
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to delete this crew'**
  String get noPermissionToDelete;

  /// Message when all roles in crew are already filled
  ///
  /// In en, this message translates to:
  /// **'All roles are already filled'**
  String get allRolesFilled;

  /// Error message when character is not found
  ///
  /// In en, this message translates to:
  /// **'Character not found'**
  String get characterNotFound;

  /// Error message when character fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading character'**
  String get characterLoadError;

  /// Success message when member is added to crew with role
  ///
  /// In en, this message translates to:
  /// **'{characterName} added as {role}'**
  String memberAddedAsRole(String characterName, String role);

  /// Success message when crew is deleted with crew name
  ///
  /// In en, this message translates to:
  /// **'Crew \"{crewName}\" deleted'**
  String crewDeletedWithName(String crewName);

  /// Prompt text for generating pirate flag
  ///
  /// In en, this message translates to:
  /// **'Enter a prompt to generate the pirate flag'**
  String get generatePirateFlagPrompt;

  /// Success message when pirate flag is generated
  ///
  /// In en, this message translates to:
  /// **'Pirate flag generated successfully!'**
  String get pirateFlagGeneratedSuccess;

  /// Error message when pirate flag generation fails
  ///
  /// In en, this message translates to:
  /// **'Error generating flag: {error}'**
  String pirateFlagGenerationError(String error);

  /// Prompt text for generating boat
  ///
  /// In en, this message translates to:
  /// **'Enter a prompt to generate the boat'**
  String get generateBoatPrompt;

  /// Success message when boat is generated
  ///
  /// In en, this message translates to:
  /// **'Boat generated successfully!'**
  String get boatGeneratedSuccess;

  /// Error message when boat generation fails
  ///
  /// In en, this message translates to:
  /// **'Error generating boat: {error}'**
  String boatGenerationError(String error);

  /// Snackbar message when profile photo is tapped
  ///
  /// In en, this message translates to:
  /// **'Profile photo tapped'**
  String get profilePhotoTapped;

  /// Shows the zodiac Capricorn
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get zodiacCapricorn;

  /// Duels screen title
  ///
  /// In en, this message translates to:
  /// **'Duels'**
  String get duels;

  /// Duels screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Character vs Character'**
  String get duelsSubtitle;

  /// Text shown between characters in duel arena
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get versus;

  /// Text shown after winner name
  ///
  /// In en, this message translates to:
  /// **'Wins!'**
  String get winner;

  /// Button text to start a duel
  ///
  /// In en, this message translates to:
  /// **'Start Duel'**
  String get startDuel;

  /// Text shown when duel is happening
  ///
  /// In en, this message translates to:
  /// **'Battle in Progress...'**
  String get duelInProgress;

  /// Title for stats comparison section
  ///
  /// In en, this message translates to:
  /// **'Character Stats'**
  String get characterStats;

  /// Title for first character selector
  ///
  /// In en, this message translates to:
  /// **'Select First Fighter'**
  String get selectFirstFighter;

  /// Title for second character selector
  ///
  /// In en, this message translates to:
  /// **'Select Second Fighter'**
  String get selectSecondFighter;

  /// Placeholder text for character selection
  ///
  /// In en, this message translates to:
  /// **'Select a Character'**
  String get selectACharacter;

  /// Button text to randomize character selection
  ///
  /// In en, this message translates to:
  /// **'Randomize'**
  String get randomizeCharacters;

  /// Button text to reset duel
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetDuel;

  /// Haki type pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {types} =1 {type} other {types}}'**
  String hakiType(num count);

  /// Button text to start a new duel
  ///
  /// In en, this message translates to:
  /// **'New Duel'**
  String get newDuel;

  /// Title for account settings section in profile
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Menu item to edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Subtitle for edit profile menu item
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get editProfileSubtitle;

  /// Menu item for notifications settings
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Subtitle for notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Manage your notification preferences'**
  String get notificationsSubtitle;

  /// Title for app settings section in profile
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Menu item for language settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Subtitle for language menu item
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get languageSubtitle;

  /// Menu item for theme settings
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Text for dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// Text for light theme option
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightTheme;

  /// Snackbar message when dark theme is activated
  ///
  /// In en, this message translates to:
  /// **'Dark theme activated'**
  String get darkThemeActivated;

  /// Snackbar message when light theme is activated
  ///
  /// In en, this message translates to:
  /// **'Light theme activated'**
  String get lightThemeActivated;

  /// Title for support section in profile
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Menu item for help and support
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Subtitle for help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Get help and contact support'**
  String get helpSupportSubtitle;

  /// Menu item for about section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Subtitle for about menu item
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get aboutSubtitle;

  /// Validation message for minimum name length.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameMinLength;

  /// Title for tags section
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Message when no tags are present.
  ///
  /// In en, this message translates to:
  /// **'No tags added'**
  String get noTagsAdded;

  /// Section title for pirate flag.
  ///
  /// In en, this message translates to:
  /// **'Pirate Flag (Jolly Roger)'**
  String get pirateFlagSectionTitle;

  /// Title for pirate flag image.
  ///
  /// In en, this message translates to:
  /// **'Crew Pirate Flag'**
  String get pirateFlagTitle;

  /// Label for AI prompt input
  ///
  /// In en, this message translates to:
  /// **'AI Prompt'**
  String get aiPromptLabel;

  /// Hint for pirate flag prompt.
  ///
  /// In en, this message translates to:
  /// **'Ex: pirate flag with skull and crossed swords'**
  String get pirateFlagPromptHint;

  /// Button text to generate pirate flag.
  ///
  /// In en, this message translates to:
  /// **'Generate Flag'**
  String get generateFlag;

  /// Section title for crew boat.
  ///
  /// In en, this message translates to:
  /// **'Crew Boat'**
  String get crewBoatSectionTitle;

  /// Hint for boat name field.
  ///
  /// In en, this message translates to:
  /// **'Ex: Going Merry'**
  String get boatNameHint;

  /// Button text to generate boat.
  ///
  /// In en, this message translates to:
  /// **'Generate Boat'**
  String get generateBoat;

  /// Title for boat image.
  ///
  /// In en, this message translates to:
  /// **'Crew Boat'**
  String get boatTitle;

  /// Info text about using AI prompts.
  ///
  /// In en, this message translates to:
  /// **'Use descriptive prompts to generate unique images for your crew. Generated images will be saved automatically.'**
  String get aiPromptInfo;

  /// Section title for fighting style details card.
  ///
  /// In en, this message translates to:
  /// **'Fighting Style'**
  String get fightingStyleSectionTitle;

  /// Label for the name of the fighting style.
  ///
  /// In en, this message translates to:
  /// **'Style Name'**
  String get fightingStyleNameLabel;

  /// Label for the type of fighting style.
  ///
  /// In en, this message translates to:
  /// **'Fighting Type'**
  String get fightingStyleTypeLabel;

  /// Label for the weapons used in the fighting style.
  ///
  /// In en, this message translates to:
  /// **'Weapons'**
  String get fightingStyleWeaponsLabel;

  /// Label for the attacks of the fighting style.
  ///
  /// In en, this message translates to:
  /// **'Attacks'**
  String get fightingStyleAttacksLabel;

  /// Title for Nami finances screen and bottom navigation.
  ///
  /// In en, this message translates to:
  /// **'Finances'**
  String get finances;

  /// Label for monthly income field in finances screen.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get monthlyIncome;

  /// Hint for monthly income field.
  ///
  /// In en, this message translates to:
  /// **'Enter your monthly income'**
  String get monthlyIncomeHint;

  /// Title for expenses
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Label for fixed expenses field.
  ///
  /// In en, this message translates to:
  /// **'Fixed Expenses (Rent, Bills)'**
  String get fixedExpenses;

  /// Label for food expenses field.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get foodExpenses;

  /// Label for transport expenses field.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transportExpenses;

  /// Label for entertainment expenses field.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainmentExpenses;

  /// Label for other expenses field.
  ///
  /// In en, this message translates to:
  /// **'Other Expenses'**
  String get otherExpenses;

  /// Section title for financial results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// Label for total expenses result.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// Label for available amount result.
  ///
  /// In en, this message translates to:
  /// **'Available Amount'**
  String get availableAmount;

  /// Label for daily available amount result.
  ///
  /// In en, this message translates to:
  /// **'Daily Available Amount'**
  String get dailyAmount;

  /// Currency symbol for the current locale.
  ///
  /// In en, this message translates to:
  /// **'R\$'**
  String get currency;

  /// Suffix for daily amounts.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get perDay;

  /// Category name for health
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// Instruction text for expense category selection dialog.
  ///
  /// In en, this message translates to:
  /// **'Select expense category:'**
  String get selectExpenseCategory;

  /// Label for category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Remove button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Label for value input field.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// Button text to add new income item.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// Button text to add new expense item.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Title for savings section.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// Label for monthly savings field.
  ///
  /// In en, this message translates to:
  /// **'Monthly Savings'**
  String get monthlySavings;

  /// Hint for monthly savings field.
  ///
  /// In en, this message translates to:
  /// **'How much do you save per month?'**
  String get savingsHint;

  /// Label for savings percentage of income.
  ///
  /// In en, this message translates to:
  /// **'Savings Percentage'**
  String get savingsPercentage;

  /// Label for accumulated value in one year.
  ///
  /// In en, this message translates to:
  /// **'Yearly Savings'**
  String get yearlySavings;

  /// Title for total accumulated savings.
  ///
  /// In en, this message translates to:
  /// **'Accumulated'**
  String get accumulatedSavings;

  /// Title for savings period section.
  ///
  /// In en, this message translates to:
  /// **'Savings Period'**
  String get savingsPeriod;

  /// Workout title screen.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @workout_title_screen.
  ///
  /// In en, this message translates to:
  /// **'Workout with Zoro'**
  String get workout_title_screen;

  /// Main title for health assessment screen.
  ///
  /// In en, this message translates to:
  /// **'Complete Health Assessment'**
  String get workout_health_assessment;

  /// Explanatory subtitle for health assessment.
  ///
  /// In en, this message translates to:
  /// **'Combines BMI, waist-to-height ratio and body fat percentage for a more accurate health assessment'**
  String get workout_health_assessment_subtitle;

  /// Title for results section.
  ///
  /// In en, this message translates to:
  /// **'Assessment Results'**
  String get workout_results;

  /// Title for recommendations section.
  ///
  /// In en, this message translates to:
  /// **'Personalized Recommendations'**
  String get workout_recommendations;

  /// Button text to calculate metrics.
  ///
  /// In en, this message translates to:
  /// **'Calculate Health Metrics'**
  String get workout_calculate_metrics;

  /// Button text for new assessment.
  ///
  /// In en, this message translates to:
  /// **'New Assessment'**
  String get workout_new_assessment;

  /// Gender field label.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get workout_gender;

  /// Age field label.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get workout_age;

  /// Height field label.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get workout_height;

  /// Weight field label.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get workout_weight;

  /// Waist field label.
  ///
  /// In en, this message translates to:
  /// **'Waist Circumference (cm)'**
  String get workout_waist;

  /// Health score label.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get workout_health_score;

  /// BMI label.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get workout_bmi;

  /// Waist-to-height ratio label.
  ///
  /// In en, this message translates to:
  /// **'Waist-to-Height Ratio'**
  String get workout_waist_to_height;

  /// Body fat percentage label.
  ///
  /// In en, this message translates to:
  /// **'Body Fat Percentage'**
  String get workout_body_fat;

  /// BMI formula description.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg) / Height (m)²'**
  String get workout_formula_bmi;

  /// Waist-to-height ratio formula description.
  ///
  /// In en, this message translates to:
  /// **'Waist (cm) / Height (cm)'**
  String get workout_formula_waist_to_height;

  /// Body fat percentage formula description.
  ///
  /// In en, this message translates to:
  /// **'Formula based on BMI, age and gender'**
  String get workout_formula_body_fat;

  /// Validation message for required gender.
  ///
  /// In en, this message translates to:
  /// **'Please select gender'**
  String get workout_validation_gender_required;

  /// Validation message for required age.
  ///
  /// In en, this message translates to:
  /// **'Please enter your age'**
  String get workout_validation_age_required;

  /// Validation message for invalid age.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get workout_validation_age_invalid;

  /// Validation message for required height.
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get workout_validation_height_required;

  /// Validation message for invalid height.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get workout_validation_height_invalid;

  /// Validation message for required weight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight'**
  String get workout_validation_weight_required;

  /// Validation message for invalid weight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get workout_validation_weight_invalid;

  /// Validation message for required waist.
  ///
  /// In en, this message translates to:
  /// **'Please enter waist measurement'**
  String get workout_validation_waist_required;

  /// Validation message for invalid waist.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get workout_validation_waist_invalid;

  /// Male option in gender dropdown.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get workout_gender_male;

  /// Female option in gender dropdown.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get workout_gender_female;

  /// Excellent category for health metrics.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get workout_category_excellent;

  /// Good category for health metrics.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get workout_category_good;

  /// Regular category for health metrics.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get workout_category_regular;

  /// Needs improvement category for health metrics.
  ///
  /// In en, this message translates to:
  /// **'Needs improvement'**
  String get workout_category_needs_improvement;

  /// Underweight category for BMI.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get workout_category_underweight;

  /// Normal weight category for BMI.
  ///
  /// In en, this message translates to:
  /// **'Normal weight'**
  String get workout_category_normal;

  /// Overweight category for BMI.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get workout_category_overweight;

  /// Obesity grade 1 category for BMI.
  ///
  /// In en, this message translates to:
  /// **'Obesity grade 1'**
  String get workout_category_obesity_1;

  /// Obesity grade 2 category for BMI.
  ///
  /// In en, this message translates to:
  /// **'Obesity grade 2'**
  String get workout_category_obesity_2;

  /// BMI category for grade 3 obesity.
  ///
  /// In en, this message translates to:
  /// **'Obesity grade 3'**
  String get workout_category_obesity_3;

  /// Attention category for waist-to-height ratio.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get workout_category_attention;

  /// High risk category for waist-to-height ratio.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get workout_category_high_risk;

  /// Very low category for body fat percentage.
  ///
  /// In en, this message translates to:
  /// **'Very low'**
  String get workout_category_very_low;

  /// Athletic category for body fat percentage.
  ///
  /// In en, this message translates to:
  /// **'Athletic'**
  String get workout_category_athletic;

  /// Acceptable category for body fat percentage.
  ///
  /// In en, this message translates to:
  /// **'Acceptable'**
  String get workout_category_acceptable;

  /// High category for body fat percentage.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get workout_category_high;

  /// Advanced strength exercise.
  ///
  /// In en, this message translates to:
  /// **'Advanced strength training 4x per week'**
  String get workout_exercise_advanced_strength;

  /// HIIT cardio exercise.
  ///
  /// In en, this message translates to:
  /// **'High intensity cardio (HIIT)'**
  String get workout_exercise_hiit;

  /// Competitive sports exercise.
  ///
  /// In en, this message translates to:
  /// **'Competitive sports'**
  String get workout_exercise_competitive_sports;

  /// Complex functional training exercise.
  ///
  /// In en, this message translates to:
  /// **'Complex functional training'**
  String get workout_exercise_complex_functional;

  /// Flexibility and mobility exercise.
  ///
  /// In en, this message translates to:
  /// **'Flexibility and mobility'**
  String get workout_exercise_flexibility;

  /// Strength training exercise.
  ///
  /// In en, this message translates to:
  /// **'Strength training 3x per week'**
  String get workout_exercise_strength_training;

  /// Moderate cardio exercise.
  ///
  /// In en, this message translates to:
  /// **'Moderate cardio 30-45 min'**
  String get workout_exercise_moderate_cardio;

  /// Functional training exercise.
  ///
  /// In en, this message translates to:
  /// **'Functional training'**
  String get workout_exercise_functional;

  /// Yoga or pilates exercise.
  ///
  /// In en, this message translates to:
  /// **'Yoga or pilates'**
  String get workout_exercise_yoga_pilates;

  /// Recreational sports exercise.
  ///
  /// In en, this message translates to:
  /// **'Recreational sports'**
  String get workout_exercise_recreational_sports;

  /// Walking exercise.
  ///
  /// In en, this message translates to:
  /// **'Walking 30-45 minutes'**
  String get workout_exercise_walking;

  /// Basic strength exercise.
  ///
  /// In en, this message translates to:
  /// **'Basic strength training 2x per week'**
  String get workout_exercise_basic_strength;

  /// Water aerobics exercise.
  ///
  /// In en, this message translates to:
  /// **'Water aerobics'**
  String get workout_exercise_water_aerobics;

  /// Stretching exercise.
  ///
  /// In en, this message translates to:
  /// **'Daily stretching'**
  String get workout_exercise_stretching;

  /// Breathing exercise.
  ///
  /// In en, this message translates to:
  /// **'Breathing exercises'**
  String get workout_exercise_breathing;

  /// Light walking exercise.
  ///
  /// In en, this message translates to:
  /// **'Light walking 20-30 minutes'**
  String get workout_exercise_light_walking;

  /// Light stretching exercise.
  ///
  /// In en, this message translates to:
  /// **'Light stretching exercises'**
  String get workout_exercise_light_stretching;

  /// Soft water aerobics exercise.
  ///
  /// In en, this message translates to:
  /// **'Soft water aerobics'**
  String get workout_exercise_soft_water_aerobics;

  /// Tai Chi or soft Yoga exercise.
  ///
  /// In en, this message translates to:
  /// **'Tai Chi or soft Yoga'**
  String get workout_exercise_tai_chi_yoga;

  /// Consult professional exercise.
  ///
  /// In en, this message translates to:
  /// **'Consult health professional'**
  String get workout_exercise_consult_professional;

  /// Cardiovascular focused exercise.
  ///
  /// In en, this message translates to:
  /// **'Focus on cardiovascular exercises'**
  String get workout_exercise_cardiovascular_focus;

  /// Core training exercise.
  ///
  /// In en, this message translates to:
  /// **'Specific core training'**
  String get workout_exercise_core_training;

  /// Diet control exercise.
  ///
  /// In en, this message translates to:
  /// **'Diet control'**
  String get workout_exercise_diet_control;

  /// Low impact exercise.
  ///
  /// In en, this message translates to:
  /// **'Low impact activities'**
  String get workout_exercise_low_impact;

  /// Professional supervision exercise.
  ///
  /// In en, this message translates to:
  /// **'Professional supervision'**
  String get workout_exercise_professional_supervision;

  /// Gradual progression exercise.
  ///
  /// In en, this message translates to:
  /// **'Gradual progression'**
  String get workout_exercise_gradual_progression;

  /// Savings period text for years and months.
  ///
  /// In en, this message translates to:
  /// **'{years} year{years, plural, =1 {} other {s}} and {months} month{months, plural, =1 {} other {s}}'**
  String savings_period_years_and_months(int years, int months);

  /// Savings period text for years only.
  ///
  /// In en, this message translates to:
  /// **'{years} year{years, plural, =1 {} other {s}}'**
  String savings_period_years_only(int years);

  /// Savings period text for months only.
  ///
  /// In en, this message translates to:
  /// **'{months} month{months, plural, =1 {} other {s}}'**
  String savings_period_months_only(int months);

  /// Savings period text for one month.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get savings_period_one_month;

  /// Formatted total savings with period.
  ///
  /// In en, this message translates to:
  /// **'R\$ {amount} in {period}'**
  String savings_formatted_total(String amount, String period);

  /// Workout calendar title.
  ///
  /// In en, this message translates to:
  /// **'Workout Calendar'**
  String get workout_calendar_title;

  /// Sunday in calendar.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get workout_calendar_sunday;

  /// Monday in calendar.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get workout_calendar_monday;

  /// Tuesday in calendar.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get workout_calendar_tuesday;

  /// Wednesday in calendar.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get workout_calendar_wednesday;

  /// Thursday in calendar.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get workout_calendar_thursday;

  /// Friday in calendar.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get workout_calendar_friday;

  /// Saturday in calendar.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get workout_calendar_saturday;

  /// Label for workout days goal.
  ///
  /// In en, this message translates to:
  /// **'Workout days goal per week'**
  String get workout_workout_days_goal;

  /// Validation for required workout days goal.
  ///
  /// In en, this message translates to:
  /// **'Select your workout days goal'**
  String get workout_validation_workout_days_required;

  /// Singular of day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get workout_day;

  /// Plural of days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get workout_days;

  /// Cooking screen title for bottom navigation.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get cooking;

  /// Title for the plate guide screen.
  ///
  /// In en, this message translates to:
  /// **'Healthy Plate Guide'**
  String get plateGuideTitle;

  /// Header text explaining the plate guide.
  ///
  /// In en, this message translates to:
  /// **'Based on Brazilian Ministry of Health recommendations, this guide shows how to build a balanced plate with ideal proportions of each food group.'**
  String get plateGuideHeader;

  /// Title for the pie chart section.
  ///
  /// In en, this message translates to:
  /// **'Plate Division'**
  String get plateDivision;

  /// Title for vegetables section.
  ///
  /// In en, this message translates to:
  /// **'Vegetables and Legumes'**
  String get vegetablesTitle;

  /// Subtitle for vegetables section.
  ///
  /// In en, this message translates to:
  /// **'50% of plate'**
  String get vegetablesSubtitle;

  /// Description for vegetables section.
  ///
  /// In en, this message translates to:
  /// **'Regulatory foods rich in vitamins, minerals and fiber'**
  String get vegetablesDescription;

  /// Examples for vegetables section.
  ///
  /// In en, this message translates to:
  /// **'Lettuce, watercress, arugula, spinach, broccoli, cauliflower, carrot, zucchini'**
  String get vegetablesExamples;

  /// Title for proteins section.
  ///
  /// In en, this message translates to:
  /// **'Proteins'**
  String get proteinsTitle;

  /// Subtitle for proteins section.
  ///
  /// In en, this message translates to:
  /// **'25% of plate'**
  String get proteinsSubtitle;

  /// Description for proteins section.
  ///
  /// In en, this message translates to:
  /// **'Building foods essential for muscles and tissues'**
  String get proteinsDescription;

  /// Examples for proteins section.
  ///
  /// In en, this message translates to:
  /// **'Chicken, fish, meat, eggs, beans, lentils, chickpeas'**
  String get proteinsExamples;

  /// Title for carbohydrates section.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydratesTitle;

  /// Subtitle for carbohydrates section.
  ///
  /// In en, this message translates to:
  /// **'25% of plate'**
  String get carbohydratesSubtitle;

  /// Description for carbohydrates section.
  ///
  /// In en, this message translates to:
  /// **'Energy foods that provide energy for the body'**
  String get carbohydratesDescription;

  /// Examples for carbohydrates section.
  ///
  /// In en, this message translates to:
  /// **'Rice, potato, pasta, bread, sweet potato, cassava'**
  String get carbohydratesExamples;

  /// Title for Sanji's tips section.
  ///
  /// In en, this message translates to:
  /// **'Sanji\'s Tips'**
  String get sanjiTipsTitle;

  /// First tip from Sanji.
  ///
  /// In en, this message translates to:
  /// **'Prefer fresh or minimally processed foods'**
  String get sanjiTip1;

  /// Second tip from Sanji.
  ///
  /// In en, this message translates to:
  /// **'Use salt, oils and sugars in moderation'**
  String get sanjiTip2;

  /// Third tip from Sanji.
  ///
  /// In en, this message translates to:
  /// **'Vary the colors and types of vegetables and legumes'**
  String get sanjiTip3;

  /// Fourth tip from Sanji.
  ///
  /// In en, this message translates to:
  /// **'Choose healthier preparations (steam, sautéed, baked)'**
  String get sanjiTip4;

  /// Fifth tip from Sanji.
  ///
  /// In en, this message translates to:
  /// **'Enjoy fruits as dessert and snacks'**
  String get sanjiTip5;

  /// Reference text about the Brazilian food guide.
  ///
  /// In en, this message translates to:
  /// **'Consult the Food Guide for the Brazilian Population from the Ministry of Health for more detailed information.'**
  String get sanjiReference;

  /// Examples text with food list.
  ///
  /// In en, this message translates to:
  /// **'Examples: {foodList}'**
  String examples(String foodList);

  /// Title for nutrition results section.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Results'**
  String get nutritionResultsTitle;

  /// Title for BMR metric card.
  ///
  /// In en, this message translates to:
  /// **'BMR (Basal Metabolic Rate)'**
  String get bmrTitle;

  /// Subtitle for BMR metric card.
  ///
  /// In en, this message translates to:
  /// **'Calories your body burns at rest'**
  String get bmrSubtitle;

  /// Title for TDEE metric card.
  ///
  /// In en, this message translates to:
  /// **'TDEE (Total Daily Energy Expenditure)'**
  String get tdeeTitle;

  /// Subtitle for TDEE metric card.
  ///
  /// In en, this message translates to:
  /// **'Total calories you spend per day'**
  String get tdeeSubtitle;

  /// Title for calories per goal section.
  ///
  /// In en, this message translates to:
  /// **'Calories per Goal'**
  String get caloriesPerGoal;

  /// Maintain weight goal option.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get maintainWeight;

  /// Lose weight goal option.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get loseWeight;

  /// Muscle gain goal option.
  ///
  /// In en, this message translates to:
  /// **'Gain Muscle'**
  String get gainMuscle;

  /// Weight loss goal option.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get weightLoss;

  /// Maintenance goal option.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// Muscle gain goal option.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get muscleGain;

  /// Title for classifications section.
  ///
  /// In en, this message translates to:
  /// **'Classifications'**
  String get classifications;

  /// BMI label.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// Waist to height ratio label.
  ///
  /// In en, this message translates to:
  /// **'Waist/Height'**
  String get waistToHeight;

  /// Title for Sanji's tip section.
  ///
  /// In en, this message translates to:
  /// **'Personalized Recipe'**
  String get sanjiTipTitle;

  /// Text for Sanji's tip.
  ///
  /// In en, this message translates to:
  /// **'Click to receive a personalized recipe based on your nutritional data!'**
  String get sanjiTipText;

  /// Question for plate guide section.
  ///
  /// In en, this message translates to:
  /// **'How to build a healthy plate?'**
  String get plateGuideQuestion;

  /// Subtitle for plate guide section.
  ///
  /// In en, this message translates to:
  /// **'Learn the Ministry of Health recommendations for building a balanced plate'**
  String get plateGuideSubtitle;

  /// Button text to view plate guide.
  ///
  /// In en, this message translates to:
  /// **'View Plate Guide'**
  String get viewPlateGuide;

  /// Calories per day format.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal/day'**
  String kcalPerDay(String calories);

  /// Título da tela de finanças com a Nami.
  ///
  /// In en, this message translates to:
  /// **'Save with Nami'**
  String get financeWithNami;

  /// Title for Sanji cooking screen.
  ///
  /// In en, this message translates to:
  /// **'Cooking with Sanji'**
  String get cookingWithSanji;

  /// Button text for new calculation.
  ///
  /// In en, this message translates to:
  /// **'New Calculation'**
  String get newCalculation;

  /// Loading text when calculating nutrition.
  ///
  /// In en, this message translates to:
  /// **'Calculating nutrition...'**
  String get calculatingNutrition;

  /// First Sanji quote for header.
  ///
  /// In en, this message translates to:
  /// **'\"A true chef doesn\'t just cook, but nourishes the soul!\" - Sanji'**
  String get sanjiQuote1;

  /// Second Sanji quote for header.
  ///
  /// In en, this message translates to:
  /// **'\"Food is the fuel that moves the body and spirit!\" - Sanji'**
  String get sanjiQuote2;

  /// Third Sanji quote for header.
  ///
  /// In en, this message translates to:
  /// **'\"A balanced diet is fundamental to maintain energy and health!\" - Sanji'**
  String get sanjiQuote3;

  /// Fourth Sanji quote for header.
  ///
  /// In en, this message translates to:
  /// **'\"Here you will find recipes that combine nutrition and flavor!\" - Sanji'**
  String get sanjiQuote4;

  /// Fifth Sanji quote for header.
  ///
  /// In en, this message translates to:
  /// **'\"Inspired by the culinary philosophy of the best chef of the seas!\" - Sanji'**
  String get sanjiQuote5;

  /// Title for personal data section.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalData;

  /// Label for gender field.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Validation message for gender selection.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// Validation message for age field.
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get enterAge;

  /// Validation message for invalid number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// Label for weight field.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight;

  /// Validation message for weight field.
  ///
  /// In en, this message translates to:
  /// **'Enter your weight'**
  String get enterWeight;

  /// Label for height field.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get height;

  /// Validation message for height field.
  ///
  /// In en, this message translates to:
  /// **'Enter your height'**
  String get enterHeight;

  /// Label for waist circumference field.
  ///
  /// In en, this message translates to:
  /// **'Waist Circumference (cm)'**
  String get waistCircumference;

  /// Validation message for waist field.
  ///
  /// In en, this message translates to:
  /// **'Enter waist measurement'**
  String get enterWaist;

  /// Title for activity level section.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// Label for activity level dropdown.
  ///
  /// In en, this message translates to:
  /// **'Select your activity level'**
  String get selectActivityLevel;

  /// Validation message for activity level selection.
  ///
  /// In en, this message translates to:
  /// **'Select the activity level'**
  String get selectActivityLevelValidation;

  /// Title for goal section.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// Label for goal dropdown.
  ///
  /// In en, this message translates to:
  /// **'Select your goal'**
  String get selectGoal;

  /// Validation message for goal selection.
  ///
  /// In en, this message translates to:
  /// **'Select your goal'**
  String get selectGoalValidation;

  /// Button text to calculate nutrition.
  ///
  /// In en, this message translates to:
  /// **'Calculate Nutrition'**
  String get calculateNutrition;

  /// Error message when link cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// Sedentary activity level option.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get sedentary;

  /// Light activity level option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Moderate activity level option.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// Active activity level option.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Very active activity level option.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get veryActive;

  /// BMI category for underweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get underweight;

  /// BMI category for normal weight.
  ///
  /// In en, this message translates to:
  /// **'Normal Weight'**
  String get normalWeight;

  /// BMI category for overweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get overweight;

  /// BMI category for grade 1 obesity.
  ///
  /// In en, this message translates to:
  /// **'Grade 1 Obesity'**
  String get obesityGrade1;

  /// BMI category for grade 2 obesity.
  ///
  /// In en, this message translates to:
  /// **'Grade 2 Obesity'**
  String get obesityGrade2;

  /// BMI category for grade 3 obesity.
  ///
  /// In en, this message translates to:
  /// **'Grade 3 Obesity'**
  String get obesityGrade3;

  /// Waist-to-height ratio category for excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// Waist-to-height ratio category for good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// Waist-to-height ratio category for attention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// Waist-to-height ratio category for high risk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// Planner
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// Knowledge with Robin title screen
  ///
  /// In en, this message translates to:
  /// **'Knowledge with Robin'**
  String get knowledgeTitleScreen;

  /// Title for timeline of objectives section
  ///
  /// In en, this message translates to:
  /// **'Timeline of Objectives'**
  String get timelineOfObjectives;

  /// See all button text
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Message when no objectives are created
  ///
  /// In en, this message translates to:
  /// **'No objectives created'**
  String get noObjectivesCreated;

  /// Message to encourage creating first objective
  ///
  /// In en, this message translates to:
  /// **'Start creating your first objective'**
  String get startCreatingFirstObjective;

  /// Title for recent objectives section
  ///
  /// In en, this message translates to:
  /// **'Recent Objectives'**
  String get recentObjectives;

  /// Label for total count
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// Error message when loading objectives fails
  ///
  /// In en, this message translates to:
  /// **'Error loading objectives'**
  String get errorLoadingObjectives;

  /// Description for timeline section
  ///
  /// In en, this message translates to:
  /// **'Organize your study goals'**
  String get organizeStudyGoals;

  /// Label for progress section
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Title for details section
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Label for creation date
  ///
  /// In en, this message translates to:
  /// **'Creation Date'**
  String get creationDate;

  /// Label for deadline
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// Title for notes section
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Label for completed objectives
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Status for objective in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Status for overdue objective
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// Status for objective not started
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// Category name for study
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// Category name for work
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// Category name for personal
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// Category name for finance
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// Text for deadline due today
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// Text for deadline due in X days
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days'**
  String dueInDays(int days);

  /// Text for overdue deadline
  ///
  /// In en, this message translates to:
  /// **'Overdue by {days} days'**
  String overdueDays(int days);

  /// Text for deadline that passed
  ///
  /// In en, this message translates to:
  /// **'Due {days} days ago'**
  String dueDaysAgo(int days);

  /// Title for delete objective dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Objective'**
  String get deleteObjective;

  /// Confirmation message for deleting objective
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteObjectiveConfirmation(String title);

  /// Filter option for all items
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Title for new goal dialog
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoal;

  /// Label for title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Validation message for required title
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// Hint for goal title field
  ///
  /// In en, this message translates to:
  /// **'Enter the goal title'**
  String get enterGoalTitle;

  /// Hint for goal description field
  ///
  /// In en, this message translates to:
  /// **'Enter a description for the goal'**
  String get enterGoalDescription;

  /// Label for initial progress slider
  ///
  /// In en, this message translates to:
  /// **'Initial Progress: {progress}%'**
  String initialProgress(int progress);

  /// Hint for tags field
  ///
  /// In en, this message translates to:
  /// **'Enter tags separated by comma'**
  String get enterTagsCommaSeparated;

  /// Hint for notes field
  ///
  /// In en, this message translates to:
  /// **'Enter additional notes'**
  String get enterAdditionalNotes;

  /// Validation message for biological sex
  ///
  /// In en, this message translates to:
  /// **'Please select your biological sex.'**
  String get onboardingBiologicalSex;

  /// Validation message for required fields
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get onboardingFillAllFields;

  /// Biological sex male
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Biological sex female
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Title for recommendations
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// Edit plan button text
  ///
  /// In en, this message translates to:
  /// **'Edit Plan'**
  String get editPlan;

  /// Success message for workout plan
  ///
  /// In en, this message translates to:
  /// **'Workout plan saved successfully!'**
  String get workoutPlanSaved;

  /// Add split button text
  ///
  /// In en, this message translates to:
  /// **'Add Split'**
  String get addSplit;

  /// Hint for split name
  ///
  /// In en, this message translates to:
  /// **'Split name (e.g., Workout A)'**
  String get splitNameHint;

  /// Hint for exercise
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseHint;

  /// Hint for sets and reps
  ///
  /// In en, this message translates to:
  /// **'3x15'**
  String get setsRepsHint;

  /// Error message for no assessment
  ///
  /// In en, this message translates to:
  /// **'No assessment found for the current month'**
  String get noAssessmentFound;

  /// Generic add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// Label to select race
  ///
  /// In en, this message translates to:
  /// **'Select Race'**
  String get selectRace;

  /// Label for style name
  ///
  /// In en, this message translates to:
  /// **'Style Name'**
  String get styleName;

  /// Label for fighting type
  ///
  /// In en, this message translates to:
  /// **'Fighting Type'**
  String get fightingType;

  /// Add weapon button text
  ///
  /// In en, this message translates to:
  /// **'Add Weapon'**
  String get addWeapon;

  /// Add attack button text
  ///
  /// In en, this message translates to:
  /// **'Add Attack'**
  String get addAttack;

  /// Hint for fighting style
  ///
  /// In en, this message translates to:
  /// **'e.g.: Three Swords Style'**
  String get threeSwordsStyleHint;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLang;

  /// Portuguese language name
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get portugueseLang;

  /// Body composition title
  ///
  /// In en, this message translates to:
  /// **'Body Composition'**
  String get bodyComposition;

  /// Body data title
  ///
  /// In en, this message translates to:
  /// **'Body Data'**
  String get bodyData;

  /// Create first goal button text
  ///
  /// In en, this message translates to:
  /// **'Create First Goal'**
  String get createFirstGoal;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// Update body composition button text
  ///
  /// In en, this message translates to:
  /// **'Update Body Composition'**
  String get updateBodyComposition;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainAction;

  /// Hint for food ingredients
  ///
  /// In en, this message translates to:
  /// **'e.g.: chicken, rice, onion...'**
  String get foodExampleHint;

  /// Label for meal type
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// Label for dietary restrictions
  ///
  /// In en, this message translates to:
  /// **'Dietary Restrictions'**
  String get dietaryRestrictions;

  /// Empty state for incomes
  ///
  /// In en, this message translates to:
  /// **'No income registered'**
  String get noIncomeRegistered;

  /// Setup finances button text
  ///
  /// In en, this message translates to:
  /// **'Setup finances'**
  String get setupFinances;

  /// View details button text
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Edit data button text
  ///
  /// In en, this message translates to:
  /// **'Edit data'**
  String get editData;

  /// Title for month balance
  ///
  /// In en, this message translates to:
  /// **'Month Balance'**
  String get monthBalance;

  /// Title for incomes
  ///
  /// In en, this message translates to:
  /// **'Incomes'**
  String get incomes;

  /// Title for reserves
  ///
  /// In en, this message translates to:
  /// **'Reserves'**
  String get reserves;

  /// Title for categories
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Instruction to generate pirate flag
  ///
  /// In en, this message translates to:
  /// **'Enter a prompt to generate the pirate flag'**
  String get promptPirateFlag;

  /// Success message for generated flag
  ///
  /// In en, this message translates to:
  /// **'Pirate flag generated successfully!'**
  String get flagGeneratedSuccess;

  /// Instruction to generate ship
  ///
  /// In en, this message translates to:
  /// **'Enter a prompt to generate the ship'**
  String get promptShip;

  /// Success message for generated ship
  ///
  /// In en, this message translates to:
  /// **'Ship generated successfully!'**
  String get shipGeneratedSuccess;

  /// Title for create crew screen
  ///
  /// In en, this message translates to:
  /// **'Create Crew'**
  String get createCrewTitle;

  /// Success message for created crew
  ///
  /// In en, this message translates to:
  /// **'Crew created successfully!'**
  String get crewCreatedSuccess;

  /// Hint for crew tags
  ///
  /// In en, this message translates to:
  /// **'e.g.: Pirates, Adventurers, etc.'**
  String get crewTagsHint;

  /// Label for required crew name
  ///
  /// In en, this message translates to:
  /// **'Crew Name *'**
  String get crewNameRequired;

  /// Hint for crew description
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about your crew...'**
  String get crewDescriptionHint;

  /// Label for ship name
  ///
  /// In en, this message translates to:
  /// **'Ship Name'**
  String get shipNameLabel;

  /// Label for pirate flag
  ///
  /// In en, this message translates to:
  /// **'Pirate Flag'**
  String get pirateFlagLabel;

  /// Label for crew ship
  ///
  /// In en, this message translates to:
  /// **'Crew Ship'**
  String get crewShipLabel;

  /// Label for tag name
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagNameLabel;

  /// Hint for custom crew
  ///
  /// In en, this message translates to:
  /// **'e.g.: Mugiwaras Custom'**
  String get customCrewHint;

  /// Hint for merry ship
  ///
  /// In en, this message translates to:
  /// **'e.g.: Going Merry'**
  String get merryShipHint;

  /// Go home button text
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHomeAction;

  /// Title for AI generated image
  ///
  /// In en, this message translates to:
  /// **'AI Generated Image'**
  String get aiGeneratedImage;

  /// Notification title for Nami finances
  ///
  /// In en, this message translates to:
  /// **'💰 Monthly Report - Nami Finances'**
  String get monthlyReportFinances;

  /// Notification title for Zoro workout
  ///
  /// In en, this message translates to:
  /// **'⚔️ Zoro\'s Workout'**
  String get zoroWorkoutNotif;

  /// Notification title for Sanji tip
  ///
  /// In en, this message translates to:
  /// **'👨‍🍳 Sanji\'s Tip'**
  String get sanjiTipNotif;

  /// Notification title for featured character
  ///
  /// In en, this message translates to:
  /// **'🏴‍☠️ Featured Character'**
  String get featuredCharacterNotif;

  /// Notification title for financial tip
  ///
  /// In en, this message translates to:
  /// **'💰 Financial Tip'**
  String get financialTipNotif;

  /// Notification title for character duel
  ///
  /// In en, this message translates to:
  /// **'🎯 Character Duel'**
  String get characterDuelNotif;

  /// Auth status message
  ///
  /// In en, this message translates to:
  /// **'Checking authentication status...'**
  String get checkingAuthStatus;

  /// Auth status message for signing in
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingInAuth;

  /// Auth status message for signing out
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get signingOutAuth;

  /// No description provided for @createWorkoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Workout Plan'**
  String get createWorkoutPlan;

  /// No description provided for @createCustomPlanTap.
  ///
  /// In en, this message translates to:
  /// **'Tap to create your custom plan'**
  String get createCustomPlanTap;

  /// No description provided for @defaultWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get defaultWorkoutName;

  /// No description provided for @todayWorkoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout (Completed)'**
  String get todayWorkoutCompleted;

  /// No description provided for @todayWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get todayWorkout;

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 exercise} other {{count} exercises}}'**
  String exerciseCount(int count);

  /// No description provided for @completedWithCheck.
  ///
  /// In en, this message translates to:
  /// **'✅ Completed'**
  String get completedWithCheck;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noExercisesInSplit.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this split.'**
  String get noExercisesInSplit;

  /// No description provided for @viewProgress.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @increaseProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Increase Progress'**
  String get increaseProgressTitle;

  /// No description provided for @decreaseProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Decrease Progress'**
  String get decreaseProgressTitle;

  /// No description provided for @objectiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Objective: {title}'**
  String objectiveLabel(String title);

  /// No description provided for @currentProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Current progress: '**
  String get currentProgressLabel;

  /// No description provided for @newProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'New progress: '**
  String get newProgressLabel;

  /// No description provided for @planUpdatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Updates on the plan:'**
  String get planUpdatesLabel;

  /// No description provided for @progressIncreaseHint.
  ///
  /// In en, this message translates to:
  /// **'What did you do to progress? (e.g., studied for 2 hours, completed exercises...)'**
  String get progressIncreaseHint;

  /// No description provided for @progressDecreaseHint.
  ///
  /// In en, this message translates to:
  /// **'Why did the progress decrease? (e.g., delay, difficulty encountered...)'**
  String get progressDecreaseHint;

  /// No description provided for @describeWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Please describe what happened'**
  String get describeWhatHappened;

  /// No description provided for @increaseAction.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increaseAction;

  /// No description provided for @decreaseAction.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decreaseAction;

  /// No description provided for @emptyTimelineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start by creating your first objective to organize your study goals and track your progress.'**
  String get emptyTimelineSubtitle;

  /// No description provided for @biologicalSexLabel.
  ///
  /// In en, this message translates to:
  /// **'Biological Sex'**
  String get biologicalSexLabel;

  /// No description provided for @objectiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get objectiveTitle;

  /// No description provided for @activityLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Physical Activity Level'**
  String get activityLevelLabel;

  /// No description provided for @circumferencesLabel.
  ///
  /// In en, this message translates to:
  /// **'Circumferences'**
  String get circumferencesLabel;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @currentWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeightLabel;

  /// No description provided for @waistLabel.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waistLabel;

  /// No description provided for @chestLabel.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chestLabel;

  /// No description provided for @armLabel.
  ///
  /// In en, this message translates to:
  /// **'Arm'**
  String get armLabel;

  /// No description provided for @hipLabel.
  ///
  /// In en, this message translates to:
  /// **'Hip'**
  String get hipLabel;

  /// No description provided for @thighLabel.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get thighLabel;

  /// No description provided for @monthOverview.
  ///
  /// In en, this message translates to:
  /// **'Month overview'**
  String get monthOverview;

  /// No description provided for @balanceChart.
  ///
  /// In en, this message translates to:
  /// **'Balance chart'**
  String get balanceChart;

  /// No description provided for @incomesLabel.
  ///
  /// In en, this message translates to:
  /// **'Incomes'**
  String get incomesLabel;

  /// No description provided for @expensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesLabel;

  /// No description provided for @reservesLabel.
  ///
  /// In en, this message translates to:
  /// **'Reserves'**
  String get reservesLabel;

  /// No description provided for @totalReceived.
  ///
  /// In en, this message translates to:
  /// **'Total received'**
  String get totalReceived;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @noIncomesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No incomes registered'**
  String get noIncomesRegistered;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// No description provided for @errorGeneratingFlag.
  ///
  /// In en, this message translates to:
  /// **'Error generating flag: {error}'**
  String errorGeneratingFlag(String error);

  /// No description provided for @errorGeneratingShip.
  ///
  /// In en, this message translates to:
  /// **'Error generating ship: {error}'**
  String errorGeneratingShip(String error);

  /// No description provided for @crewDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Crew \"{name}\" deleted'**
  String crewDeletedMessage(String name);

  /// No description provided for @averageBountyLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Bounty'**
  String get averageBountyLabel;

  /// No description provided for @rolesLabel.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get rolesLabel;

  /// No description provided for @updateBodyCompositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Update Body Composition'**
  String get updateBodyCompositionLabel;

  /// No description provided for @linkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link: {url}'**
  String linkLabel(String url);

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @ageValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your age'**
  String get ageValidator;

  /// No description provided for @heightValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get heightValidator;

  /// No description provided for @weightValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight'**
  String get weightValidator;

  /// No description provided for @goalsAndMeasuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals & Measures'**
  String get goalsAndMeasuresTitle;

  /// No description provided for @goalsAndMeasuresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define your objective and add measures to track your progress with Sanji & Zoro.'**
  String get goalsAndMeasuresSubtitle;

  /// No description provided for @goalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get goalLoseWeight;

  /// No description provided for @goalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get goalMaintain;

  /// No description provided for @goalGainMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain Muscle'**
  String get goalGainMuscle;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get activityLight;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get activityModerate;

  /// No description provided for @activityIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get activityIntense;

  /// No description provided for @activityVeryIntense.
  ///
  /// In en, this message translates to:
  /// **'Very Intense'**
  String get activityVeryIntense;

  /// No description provided for @expensesDetails.
  ///
  /// In en, this message translates to:
  /// **'Expenses Details'**
  String get expensesDetails;

  /// No description provided for @totalExpensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses:'**
  String get totalExpensesLabel;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @cookingTipsHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: chicken, rice, onion...'**
  String get cookingTipsHint;

  /// No description provided for @todayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today (completed)'**
  String get todayCompleted;

  /// No description provided for @assessmentResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assessment Results'**
  String get assessmentResultsTitle;

  /// No description provided for @topRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Recommendations'**
  String get topRecommendationsTitle;

  /// No description provided for @weekProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Week Progress'**
  String get weekProgressTitle;

  /// No description provided for @streakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakTitle;

  /// No description provided for @thisMonthSuffix.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get thisMonthSuffix;

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysSuffix;

  /// No description provided for @doneTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get doneTodayLabel;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @onlyCurrentMonthEditAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only possible to edit finances of the current month'**
  String get onlyCurrentMonthEditAllowed;

  /// No description provided for @saveWithNami.
  ///
  /// In en, this message translates to:
  /// **'Save with Nami'**
  String get saveWithNami;

  /// No description provided for @configureYourFinances.
  ///
  /// In en, this message translates to:
  /// **'Configure your finances of the month and track\nyour progress in real time.'**
  String get configureYourFinances;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @noExpensesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No expenses registered'**
  String get noExpensesRegistered;

  /// No description provided for @categoryFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get categoryFixed;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableLabel;

  /// No description provided for @savingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savingsLabel;

  /// No description provided for @incomeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Income Details'**
  String get incomeDetailsTitle;

  /// No description provided for @savingsDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings Details'**
  String get savingsDetailsTitle;

  /// No description provided for @monthSavings.
  ///
  /// In en, this message translates to:
  /// **'Month Savings'**
  String get monthSavings;

  /// No description provided for @financialMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Metrics'**
  String get financialMetricsTitle;

  /// No description provided for @dailyAvailableAmount.
  ///
  /// In en, this message translates to:
  /// **'Daily Available Amount'**
  String get dailyAvailableAmount;

  /// No description provided for @janAbbr.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get janAbbr;

  /// No description provided for @febAbbr.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get febAbbr;

  /// No description provided for @marAbbr.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get marAbbr;

  /// No description provided for @aprAbbr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get aprAbbr;

  /// No description provided for @mayAbbr.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get mayAbbr;

  /// No description provided for @junAbbr.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get junAbbr;

  /// No description provided for @julAbbr.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get julAbbr;

  /// No description provided for @augAbbr.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get augAbbr;

  /// No description provided for @sepAbbr.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sepAbbr;

  /// No description provided for @octAbbr.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get octAbbr;

  /// No description provided for @novAbbr.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get novAbbr;

  /// No description provided for @decAbbr.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get decAbbr;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @currentMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get currentMonthLabel;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @workoutStatusDefeated.
  ///
  /// In en, this message translates to:
  /// **'Defeated'**
  String get workoutStatusDefeated;

  /// No description provided for @workoutStatusOnTarget.
  ///
  /// In en, this message translates to:
  /// **'On Target!'**
  String get workoutStatusOnTarget;

  /// No description provided for @zoroQuoteDefeated.
  ///
  /// In en, this message translates to:
  /// **'\"I will never lose again.\"'**
  String get zoroQuoteDefeated;

  /// No description provided for @zoroQuoteProud.
  ///
  /// In en, this message translates to:
  /// **'\"No matter what happens, I will never lose again.\"'**
  String get zoroQuoteProud;

  /// No description provided for @zoroStatusDefeated.
  ///
  /// In en, this message translates to:
  /// **'Zoro is defeated...'**
  String get zoroStatusDefeated;

  /// No description provided for @zoroStatusProud.
  ///
  /// In en, this message translates to:
  /// **'Zoro is proud!'**
  String get zoroStatusProud;

  /// No description provided for @workoutsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 workout remaining this week} other{{count} workouts remaining this week}}'**
  String workoutsRemaining(int count);

  /// No description provided for @weeklyGoalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal completed! 🎯'**
  String get weeklyGoalCompleted;

  /// No description provided for @workoutDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} days'**
  String workoutDaysCount(int done, int total);

  /// Vegapunk feature name shown in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Vegapunk'**
  String get vegapunk;

  /// Title of the Ask Vegapunk chat screen
  ///
  /// In en, this message translates to:
  /// **'Ask Vegapunk'**
  String get vegapunkChatTitle;

  /// Placeholder text in the chat input field
  ///
  /// In en, this message translates to:
  /// **'Ask anything...'**
  String get vegapunkChatHint;

  /// Title shown while the on-device LLM model is downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading Vegapunk\'s brain'**
  String get vegapunkModelDownloadTitle;

  /// Subtitle explaining the model download size and privacy
  ///
  /// In en, this message translates to:
  /// **'One-time download (~2.4 GB). The model runs fully on your device.'**
  String get vegapunkModelDownloadSubtitle;

  /// Message shown while the model is loading into memory
  ///
  /// In en, this message translates to:
  /// **'Activating Vegapunk...'**
  String get vegapunkModelLoadingTitle;

  /// Error message shown when the model fails to load
  ///
  /// In en, this message translates to:
  /// **'Vegapunk failed to initialize'**
  String get vegapunkModelErrorTitle;

  /// Button label to retry model download or initialization
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get vegapunkRetry;

  /// Button label to cancel model download
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get vegapunkCancel;

  /// Prompt shown when the chat has no messages yet
  ///
  /// In en, this message translates to:
  /// **'Vegapunk is ready. Ask me anything.'**
  String get vegapunkChatEmpty;

  /// Button label to stop the current generation
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get vegapunkStopGeneration;

  /// Vegapunk Satellite Stella
  ///
  /// In en, this message translates to:
  /// **'Stella (Original)'**
  String get vegapunkSatelliteStella;

  /// Vegapunk Satellite Shaka
  ///
  /// In en, this message translates to:
  /// **'Shaka (Good)'**
  String get vegapunkSatelliteShaka;

  /// Vegapunk Satellite Lilith
  ///
  /// In en, this message translates to:
  /// **'Lilith (Evil)'**
  String get vegapunkSatelliteLilith;

  /// Vegapunk Satellite Edison
  ///
  /// In en, this message translates to:
  /// **'Edison (Thinking)'**
  String get vegapunkSatelliteEdison;

  /// Vegapunk Satellite Pythagoras
  ///
  /// In en, this message translates to:
  /// **'Pythagoras (Wisdom)'**
  String get vegapunkSatellitePythagoras;

  /// Vegapunk Satellite Atlas
  ///
  /// In en, this message translates to:
  /// **'Atlas (Violence)'**
  String get vegapunkSatelliteAtlas;

  /// Vegapunk Satellite York
  ///
  /// In en, this message translates to:
  /// **'York (Greed)'**
  String get vegapunkSatelliteYork;

  /// Label for Vegapunk Thinking Mode toggle switch
  ///
  /// In en, this message translates to:
  /// **'Thinking Mode'**
  String get vegapunkThinkingMode;

  /// Description text for Vegapunk Thinking Mode toggle switch
  ///
  /// In en, this message translates to:
  /// **'Enable reasoning trace (increases memory and latency)'**
  String get vegapunkThinkingModeDesc;

  /// Header card title on the cooking tips screen
  ///
  /// In en, this message translates to:
  /// **'Personalized Meal with Sanji'**
  String get cookingPersonalizedMealTitle;

  /// Header card subtitle on the cooking tips screen
  ///
  /// In en, this message translates to:
  /// **'Add the ingredients you have and receive a personalized recipe based on your nutritional data!'**
  String get cookingPersonalizedMealSubtitle;

  /// Section title for the ingredient input area
  ///
  /// In en, this message translates to:
  /// **'Available Ingredients'**
  String get cookingAvailableIngredients;

  /// Card title for the personalized meal section
  ///
  /// In en, this message translates to:
  /// **'Personalized Meal'**
  String get cookingPersonalizedMeal;

  /// Info line showing target calories and goal
  ///
  /// In en, this message translates to:
  /// **'Target calories: {calories} kcal | Goal: {goal}'**
  String cookingTargetCaloriesInfo(String calories, String goal);

  /// Loading label on the generate meal button
  ///
  /// In en, this message translates to:
  /// **'Generating meal...'**
  String get cookingGeneratingMeal;

  /// Label on the generate meal button
  ///
  /// In en, this message translates to:
  /// **'Generate Meal'**
  String get cookingGenerateMeal;

  /// Title of the result card showing the personalized recipe
  ///
  /// In en, this message translates to:
  /// **'Personalized Recipe - {mealType}'**
  String cookingPersonalizedRecipeTitle(String mealType);

  /// Display label for the maintenance goal
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get cookingGoalMaintenance;

  /// Display label for the weight-loss goal
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get cookingGoalWeightLoss;

  /// Display label for the muscle-gain goal
  ///
  /// In en, this message translates to:
  /// **'Gain muscle'**
  String get cookingGoalMuscleGain;

  /// Meal type option
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealTypeBreakfast;

  /// Meal type option
  ///
  /// In en, this message translates to:
  /// **'Morning Snack'**
  String get mealTypeMorningSnack;

  /// Meal type option
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealTypeLunch;

  /// Meal type option
  ///
  /// In en, this message translates to:
  /// **'Afternoon Snack'**
  String get mealTypeAfternoonSnack;

  /// Meal type option
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealTypeDinner;

  /// Meal type option
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get mealTypeDessert;

  /// Meal type option
  ///
  /// In en, this message translates to:
  /// **'Night Snack'**
  String get mealTypeNightSnack;

  /// Dietary restriction option — no restrictions
  ///
  /// In en, this message translates to:
  /// **'No restrictions'**
  String get dietaryRestrictionNone;

  /// Dietary restriction option
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietaryRestrictionVegetarian;

  /// Dietary restriction option
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietaryRestrictionVegan;

  /// Dietary restriction option
  ///
  /// In en, this message translates to:
  /// **'Gluten-free'**
  String get dietaryRestrictionGlutenFree;

  /// Dietary restriction option
  ///
  /// In en, this message translates to:
  /// **'Lactose-free'**
  String get dietaryRestrictionLactoseFree;

  /// Dietary restriction option
  ///
  /// In en, this message translates to:
  /// **'Low carb'**
  String get dietaryRestrictionLowCarb;

  /// Dietary restriction option
  ///
  /// In en, this message translates to:
  /// **'High protein'**
  String get dietaryRestrictionHighProtein;
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
    'that was used.',
  );
}
