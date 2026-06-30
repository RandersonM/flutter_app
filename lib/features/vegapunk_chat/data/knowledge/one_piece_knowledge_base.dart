import 'package:opfan/core/models/rag/rag_document.dart';

class OnePieceKnowledgeBase {
  OnePieceKnowledgeBase._();

  static List<RagDocument> get documents => [
        ..._vegapunkDocs,
        ..._characterDocs,
        ..._devilFruitDocs,
        ..._arcDocs,
      ];

  static List<RagDocument> getDocumentsForCategories(List<String>? categories) {
    if (categories == null || categories.isEmpty) {
      return documents;
    }
    final mappedCategories = categories.map((c) {
      final norm = c.toLowerCase().trim().replaceAll('docs', '').replaceAll('doc', '');
      if (norm == 'character') return 'character';
      if (norm == 'vegapunk') return 'vegapunk';
      if (norm == 'devilfruit' || norm == 'devil_fruit') return 'devil_fruit';
      if (norm == 'arc') return 'arc';
      return norm;
    }).toList();

    return documents.where((doc) => mappedCategories.contains(doc.category)).toList();
  }

  // ─── Vegapunk & Satellites ───────────────────────────────────────────────

  static const _vegapunkDocs = [
    RagDocument(
      id: 'vgp-001-pt',
      content:
          'Vegapunk é o maior cientista do mundo de One Piece, considerado 500 anos à frente de seu tempo. '
          'Ele trabalhou para o Governo Mundial na ilha Egghead. Seu corpo real (Stella) é velho e frágil. '
          'Ele dividiu sua mente em seis satélites autônomos, cada um representando um aspecto de sua personalidade.',
      category: 'vegapunk',
      language: 'pt',
      topic: 'vegapunk',
    ),
    RagDocument(
      id: 'vgp-001-en',
      content:
          'Vegapunk is the greatest scientist in the One Piece world, considered 500 years ahead of his time. '
          'He worked for the World Government on Egghead Island. His real body (Stella) is old and frail. '
          'He split his mind into six autonomous satellites, each representing an aspect of his personality.',
      category: 'vegapunk',
      language: 'en',
      topic: 'vegapunk',
    ),
    RagDocument(
      id: 'vgp-002-pt',
      content:
          'Os seis satélites de Vegapunk são: Shaka (01 - Bondade), Lilith (02 - Maldade), '
          'Edison (03 - Pensamento), Pitágoras (04 - Sabedoria), Atlas (05 - Violência) e York (06 - Ganância). '
          'York traiu Vegapunk ao se aliar com os Cinco Estrelas para se tornar um Celestial Dragon.',
      category: 'vegapunk',
      language: 'pt',
      topic: 'satellites',
    ),
    RagDocument(
      id: 'vgp-002-en',
      content:
          'Vegapunk\'s six satellites are: Shaka (01 - Goodness), Lilith (02 - Evil), '
          'Edison (03 - Thinking), Pythagoras (04 - Wisdom), Atlas (05 - Violence), and York (06 - Greed). '
          'York betrayed Vegapunk by allying with the Five Elders to become a Celestial Dragon.',
      category: 'vegapunk',
      language: 'en',
      topic: 'satellites',
    ),
    RagDocument(
      id: 'vgp-003-pt',
      content:
          'Vegapunk criou os Pacifistas (clones de Bartholomew Kuma), a tecnologia de Seraphins (os mais poderosos Pacifistas, '
          'baseados nos ex-Shichibukai com sangue de Joy Boy), os dragões artificiais de Punk Hazard, '
          'e descobriu a fonte de energia do mundo — o fruto do gigante ancestral Imu.',
      category: 'vegapunk',
      language: 'pt',
      topic: 'inventions',
    ),
    RagDocument(
      id: 'vgp-003-en',
      content:
          'Vegapunk created the Pacifistas (clones of Bartholomew Kuma), the Seraphim technology '
          '(the most powerful Pacifistas, based on former Warlords with Joy Boy\'s blood), '
          'the artificial dragons on Punk Hazard, and discovered the world\'s energy source.',
      category: 'vegapunk',
      language: 'en',
      topic: 'inventions',
    ),
  ];

  // ─── Characters ──────────────────────────────────────────────────────────

