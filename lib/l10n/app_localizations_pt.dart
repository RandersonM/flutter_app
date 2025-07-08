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
  String get crewUpdateError => 'Erro ao atualizar tripulação';

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
}
