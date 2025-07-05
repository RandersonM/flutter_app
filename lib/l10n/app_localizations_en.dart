// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String affiliation(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Affiliations',
      one: 'Affiliation',
      zero: 'Affiliation',
    );
    return '$_temp0';
  }

  @override
  String get beastsPirates => 'Beasts Pirates';

  @override
  String get bigMomPirates => 'Big Mom Pirates';

  @override
  String get bounty => 'Bounty';

  @override
  String get calculatorTitle => 'Calculator';

  @override
  String get counterTitle => 'Counter';

  @override
  String get devilFruitUserPrefix => 'User of';

  @override
  String get emperors => 'Four Emperors';

  @override
  String get haki => 'Haki';

  @override
  String get home => 'Home';

  @override
  String get howManyPushPhrase => 'You have pushed the button this many times:';

  @override
  String get noResearchYet => 'No research done yet.';

  @override
  String get noResultsFound => 'No results found for';

  @override
  String occupation(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Occupations',
      one: 'Occupation',
      zero: 'Occupation',
    );
    return '$_temp0';
  }

  @override
  String get onePiece => 'One Piece';

  @override
  String get result => 'Result';

  @override
  String get search => 'Search';

  @override
  String get superRookie => 'Super Rookie';

  @override
  String get strawHat => 'Straw Hat Pirates';

  @override
  String get featuredCharacter => 'Featured Character';

  @override
  String get randomCharacter => 'Random Character';

  @override
  String get refresh => 'Refresh';

  @override
  String get statistics => 'Details';

  @override
  String get myCharacters => 'My Characters';

  @override
  String get totalCharacters => 'Total Characters';

  @override
  String get highestBounty => 'Highest Bounty';

  @override
  String get crews => 'Crews';

  @override
  String get searchingVideo => 'Searching AMV video...';

  @override
  String get loadingError => 'Error loading character';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get loading => 'Loading...';

  @override
  String get imageUnavailable => 'Image\nUnavailable';

  @override
  String get selectCharacter => 'Select Character';

  @override
  String get signo => 'Zodiac Sign';

  @override
  String get status => 'Status';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get noImage => 'No Image';

  @override
  String get createCustomCharacterTitle => 'Create Custom Character';

  @override
  String get createCustomCharacterSubtitle =>
      'Fill in the information below to create your unique character in the One Piece world!';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get name => 'Name';

  @override
  String get nameRequired => 'Please enter a name';

  @override
  String get nameHint => 'Ex: Monkey D. Luffy';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameHint => 'Ex: Luffy, Straw Hat';

  @override
  String get age => 'Idade';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get birthDateHint => 'DD/MM/YYYY';

  @override
  String get powers => 'Powers';

  @override
  String get devilFruitHint => 'Ex: Gomu Gomu no Mi';

  @override
  String get hakiTypes => 'Haki Types';

  @override
  String get haoshokuHaki => 'Haoshoku Haki (King\'s Haki)';

  @override
  String get busoshokuHaki => 'Busoshoku Haki (Armament Haki)';

  @override
  String get kenbunshokuHaki => 'Kenbunshoku Haki (Observation Haki)';

  @override
  String get background => 'Background';

  @override
  String get crewHint => 'Ex: Straw Hat Pirates';

  @override
  String get bountyRequired => 'Please enter a bounty';

  @override
  String get bountyHint => 'Ex: 3,000,000,000 Berries';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get imageUrlHint => 'Ex: https://example.com/image.jpg';

  @override
  String get captured => 'Captured';

  @override
  String get alive => 'Alive';

  @override
  String get dead => 'Dead';

  @override
  String get unknown => 'Unknown';

  @override
  String get affiliations => 'Affiliations';

  @override
  String get marines => 'Marines';

  @override
  String get revolutionaries => 'Revolutionaries';

  @override
  String get yonkou => 'Yonkou';

  @override
  String get shichibukai => 'Shichibukai';

  @override
  String get independent => 'Independent';

  @override
  String get pirate => 'Pirate';

  @override
  String get pirateAlliance => 'Pirate Alliance';

  @override
  String get occupations => 'Occupations';

  @override
  String get captain => 'Captain';

  @override
  String get admiral => 'Admiral';

  @override
  String get viceAdmiral => 'Vice Admiral';

  @override
  String get revolutionary => 'Revolutionary';

  @override
  String get merchant => 'Merchant';

  @override
  String get doctor => 'Doctor';

  @override
  String get navigator => 'Navigator';

  @override
  String get cook => 'Cook';

  @override
  String get sniper => 'Sniper';

  @override
  String get swordsman => 'Swordsman';

  @override
  String get carpenter => 'Carpenter';

  @override
  String get archaeologist => 'Archaeologist';

  @override
  String get sharpshooter => 'Sharpshooter';

  @override
  String get description => 'Description';

  @override
  String get characterStory => 'Character Story';

  @override
  String get characterStoryHint => 'Tell the story of your custom character...';

  @override
  String get createCharacter => 'Create Character';

  @override
  String get cancel => 'Cancel';

  @override
  String get success => 'Success!';

  @override
  String get characterCreatedSuccess =>
      'Custom character created successfully!';

  @override
  String get error => 'Error';

  @override
  String characterCreationError(String message) {
    return 'Error creating character: $message';
  }

  @override
  String get ok => 'OK';

  @override
  String get devilFruit => 'Devil Fruit';

  @override
  String crew(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Crews',
      one: 'Crew',
      zero: 'Crew',
    );
    return '$_temp0';
  }

  @override
  String get ariesSign => 'Aries';

  @override
  String get taurusSign => 'Taurus';

  @override
  String get geminiSign => 'Gemini';

  @override
  String get cancerSign => 'Cancer';

  @override
  String get leoSign => 'Leo';

  @override
  String get virgoSign => 'Virgo';

  @override
  String get libraSign => 'Libra';

  @override
  String get scorpioSign => 'Scorpio';

  @override
  String get sagittariusSign => 'Sagittarius';

  @override
  String get capricornSign => 'Capricorn';

  @override
  String get aquariusSign => 'Aquarius';

  @override
  String get piscesSign => 'Pisces';

  @override
  String get welcome => 'Welcome,';

  @override
  String get welcomeToOpfan => 'Welcome to OpFan';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get authenticationError => 'Authentication Error';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String get clearDataAndContinue => 'Clear data and continue';

  @override
  String get searchPlaceholder => 'Search by roman or japanese name...';

  @override
  String get filterByType => 'Filter by type';

  @override
  String get clear => 'Clear';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get noFruitFound => 'No fruit found';

  @override
  String get noDevilFruitAvailable => 'No Devil Fruit available';

  @override
  String get adjustFiltersOrSearch =>
      'Try adjusting the filters or search for other terms';

  @override
  String get errorLoadingContent => 'Error loading content';

  @override
  String get searching => 'Searching...';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get loginWelcomeSubtitle =>
      'Explore the world of One Piece and discover your favorite characters';

  @override
  String get version => 'version';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get close => 'Close';

  @override
  String get type => 'Type';

  @override
  String get createCustomCharacter => 'Create character';

  @override
  String get createCrew => 'Create new crew';

  @override
  String viewingCharacter(String characterName) {
    return 'Viewing $characterName';
  }

  @override
  String editingCharacter(String characterName) {
    return 'Editing $characterName';
  }
}
