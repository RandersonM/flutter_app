/// Pre-model heuristic that detects tool intent from user messages.
///
/// This is a critical component: the Gemma 4 E2B model (2B params) is not
/// always reliable at deciding when to use tools. This detector analyzes
/// the user's message BEFORE sending to the model and can:
///
/// 1. **High confidence** — Return the exact tool name and extracted query,
///    allowing the system to call the tool directly without waiting for the model.
/// 2. **Medium confidence** — Return a hint that gets prepended to the prompt
///    to nudge the model toward using the right tool.
/// 3. **No match** — Return null, letting the model decide freely.
class ToolIntentDetector {
  const ToolIntentDetector();

  /// Analyze user message and detect tool intent.
  ToolIntentResult? detect(String message) {
    final lower = message.toLowerCase().trim();

    // ── searchInternet ──────────────────────────────────────────────────
    if (_matchesSearchIntent(lower)) {
      final query = _extractSearchQuery(lower, message);
      return ToolIntentResult(
        toolName: 'searchInternet',
        confidence: ToolIntentConfidence.high,
        extractedArgs: {'query': query},
      );
    }

    // ── getUserProfile ──────────────────────────────────────────────────
    if (_matchesProfileIntent(lower)) {
      return const ToolIntentResult(
        toolName: 'getUserProfile',
        confidence: ToolIntentConfidence.high,
        extractedArgs: {},
      );
    }

    // ── getWorkoutHistory ───────────────────────────────────────────────
    if (_matchesWorkoutHistoryIntent(lower)) {
      return const ToolIntentResult(
        toolName: 'getWorkoutHistory',
        confidence: ToolIntentConfidence.high,
        extractedArgs: {},
      );
    }

    // ── saveWorkout ─────────────────────────────────────────────────────
    // It writes data, so a negated or hypothetical sentence ("não treinei
    // hoje", "if I trained today…") must not trigger it.
    if (_matchesSaveWorkoutIntent(lower)) {
      return const ToolIntentResult(
        toolName: 'saveWorkout',
        confidence: ToolIntentConfidence.high,
        extractedArgs: {},
      );
    }

    // ── getCharacterInfo ────────────────────────────────────────────────
    // This one is medium confidence: the model usually handles character
    // questions well, so we just hint rather than force.
    final characterMatch = _matchesCharacterIntent(lower);
    if (characterMatch != null) {
      return ToolIntentResult(
        toolName: 'getCharacterInfo',
        confidence: ToolIntentConfidence.medium,
        extractedArgs: {'characterName': characterMatch},
      );
    }

    // ── Implicit search (medium confidence) ─────────────────────────────
    if (_matchesImplicitSearchIntent(lower)) {
      final query = _extractSearchQuery(lower, message);
      return ToolIntentResult(
        toolName: 'searchInternet',
        confidence: ToolIntentConfidence.medium,
        extractedArgs: {'query': query},
      );
    }

    return null;
  }

  // ── Search Intent ──────────────────────────────────────────────────────

  /// Explicit search triggers (high confidence).
  bool _matchesSearchIntent(String lower) {
    const triggers = [
      // Portuguese
      'pesquise na internet',
      'pesquise na web',
      'pesquisa na internet',
      'busque na internet',
      'busque na web',
      'procure na internet',
      'procure na web',
      'pesquise sobre',
      'pesquise para mim',
      'faça uma pesquisa',
      'faz uma pesquisa',
      // English
      'search the internet',
      'search the web',
      'search online',
      'look up online',
      'google for',
      'search for',
      'web search',
    ];
    return triggers.any((t) => lower.contains(t));
  }

  /// Implicit search triggers — topics that almost always need web data.
  bool _matchesImplicitSearchIntent(String lower) {
    const triggers = [
      // Sports / Events (PT)
      'quem joga', 'quem jogou', 'qual time joga',
      'resultado do jogo', 'resultado da partida',
      'placar do jogo', 'placar da partida',
      'tabela do campeonato', 'classificação do',
      'próximo jogo', 'ultimo jogo', 'último jogo',
      'copa do mundo', 'copa america', 'copa américa',
      'champions league', 'libertadores',
      'brasileirão', 'brasileirao',
      'olimpíadas', 'olimpiadas',
      // Sports / Events (EN)
      'who plays', 'who played', 'what team plays',
      'game score', 'match result', 'match score',
      'world cup', 'super bowl', 'nba finals',
      'premier league', 'la liga', 'serie a',
      // News / Current events (PT)
      'notícia', 'noticia', 'últimas notícias',
      'aconteceu hoje', 'acontecendo agora',
      'que horas é', 'previsão do tempo',
      'cotação do dólar', 'cotação do dollar',
      'preço do bitcoin', 'preço da',
      // News / Current events (EN)
      'latest news', 'breaking news', 'what happened',
      'current events', 'weather forecast',
      'stock price', 'bitcoin price',
      'exchange rate',
      // Temporal markers that imply current info
      'hoje', 'amanhã', 'ontem', 'agora', 'essa semana',
      'today', 'tomorrow', 'yesterday', 'this week',
      'right now', 'currently',
    ];
    return triggers.any((t) => lower.contains(t));
  }