  static const _characterDocs = [
    RagDocument(
      id: 'char-luffy-pt',
      content:
          'Monkey D. Luffy é o capitão dos Piratas do Chapéu de Palha e o protagonista de One Piece. '
          'Comeu a Gomu Gomu no Mi (revelada ser na verdade a Hito Hito no Mi, Modelo: Nika), '
          'que o torna o Guerreiro da Libertação do Sol — Joy Boy reencarnado. '
          'Seu objetivo é se tornar o Rei dos Piratas encontrando o One Piece.',
      category: 'character',
      language: 'pt',
      topic: 'luffy',
    ),
    RagDocument(
      id: 'char-luffy-en',
      content:
          'Monkey D. Luffy is the captain of the Straw Hat Pirates and protagonist of One Piece. '
          'He ate the Gomu Gomu no Mi (revealed to actually be the Hito Hito no Mi, Model: Nika), '
          'making him the Sun God Nika — Joy Boy reincarnated. '
          'His goal is to become King of the Pirates by finding the One Piece.',
      category: 'character',
      language: 'en',
      topic: 'luffy',
    ),
    RagDocument(
      id: 'char-zoro-pt',
      content:
          'Roronoa Zoro é o espadachim dos Piratas do Chapéu de Palha e o primeiro tripulante de Luffy. '
          'Usa o estilo Santoryu (três espadas). Seu objetivo é se tornar o maior espadachim do mundo, '
          'superando Dracule Mihawk. É o braço direito de Luffy e tem senso de direção péssimo.',
      category: 'character',
      language: 'pt',
      topic: 'zoro',
    ),
    RagDocument(
      id: 'char-zoro-en',
      content:
          'Roronoa Zoro is the swordsman of the Straw Hat Pirates and Luffy\'s first crew member. '
          'He uses the Santoryu style (three swords). His goal is to become the world\'s greatest swordsman, '
          'surpassing Dracule Mihawk. He is Luffy\'s right-hand man and has a terrible sense of direction.',
      category: 'character',
      language: 'en',
      topic: 'zoro',
    ),
    RagDocument(
      id: 'char-nami-pt',
      content:
          'Nami é a navegadora dos Piratas do Chapéu de Palha. Seu sonho é criar um mapa do mundo inteiro. '
          'Ela usa um Clima-Tact para controlar o clima em batalha. Nasceu no vilarejo de Cocoyashi '
          'e roubou de piratas para comprar a liberdade de sua ilha.',
      category: 'character',
      language: 'pt',
      topic: 'nami',
    ),
    RagDocument(
      id: 'char-nami-en',
      content:
          'Nami is the navigator of the Straw Hat Pirates. Her dream is to create a map of the entire world. '
          'She uses a Clima-Tact to control weather in battle. She was born in Cocoyashi Village '
          'and stole from pirates to buy her island\'s freedom.',
      category: 'character',
      language: 'en',
      topic: 'nami',
    ),
    RagDocument(
      id: 'char-sanji-pt',
      content:
          'Sanji é o cozinheiro dos Piratas do Chapéu de Palha. Luta usando apenas as pernas, '
          'com técnicas de fogo chamadas "Diable Jambe". Seu sonho é encontrar o "All Blue", '
          'um oceano lendário onde peixes de todos os mares se reúnem. É filho de Judge Vinsmoke, '
          'líder do grupo de mercenários Germa 66.',
      category: 'character',
      language: 'pt',
      topic: 'sanji',
    ),
    RagDocument(
      id: 'char-sanji-en',
      content:
          'Sanji is the cook of the Straw Hat Pirates. He fights using only his legs '
          'with fire techniques called "Diable Jambe". His dream is to find the "All Blue", '
          'a legendary ocean where fish from all seas gather. He is the son of Judge Vinsmoke, '
          'leader of the Germa 66 mercenary group.',
      category: 'character',
      language: 'en',
      topic: 'sanji',
    ),
    RagDocument(
      id: 'char-robin-pt',
      content:
          'Nico Robin é a arqueóloga dos Piratas do Chapéu de Palha. Comeu a Hana Hana no Mi, '
          'que permite criar cópias de partes do seu corpo em qualquer superfície. '
          'Ela é a única pessoa viva capaz de ler os Poneglyphs, pedras antigas com a história verdadeira do mundo.',
      category: 'character',
      language: 'pt',
      topic: 'robin',
    ),
    RagDocument(
      id: 'char-robin-en',
      content:
          'Nico Robin is the archaeologist of the Straw Hat Pirates. She ate the Hana Hana no Mi, '
          'which allows her to create copies of her body parts on any surface. '
          'She is the only living person able to read Poneglyphs, ancient stones containing the world\'s true history.',
      category: 'character',
      language: 'en',
      topic: 'robin',
    ),
    RagDocument(
      id: 'char-shanks-pt',
      content:
          'Shanks é um dos Quatro Imperadores e líder dos Piratas do Cabelo Vermelho. '
          'Ele é o responsável por dar o chapéu de palha a Luffy e inspirá-lo a se tornar pirata. '
          'É famoso por seu Haki de Rei extremamente poderoso, capaz de nocautear centenas de pessoas a quilômetros de distância.',
      category: 'character',
      language: 'pt',
      topic: 'shanks',
    ),
    RagDocument(
      id: 'char-shanks-en',
      content:
          'Shanks is one of the Four Emperors and leader of the Red Hair Pirates. '
          'He gave Luffy his straw hat and inspired him to become a pirate. '
          'He is famous for his extremely powerful Conqueror\'s Haki, able to knock out hundreds at once from miles away.',
      category: 'character',
      language: 'en',
      topic: 'shanks',
    ),
  ];

