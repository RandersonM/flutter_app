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
  /// **'Expenses by Category'**
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

  /// Cancel button text.
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

  /// Fighting type option for other
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

  /// Section title for tags.
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

  /// Label for AI prompt field.
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

  /// Section title for expenses in finances screen.
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

  /// Health expenses category.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// Instruction text for expense category selection dialog.
  ///
  /// In en, this message translates to:
  /// **'Select expense category:'**
  String get selectExpenseCategory;

  /// Label for category dropdown in expense dialog.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Remove button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

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
  /// **'of Income'**
  String get savingsPercentage;

  /// Label for accumulated value in one year.
  ///
  /// In en, this message translates to:
  /// **'Accumulated in 1 Year'**
  String get yearlySavings;
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