  /// Extract a search query from the message, removing trigger phrases.
  String _extractSearchQuery(String lower, String original) {
    // Remove common trigger prefixes to get a cleaner query
    var query = original.trim();
    const prefixesToRemove = [
      'pesquise na internet',
      'pesquise na web',
      'busque na internet',
      'procure na internet',
      'pesquise sobre',
      'pesquise para mim',
      'faça uma pesquisa sobre',
      'faz uma pesquisa sobre',
      'search the internet for',
      'search the web for',
      'search online for',
      'search for',
      'look up',
    ];

    final lowerQuery = query.toLowerCase();
    for (final prefix in prefixesToRemove) {
      if (lowerQuery.startsWith(prefix)) {
        query = query.substring(prefix.length).trim();
        break;
      }
    }

    // If the query is too short after cleanup, use the original
    if (query.length < 3) query = original.trim();

    return query;
  }

  // ── Profile Intent ─────────────────────────────────────────────────────

  bool _matchesProfileIntent(String lower) {
    const triggers = [
      // Portuguese
      'meu perfil', 'meus dados', 'minhas informações',
      'meu peso', 'minha altura', 'minha idade',
      'meu nome', 'meu email',
      'meu nível de atividade', 'meu objetivo',
      'quanto eu peso', 'qual minha altura',
      'qual meu peso', 'qual meu objetivo',
      // English
      'my profile', 'my data', 'my information',
      'my weight', 'my height', 'my age',
      'my name', 'my email',
      'my activity level', 'my goal',
      'how much do i weigh', 'how tall am i',
    ];
    return triggers.any((t) => lower.contains(t));
  }

  // ── Workout History Intent ─────────────────────────────────────────────

  bool _matchesWorkoutHistoryIntent(String lower) {
    const triggers = [
      // Portuguese
      'meu histórico de treino', 'meus treinos',
      'quantos dias treinei', 'quantos treinos',
      'meu plano de treino', 'minha rotina de treino',
      'quando treinei', 'dias que treinei',
      'evolução do meu peso', 'evolução do meu treino',
      'meu progresso', 'minha avaliação',
      // English
      'my workout history', 'my workouts',
      'how many days trained', 'how many workouts',
      'my workout plan', 'my training routine',
      'when did i train', 'days i trained',
      'my weight progress', 'my training progress',
      'my assessment',
    ];
    return triggers.any((t) => lower.contains(t));
  }

  // ── Save Workout Intent ────────────────────────────────────────────────

  static const _saveWorkoutTriggers = [
    // Portuguese
    'treinei hoje', 'fiz treino hoje',
    'completei meu treino', 'terminei meu treino',
    'salvar treino', 'registrar treino',
    'marcar treino de hoje', 'registrar que treinei',
    // English
    'i trained today', 'i worked out today',
    'completed my workout', 'finished my workout',
    'save workout', 'record workout',
    'log my workout', 'mark today as trained',
  ];

  static final _saveWorkoutTrigger = RegExp(
    _saveWorkoutTriggers.map(RegExp.escape).join('|'),
  );

  // Looked for only in the trigger's clause, before the trigger: a negation
  // after it ("treinei hoje e nem cansei", "can't feel my legs") or in an
  // earlier clause ("não sei, mas treinei hoje") is about something else.
  // `n`, `ñ` and `naum` are typed for "não"; `’` is the iOS apostrophe.
  static final _negation = RegExp(
    r"(?<!\p{L})(não|nao|naum|ñ|n|nem|nunca|jamais|quase|not|never|cannot|"
    r"almost|didnt|dont|doesnt|havent|hasnt|cant|couldnt|wasnt|"
    r"\p{L}+n['’]t)(?!\p{L})",
    unicode: true,
  );