  // ─── Devil Fruits ────────────────────────────────────────────────────────

  static const _devilFruitDocs = [
    RagDocument(
      id: 'df-gomu-pt',
      content:
          'A Gomu Gomu no Mi (verdadeiro nome: Hito Hito no Mi, Modelo: Nika) foi comida por Luffy. '
          'Ela transforma o corpo em borracha, tornando-o imune a impactos físicos e raios elétricos. '
          'No Gear 5, Luffy acessa o poder do Sol God Nika, com habilidades de desenho animado ilimitadas.',
      category: 'devil_fruit',
      language: 'pt',
      topic: 'gomu_gomu',
    ),
    RagDocument(
      id: 'df-gomu-en',
      content:
          'The Gomu Gomu no Mi (true name: Hito Hito no Mi, Model: Nika) was eaten by Luffy. '
          'It transforms the body into rubber, making it immune to blunt force and electricity. '
          'In Gear 5, Luffy accesses the Sun God Nika\'s power with unlimited cartoon-like abilities.',
      category: 'devil_fruit',
      language: 'en',
      topic: 'gomu_gomu',
    ),
    RagDocument(
      id: 'df-mera-pt',
      content:
          'A Mera Mera no Mi é uma Logia que transforma o usuário em fogo. '
          'Foi comida por Portgas D. Ace (irmão de Luffy) e depois por Sabo (irmão jurado de Luffy). '
          'O usuário pode criar e controlar chamas e é imune a fogo.',
      category: 'devil_fruit',
      language: 'pt',
      topic: 'mera_mera',
    ),
    RagDocument(
      id: 'df-mera-en',
      content:
          'The Mera Mera no Mi is a Logia that turns the user into fire. '
          'It was eaten by Portgas D. Ace (Luffy\'s brother) and later by Sabo (Luffy\'s sworn brother). '
          'The user can create and control flames and is immune to fire.',
      category: 'devil_fruit',
      language: 'en',
      topic: 'mera_mera',
    ),
    RagDocument(
      id: 'df-hie-pt',
      content:
          'A Hie Hie no Mi é uma Logia do gelo, comida pelo Almirante Aokiji (Kuzan). '
          'Permite criar e controlar gelo, congelar qualquer coisa instantaneamente e transformar o corpo em gelo.',
      category: 'devil_fruit',
      language: 'pt',
      topic: 'hie_hie',
    ),
    RagDocument(
      id: 'df-hie-en',
      content:
          'The Hie Hie no Mi is an ice Logia eaten by Admiral Aokiji (Kuzan). '
          'It allows creating and controlling ice, freezing anything instantly, and transforming the body into ice.',
      category: 'devil_fruit',
      language: 'en',
      topic: 'hie_hie',
    ),
    RagDocument(
      id: 'df-gura-pt',
      content:
          'A Gura Gura no Mi é considerada a Paramecia mais poderosa, comida por Whitebeard (Edward Newgate). '
          'Permite criar tremores e terremotos capazes de destruir o mundo. '
          'Após a morte de Whitebeard, o poder foi absorvido por Barba Negra (Marshall D. Teach).',
      category: 'devil_fruit',
      language: 'pt',
      topic: 'gura_gura',
    ),
    RagDocument(
      id: 'df-gura-en',
      content:
          'The Gura Gura no Mi is considered the strongest Paramecia, eaten by Whitebeard (Edward Newgate). '
          'It allows creating quakes and earthquakes capable of destroying the world. '
          'After Whitebeard\'s death, the power was absorbed by Blackbeard (Marshall D. Teach).',
      category: 'devil_fruit',
      language: 'en',
      topic: 'gura_gura',
    ),
    RagDocument(
      id: 'df-ope-pt',
      content:
          'A Ope Ope no Mi é uma Paramecia comida por Trafalgar D. Water Law. '
          'Cria uma "sala de operação" esférica onde o usuário pode reorganizar tudo dentro. '
          'É chamada de "Fruta Definitiva" porque pode conceder imortalidade a outro — ao custo da vida do usuário.',
      category: 'devil_fruit',
      language: 'pt',
      topic: 'ope_ope',
    ),
    RagDocument(
      id: 'df-ope-en',
      content:
          'The Ope Ope no Mi is a Paramecia eaten by Trafalgar D. Water Law. '
          'It creates a spherical "operating room" where the user can rearrange everything inside. '
          'It\'s called the "Ultimate Fruit" because it can grant immortality to another — at the cost of the user\'s life.',
      category: 'devil_fruit',
      language: 'en',
      topic: 'ope_ope',
    ),
  ];

