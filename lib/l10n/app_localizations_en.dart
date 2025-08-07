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
  String get financialSummary => 'Financial Summary';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get historyLast6Months => 'Last 6 Months History';

  @override
  String get noHistoryAvailable => 'No history available';

  @override
  String get loadingHistory => 'Loading history...';

  @override
  String get namiApproves => 'Nami approves!';

  @override
  String get namiNeedsReview => 'Nami needs to review this';

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
  String get age => 'Age';

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
  String get viceCaptain => 'Vice Captain';

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
  String get noDevilFruit => 'No Devil Fruit';

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
  String get clearFilters => 'Clear filters';

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
  String get loginBannerTitle => 'Sign in to access exclusive features';

  @override
  String get loginBannerSubtitle =>
      'Create characters, participate in duels and much more';

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
  String get createCrew => 'Create Crew';

  @override
  String get boat => ' Boat';

  @override
  String get crewBoatName => ' Boat name';

  @override
  String get crewRole => 'Crew Role';

  @override
  String get crewRoleHint => 'Select your role in the crew';

  @override
  String get helmsman => 'Helmsman';

  @override
  String get musician => 'Musician';

  @override
  String get boatswain => 'Boatswain';

  @override
  String viewingCharacter(String characterName) {
    return 'Viewing $characterName';
  }

  @override
  String editingCharacter(String characterName) {
    return 'Editing $characterName';
  }

  @override
  String get editCustomCharacterTitle => 'Edit Custom Character';

  @override
  String get editCustomCharacterSubtitle =>
      'Modify your character\'s information';

  @override
  String get update => 'Update';

  @override
  String get characterUpdatedSuccess => 'Character updated successfully';

  @override
  String characterUpdateError(String message) {
    return 'Error updating character: $message';
  }

  @override
  String get berriesTotal => 'Berries total';

  @override
  String members(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Members',
      one: 'Member',
      zero: 'Member',
    );
    return '$_temp0';
  }

  @override
  String get searchCrews => 'Search crews...';

  @override
  String get filter => 'Filter';

  @override
  String get myCrews => 'My Crews';

  @override
  String get allCrews => 'All Crews';

  @override
  String get errorLoadingCrews => 'Error loading crews';

  @override
  String get noCrewsFound => 'No crews found';

  @override
  String get createFirstCrew => 'Create your first crew!';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String confirmDeleteCrew(String crewName) {
    return 'Are you sure you want to delete the crew \"$crewName\"?';
  }

  @override
  String viewingCrew(String crewName) {
    return 'Viewing crew: $crewName';
  }

  @override
  String editingCrew(String crewName) {
    return 'Editing crew: $crewName';
  }

  @override
  String get aiImageGeneration => 'AI Image Generation';

  @override
  String get aiImageGenerationSubtitle =>
      'Generate a unique image for your character using AI';

  @override
  String get imagePrompt => 'Image Prompt';

  @override
  String get imagePromptHint => 'Describe how your character should look...';

  @override
  String get generateImage => 'Generate Image';

  @override
  String get generatingImage => 'Generating...';

  @override
  String get imageLoadError => 'Failed to load image';

  @override
  String get editCrewTitle => 'Edit Crew';

  @override
  String get editCrewSubtitle => 'Modify your crew\'s information';

  @override
  String get crewUpdatedSuccess => 'Crew updated successfully';

  @override
  String get crewUpdateError => 'Error updating crew';

  @override
  String get regenerateImage => 'Regenerate';

  @override
  String get useImage => 'Use Image';

  @override
  String get imageConfirmed => 'Image Confirmed';

  @override
  String get promptRequired => 'Please enter a prompt';

  @override
  String get imageGenerationError =>
      'Failed to generate image. Please try again.';

  @override
  String get selectDevilFruit => 'Select Devil Fruit';

  @override
  String get selectDevilFruitPlaceholder => 'Select a Devil Fruit';

  @override
  String get searchDevilFruit => 'Search Devil Fruit...';

  @override
  String get noDevilFruitFound => 'No Devil Fruit found';

  @override
  String get filterBy => 'Filter by';

  @override
  String get crewTeam => 'Crew';

  @override
  String get filterByDevilFruit => 'Filter by Devil Fruit';

  @override
  String get filterByCrew => 'Filter by Crew';

  @override
  String get addTag => 'Add Tag';

  @override
  String get addMember => 'Add Member';

  @override
  String get noCharactersAvailable => 'No characters available to add';

  @override
  String get tagName => 'Tag name';

  @override
  String get tagNameHint => 'Ex: Pirates, Adventurers, etc.';

  @override
  String get crewName => 'Crew Name *';

  @override
  String get crewNameHint => 'Ex: Custom Mugiwara';

  @override
  String get descriptionHint => 'Tell us about your crew...';

  @override
  String get pirateFlagUrl => 'Pirate Flag URL';

  @override
  String get pirateFlagUrlHint => 'https://example.com/flag.jpg';

  @override
  String get shipImageUrl => 'Ship Image URL';

  @override
  String get shipImageUrlHint => 'https://example.com/ship.jpg';

  @override
  String get devilFruitName => 'Devil fruit name';

  @override
  String get devilFruitNameHint => 'Ex: Gomu Gomu no Mi';

  @override
  String get crewNameFilter => 'Crew name';

  @override
  String get crewNameFilterHint => 'Ex: Straw Hat Pirates';

  @override
  String get dateFormat => 'DD/MM/YYYY';

  @override
  String get numberFormat => '0';

  @override
  String get editProfileTapped => 'Edit Profile tapped';

  @override
  String get notificationsTapped => 'Notifications tapped';

  @override
  String get languageTapped => 'Language tapped';

  @override
  String get themeTapped => 'Theme tapped';

  @override
  String get helpSupportTapped => 'Help & Support tapped';

  @override
  String get aboutTapped => 'About tapped';

  @override
  String get characterDeleted => 'Character deleted successfully';

  @override
  String get crewCreated => 'Crew created successfully';

  @override
  String get crewCreationError => 'Error creating crew';

  @override
  String get crewDeleted => 'Crew deleted successfully';

  @override
  String get crewDeletionError => 'Error deleting crew';

  @override
  String get memberAdded => 'Member added successfully';

  @override
  String get memberAdditionError => 'Error adding member';

  @override
  String get memberRemoved => 'Member removed successfully';

  @override
  String get memberRemovalError => 'Error removing member';

  @override
  String get crewUpdated => 'Crew updated successfully';

  @override
  String get loginError => 'Login error';

  @override
  String get videoLoadError => 'Error loading video';

  @override
  String get videoLoadSuccess => 'Video loaded successfully';

  @override
  String devilFruitSearchError(String error) {
    return 'Error searching Devil Fruit: $error';
  }

  @override
  String get noCustomCharactersFound => 'No custom characters found';

  @override
  String get createFirstCustomCharacter =>
      'Create your first custom character!';

  @override
  String get onePieceCharacters => 'One Piece Characters';

  @override
  String get customCharacters => 'Custom Characters';

  @override
  String get noOnePieceCharacters => 'No One Piece characters available';

  @override
  String get noCustomCharacters => 'No custom characters available';

  @override
  String get dualWielder => 'Dual Wielder';

  @override
  String get fighter => 'Fighter';

  @override
  String get taekwondo => 'Taekwondo';

  @override
  String get kicker => 'Kicker';

  @override
  String get archer => 'Archer';

  @override
  String get staff => 'Staff';

  @override
  String get other => 'Other';

  @override
  String get race => 'Race';

  @override
  String get human => 'Human';

  @override
  String get giant => 'Giant';

  @override
  String get fishman => 'Fishman';

  @override
  String get mermaid => 'Mermaid';

  @override
  String get mink => 'Mink';

  @override
  String get lunarian => 'Lunarian';

  @override
  String get buccaneer => 'Buccaneer';

  @override
  String get oni => 'Oni';

  @override
  String get skypiean => 'Skypiean';

  @override
  String get longarm => 'Longarm';

  @override
  String get tonatta => 'Tonatta';

  @override
  String get add => 'Add';

  @override
  String get noPermissionToEdit =>
      'You don\'t have permission to edit this crew';

  @override
  String get noPermissionToDelete =>
      'You don\'t have permission to delete this crew';

  @override
  String get allRolesFilled => 'All roles are already filled';

  @override
  String get characterNotFound => 'Character not found';

  @override
  String get characterLoadError => 'Error loading character';

  @override
  String memberAddedAsRole(String characterName, String role) {
    return '$characterName added as $role';
  }

  @override
  String crewDeletedWithName(String crewName) {
    return 'Crew \"$crewName\" deleted';
  }

  @override
  String get generatePirateFlagPrompt =>
      'Enter a prompt to generate the pirate flag';

  @override
  String get pirateFlagGeneratedSuccess =>
      'Pirate flag generated successfully!';

  @override
  String pirateFlagGenerationError(String error) {
    return 'Error generating flag: $error';
  }

  @override
  String get generateBoatPrompt => 'Enter a prompt to generate the boat';

  @override
  String get boatGeneratedSuccess => 'Boat generated successfully!';

  @override
  String boatGenerationError(String error) {
    return 'Error generating boat: $error';
  }

  @override
  String get profilePhotoTapped => 'Profile photo tapped';

  @override
  String get zodiacCapricorn => 'Capricorn';

  @override
  String get duels => 'Duels';

  @override
  String get duelsSubtitle => 'Character vs Character';

  @override
  String get versus => 'VS';

  @override
  String get winner => 'Wins!';

  @override
  String get startDuel => 'Start Duel';

  @override
  String get duelInProgress => 'Battle in Progress...';

  @override
  String get characterStats => 'Character Stats';

  @override
  String get selectFirstFighter => 'Select First Fighter';

  @override
  String get selectSecondFighter => 'Select Second Fighter';

  @override
  String get selectACharacter => 'Select a Character';

  @override
  String get randomizeCharacters => 'Randomize';

  @override
  String get resetDuel => 'Reset';

  @override
  String hakiType(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'types',
      one: 'type',
      zero: 'types',
    );
    return '$_temp0';
  }

  @override
  String get newDuel => 'New Duel';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get editProfileSubtitle => 'Update your personal information';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Manage your notification preferences';

  @override
  String get appSettings => 'App Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Change app language';

  @override
  String get theme => 'Theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkThemeActivated => 'Dark theme activated';

  @override
  String get lightThemeActivated => 'Light theme activated';

  @override
  String get support => 'Support';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get helpSupportSubtitle => 'Get help and contact support';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle => 'App version and information';

  @override
  String get nameMinLength => 'Name must be at least 3 characters';

  @override
  String get tags => 'Tags';

  @override
  String get noTagsAdded => 'No tags added';

  @override
  String get pirateFlagSectionTitle => 'Pirate Flag (Jolly Roger)';

  @override
  String get pirateFlagTitle => 'Crew Pirate Flag';

  @override
  String get aiPromptLabel => 'AI Prompt';

  @override
  String get pirateFlagPromptHint =>
      'Ex: pirate flag with skull and crossed swords';

  @override
  String get generateFlag => 'Generate Flag';

  @override
  String get crewBoatSectionTitle => 'Crew Boat';

  @override
  String get boatNameHint => 'Ex: Going Merry';

  @override
  String get generateBoat => 'Generate Boat';

  @override
  String get boatTitle => 'Crew Boat';

  @override
  String get aiPromptInfo =>
      'Use descriptive prompts to generate unique images for your crew. Generated images will be saved automatically.';

  @override
  String get fightingStyleSectionTitle => 'Fighting Style';

  @override
  String get fightingStyleNameLabel => 'Style Name';

  @override
  String get fightingStyleTypeLabel => 'Fighting Type';

  @override
  String get fightingStyleWeaponsLabel => 'Weapons';

  @override
  String get fightingStyleAttacksLabel => 'Attacks';

  @override
  String get finances => 'Finances';

  @override
  String get monthlyIncome => 'Monthly Income';

  @override
  String get monthlyIncomeHint => 'Enter your monthly income';

  @override
  String get expenses => 'Expenses';

  @override
  String get fixedExpenses => 'Fixed Expenses (Rent, Bills)';

  @override
  String get foodExpenses => 'Food';

  @override
  String get transportExpenses => 'Transport';

  @override
  String get entertainmentExpenses => 'Entertainment';

  @override
  String get otherExpenses => 'Other Expenses';

  @override
  String get results => 'Results';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get availableAmount => 'Available Amount';

  @override
  String get dailyAmount => 'Daily Available Amount';

  @override
  String get currency => 'R\$';

  @override
  String get perDay => '/day';

  @override
  String get health => 'Health';

  @override
  String get selectExpenseCategory => 'Select expense category:';

  @override
  String get category => 'Category';

  @override
  String get remove => 'Remove';

  @override
  String get value => 'Value';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get savings => 'Savings';

  @override
  String get monthlySavings => 'Monthly Savings';

  @override
  String get savingsHint => 'How much do you save per month?';

  @override
  String get savingsPercentage => 'of Income';

  @override
  String get yearlySavings => 'Accumulated in 1 Year';
}