  // Portuguese also negates right after the verb: "treinei hoje não".
  static final _negationRightAfter = RegExp(
    r'^\s*(não|nao|naum|ñ|n)(?!\p{L})',
    unicode: true,
  );

  // "treinei hoje sem parar" is a workout; "fiquei sem registrar treino" isn't.
  static final _withoutRightBefore = RegExp(
    r'(?<!\p{L})sem\s+$',
    unicode: true,
  );

  static final _hypothetical = RegExp(
    r'(?<!\p{L})(se|if|whether|será que)(?!\p{L})',
    unicode: true,
  );

  // A question typed without "?" ("quanto tempo treinei hoje", "have i
  // trained today"). Matched up to the end of the trigger, so an auxiliary
  // before a trigger that starts with "i" still counts.
  static final _interrogative = RegExp(
    r'(?<!\p{L})(quanto|quanta|quantos|quantas|qual|quais|onde|como|o que|'
    r'por que|how|what|which|where|why|'
    r'(did|do|does|should|have|has|had) i)(?!\p{L})',
    unicode: true,
  );

  // "quando"/"when" asks about the workout only right before it ("me diz
  // quando treinei hoje"); in "quando acordei treinei hoje" it marks a time.
  static final _whenRightBefore = RegExp(
    r'(?<!\p{L})(quando|when)\s+((eu|i)\s+)?$',
    unicode: true,
  );

  static final _clauseBoundary = RegExp(r'[.,;:!?\n]');
  static final _sentenceEnd = RegExp(r'[.!?\n]');

  /// Every trigger in the message must be affirmed: a write is not worth a
  /// guess when one mention is negated.
  bool _matchesSaveWorkoutIntent(String lower) {
    final triggers = _saveWorkoutTrigger.allMatches(lower).toList();
    return triggers.isNotEmpty &&
        triggers.every((trigger) => _isAffirmed(lower, trigger));
  }

  bool _isAffirmed(String lower, Match trigger) {
    final before = lower.substring(0, trigger.start);
    final after = lower.substring(trigger.end);
    final clauseBefore = before.substring(
      before.lastIndexOf(_clauseBoundary) + 1,
    );

    final isQuestion =
        _sentenceEnd.firstMatch(after)?[0] == '?' ||
        _interrogative.hasMatch('$clauseBefore${trigger[0]}') ||
        _whenRightBefore.hasMatch(clauseBefore);
    final isNegated =
        _negation.hasMatch(clauseBefore) ||
        _negationRightAfter.hasMatch(after) ||
        _withoutRightBefore.hasMatch(clauseBefore);

    return !isQuestion && !isNegated && !_hypothetical.hasMatch(clauseBefore);
  }

  // ── Character Info Intent ──────────────────────────────────────────────

  /// Returns the character name if detected, null otherwise.
  String? _matchesCharacterIntent(String lower) {
    const patterns = [
      // Portuguese
      'quem é o ', 'quem é a ',
      'me fale sobre o ', 'me fale sobre a ',
      'informações sobre o ', 'informações sobre a ',
      'dados do ', 'dados da ',
      'stats do ', 'stats da ',
      'atributos do ', 'atributos da ',
      // English
      'who is ',
      'tell me about ',
      'information about ',
      'stats of ', 'stats for ',
      'attributes of ',
    ];

    for (final pattern in patterns) {
      if (lower.contains(pattern)) {
        final idx = lower.indexOf(pattern);
        final afterPattern = lower.substring(idx + pattern.length).trim();
        // Extract the character name (take until end or punctuation)
        final name = afterPattern.split(RegExp(r'[?.!,]')).first.trim();
        if (name.isNotEmpty && name.length < 50) {
          return name;
        }
      }
    }
    return null;
  }
}

/// Result of a tool intent detection.
class ToolIntentResult {
  const ToolIntentResult({
    required this.toolName,
    required this.confidence,
    this.extractedArgs = const {},
  });

  /// The name of the tool that should be called.
  final String toolName;

  /// Confidence level of the detection.
  final ToolIntentConfidence confidence;

  /// Pre-extracted arguments for the tool call.
  final Map<String, dynamic> extractedArgs;
}

/// Confidence level of tool intent detection.
enum ToolIntentConfidence {
  /// The user explicitly requested this tool — execute directly.
  high,

  /// The message likely needs this tool — add a hint to the prompt.
  medium,
}