  // ─── Arcs ────────────────────────────────────────────────────────────────

  static const _arcDocs = [
    RagDocument(
      id: 'arc-marineford-pt',
      content:
          'A Guerra de Marineford foi o maior confronto da era moderna em One Piece. '
          'Os Piratas do Barba Branca tentaram resgatar Portgas D. Ace da execução na sede da Marinha. '
          'Ace morreu protegendo Luffy de Akainu. Barba Branca também morreu nesta batalha. '
          'O evento marcou o fim da Era de Barba Branca.',
      category: 'arc',
      language: 'pt',
      topic: 'marineford',
    ),
    RagDocument(
      id: 'arc-marineford-en',
      content:
          'The Marineford War was the greatest conflict of the modern era in One Piece. '
          'The Whitebeard Pirates tried to rescue Portgas D. Ace from execution at Marine HQ. '
          'Ace died protecting Luffy from Akainu. Whitebeard also died in this battle. '
          'The event marked the end of the Whitebeard Era.',
      category: 'arc',
      language: 'en',
      topic: 'marineford',
    ),
    RagDocument(
      id: 'arc-wano-pt',
      content:
          'O arco de Wano Kuni é um dos maiores de One Piece. Os Chapéus de Palha se aliaram aos Samurais de Wano '
          'e ao Exército da Libertação dos Dragões para derrubar Kaido e Orochi. '
          'Luffy derrotou Kaido usando o Gear 5 (Sol God Nika). '
          'Wano estava isolado do mundo há séculos por causa de Kaido e Orochi.',
      category: 'arc',
      language: 'pt',
      topic: 'wano',
    ),
    RagDocument(
      id: 'arc-wano-en',
      content:
          'The Wano Country arc is one of the largest in One Piece. The Straw Hats allied with Wano\'s samurai '
          'and the Revolutionary Army to overthrow Kaido and Orochi. '
          'Luffy defeated Kaido using Gear 5 (Sun God Nika). '
          'Wano had been isolated from the world for centuries because of Kaido and Orochi.',
      category: 'arc',
      language: 'en',
      topic: 'wano',
    ),
    RagDocument(
      id: 'arc-egghead-pt',
      content:
          'O arco de Egghead é o arco atual (era do final). Os Chapéus de Palha visitam a ilha de Vegapunk, '
          'que é a ilha do futuro com tecnologia avançada. York trai Vegapunk, os Cinco Estrelas invadem a ilha, '
          'e Vegapunk transmite uma mensagem para o mundo inteiro antes de ser assassinado. '
          'O arco revela segredos sobre o Século Vazio e a história do mundo.',
      category: 'arc',
      language: 'pt',
      topic: 'egghead',
    ),
    RagDocument(
      id: 'arc-egghead-en',
      content:
          'The Egghead arc is the current arc (final saga). The Straw Hats visit Vegapunk\'s island, '
          'the island of the future with advanced technology. York betrays Vegapunk, the Five Elders invade, '
          'and Vegapunk broadcasts a message to the entire world before being killed. '
          'The arc reveals secrets about the Void Century and the world\'s true history.',
      category: 'arc',
      language: 'en',
      topic: 'egghead',
    ),
    RagDocument(
      id: 'arc-dressrosa-pt',
      content:
          'O arco de Dressrosa revelou a história de Donquixote Doflamingo e seu controle sobre o reino. '
          'Luffy derrotou Doflamingo com o Gear 4 (Boundman). Law e Luffy formaram uma aliança. '
          'O arco introduziu os Minks e a existência de Zou, além do Exército da Libertação dos Dragões.',
      category: 'arc',
      language: 'pt',
      topic: 'dressrosa',
    ),
    RagDocument(
      id: 'arc-dressrosa-en',
      content:
          'The Dressrosa arc revealed the history of Donquixote Doflamingo and his control over the kingdom. '
          'Luffy defeated Doflamingo with Gear 4 (Boundman). Law and Luffy formed an alliance. '
          'The arc introduced the Minks and the existence of Zou, as well as the Revolutionary Army.',
      category: 'arc',
      language: 'en',
      topic: 'dressrosa',
    ),
  ];
}
