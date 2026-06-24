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
  String get expensesByCategory => 'Expenses by category';

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
  String get save => 'Save';

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
  String get savingsPercentage => 'Savings Percentage';

  @override
  String get yearlySavings => 'Yearly Savings';

  @override
  String get accumulatedSavings => 'Accumulated';

  @override
  String get savingsPeriod => 'Savings Period';

  @override
  String get workout => 'Workout';

  @override
  String get workout_title_screen => 'Workout with Zoro';

  @override
  String get workout_health_assessment => 'Complete Health Assessment';

  @override
  String get workout_health_assessment_subtitle =>
      'Combines BMI, waist-to-height ratio and body fat percentage for a more accurate health assessment';

  @override
  String get workout_results => 'Assessment Results';

  @override
  String get workout_recommendations => 'Personalized Recommendations';

  @override
  String get workout_calculate_metrics => 'Calculate Health Metrics';

  @override
  String get workout_new_assessment => 'New Assessment';

  @override
  String get workout_gender => 'Gender';

  @override
  String get workout_age => 'Age';

  @override
  String get workout_height => 'Height (cm)';

  @override
  String get workout_weight => 'Weight (kg)';

  @override
  String get workout_waist => 'Waist Circumference (cm)';

  @override
  String get workout_health_score => 'Health Score';

  @override
  String get workout_bmi => 'BMI';

  @override
  String get workout_waist_to_height => 'Waist-to-Height Ratio';

  @override
  String get workout_body_fat => 'Body Fat Percentage';

  @override
  String get workout_formula_bmi => 'Weight (kg) / Height (m)²';

  @override
  String get workout_formula_waist_to_height => 'Waist (cm) / Height (cm)';

  @override
  String get workout_formula_body_fat => 'Formula based on BMI, age and gender';

  @override
  String get workout_validation_gender_required => 'Please select gender';

  @override
  String get workout_validation_age_required => 'Please enter your age';

  @override
  String get workout_validation_age_invalid => 'Please enter a valid number';

  @override
  String get workout_validation_height_required => 'Please enter your height';

  @override
  String get workout_validation_height_invalid => 'Please enter a valid number';

  @override
  String get workout_validation_weight_required => 'Please enter your weight';

  @override
  String get workout_validation_weight_invalid => 'Please enter a valid number';

  @override
  String get workout_validation_waist_required =>
      'Please enter waist measurement';

  @override
  String get workout_validation_waist_invalid => 'Please enter a valid number';

  @override
  String get workout_gender_male => 'Male';

  @override
  String get workout_gender_female => 'Female';

  @override
  String get workout_category_excellent => 'Excellent';

  @override
  String get workout_category_good => 'Good';

  @override
  String get workout_category_regular => 'Regular';

  @override
  String get workout_category_needs_improvement => 'Needs improvement';

  @override
  String get workout_category_underweight => 'Underweight';

  @override
  String get workout_category_normal => 'Normal weight';

  @override
  String get workout_category_overweight => 'Overweight';

  @override
  String get workout_category_obesity_1 => 'Obesity grade 1';

  @override
  String get workout_category_obesity_2 => 'Obesity grade 2';

  @override
  String get workout_category_obesity_3 => 'Obesity grade 3';

  @override
  String get workout_category_attention => 'Attention';

  @override
  String get workout_category_high_risk => 'High risk';

  @override
  String get workout_category_very_low => 'Very low';

  @override
  String get workout_category_athletic => 'Athletic';

  @override
  String get workout_category_acceptable => 'Acceptable';

  @override
  String get workout_category_high => 'High';

  @override
  String get workout_exercise_advanced_strength =>
      'Advanced strength training 4x per week';

  @override
  String get workout_exercise_hiit => 'High intensity cardio (HIIT)';

  @override
  String get workout_exercise_competitive_sports => 'Competitive sports';

  @override
  String get workout_exercise_complex_functional =>
      'Complex functional training';

  @override
  String get workout_exercise_flexibility => 'Flexibility and mobility';

  @override
  String get workout_exercise_strength_training =>
      'Strength training 3x per week';

  @override
  String get workout_exercise_moderate_cardio => 'Moderate cardio 30-45 min';

  @override
  String get workout_exercise_functional => 'Functional training';

  @override
  String get workout_exercise_yoga_pilates => 'Yoga or pilates';

  @override
  String get workout_exercise_recreational_sports => 'Recreational sports';

  @override
  String get workout_exercise_walking => 'Walking 30-45 minutes';

  @override
  String get workout_exercise_basic_strength =>
      'Basic strength training 2x per week';

  @override
  String get workout_exercise_water_aerobics => 'Water aerobics';

  @override
  String get workout_exercise_stretching => 'Daily stretching';

  @override
  String get workout_exercise_breathing => 'Breathing exercises';

  @override
  String get workout_exercise_light_walking => 'Light walking 20-30 minutes';

  @override
  String get workout_exercise_light_stretching => 'Light stretching exercises';

  @override
  String get workout_exercise_soft_water_aerobics => 'Soft water aerobics';

  @override
  String get workout_exercise_tai_chi_yoga => 'Tai Chi or soft Yoga';

  @override
  String get workout_exercise_consult_professional =>
      'Consult health professional';

  @override
  String get workout_exercise_cardiovascular_focus =>
      'Focus on cardiovascular exercises';

  @override
  String get workout_exercise_core_training => 'Specific core training';

  @override
  String get workout_exercise_diet_control => 'Diet control';

  @override
  String get workout_exercise_low_impact => 'Low impact activities';

  @override
  String get workout_exercise_professional_supervision =>
      'Professional supervision';

  @override
  String get workout_exercise_gradual_progression => 'Gradual progression';

  @override
  String savings_period_years_and_months(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$years year$_temp0 and $months month$_temp1';
  }

  @override
  String savings_period_years_only(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$years year$_temp0';
  }

  @override
  String savings_period_months_only(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$months month$_temp0';
  }

  @override
  String get savings_period_one_month => '1 month';

  @override
  String savings_formatted_total(String amount, String period) {
    return 'R\$ $amount in $period';
  }

  @override
  String get workout_calendar_title => 'Workout Calendar';

  @override
  String get workout_calendar_sunday => 'Sun';

  @override
  String get workout_calendar_monday => 'Mon';

  @override
  String get workout_calendar_tuesday => 'Tue';

  @override
  String get workout_calendar_wednesday => 'Wed';

  @override
  String get workout_calendar_thursday => 'Thu';

  @override
  String get workout_calendar_friday => 'Fri';

  @override
  String get workout_calendar_saturday => 'Sat';

  @override
  String get workout_workout_days_goal => 'Workout days goal per week';

  @override
  String get workout_validation_workout_days_required =>
      'Select your workout days goal';

  @override
  String get workout_day => 'day';

  @override
  String get workout_days => 'days';

  @override
  String get cooking => 'Cooking';

  @override
  String get plateGuideTitle => 'Healthy Plate Guide';

  @override
  String get plateGuideHeader =>
      'Based on Brazilian Ministry of Health recommendations, this guide shows how to build a balanced plate with ideal proportions of each food group.';

  @override
  String get plateDivision => 'Plate Division';

  @override
  String get vegetablesTitle => 'Vegetables and Legumes';

  @override
  String get vegetablesSubtitle => '50% of plate';

  @override
  String get vegetablesDescription =>
      'Regulatory foods rich in vitamins, minerals and fiber';

  @override
  String get vegetablesExamples =>
      'Lettuce, watercress, arugula, spinach, broccoli, cauliflower, carrot, zucchini';

  @override
  String get proteinsTitle => 'Proteins';

  @override
  String get proteinsSubtitle => '25% of plate';

  @override
  String get proteinsDescription =>
      'Building foods essential for muscles and tissues';

  @override
  String get proteinsExamples =>
      'Chicken, fish, meat, eggs, beans, lentils, chickpeas';

  @override
  String get carbohydratesTitle => 'Carbohydrates';

  @override
  String get carbohydratesSubtitle => '25% of plate';

  @override
  String get carbohydratesDescription =>
      'Energy foods that provide energy for the body';

  @override
  String get carbohydratesExamples =>
      'Rice, potato, pasta, bread, sweet potato, cassava';

  @override
  String get sanjiTipsTitle => 'Sanji\'s Tips';

  @override
  String get sanjiTip1 => 'Prefer fresh or minimally processed foods';

  @override
  String get sanjiTip2 => 'Use salt, oils and sugars in moderation';

  @override
  String get sanjiTip3 => 'Vary the colors and types of vegetables and legumes';

  @override
  String get sanjiTip4 =>
      'Choose healthier preparations (steam, sautéed, baked)';

  @override
  String get sanjiTip5 => 'Enjoy fruits as dessert and snacks';

  @override
  String get sanjiReference =>
      'Consult the Food Guide for the Brazilian Population from the Ministry of Health for more detailed information.';

  @override
  String examples(String foodList) {
    return 'Examples: $foodList';
  }

  @override
  String get nutritionResultsTitle => 'Nutritional Results';

  @override
  String get bmrTitle => 'BMR (Basal Metabolic Rate)';

  @override
  String get bmrSubtitle => 'Calories your body burns at rest';

  @override
  String get tdeeTitle => 'TDEE (Total Daily Energy Expenditure)';

  @override
  String get tdeeSubtitle => 'Total calories you spend per day';

  @override
  String get caloriesPerGoal => 'Calories per Goal';

  @override
  String get maintainWeight => 'Maintain Weight';

  @override
  String get loseWeight => 'Lose Weight';

  @override
  String get gainMuscle => 'Gain Muscle';

  @override
  String get weightLoss => 'Weight Loss';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get muscleGain => 'Muscle Gain';

  @override
  String get classifications => 'Classifications';

  @override
  String get bmi => 'BMI';

  @override
  String get waistToHeight => 'Waist/Height';

  @override
  String get sanjiTipTitle => 'Receita Personalizada';

  @override
  String get sanjiTipText =>
      'Clique para receber uma receita personalizada baseada nos seus dados nutricionais!';

  @override
  String get plateGuideQuestion => 'How to build a healthy plate?';

  @override
  String get plateGuideSubtitle =>
      'Learn the Ministry of Health recommendations for building a balanced plate';

  @override
  String get viewPlateGuide => 'View Plate Guide';

  @override
  String kcalPerDay(String calories) {
    return '$calories kcal/day';
  }

  @override
  String get financeWithNami => 'Economize com a Nami';

  @override
  String get cookingWithSanji => 'Cooking with Sanji';

  @override
  String get newCalculation => 'New Calculation';

  @override
  String get calculatingNutrition => 'Calculating nutrition...';

  @override
  String get sanjiQuote1 =>
      '\"A true chef doesn\'t just cook, but nourishes the soul!\" - Sanji';

  @override
  String get sanjiQuote2 =>
      '\"Food is the fuel that moves the body and spirit!\" - Sanji';

  @override
  String get sanjiQuote3 =>
      '\"A balanced diet is fundamental to maintain energy and health!\" - Sanji';

  @override
  String get sanjiQuote4 =>
      '\"Here you will find recipes that combine nutrition and flavor!\" - Sanji';

  @override
  String get sanjiQuote5 =>
      '\"Inspired by the culinary philosophy of the best chef of the seas!\" - Sanji';

  @override
  String get personalData => 'Personal Data';

  @override
  String get gender => 'Gender';

  @override
  String get selectGender => 'Select gender';

  @override
  String get enterAge => 'Enter your age';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get weight => 'Weight (kg)';

  @override
  String get enterWeight => 'Enter your weight';

  @override
  String get height => 'Height (cm)';

  @override
  String get enterHeight => 'Enter your height';

  @override
  String get waistCircumference => 'Waist Circumference (cm)';

  @override
  String get enterWaist => 'Enter waist measurement';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get selectActivityLevel => 'Select your activity level';

  @override
  String get selectActivityLevelValidation => 'Select the activity level';

  @override
  String get goal => 'Goal';

  @override
  String get selectGoal => 'Select your goal';

  @override
  String get selectGoalValidation => 'Select your goal';

  @override
  String get calculateNutrition => 'Calculate Nutrition';

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get sedentary => 'Sedentary';

  @override
  String get light => 'Light';

  @override
  String get moderate => 'Moderate';

  @override
  String get active => 'Active';

  @override
  String get veryActive => 'Very Active';

  @override
  String get underweight => 'Underweight';

  @override
  String get normalWeight => 'Normal Weight';

  @override
  String get overweight => 'Overweight';

  @override
  String get obesityGrade1 => 'Grade 1 Obesity';

  @override
  String get obesityGrade2 => 'Grade 2 Obesity';

  @override
  String get obesityGrade3 => 'Grade 3 Obesity';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get attention => 'Attention';

  @override
  String get highRisk => 'High Risk';

  @override
  String get planner => 'Planner';

  @override
  String get knowledgeTitleScreen => 'Knowledge with Robin';

  @override
  String get timelineOfObjectives => 'Timeline of Objectives';

  @override
  String get seeAll => 'See all';

  @override
  String get noObjectivesCreated => 'No objectives created';

  @override
  String get startCreatingFirstObjective =>
      'Start creating your first objective';

  @override
  String get recentObjectives => 'Recent Objectives';

  @override
  String get total => 'total';

  @override
  String get errorLoadingObjectives => 'Error loading objectives';

  @override
  String get organizeStudyGoals => 'Organize your study goals';

  @override
  String get progress => 'Progress';

  @override
  String get details => 'Details';

  @override
  String get creationDate => 'Creation Date';

  @override
  String get deadline => 'Deadline';

  @override
  String get notes => 'Notes';

  @override
  String get completed => 'Completed';

  @override
  String get inProgress => 'In Progress';

  @override
  String get overdue => 'Overdue';

  @override
  String get notStarted => 'Not Started';

  @override
  String get study => 'Study';

  @override
  String get work => 'Work';

  @override
  String get personal => 'Personal';

  @override
  String get finance => 'Finance';

  @override
  String get dueToday => 'Due today';

  @override
  String dueInDays(int days) {
    return 'Due in $days days';
  }

  @override
  String overdueDays(int days) {
    return 'Overdue by $days days';
  }

  @override
  String dueDaysAgo(int days) {
    return 'Due $days days ago';
  }

  @override
  String get deleteObjective => 'Delete Objective';

  @override
  String deleteObjectiveConfirmation(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get all => 'All';

  @override
  String get newGoal => 'New Goal';

  @override
  String get title => 'Title';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get enterGoalTitle => 'Enter the goal title';

  @override
  String get enterGoalDescription => 'Enter a description for the goal';

  @override
  String initialProgress(int progress) {
    return 'Initial Progress: $progress%';
  }

  @override
  String get enterTagsCommaSeparated => 'Enter tags separated by comma';

  @override
  String get enterAdditionalNotes => 'Enter additional notes';

  @override
  String get onboardingBiologicalSex => 'Please select your biological sex.';

  @override
  String get onboardingFillAllFields => 'Please fill in all required fields.';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get editPlan => 'Edit Plan';

  @override
  String get workoutPlanSaved => 'Workout plan saved successfully!';

  @override
  String get addSplit => 'Add Split';

  @override
  String get splitNameHint => 'Split name (e.g., Workout A)';

  @override
  String get exerciseHint => 'Exercise';

  @override
  String get setsRepsHint => '3x15';

  @override
  String get noAssessmentFound => 'No assessment found for the current month';

  @override
  String get addAction => 'Add';

  @override
  String get selectRace => 'Select Race';

  @override
  String get styleName => 'Style Name';

  @override
  String get fightingType => 'Fighting Type';

  @override
  String get addWeapon => 'Add Weapon';

  @override
  String get addAttack => 'Add Attack';

  @override
  String get threeSwordsStyleHint => 'e.g.: Three Swords Style';

  @override
  String get englishLang => 'English';

  @override
  String get portugueseLang => 'Português';

  @override
  String get bodyComposition => 'Body Composition';

  @override
  String get bodyData => 'Body Data';

  @override
  String get createFirstGoal => 'Create First Goal';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get saveAction => 'Save';

  @override
  String get clearAction => 'Clear';

  @override
  String get updateBodyComposition => 'Update Body Composition';

  @override
  String get tryAgainAction => 'Try again';

  @override
  String get foodExampleHint => 'e.g.: chicken, rice, onion...';

  @override
  String get mealType => 'Meal Type';

  @override
  String get dietaryRestrictions => 'Dietary Restrictions';

  @override
  String get noIncomeRegistered => 'No income registered';

  @override
  String get setupFinances => 'Setup finances';

  @override
  String get viewDetails => 'View Details';

  @override
  String get editData => 'Edit data';

  @override
  String get monthBalance => 'Month Balance';

  @override
  String get incomes => 'Incomes';

  @override
  String get reserves => 'Reserves';

  @override
  String get categories => 'Categories';

  @override
  String get promptPirateFlag => 'Enter a prompt to generate the pirate flag';

  @override
  String get flagGeneratedSuccess => 'Pirate flag generated successfully!';

  @override
  String get promptShip => 'Enter a prompt to generate the ship';

  @override
  String get shipGeneratedSuccess => 'Ship generated successfully!';

  @override
  String get createCrewTitle => 'Create Crew';

  @override
  String get crewCreatedSuccess => 'Crew created successfully!';

  @override
  String get crewTagsHint => 'e.g.: Pirates, Adventurers, etc.';

  @override
  String get crewNameRequired => 'Crew Name *';

  @override
  String get crewDescriptionHint => 'Tell us a bit about your crew...';

  @override
  String get shipNameLabel => 'Ship Name';

  @override
  String get pirateFlagLabel => 'Pirate Flag';

  @override
  String get crewShipLabel => 'Crew Ship';

  @override
  String get tagNameLabel => 'Tag name';

  @override
  String get customCrewHint => 'e.g.: Mugiwaras Custom';

  @override
  String get merryShipHint => 'e.g.: Going Merry';

  @override
  String get goHomeAction => 'Go Home';

  @override
  String get aiGeneratedImage => 'AI Generated Image';

  @override
  String get monthlyReportFinances => '💰 Monthly Report - Nami Finances';

  @override
  String get zoroWorkoutNotif => '⚔️ Zoro\'s Workout';

  @override
  String get sanjiTipNotif => '👨‍🍳 Sanji\'s Tip';

  @override
  String get featuredCharacterNotif => '🏴‍☠️ Featured Character';

  @override
  String get financialTipNotif => '💰 Financial Tip';

  @override
  String get characterDuelNotif => '🎯 Character Duel';

  @override
  String get checkingAuthStatus => 'Checking authentication status...';

  @override
  String get signingInAuth => 'Signing in...';

  @override
  String get signingOutAuth => 'Signing out...';

  @override
  String get createWorkoutPlan => 'Create Workout Plan';

  @override
  String get createCustomPlanTap => 'Tap to create your custom plan';

  @override
  String get defaultWorkoutName => 'Workout';

  @override
  String get todayWorkoutCompleted => 'Today\'s Workout (Completed)';

  @override
  String get todayWorkout => 'Today\'s Workout';

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get completedWithCheck => '✅ Completed';

  @override
  String get today => 'Today';

  @override
  String get noExercisesInSplit => 'No exercises in this split.';

  @override
  String get viewProgress => 'View Progress';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String get increaseProgressTitle => 'Increase Progress';

  @override
  String get decreaseProgressTitle => 'Decrease Progress';

  @override
  String objectiveLabel(String title) {
    return 'Objective: $title';
  }

  @override
  String get currentProgressLabel => 'Current progress: ';

  @override
  String get newProgressLabel => 'New progress: ';

  @override
  String get planUpdatesLabel => 'Updates on the plan:';

  @override
  String get progressIncreaseHint =>
      'What did you do to progress? (e.g., studied for 2 hours, completed exercises...)';

  @override
  String get progressDecreaseHint =>
      'Why did the progress decrease? (e.g., delay, difficulty encountered...)';

  @override
  String get describeWhatHappened => 'Please describe what happened';

  @override
  String get increaseAction => 'Increase';

  @override
  String get decreaseAction => 'Decrease';

  @override
  String get emptyTimelineSubtitle =>
      'Start by creating your first objective to organize your study goals and track your progress.';

  @override
  String get biologicalSexLabel => 'Biological Sex';

  @override
  String get objectiveTitle => 'Objective';

  @override
  String get activityLevelLabel => 'Physical Activity Level';

  @override
  String get circumferencesLabel => 'Circumferences';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get ageLabel => 'Age';

  @override
  String get heightLabel => 'Height';

  @override
  String get currentWeightLabel => 'Current Weight';

  @override
  String get waistLabel => 'Waist';

  @override
  String get chestLabel => 'Chest';

  @override
  String get armLabel => 'Arm';

  @override
  String get hipLabel => 'Hip';

  @override
  String get thighLabel => 'Thigh';

  @override
  String get monthOverview => 'Month overview';

  @override
  String get balanceChart => 'Balance chart';

  @override
  String get incomesLabel => 'Incomes';

  @override
  String get expensesLabel => 'Expenses';

  @override
  String get reservesLabel => 'Reserves';

  @override
  String get totalReceived => 'Total received';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get noIncomesRegistered => 'No incomes registered';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String errorGeneratingFlag(String error) {
    return 'Error generating flag: $error';
  }

  @override
  String errorGeneratingShip(String error) {
    return 'Error generating ship: $error';
  }

  @override
  String crewDeletedMessage(String name) {
    return 'Crew \"$name\" deleted';
  }

  @override
  String get averageBountyLabel => 'Average Bounty';

  @override
  String get rolesLabel => 'Roles';

  @override
  String get updateBodyCompositionLabel => 'Update Body Composition';

  @override
  String linkLabel(String url) {
    return 'Link: $url';
  }

  @override
  String get saveLabel => 'Save';

  @override
  String get ageValidator => 'Please enter your age';

  @override
  String get heightValidator => 'Please enter your height';

  @override
  String get weightValidator => 'Please enter your weight';

  @override
  String get goalsAndMeasuresTitle => 'Goals & Measures';

  @override
  String get goalsAndMeasuresSubtitle =>
      'Define your objective and add measures to track your progress with Sanji & Zoro.';

  @override
  String get goalLoseWeight => 'Lose Weight';

  @override
  String get goalMaintain => 'Maintain Weight';

  @override
  String get goalGainMuscle => 'Gain Muscle';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activityLight => 'Light';

  @override
  String get activityModerate => 'Moderate';

  @override
  String get activityIntense => 'Intense';

  @override
  String get activityVeryIntense => 'Very Intense';

  @override
  String get expensesDetails => 'Expenses Details';

  @override
  String get totalExpensesLabel => 'Total Expenses:';

  @override
  String get copyAction => 'Copy';

  @override
  String get cookingTipsHint => 'Ex: chicken, rice, onion...';

  @override
  String get todayCompleted => 'Today (completed)';

  @override
  String get assessmentResultsTitle => 'Assessment Results';

  @override
  String get topRecommendationsTitle => 'Top Recommendations';

  @override
  String get weekProgressTitle => 'Week Progress';

  @override
  String get streakTitle => 'Streak';

  @override
  String get thisMonthSuffix => 'this month';

  @override
  String get daysSuffix => 'days';

  @override
  String get doneTodayLabel => 'Done today';

  @override
  String get pendingLabel => 'Pending';

  @override
  String get onlyCurrentMonthEditAllowed =>
      'Only possible to edit finances of the current month';

  @override
  String get saveWithNami => 'Save with Nami';

  @override
  String get configureYourFinances =>
      'Configure your finances of the month and track\nyour progress in real time.';

  @override
  String get incomeLabel => 'Income';

  @override
  String get noExpensesRegistered => 'No expenses registered';

  @override
  String get categoryFixed => 'Fixed';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get availableLabel => 'Available';

  @override
  String get savingsLabel => 'Savings';

  @override
  String get incomeDetailsTitle => 'Income Details';

  @override
  String get savingsDetailsTitle => 'Savings Details';

  @override
  String get monthSavings => 'Month Savings';

  @override
  String get financialMetricsTitle => 'Financial Metrics';

  @override
  String get dailyAvailableAmount => 'Daily Available Amount';

  @override
  String get janAbbr => 'Jan';

  @override
  String get febAbbr => 'Feb';

  @override
  String get marAbbr => 'Mar';

  @override
  String get aprAbbr => 'Apr';

  @override
  String get mayAbbr => 'May';

  @override
  String get junAbbr => 'Jun';

  @override
  String get julAbbr => 'Jul';

  @override
  String get augAbbr => 'Aug';

  @override
  String get sepAbbr => 'Sep';

  @override
  String get octAbbr => 'Oct';

  @override
  String get novAbbr => 'Nov';

  @override
  String get decAbbr => 'Dec';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get currentMonthLabel => 'Current Month';

  @override
  String get yesLabel => 'Yes';

  @override
  String get noLabel => 'No';

  @override
  String get workoutStatusDefeated => 'Defeated';

  @override
  String get workoutStatusOnTarget => 'On Target!';

  @override
  String get zoroQuoteDefeated => '\"I will never lose again.\"';

  @override
  String get zoroQuoteProud =>
      '\"No matter what happens, I will never lose again.\"';

  @override
  String get zoroStatusDefeated => 'Zoro is defeated...';

  @override
  String get zoroStatusProud => 'Zoro is proud!';

  @override
  String workoutsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts remaining this week',
      one: '1 workout remaining this week',
    );
    return '$_temp0';
  }

  @override
  String get weeklyGoalCompleted => 'Weekly goal completed! 🎯';

  @override
  String workoutDaysCount(int done, int total) {
    return '$done / $total days';
  }
}
