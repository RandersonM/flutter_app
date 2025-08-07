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
  String get expensesByCategory => 'Despesas por Categoria';

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
  String get delete => 'Deletar';

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
  String get savingsPercentage => 'da Renda';

  @override
  String get yearlySavings => 'Acumulado em 1 Ano';
}
