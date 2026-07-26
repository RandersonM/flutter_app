// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String affiliation(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Afiliações',
      one: 'Afiliação',
      zero: 'Afiliação',
    );
    return '$_temp0';
  }

  @override
  String get beastsPirates => 'Beasts Pirates';

  @override
  String get bigMomPirates => 'Big Mom Pirates';

  @override
  String get bounty => 'Recompensa';

  @override
  String get calculatorTitle => 'Calculadora';

  @override
  String get counterTitle => 'Contador';

  @override
  String get devilFruitUserPrefix => 'Usuário da';

  @override
  String get emperors => 'Four Emperors';

  @override
  String get haki => 'Haki';

  @override
  String get home => 'Início';

  @override
  String get howManyPushPhrase => 'Você apertou o botão esse numero de vezes';

  @override
  String get noResearchYet => 'Nenhuma pesquisa feita ainda.';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado para';

  @override
  String occupation(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ocupações',
      one: 'Ocupação',
      zero: 'Ocupação',
    );
    return '$_temp0';
  }

  @override
  String get onePiece => 'One Piece';

  @override
  String get financialSummary => 'Resumo Financeiro';

  @override
  String get totalIncome => 'Renda Total';

  @override
  String get expensesByCategory => 'Gastos por categoria';

  @override
  String get historyLast6Months => 'Histórico dos Últimos 6 Meses';

  @override
  String get noHistoryAvailable => 'Nenhum histórico disponível';

  @override
  String get loadingHistory => 'Carregando histórico...';

  @override
  String get namiApproves => 'Nami aprova!';

  @override
  String get namiNeedsReview => 'Nami precisa rever isso';

  @override
  String get result => 'Resultado';

  @override
  String get search => 'Procurar';

  @override
  String get superRookie => 'Super Rookie';

  @override
  String get strawHat => 'Piratas do Chapéu de Palha';

  @override
  String get featuredCharacter => 'Personagem em Destaque';

  @override
  String get randomCharacter => 'Personagem Aleatório';

  @override
  String get refresh => 'Atualizar';

  @override
  String get statistics => 'Detalhes';

  @override
  String get myCharacters => 'Meus Personagens';

  @override
  String get totalCharacters => 'Total de Personagens';

  @override
  String get highestBounty => 'Bounty Mais Alta';

  @override
  String get crews => 'Tripulações';

  @override
  String get searchingVideo => 'Buscando vídeo AMV...';

  @override
  String get loadingError => 'Erro ao carregar personagem';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get loading => 'Carregando...';

  @override
  String get imageUnavailable => 'Imagem\nIndisponível';

  @override
  String get selectCharacter => 'Selecionar Personagem';

  @override
  String get signo => 'Signo';

  @override
  String get status => 'Status';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get noImage => 'Sem Imagem';

  @override
  String get createCustomCharacterTitle => 'Criar Personagem';

  @override
  String get createCustomCharacterSubtitle =>
      'Preencha as informações abaixo para criar seu personagem único no mundo de One Piece!';

  @override
  String get basicInfo => 'Informações Básicas';

  @override
  String get name => 'Nome';

  @override
  String get nameRequired => 'Por favor, insira um nome';

  @override
  String get nameHint => 'Ex: Monkey D. Luffy';

  @override
  String get nickname => 'Alcunha';

  @override
  String get nicknameHint => 'Ex: Chapéu de Palha';

  @override
  String get age => 'Idade';

  @override
  String get birthDate => 'Data de Nascimento';

  @override
  String get birthDateHint => 'DD/MM/AAAA';

  @override
  String get powers => 'Poderes';

  @override
  String get devilFruitHint => 'Ex: Gomu Gomu no Mi';

  @override
  String get hakiTypes => 'Tipos de Haki';

  @override
  String get haoshokuHaki => 'Haoshoku Haki (Haki do Rei)';

  @override
  String get busoshokuHaki => 'Busoshoku Haki (Haki da Armadura)';

  @override
  String get kenbunshokuHaki => 'Kenbunshoku Haki (Haki da Observação)';

  @override
  String get background => 'Background';

  @override
  String get crewHint => 'Ex: Piratas do Chapéu de Palha';

  @override
  String get bountyRequired => 'Por favor, insira uma recompensa';

  @override
  String get bountyHint => 'Ex: 3,000,000,000 Berries';

  @override
  String get imageUrl => 'URL da Imagem';

  @override
  String get imageUrlHint => 'Ex: https://example.com/image.jpg';

  @override
  String get captured => 'Capturado';

  @override
  String get alive => 'Vivo';

  @override
  String get dead => 'Morto';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get affiliations => 'Afiliações';

  @override
  String get marines => 'Marinha';

  @override
  String get revolutionaries => 'Revolucionários';

  @override
  String get yonkou => 'Yonkou';

  @override
  String get shichibukai => 'Shichibukai';

  @override
  String get independent => 'Independente';

  @override
  String get pirate => 'Pirata';

  @override
  String get pirateAlliance => 'Aliança Pirata';

  @override
  String get occupations => 'Ocupações';

  @override
  String get captain => 'Capitão';

  @override
  String get viceCaptain => 'Vice-Capitão';

  @override
  String get admiral => 'Almirante';

  @override
  String get viceAdmiral => 'Vice-Almirante';

  @override
  String get revolutionary => 'Revolucionário';

  @override
  String get merchant => 'Mercador';

  @override
  String get doctor => 'Médico';

  @override
  String get navigator => 'Navegador';

  @override
  String get cook => 'Cozinheiro';

  @override
  String get sniper => 'Arqueiro';

  @override
  String get swordsman => 'Espadachim';

  @override
  String get carpenter => 'Carpinteiro';

  @override
  String get archaeologist => 'Arqueólogo';

  @override
  String get sharpshooter => 'Atirador';

  @override
  String get description => 'Descrição';

  @override
  String get characterStory => 'História do Personagem';

  @override
  String get characterStoryHint =>
      'Conte a história do seu personagem customizado...';

  @override
  String get createCharacter => 'Criar Personagem';

  @override
  String get cancel => 'Cancelar';

  @override
  String get success => 'Sucesso!';

  @override
  String get characterCreatedSuccess =>
      'Personagem customizado criado com sucesso!';

  @override
  String get error => 'Erro';

  @override
  String characterCreationError(String message) {
    return 'Erro ao criar personagem: $message';
  }

  @override
  String get ok => 'OK';

  @override
  String get devilFruit => 'Fruta do Diabo';

  @override
  String get noDevilFruit => 'Sem Akuma no Mi';

  @override
  String crew(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tripulações',
      one: 'Tripulação',
      zero: 'Tripulação',
    );
    return '$_temp0';
  }

  @override
  String get ariesSign => 'Áries';

  @override
  String get taurusSign => 'Touro';

  @override
  String get geminiSign => 'Gêmeos';

  @override
  String get cancerSign => 'Câncer';

  @override
  String get leoSign => 'Leão';

  @override
  String get virgoSign => 'Virgem';

  @override
  String get libraSign => 'Libra';

  @override
  String get scorpioSign => 'Escorpião';

  @override
  String get sagittariusSign => 'Sagitário';

  @override
  String get capricornSign => 'Capricórnio';

  @override
  String get aquariusSign => 'Aquário';

  @override
  String get piscesSign => 'Peixes';

  @override
  String get welcome => 'Bem-vindo,';

  @override
  String get welcomeToOpfan => 'Bem-vindo ao OpFan';

  @override
  String get signInWithGoogle => 'Entrar com Google';

  @override
  String get signingIn => 'Entrando...';

  @override
  String get authenticationError => 'Erro na Autenticação';

  @override
  String get tryAgainButton => 'Tentar Novamente';

  @override
  String get clearDataAndContinue => 'Limpar dados e continuar';

  @override
  String get searchPlaceholder => 'Pesquisar por nome romano ou japonês...';

  @override
  String get filterByType => 'Filtrar por tipo';

  @override
  String get clear => 'Limpar';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get noFruitFound => 'Nenhuma fruta encontrada';

  @override
  String get noDevilFruitAvailable => 'Nenhuma Akuma no Mi disponível';

  @override
  String get adjustFiltersOrSearch =>
      'Tente ajustar os filtros ou buscar por outros termos';

  @override
  String get errorLoadingContent => 'Erro ao carregar conteúdo';

  @override
  String get searching => 'Pesquisando...';

  @override
  String get skipForNow => 'Pular por agora';

  @override
  String get loginBannerTitle => 'Faça login para acessar recursos exclusivos';

  @override
  String get loginBannerSubtitle =>
      'Crie personagens, participe de duelos e muito mais';

  @override
  String get loginWelcomeSubtitle =>
      'Explore o mundo de One Piece e descubra seus personagens favoritos';

  @override
  String get version => 'versão ';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configurações';

  @override
  String get logout => 'Sair';

  @override
  String get close => 'Fechar';

  @override
  String get type => 'Tipo';

  @override
  String get createCustomCharacter => 'Criar personagem';

  @override
  String get createCrew => 'Criar Tripulação';

  @override
  String get boat => ' Barco';

  @override
  String get crewBoatName => 'Nome do Barco';

  @override
  String get crewRole => 'Cargo na Tripulação';

  @override
  String get crewRoleHint => 'Selecione seu cargo na tripulação';

  @override
  String get helmsman => 'Timoneiro';

  @override
  String get musician => 'Músico';

  @override
  String get boatswain => 'Contramestre';

  @override
  String viewingCharacter(String characterName) {
    return 'Visualizando $characterName';
  }

  @override
  String editingCharacter(String characterName) {
    return 'Editando $characterName';
  }

  @override
  String get editCustomCharacterTitle => 'Editar Personagem Customizado';

  @override
  String get editCustomCharacterSubtitle =>
      'Modifique as informações do seu personagem';

  @override
  String get update => 'Atualizar';

  @override
  String get characterUpdatedSuccess => 'Personagem atualizado com sucesso';

  @override
  String characterUpdateError(String message) {
    return 'Erro ao atualizar personagem: $message';
  }

  @override
  String get berriesTotal => 'Berries total';

  @override
  String members(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Membros',
      one: 'Membro',
      zero: 'Membro',
    );
    return '$_temp0';
  }

  @override
  String get searchCrews => 'Buscar tripulações...';

  @override
  String get filter => 'Filtrar';

  @override
  String get myCrews => 'Minhas Tripulações';

  @override
  String get allCrews => 'Todas as Tripulações';

  @override
  String get errorLoadingCrews => 'Erro ao carregar tripulações';

  @override
  String get noCrewsFound => 'Nenhuma tripulação encontrada';

  @override
  String get createFirstCrew => 'Crie sua primeira tripulação!';

  @override
  String get confirmDelete => 'Confirmar exclusão';

  @override
  String confirmDeleteCrew(String crewName) {
    return 'Tem certeza que deseja excluir a tripulação \"$crewName\"?';
  }

  @override
  String viewingCrew(String crewName) {
    return 'Visualizando tripulação: $crewName';
  }

  @override
  String editingCrew(String crewName) {
    return 'Editando tripulação: $crewName';
  }

  @override
  String get aiImageGeneration => 'Geração de Imagem por IA';

  @override
  String get aiImageGenerationSubtitle =>
      'Gere uma imagem única para seu personagem usando IA';

  @override
  String get imagePrompt => 'Prompt da Imagem';

  @override
  String get imagePromptHint => 'Descreva como seu personagem deve parecer...';

  @override
  String get generateImage => 'Gerar Imagem';

  @override
  String get generatingImage => 'Gerando...';

  @override
  String get imageLoadError => 'Falha ao carregar imagem';

  @override
  String get editCrewTitle => 'Editar Tripulação';

  @override
  String get editCrewSubtitle => 'Modifique as informações da sua tripulação';

  @override
  String get crewUpdatedSuccess => 'Tripulação atualizada com sucesso';

  @override
  String get crewUpdateError => 'Erro ao atualizar tripulação';

  @override
  String get regenerateImage => 'Regenerar';

  @override
  String get useImage => 'Usar Imagem';

  @override
  String get imageConfirmed => 'Imagem Confirmada';

  @override
  String get promptRequired => 'Por favor, insira um prompt';

  @override
  String get imageGenerationError => 'Falha ao gerar imagem. Tente novamente.';

  @override
  String get selectDevilFruit => 'Selecionar Akuma no Mi';

  @override
  String get selectDevilFruitPlaceholder => 'Selecione uma Akuma no Mi';

  @override
  String get searchDevilFruit => 'Buscar Akuma no Mi...';

  @override
  String get noDevilFruitFound => 'Nenhuma Akuma no Mi encontrada';

  @override
  String get filterBy => 'Filtrar por';

  @override
  String get crewTeam => 'Equipe';

  @override
  String get filterByDevilFruit => 'Filtrar por Fruta do Diabo';

  @override
  String get filterByCrew => 'Filtrar por Equipe';

  @override
  String get addTag => 'Adicionar Tag';

  @override
  String get addMember => 'Adicionar Membro';

  @override
  String get noCharactersAvailable =>
      'Nenhum personagem disponível para adicionar';

  @override
  String get tagName => 'Nome da tag';

  @override
  String get tagNameHint => 'Ex: Piratas, Aventureiros, etc.';

  @override
  String get crewName => 'Nome da Tripulação *';

  @override
  String get crewNameHint => 'Ex: Mugiwaras Custom';

  @override
  String get descriptionHint => 'Conte um pouco sobre sua tripulação...';

  @override
  String get pirateFlagUrl => 'URL da Bandeira Pirata';

  @override
  String get pirateFlagUrlHint => 'https://exemplo.com/bandeira.jpg';

  @override
  String get shipImageUrl => 'URL da Imagem do Barco';

  @override
  String get shipImageUrlHint => 'https://exemplo.com/barco.jpg';

  @override
  String get devilFruitName => 'Nome da fruta';

  @override
  String get devilFruitNameHint => 'Ex: Gomu Gomu no Mi';

  @override
  String get crewNameFilter => 'Nome da equipe';

  @override
  String get crewNameFilterHint => 'Ex: Piratas do Chapéu de Palha';

  @override
  String get dateFormat => 'DD/MM/AAAA';

  @override
  String get numberFormat => '0';

  @override
  String get editProfileTapped => 'Perfil editado tocado';

  @override
  String get notificationsTapped => 'Notificações tocadas';

  @override
  String get languageTapped => 'Idioma tocado';

  @override
  String get themeTapped => 'Tema tocado';

  @override
  String get helpSupportTapped => 'Ajuda e Suporte tocado';

  @override
  String get aboutTapped => 'Sobre tocado';

  @override
  String get characterDeleted => 'Personagem excluído com sucesso';

  @override
  String get crewCreated => 'Tripulação criada com sucesso';

  @override
  String get crewCreationError => 'Erro ao criar tripulação';

  @override
  String get crewDeleted => 'Tripulação excluída com sucesso';

  @override
  String get crewDeletionError => 'Erro ao excluir tripulação';

  @override
  String get memberAdded => 'Membro adicionado com sucesso';

  @override
  String get memberAdditionError => 'Erro ao adicionar membro';

  @override
  String get memberRemoved => 'Membro removido com sucesso';

  @override
  String get memberRemovalError => 'Erro ao remover membro';

  @override
  String get crewUpdated => 'Tripulação atualizada com sucesso';

  @override
  String get loginError => 'Erro de login';

  @override
  String get videoLoadError => 'Erro ao carregar vídeo';

  @override
  String get videoLoadSuccess => 'Vídeo carregado com sucesso';

  @override
  String devilFruitSearchError(String error) {
    return 'Erro ao buscar Akuma no Mi: $error';
  }

  @override
  String get noCustomCharactersFound =>
      'Nenhum personagem customizado encontrado';

  @override
  String get createFirstCustomCharacter =>
      'Crie seu primeiro personagem customizado!';

  @override
  String get onePieceCharacters => 'Personagens One Piece';

  @override
  String get customCharacters => 'Personagens Customizados';

  @override
  String get noOnePieceCharacters => 'Nenhum personagem One Piece disponível';

  @override
  String get noCustomCharacters => 'Nenhum personagem customizado disponível';

  @override
  String get dualWielder => 'Dual Wielder';

  @override
  String get fighter => 'Lutador';

  @override
  String get taekwondo => 'Taekwondo';

  @override
  String get kicker => 'Chute';

  @override
  String get archer => 'Arco';

  @override
  String get staff => 'Bastão';

  @override
  String get other => 'Outro';

  @override
  String get race => 'Raça';

  @override
  String get human => 'Humano';

  @override
  String get giant => 'Gigante';

  @override
  String get fishman => 'Homem-Peixe';

  @override
  String get mermaid => 'Sereia';

  @override
  String get mink => 'Mink';

  @override
  String get lunarian => 'Lunariano';

  @override
  String get buccaneer => 'Bucaneiro';

  @override
  String get oni => 'Oni';

  @override
  String get skypiean => 'Skypieano';

  @override
  String get longarm => 'Braços Longo';

  @override
  String get tonatta => 'Tonatta';

  @override
  String get add => 'Adicionar';

  @override
  String get noPermissionToEdit =>
      'Você não tem permissão para editar esta tripulação';

  @override
  String get noPermissionToDelete =>
      'Você não tem permissão para excluir esta tripulação';

  @override
  String get allRolesFilled => 'Todas as roles já estão preenchidas';

  @override
  String get characterNotFound => 'Personagem não encontrado';

  @override
  String get characterLoadError => 'Erro ao carregar personagem';

  @override
  String memberAddedAsRole(String characterName, String role) {
    return '$characterName adicionado como $role';
  }

  @override
  String crewDeletedWithName(String crewName) {
    return 'Tripulação \"$crewName\" excluída';
  }

  @override
  String get generatePirateFlagPrompt =>
      'Digite um prompt para gerar a bandeira pirata';

  @override
  String get pirateFlagGeneratedSuccess =>
      'Bandeira pirata gerada com sucesso!';

  @override
  String pirateFlagGenerationError(String error) {
    return 'Erro ao gerar bandeira: $error';
  }

  @override
  String get generateBoatPrompt => 'Digite um prompt para gerar o barco';

  @override
  String get boatGeneratedSuccess => 'Barco gerado com sucesso!';

  @override
  String boatGenerationError(String error) {
    return 'Erro ao gerar barco: $error';
  }

  @override
  String get profilePhotoTapped => 'Foto do perfil tocada';

  @override
  String get zodiacCapricorn => 'Capricórnio';

  @override
  String get duels => 'Duelos';

  @override
  String get duelsSubtitle => 'Personagem vs Personagem';

  @override
  String get versus => 'VS';

  @override
  String get winner => 'Venceu!';

  @override
  String get startDuel => 'Iniciar Duelo';

  @override
  String get duelInProgress => 'Batalha em Progresso...';

  @override
  String get characterStats => 'Stats dos Personagens';

  @override
  String get selectFirstFighter => 'Selecione o Primeiro Lutador';

  @override
  String get selectSecondFighter => 'Selecione o Segundo Lutador';

  @override
  String get selectACharacter => 'Selecione um Personagem';

  @override
  String get randomizeCharacters => 'Aleatorizar';

  @override
  String get resetDuel => 'Resetar';

  @override
  String hakiType(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tipos',
      one: 'tipo',
      zero: 'tipos',
    );
    return '$_temp0';
  }

  @override
  String get newDuel => 'Novo Duelo';

  @override
  String get accountSettings => 'Configurações da Conta';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get editProfileSubtitle => 'Atualize suas informações pessoais';

  @override
  String get notifications => 'Notificações';

  @override
  String get notificationsSubtitle =>
      'Gerencie suas preferências de notificação';

  @override
  String get appSettings => 'Configurações do App';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Alterar idioma do app';

  @override
  String get theme => 'Tema';

  @override
  String get darkTheme => 'Tema escuro';

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get darkThemeActivated => 'Tema escuro ativado';

  @override
  String get lightThemeActivated => 'Tema claro ativado';

  @override
  String get support => 'Suporte';

  @override
  String get helpSupport => 'Ajuda e Suporte';

  @override
  String get helpSupportSubtitle =>
      'Obtenha ajuda e entre em contato com o suporte';

  @override
  String get about => 'Sobre';

  @override
  String get aboutSubtitle => 'Versão do app e informações';

  @override
  String get nameMinLength => 'Nome deve ter pelo menos 3 caracteres';

  @override
  String get tags => 'Tags';

  @override
  String get noTagsAdded => 'Nenhuma tag adicionada';

  @override
  String get pirateFlagSectionTitle => 'Bandeira Pirata (Jolly Roger)';

  @override
  String get pirateFlagTitle => 'Bandeira da Tripulação';

  @override
  String get aiPromptLabel => 'Prompt para IA';

  @override
  String get pirateFlagPromptHint =>
      'Ex: bandeira pirata com caveira e espadas cruzadas';

  @override
  String get generateFlag => 'Gerar Bandeira';

  @override
  String get crewBoatSectionTitle => 'Barco da Tripulação';

  @override
  String get boatNameHint => 'Ex: Going Merry';

  @override
  String get generateBoat => 'Gerar Barco';

  @override
  String get boatTitle => 'Barco da Tripulação';

  @override
  String get aiPromptInfo =>
      'Use prompts descritivos para gerar imagens únicas da sua tripulação. As imagens geradas serão salvas automaticamente.';

  @override
  String get fightingStyleSectionTitle => 'Estilo de Luta';

  @override
  String get fightingStyleNameLabel => 'Nome do Estilo';

  @override
  String get fightingStyleTypeLabel => 'Tipo de Luta';

  @override
  String get fightingStyleWeaponsLabel => 'Armas';

  @override
  String get fightingStyleAttacksLabel => 'Ataques';

  @override
  String get finances => 'Finanças';

  @override
  String get monthlyIncome => 'Renda Mensal';

  @override
  String get monthlyIncomeHint => 'Digite sua renda mensal';

  @override
  String get expenses => 'Gastos';

  @override
  String get fixedExpenses => 'Gastos Fixos (Aluguel, Contas)';

  @override
  String get foodExpenses => 'Alimentação';

  @override
  String get transportExpenses => 'Transporte';

  @override
  String get entertainmentExpenses => 'Entretenimento';

  @override
  String get otherExpenses => 'Outros Gastos';

  @override
  String get results => 'Resultados';

  @override
  String get totalExpenses => 'Total de Gastos';

  @override
  String get availableAmount => 'Valor Disponível';

  @override
  String get dailyAmount => 'Valor Diário Disponível';

  @override
  String get currency => 'R\$';

  @override
  String get perDay => '/dia';

  @override
  String get health => 'Saúde';

  @override
  String get selectExpenseCategory => 'Selecione a categoria do gasto:';

  @override
  String get category => 'Categoria';

  @override
  String get remove => 'Remover';

  @override
  String get save => 'Salvar';

  @override
  String get value => 'Valor';

  @override
  String get addIncome => 'Adicionar Renda';

  @override
  String get addExpense => 'Adicionar Gasto';

  @override
  String get savings => 'Cofrinho';

  @override
  String get monthlySavings => 'Poupança Mensal';

  @override
  String get savingsHint => 'Quanto você guarda por mês?';

  @override
  String get savingsPercentage => 'Percentual de Economia';

  @override
  String get yearlySavings => 'Economias Anuais';

  @override
  String get accumulatedSavings => 'Acumulado';

  @override
  String get savingsPeriod => 'Período de Economia';

  @override
  String get workout => 'Treinos';

  @override
  String get workout_title_screen => 'Treinando com o Zoro';

  @override
  String get workout_health_assessment => 'Avaliação de Saúde Completa';

  @override
  String get workout_health_assessment_subtitle =>
      'Combina IMC, relação cintura/altura e percentual de gordura para uma avaliação mais precisa da saúde';

  @override
  String get workout_results => 'Resultados da Avaliação';

  @override
  String get workout_recommendations => 'Recomendações Personalizadas';

  @override
  String get workout_calculate_metrics => 'Calcular Métricas de Saúde';

  @override
  String get workout_new_assessment => 'Nova Avaliação';

  @override
  String get workout_gender => 'Sexo';

  @override
  String get workout_age => 'Idade';

  @override
  String get workout_height => 'Altura (cm)';

  @override
  String get workout_weight => 'Peso (kg)';

  @override
  String get workout_waist => 'Circunferência da Cintura (cm)';

  @override
  String get workout_health_score => 'Pontuação de Saúde';

  @override
  String get workout_bmi => 'IMC';

  @override
  String get workout_waist_to_height => 'Relação Cintura/Altura';

  @override
  String get workout_body_fat => 'Percentual de Gordura';

  @override
  String get workout_formula_bmi => 'Peso (kg) / Altura (m)²';

  @override
  String get workout_formula_waist_to_height => 'Cintura (cm) / Altura (cm)';

  @override
  String get workout_formula_body_fat =>
      'Fórmula baseada em IMC, idade e gênero';

  @override
  String get workout_validation_gender_required => 'Selecione o sexo';

  @override
  String get workout_validation_age_required => 'Digite sua idade';

  @override
  String get workout_validation_age_invalid => 'Digite um número válido';

  @override
  String get workout_validation_height_required => 'Digite sua altura';

  @override
  String get workout_validation_height_invalid => 'Digite um número válido';

  @override
  String get workout_validation_weight_required => 'Digite seu peso';

  @override
  String get workout_validation_weight_invalid => 'Digite um número válido';

  @override
  String get workout_validation_waist_required => 'Digite a medida da cintura';

  @override
  String get workout_validation_waist_invalid => 'Digite um número válido';

  @override
  String get workout_gender_male => 'Masculino';

  @override
  String get workout_gender_female => 'Feminino';

  @override
  String get workout_category_excellent => 'Excelente';

  @override
  String get workout_category_good => 'Bom';

  @override
  String get workout_category_regular => 'Regular';

  @override
  String get workout_category_needs_improvement => 'Precisa melhorar';

  @override
  String get workout_category_underweight => 'Abaixo do peso';

  @override
  String get workout_category_normal => 'Peso normal';

  @override
  String get workout_category_overweight => 'Sobrepeso';

  @override
  String get workout_category_obesity_1 => 'Obesidade grau 1';

  @override
  String get workout_category_obesity_2 => 'Obesidade grau 2';

  @override
  String get workout_category_obesity_3 => 'Obesidade grau 3';

  @override
  String get workout_category_attention => 'Atenção';

  @override
  String get workout_category_high_risk => 'Risco elevado';

  @override
  String get workout_category_very_low => 'Muito baixo';

  @override
  String get workout_category_athletic => 'Atlético';

  @override
  String get workout_category_acceptable => 'Aceitável';

  @override
  String get workout_category_high => 'Alto';

  @override
  String get workout_exercise_advanced_strength =>
      'Treino de força avançado 4x por semana';

  @override
  String get workout_exercise_hiit => 'Cardio de alta intensidade (HIIT)';

  @override
  String get workout_exercise_competitive_sports => 'Esportes competitivos';

  @override
  String get workout_exercise_complex_functional => 'Treino funcional complexo';

  @override
  String get workout_exercise_flexibility => 'Flexibilidade e mobilidade';

  @override
  String get workout_exercise_strength_training =>
      'Treino de força 3x por semana';

  @override
  String get workout_exercise_moderate_cardio => 'Cardio moderado 30-45 min';

  @override
  String get workout_exercise_functional => 'Treino funcional';

  @override
  String get workout_exercise_yoga_pilates => 'Yoga ou pilates';

  @override
  String get workout_exercise_recreational_sports => 'Esportes recreativos';

  @override
  String get workout_exercise_walking => 'Caminhada 30-45 minutos';

  @override
  String get workout_exercise_basic_strength =>
      'Treino de força básico 2x por semana';

  @override
  String get workout_exercise_water_aerobics => 'Hidroginástica';

  @override
  String get workout_exercise_stretching => 'Alongamentos diários';

  @override
  String get workout_exercise_breathing => 'Exercícios de respiração';

  @override
  String get workout_exercise_light_walking => 'Caminhada leve 20-30 minutos';

  @override
  String get workout_exercise_light_stretching => 'Exercícios de alongamento';

  @override
  String get workout_exercise_soft_water_aerobics => 'Hidroginástica suave';

  @override
  String get workout_exercise_tai_chi_yoga => 'Tai Chi ou Yoga suave';

  @override
  String get workout_exercise_consult_professional =>
      'Consultar profissional de saúde';

  @override
  String get workout_exercise_cardiovascular_focus =>
      'Foco em exercícios cardiovasculares';

  @override
  String get workout_exercise_core_training => 'Treino de core específico';

  @override
  String get workout_exercise_diet_control => 'Controle da alimentação';

  @override
  String get workout_exercise_low_impact => 'Atividades de baixo impacto';

  @override
  String get workout_exercise_professional_supervision =>
      'Supervisão profissional';

  @override
  String get workout_exercise_gradual_progression => 'Progressão gradual';

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
      other: 'es',
      one: '',
    );
    return '$years ano$_temp0 e $months mês$_temp1';
  }

  @override
  String savings_period_years_only(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$years ano$_temp0';
  }

  @override
  String savings_period_months_only(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'es',
      one: '',
    );
    return '$months mês$_temp0';
  }

  @override
  String get savings_period_one_month => '1 mês';

  @override
  String savings_formatted_total(String amount, String period) {
    return 'R\$ $amount em $period';
  }

  @override
  String get workout_calendar_title => 'Calendário de Exercícios';

  @override
  String get workout_calendar_sunday => 'Dom';

  @override
  String get workout_calendar_monday => 'Seg';

  @override
  String get workout_calendar_tuesday => 'Ter';

  @override
  String get workout_calendar_wednesday => 'Qua';

  @override
  String get workout_calendar_thursday => 'Qui';

  @override
  String get workout_calendar_friday => 'Sex';

  @override
  String get workout_calendar_saturday => 'Sáb';

  @override
  String get workout_workout_days_goal =>
      'Meta de dias de exercício por semana';

  @override
  String get workout_validation_workout_days_required =>
      'Selecione sua meta de dias de exercício';

  @override
  String get workout_day => 'dia';

  @override
  String get workout_days => 'dias';

  @override
  String get cooking => 'Culinária';

  @override
  String get plateGuideTitle => 'Guia do Prato Saudável';

  @override
  String get plateGuideHeader =>
      'Baseado nas recomendações do Ministério da Saúde Brasileiro, este guia mostra como montar um prato equilibrado com as proporções ideais de cada grupo alimentar.';

  @override
  String get plateDivision => 'Divisão do Prato';

  @override
  String get vegetablesTitle => 'Hortaliças e Legumes';

  @override
  String get vegetablesSubtitle => '50% do prato';

  @override
  String get vegetablesDescription =>
      'Alimentos reguladores ricos em vitaminas, minerais e fibras';

  @override
  String get vegetablesExamples =>
      'Alface, agrião, rúcula, espinafre, brócolis, couve-flor, cenoura, abobrinha';

  @override
  String get proteinsTitle => 'Proteínas';

  @override
  String get proteinsSubtitle => '25% do prato';

  @override
  String get proteinsDescription =>
      'Alimentos construtores essenciais para músculos e tecidos';

  @override
  String get proteinsExamples =>
      'Frango, peixe, carne, ovos, feijão, lentilha, grão-de-bico';

  @override
  String get carbohydratesTitle => 'Carboidratos';

  @override
  String get carbohydratesSubtitle => '25% do prato';

  @override
  String get carbohydratesDescription =>
      'Alimentos energéticos que fornecem energia para o corpo';

  @override
  String get carbohydratesExamples =>
      'Arroz, batata, macarrão, pão, batata-doce, mandioca';

  @override
  String get sanjiTipsTitle => 'Dicas do Sanji';

  @override
  String get sanjiTip1 =>
      'Prefira alimentos in natura ou minimamente processados';

  @override
  String get sanjiTip2 => 'Utilize sal, óleos e açúcares com moderação';

  @override
  String get sanjiTip3 => 'Varie as cores e tipos de hortaliças e legumes';

  @override
  String get sanjiTip4 =>
      'Opte por preparações mais saudáveis (vapor, refogados, assados)';

  @override
  String get sanjiTip5 => 'Aproveite frutas como sobremesa e lanches';

  @override
  String get sanjiReference =>
      'Consulte o Guia Alimentar para a População Brasileira do Ministério da Saúde para mais informações detalhadas.';

  @override
  String examples(String foodList) {
    return 'Exemplos: $foodList';
  }

  @override
  String get nutritionResultsTitle => 'Resultados Nutricionais';

  @override
  String get bmrTitle => 'BMR (Taxa Metabólica Basal)';

  @override
  String get bmrSubtitle => 'Calorias que seu corpo queima em repouso';

  @override
  String get tdeeTitle => 'TDEE (Gasto Energético Total)';

  @override
  String get tdeeSubtitle => 'Calorias totais que você gasta por dia';

  @override
  String get caloriesPerGoal => 'Calorias por Objetivo';

  @override
  String get maintainWeight => 'Manter Peso';

  @override
  String get loseWeight => 'Emagrecer';

  @override
  String get gainMuscle => 'Ganhar Massa';

  @override
  String get weightLoss => 'Emagrecer';

  @override
  String get maintenance => 'Manter Peso';

  @override
  String get muscleGain => 'Ganhar Massa';

  @override
  String get classifications => 'Classificações';

  @override
  String get bmi => 'IMC';

  @override
  String get waistToHeight => 'Cintura/Altura';

  @override
  String get sanjiTipTitle => 'Receita Personalizadas';

  @override
  String get sanjiTipText =>
      'Clique para receber uma receita personalizada baseada nos seus dados nutricionais!';

  @override
  String get plateGuideQuestion => 'Como montar um prato saudável?';

  @override
  String get plateGuideSubtitle =>
      'Aprenda as recomendações do Ministério da Saúde para montar um prato equilibrado';

  @override
  String get viewPlateGuide => 'Ver Guia do Prato';

  @override
  String kcalPerDay(String calories) {
    return '$calories kcal/dia';
  }

  @override
  String get financeWithNami => 'Economize com a Nami';

  @override
  String get cookingWithSanji => 'Cozinhe com o Sanji';

  @override
  String get newCalculation => 'Novo Cálculo';

  @override
  String get calculatingNutrition => 'Calculando nutrição...';

  @override
  String get sanjiQuote1 =>
      '\"Um verdadeiro chef não apenas cozinha, mas nutre a alma!\" - Sanji';

  @override
  String get sanjiQuote2 =>
      '\"A comida é o combustível que move o corpo e o espírito!\" - Sanji';

  @override
  String get sanjiQuote3 =>
      '\"Uma dieta balanceada é fundamental para manter a energia e saúde!\" - Sanji';

  @override
  String get sanjiQuote4 =>
      '\"Aqui você encontrará receitas que combinam nutrição e sabor!\" - Sanji';

  @override
  String get sanjiQuote5 =>
      '\"Inspirado na filosofia culinária do melhor chef dos mares!\" - Sanji';

  @override
  String get personalData => 'Dados Pessoais';

  @override
  String get gender => 'Gênero';

  @override
  String get selectGender => 'Selecione o gênero';

  @override
  String get enterAge => 'Digite sua idade';

  @override
  String get enterValidNumber => 'Digite um número válido';

  @override
  String get weight => 'Peso (kg)';

  @override
  String get enterWeight => 'Digite seu peso';

  @override
  String get height => 'Altura (cm)';

  @override
  String get enterHeight => 'Digite sua altura';

  @override
  String get waistCircumference => 'Circunferência da Cintura (cm)';

  @override
  String get enterWaist => 'Digite a medida da cintura';

  @override
  String get activityLevel => 'Nível de Atividade';

  @override
  String get selectActivityLevel => 'Selecione seu nível de atividade';

  @override
  String get selectActivityLevelValidation => 'Selecione o nível de atividade';

  @override
  String get goal => 'Objetivo';

  @override
  String get selectGoal => 'Selecione seu objetivo';

  @override
  String get selectGoalValidation => 'Selecione seu objetivo';

  @override
  String get calculateNutrition => 'Calcular Nutrição';

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String get sedentary => 'Sedentário';

  @override
  String get light => 'Leve';

  @override
  String get moderate => 'Moderado';

  @override
  String get active => 'Ativo';

  @override
  String get veryActive => 'Muito Ativo';

  @override
  String get underweight => 'Abaixo do Peso';

  @override
  String get normalWeight => 'Peso Normal';

  @override
  String get overweight => 'Sobrepeso';

  @override
  String get obesityGrade1 => 'Obesidade Grau 1';

  @override
  String get obesityGrade2 => 'Obesidade Grau 2';

  @override
  String get obesityGrade3 => 'Obesidade Grau 3';

  @override
  String get excellent => 'Excelente';

  @override
  String get good => 'Bom';

  @override
  String get attention => 'Atenção';

  @override
  String get highRisk => 'Risco Elevado';

  @override
  String get planner => 'Planos';

  @override
  String get knowledgeTitleScreen => 'Planeje com a Robin';

  @override
  String get timelineOfObjectives => 'Timeline de Objetivos';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get noObjectivesCreated => 'Nenhum objetivo criado';

  @override
  String get startCreatingFirstObjective =>
      'Comece criando seu primeiro objetivo';

  @override
  String get recentObjectives => 'Objetivos Recentes';

  @override
  String get total => 'total';

  @override
  String get errorLoadingObjectives => 'Erro ao carregar objetivos';

  @override
  String get organizeStudyGoals => 'Organize suas metas de estudo';

  @override
  String get progress => 'Progresso';

  @override
  String get details => 'Detalhes';

  @override
  String get creationDate => 'Data de Criação';

  @override
  String get deadline => 'Prazo';

  @override
  String get notes => 'Anotações';

  @override
  String get completed => 'Concluídos';

  @override
  String get inProgress => 'Em Progresso';

  @override
  String get overdue => 'Atrasado';

  @override
  String get notStarted => 'Não Iniciado';

  @override
  String get study => 'Estudo';

  @override
  String get work => 'Trabalho';

  @override
  String get personal => 'Pessoal';

  @override
  String get finance => 'Finanças';

  @override
  String get dueToday => 'Vence hoje';

  @override
  String dueInDays(int days) {
    return 'Vence em $days dias';
  }

  @override
  String overdueDays(int days) {
    return 'Atrasado há $days dias';
  }

  @override
  String dueDaysAgo(int days) {
    return 'Venceu há $days dias';
  }

  @override
  String get deleteObjective => 'Excluir Objetivo';

  @override
  String deleteObjectiveConfirmation(String title) {
    return 'Tem certeza que deseja excluir \"$title\"?';
  }

  @override
  String get all => 'Todos';

  @override
  String get newGoal => 'Nova Meta';

  @override
  String get title => 'Título';

  @override
  String get titleRequired => 'O título é obrigatório';

  @override
  String get enterGoalTitle => 'Digite o título do objetivo';

  @override
  String get enterGoalDescription => 'Digite uma descrição para o objetivo';

  @override
  String initialProgress(int progress) {
    return 'Progresso Inicial: $progress%';
  }

  @override
  String get enterTagsCommaSeparated => 'Digite as tags separadas por vírgula';

  @override
  String get enterAdditionalNotes => 'Digite anotações adicionais';

  @override
  String get onboardingBiologicalSex =>
      'Por favor, selecione seu sexo biológico.';

  @override
  String get onboardingFillAllFields =>
      'Por favor, preencha todos os campos obrigatórios.';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Feminino';

  @override
  String get recommendations => 'Recomendações';

  @override
  String get editPlan => 'Editar Plano';

  @override
  String get workoutPlanSaved => 'Plano de treino salvo com sucesso!';

  @override
  String get addSplit => 'Adicionar Split';

  @override
  String get splitNameHint => 'Nome do split (ex: Treino A)';

  @override
  String get exerciseHint => 'Exercício';

  @override
  String get setsRepsHint => '3x15';

  @override
  String get noAssessmentFound =>
      'Nenhuma avaliação encontrada para o mês atual';

  @override
  String get addAction => 'Adicionar';

  @override
  String get selectRace => 'Selecione a Raça';

  @override
  String get styleName => 'Nome do Estilo';

  @override
  String get fightingType => 'Tipo de Luta';

  @override
  String get addWeapon => 'Adicionar Arma';

  @override
  String get addAttack => 'Adicionar Ataque';

  @override
  String get threeSwordsStyleHint => 'Ex: Estilo das Três Espadas';

  @override
  String get englishLang => 'English';

  @override
  String get portugueseLang => 'Português';

  @override
  String get bodyComposition => 'Composição Corporal';

  @override
  String get bodyData => 'Dados Corporais';

  @override
  String get createFirstGoal => 'Criar Primeiro Objetivo';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get saveAction => 'Salvar';

  @override
  String get clearAction => 'Limpar';

  @override
  String get updateBodyComposition => 'Atualizar Composição Corporal';

  @override
  String get tryAgainAction => 'Tentar novamente';

  @override
  String get foodExampleHint => 'Ex: frango, arroz, cebola...';

  @override
  String get mealType => 'Tipo de Refeição';

  @override
  String get dietaryRestrictions => 'Restrições Alimentares';

  @override
  String get noIncomeRegistered => 'Nenhuma receita registrada';

  @override
  String get setupFinances => 'Configurar finanças';

  @override
  String get viewDetails => 'Ver Detalhes';

  @override
  String get editData => 'Editar dados';

  @override
  String get monthBalance => 'Balanço do Mês';

  @override
  String get incomes => 'Receitas';

  @override
  String get reserves => 'Reserva';

  @override
  String get categories => 'Categorias';

  @override
  String get promptPirateFlag =>
      'Digite um prompt para gerar a bandeira pirata';

  @override
  String get flagGeneratedSuccess => 'Bandeira pirata gerada com sucesso!';

  @override
  String get promptShip => 'Digite um prompt para gerar o barco';

  @override
  String get shipGeneratedSuccess => 'Barco gerado com sucesso!';

  @override
  String get createCrewTitle => 'Criar Tripulação';

  @override
  String get crewCreatedSuccess => 'Tripulação criada com sucesso!';

  @override
  String get crewTagsHint => 'Ex: Piratas, Aventureiros, etc.';

  @override
  String get crewNameRequired => 'Nome da Tripulação *';

  @override
  String get crewDescriptionHint => 'Conte um pouco sobre sua tripulação...';

  @override
  String get shipNameLabel => 'Nome do Barco';

  @override
  String get pirateFlagLabel => 'Bandeira Pirata';

  @override
  String get crewShipLabel => 'Barco da Tripulação';

  @override
  String get tagNameLabel => 'Nome da tag';

  @override
  String get customCrewHint => 'Ex: Mugiwaras Custom';

  @override
  String get merryShipHint => 'Ex: Going Merry';

  @override
  String get goHomeAction => 'Voltar ao Início';

  @override
  String get aiGeneratedImage => 'Imagem Gerada por IA';

  @override
  String get monthlyReportFinances => '💰 Relatório Mensal - Nami Finances';

  @override
  String get zoroWorkoutNotif => '⚔️ Treino do Zoro';

  @override
  String get sanjiTipNotif => '👨‍🍳 Dica do Sanji';

  @override
  String get featuredCharacterNotif => '🏴‍☠️ Personagem em Destaque';

  @override
  String get financialTipNotif => '💰 Dica Financeira';

  @override
  String get characterDuelNotif => '🎯 Duelo de Personagens';

  @override
  String get checkingAuthStatus => 'Verificando status de autenticação...';

  @override
  String get signingInAuth => 'Entrando...';

  @override
  String get signingOutAuth => 'Saindo...';

  @override
  String get createWorkoutPlan => 'Criar Plano de Treino';

  @override
  String get createCustomPlanTap => 'Toque para criar seu plano personalizado';

  @override
  String get defaultWorkoutName => 'Treino';

  @override
  String get todayWorkoutCompleted => 'Treino de Hoje (Concluído)';

  @override
  String get todayWorkout => 'Treino de Hoje';

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercícios',
      one: '1 exercício',
    );
    return '$_temp0';
  }

  @override
  String get completedWithCheck => '✅ Concluído';

  @override
  String get today => 'Hoje';

  @override
  String get noExercisesInSplit => 'Nenhum exercício neste split.';

  @override
  String get viewProgress => 'Ver Progresso';

  @override
  String get startWorkout => 'Iniciar Treino';

  @override
  String get increaseProgressTitle => 'Aumentar Progresso';

  @override
  String get decreaseProgressTitle => 'Diminuir Progresso';

  @override
  String objectiveLabel(String title) {
    return 'Objetivo: $title';
  }

  @override
  String get currentProgressLabel => 'Progresso atual: ';

  @override
  String get newProgressLabel => 'Novo progresso: ';

  @override
  String get planUpdatesLabel => 'Atualizações sobre o plano:';

  @override
  String get progressIncreaseHint =>
      'O que você fez para progredir? (ex: estudou 2 horas, completou exercícios...)';

  @override
  String get progressDecreaseHint =>
      'Por que o progresso diminuiu? (ex: atraso, dificuldade encontrada...)';

  @override
  String get describeWhatHappened => 'Por favor, descreva o que aconteceu';

  @override
  String get increaseAction => 'Aumentar';

  @override
  String get decreaseAction => 'Diminuir';

  @override
  String get emptyTimelineSubtitle =>
      'Comece criando seu primeiro objetivo para organizar suas metas de estudo e acompanhar seu progresso.';

  @override
  String get biologicalSexLabel => 'Sexo Biológico';

  @override
  String get objectiveTitle => 'Objetivo';

  @override
  String get activityLevelLabel => 'Nível de Atividade Física';

  @override
  String get circumferencesLabel => 'Circunferências';

  @override
  String get optionalLabel => 'Opcional';

  @override
  String get ageLabel => 'Idade';

  @override
  String get heightLabel => 'Altura';

  @override
  String get currentWeightLabel => 'Peso Atual';

  @override
  String get waistLabel => 'Cintura';

  @override
  String get chestLabel => 'Peito';

  @override
  String get armLabel => 'Braço';

  @override
  String get hipLabel => 'Quadril';

  @override
  String get thighLabel => 'Coxa';

  @override
  String get monthOverview => 'Visão geral do mês';

  @override
  String get balanceChart => 'Gráfico de balanço';

  @override
  String get incomesLabel => 'Receitas';

  @override
  String get expensesLabel => 'Despesas';

  @override
  String get reservesLabel => 'Reserva';

  @override
  String get totalReceived => 'Total recebido';

  @override
  String get totalSpent => 'Total gasto';

  @override
  String get noIncomesRegistered => 'Nenhuma receita registrada';

  @override
  String errorPrefix(String error) {
    return 'Erro: $error';
  }

  @override
  String errorGeneratingFlag(String error) {
    return 'Erro ao gerar bandeira: $error';
  }

  @override
  String errorGeneratingShip(String error) {
    return 'Erro ao gerar barco: $error';
  }

  @override
  String crewDeletedMessage(String name) {
    return 'Tripulação \"$name\" excluída';
  }

  @override
  String get averageBountyLabel => 'Bounty Média';

  @override
  String get rolesLabel => 'Funções';

  @override
  String get updateBodyCompositionLabel => 'Atualizar Composição Corporal';

  @override
  String linkLabel(String url) {
    return 'Link: $url';
  }

  @override
  String get saveLabel => 'Salvar';

  @override
  String get ageValidator => 'Insira sua idade';

  @override
  String get heightValidator => 'Insira sua altura';

  @override
  String get weightValidator => 'Insira seu peso';

  @override
  String get goalsAndMeasuresTitle => 'Metas & Medidas';

  @override
  String get goalsAndMeasuresSubtitle =>
      'Defina seu objetivo e adicione medidas para rastrear seu progresso com Sanji & Zoro.';

  @override
  String get goalLoseWeight => 'Emagrecer';

  @override
  String get goalMaintain => 'Manter Peso';

  @override
  String get goalGainMuscle => 'Ganhar Massa';

  @override
  String get activitySedentary => 'Sedentário';

  @override
  String get activityLight => 'Leve';

  @override
  String get activityModerate => 'Moderado';

  @override
  String get activityIntense => 'Intenso';

  @override
  String get activityVeryIntense => 'Muito Intenso';

  @override
  String get expensesDetails => 'Detalhes dos Gastos';

  @override
  String get totalExpensesLabel => 'Total dos Gastos:';

  @override
  String get copyAction => 'Copiar';

  @override
  String get cookingTipsHint => 'Ex: frango, arroz, cebola...';

  @override
  String get todayCompleted => 'Hoje (concluído)';

  @override
  String get assessmentResultsTitle => 'Resultados da Avaliação';

  @override
  String get topRecommendationsTitle => 'Principais Recomendações';

  @override
  String get weekProgressTitle => 'Progresso da Semana';

  @override
  String get streakTitle => 'Ofensiva';

  @override
  String get thisMonthSuffix => 'este mês';

  @override
  String get daysSuffix => 'dias';

  @override
  String get doneTodayLabel => 'Feito hoje';

  @override
  String get pendingLabel => 'Pendente';

  @override
  String get onlyCurrentMonthEditAllowed =>
      'Só é possível editar finanças do mês atual';

  @override
  String get saveWithNami => 'Economize com a Nami';

  @override
  String get configureYourFinances =>
      'Configure suas finanças do mês e acompanhe\nseu progresso em tempo real.';

  @override
  String get incomeLabel => 'Renda';

  @override
  String get noExpensesRegistered => 'Nenhum gasto cadastrado';

  @override
  String get categoryFixed => 'Fixo';

  @override
  String get categoryFood => 'Alimentação';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryEntertainment => 'Lazer';

  @override
  String get categoryHealth => 'Saúde';

  @override
  String get categoryOther => 'Outros';

  @override
  String get availableLabel => 'Disponível';

  @override
  String get savingsLabel => 'Economias';

  @override
  String get incomeDetailsTitle => 'Detalhes da Renda';

  @override
  String get savingsDetailsTitle => 'Detalhes das Economias';

  @override
  String get monthSavings => 'Economias do Mês';

  @override
  String get financialMetricsTitle => 'Métricas Financeiras';

  @override
  String get dailyAvailableAmount => 'Valor Diário Disponível';

  @override
  String get janAbbr => 'Jan';

  @override
  String get febAbbr => 'Fev';

  @override
  String get marAbbr => 'Mar';

  @override
  String get aprAbbr => 'Abr';

  @override
  String get mayAbbr => 'Mai';

  @override
  String get junAbbr => 'Jun';

  @override
  String get julAbbr => 'Jul';

  @override
  String get augAbbr => 'Ago';

  @override
  String get sepAbbr => 'Set';

  @override
  String get octAbbr => 'Out';

  @override
  String get novAbbr => 'Nov';

  @override
  String get decAbbr => 'Dez';

  @override
  String get availableBalance => 'Saldo Disponível';

  @override
  String get currentMonthLabel => 'Mês Atual';

  @override
  String get yesLabel => 'Sim';

  @override
  String get noLabel => 'Não';

  @override
  String get workoutStatusDefeated => 'Derrotado';

  @override
  String get workoutStatusOnTarget => 'Na Meta!';

  @override
  String get zoroQuoteDefeated => '\"Eu nunca vou perder novamente.\"';

  @override
  String get zoroQuoteProud =>
      '\"Não importa o que aconteça, eu nunca vou perder novamente.\"';

  @override
  String get zoroStatusDefeated => 'Zoro está derrotado...';

  @override
  String get zoroStatusProud => 'Zoro está orgulhoso!';

  @override
  String workoutsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count treinos esta semana',
      one: 'Falta 1 treino esta semana',
    );
    return '$_temp0';
  }

  @override
  String get weeklyGoalCompleted => 'Meta semanal concluída! 🎯';

  @override
  String workoutDaysCount(int done, int total) {
    return '$done / $total dias';
  }

  @override
  String get vegapunk => 'Vegapunk';

  @override
  String get vegapunkChatTitle => 'Perguntar ao Vegapunk';

  @override
  String get vegapunkChatHint => 'Pergunte qualquer coisa...';

  @override
  String get vegapunkModelDownloadTitle => 'Baixando o cérebro do Vegapunk';

  @override
  String get vegapunkModelDownloadSubtitle =>
      'Download único (~2,4 GB). O modelo roda totalmente no seu dispositivo.';

  @override
  String get vegapunkModelLoadingTitle => 'Ativando Vegapunk...';

  @override
  String get vegapunkModelErrorTitle => 'Vegapunk falhou ao inicializar';

  @override
  String get vegapunkRetry => 'Tentar novamente';

  @override
  String get vegapunkCancel => 'Cancelar';

  @override
  String get vegapunkChatEmpty =>
      'Vegapunk está pronto. Me pergunte qualquer coisa.';

  @override
  String get vegapunkStopGeneration => 'Parar';

  @override
  String get vegapunkSatelliteStella => 'Stella (Original)';

  @override
  String get vegapunkSatelliteShaka => 'Shaka (Bondade)';

  @override
  String get vegapunkSatelliteLilith => 'Lilith (Maldade)';

  @override
  String get vegapunkSatelliteEdison => 'Edison (Pensamento)';

  @override
  String get vegapunkSatellitePythagoras => 'Pythagoras (Sabedoria)';

  @override
  String get vegapunkSatelliteAtlas => 'Atlas (Violência)';

  @override
  String get vegapunkSatelliteYork => 'York (Ganância)';

  @override
  String get vegapunkThinkingMode => 'Modo Pensamento';

  @override
  String get vegapunkThinkingModeDesc =>
      'Ativa o raciocínio lógico (aumenta memória e latência)';

  @override
  String get cookingPersonalizedMealTitle =>
      'Refeição Personalizada com o Sanji';

  @override
  String get cookingPersonalizedMealSubtitle =>
      'Adicione os ingredientes que você tem e receba uma receita personalizada baseada nos seus dados nutricionais!';

  @override
  String get cookingAvailableIngredients => 'Ingredientes Disponíveis';

  @override
  String get cookingPersonalizedMeal => 'Refeição Personalizada';

  @override
  String cookingTargetCaloriesInfo(String calories, String goal) {
    return 'Calorias alvo: $calories kcal | Objetivo: $goal';
  }

  @override
  String get cookingGeneratingMeal => 'Gerando refeição...';

  @override
  String get cookingGenerateMeal => 'Gerar Refeição';

  @override
  String cookingPersonalizedRecipeTitle(String mealType) {
    return 'Receita Personalizada - $mealType';
  }

  @override
  String get cookingGoalMaintenance => 'Manter peso';

  @override
  String get cookingGoalWeightLoss => 'Perder peso';

  @override
  String get cookingGoalMuscleGain => 'Ganhar massa muscular';

  @override
  String get mealTypeBreakfast => 'Café da manhã';

  @override
  String get mealTypeMorningSnack => 'Lanche da manhã';

  @override
  String get mealTypeLunch => 'Almoço';

  @override
  String get mealTypeAfternoonSnack => 'Café da tarde';

  @override
  String get mealTypeDinner => 'Jantar';

  @override
  String get mealTypeDessert => 'Sobremesa';

  @override
  String get mealTypeNightSnack => 'Lanche noturno';

  @override
  String get dietaryRestrictionNone => 'Sem restrições';

  @override
  String get dietaryRestrictionVegetarian => 'Vegetariano';

  @override
  String get dietaryRestrictionVegan => 'Vegano';

  @override
  String get dietaryRestrictionGlutenFree => 'Sem glúten';

  @override
  String get dietaryRestrictionLactoseFree => 'Sem lactose';

  @override
  String get dietaryRestrictionLowCarb => 'Baixo carboidrato';

  @override
  String get dietaryRestrictionHighProtein => 'Alto teor proteico';

  @override
  String get offlineBannerMessage =>
      'Você está offline. Algumas funções estão indisponíveis.';

  @override
  String get offlineScreenTitle => 'Sem Conexão com a Internet';

  @override
  String get offlineScreenSubtitle =>
      'Esta função requer conexão com a internet.\nReconecte-se para continuar.';

  @override
  String get addReserve => 'Adicionar reserva';

  @override
  String get reserveGoalOptional => 'Meta de reserva mensal (opcional)';

  @override
  String get reservePurpose => 'Finalidade';

  @override
  String get reserveNote => 'Observação (opcional)';

  @override
  String get reservePurposeEmergency => 'Emergência';

  @override
  String get reservePurposeTravel => 'Viagem';

  @override
  String get reservePurposeGoal => 'Objetivo';

  @override
  String get reservePurposeInvestment => 'Investimento';

  @override
  String get reservePurposeOther => 'Outro';

  @override
  String reserveGoalLabel(String amount) {
    return 'Meta: $amount';
  }

  @override
  String reserveGoalProgressPct(String pct) {
    return '$pct% da meta';
  }

  @override
  String reserveGoalRemaining(String amount) {
    return 'Faltam $amount';
  }

  @override
  String get reserveGoalMetricLabel => 'Meta de reserva';

  @override
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Próximo mês';

  @override
  String get editingPastMonth => 'Editando um mês passado';
}
