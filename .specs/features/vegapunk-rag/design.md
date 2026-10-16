# Design: Vegapunk RAG — Arquitetura

---

## Diagnóstico Detalhado: Por que o Qwen3 0.6B escreve demais?

```
Problema 1 — System prompt vago
  "no longer than a few paragraphs" não é quantificado.
  Modelos pequenos (0.6B) seguem instruções mais literalmente quando são numéricas.
  Fix: "Respond in 1–2 sentences for yes/no questions. Max 80 words total."

Problema 2 — maxTokens = 1024 é permissivo demais
  O modelo usa o orçamento disponível. 400 tokens força respostas menores.
  
Problema 3 — Sem contexto fundamentado
  O modelo inventa fatos plausíveis para soar completo.
  Fix: RAG injeta fatos reais → modelo ancora em evidências, não precisa inventar.

Problema 4 — Style instructions não repetem brevidade
  Cada satélite tem um style instruction próprio, mas nenhum menciona tamanho máximo.
  Fix: brevidade é responsabilidade do system prompt, não dos style instructions.
```

---

## Arquitetura Geral

```
┌────────────────────────────────────────────────────────────────┐
│                    VegapunkChatCubit                           │
│  - Ao inicializar: carrega OnePieceKnowledgeBase via RAGService│
│  - Após cada resposta: adiciona doc de sessão ao RAGService    │
│  - Ao resetar: chama RAGService.clearSession()                 │
└────────────────┬───────────────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────────────┐
│                 VegapunkChatRepository                         │
│  1. Recebe query do usuário                                    │
│  2. Chama RAGService.search(query, topK: 3)                   │
│  3. Formata contexto como List<String>                         │
│  4. Chama GemmaService.sendMessage(text, ragContext: [...])    │
└──────┬─────────────────────────────────────────────────────────┘
       │                              │
       ▼                              ▼
┌─────────────┐           ┌───────────────────────────────────┐
│  RAGService │           │           GemmaService            │
│             │           │                                   │
│ initialize()│           │ sendMessage(text, ragContext)      │
│ addDocument │           │  → monta prompt com [CONTEXT]     │
│ search()    │           │  → stream de tokens               │
│ clearSession│           │                                   │
└──────┬──────┘           └───────────────────────────────────┘
       │
  ┌────┴────────────────────────┐
  │                             │
  ▼                             ▼
┌──────────────────┐  ┌────────────────────────────┐
│OnePieceKnowledge │  │   Session Documents        │
│Base (seed docs)  │  │   (isSession: true)        │
│                  │  │                            │
│ • Vegapunk+sats  │  │ • "Usuário perguntou sobre │
│ • Personagens    │  │   Luffy. Resposta: ..."    │
│ • Frutas Diabo   │  │                            │
│ • Arcos          │  │ Limpos no clearSession()   │
└──────────────────┘  └────────────────────────────┘
         ↕
  sqlite-vec vector store
  (FlutterGemmaPlugin.instance)
```

---

## Fluxo de uma Mensagem com RAG

```
1. Usuário: "Qual é o poder da Fruta Gum-Gum?"

2. VegapunkChatRepository:
   results = await ragService.search("Fruta Gum-Gum poder", topK: 3)
   → [
       "Gomu Gomu no Mi dá ao usuário corpo de borracha, imune a impacto físico e raios",
       "Monkey D. Luffy é o capitão dos Piratas do Chapéu de Palha e comeu a Gomu Gomu no Mi",
       "Sessão anterior: usuário perguntou sobre Luffy antes"
     ]

3. GemmaService.sendMessage() monta o prompt:
   ─────────────────────────────────────────
   [CONTEXT - Knowledge Base]
   • Gomu Gomu no Mi dá ao usuário corpo de borracha, imune a impacto físico e raios
   • Monkey D. Luffy é o capitão dos Piratas do Chapéu de Palha e comeu a Gomu Gomu no Mi
   • Sessão anterior: usuário perguntou sobre Luffy antes
   ─────────────────────────────────────────
   [USER]
   Qual é o poder da Fruta Gum-Gum?
   ─────────────────────────────────────────

4. Gemma gera: "A Gomu Gomu no Mi transforma o corpo do usuário em borracha, tornando-o
   imune a impacto físico e raios elétricos. É a fruta de Monkey D. Luffy."
   → 2 frases, sem invenção.

5. Cubit adiciona doc de sessão:
   {id: 'sess-<uuid>', content: 'Usuário perguntou sobre Gomu Gomu no Mi. 
    Resposta: A Gomu Gomu no Mi transforma...', isSession: true}
```

---

## Componentes

### 1. RagDocument (model)

```dart
// lib/core/models/rag_document.dart
class RagDocument {
  final String id;
  final String content;
  final String category;    // 'character', 'devil_fruit', 'arc', 'vegapunk', 'session'
  final String language;    // 'en', 'pt', 'both'
  final String topic;       // e.g., 'luffy', 'gum-gum', 'marineford'
  final bool isSession;

  String get metadataJson => jsonEncode({
    'category': category,
    'lang': language,
    'topic': topic,
    'isSession': isSession,
  });
}
```

### 2. IRAGService + RAGService

```dart
// lib/core/services/rag/i_rag_service.dart
abstract class IRAGService {
  Future<void> initialize();
  Future<void> addDocument(RagDocument doc);
  Future<void> addDocumentBatch(List<RagDocument> docs);
  Future<List<String>> search(String query, {int topK = 3});
  Future<void> clearSession();
}

// lib/core/services/rag/rag_service.dart
class RAGService implements IRAGService {
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    // FlutterGemmaPlugin já inicializado via FlutterGemma.initialize() no main.dart
    _initialized = true;
  }

  @override
  Future<void> addDocument(RagDocument doc) async {
    await FlutterGemmaPlugin.instance.addDocument(
      id: doc.id,
      content: doc.content,
      metadata: doc.metadataJson,
    );
  }

  @override
  Future<List<String>> search(String query, {int topK = 3}) async {
    final results = await FlutterGemmaPlugin.instance.searchSimilar(
      query: query,
      topK: topK,
      threshold: 0.3,
    );
    return results.map((r) => r.content).toList();
  }

  @override
  Future<void> clearSession() async {
    // Remove docs com isSession: true via filter
    await FlutterGemmaPlugin.instance.searchSimilar(
      query: '',
      topK: 1000,
      filter: Filter(must: [FieldEquals('isSession', true)]),
    ).then((results) async {
      for (final r in results) {
        // Remove pelo id — API a confirmar
        await FlutterGemmaPlugin.instance.removeDocument(r.id);
      }
    });
  }
}
```

### 3. OnePieceKnowledgeBase

```dart
// lib/core/services/rag/one_piece_knowledge_base.dart
class OnePieceKnowledgeBase {
  static List<RagDocument> get documents => [
    // Vegapunk
    RagDocument(
      id: 'vgp-001',
      content: 'Vegapunk é o maior cientista do mundo de One Piece, trabalhou para o Governo Mundial. '
               'Seus satélites são partes de sua própria mente: Shaka (bondade), Lilith (maldade), '
               'Edison (pensamento), Pitágoras (sabedoria), Atlas (violência) e York (ganância).',
      category: 'vegapunk', language: 'pt', topic: 'vegapunk', isSession: false,
    ),
    // ... mais documentos PT e EN
    
    // Personagens
    RagDocument(id: 'char-luffy-pt', content: 'Monkey D. Luffy é o capitão...', ...),
    RagDocument(id: 'char-sanji-pt', content: 'Sanji é o cozinheiro...', ...),
    
    // Frutas do Diabo
    RagDocument(id: 'df-gomu-pt', content: 'Gomu Gomu no Mi...', ...),
    RagDocument(id: 'df-mera-pt', content: 'Mera Mera no Mi é a Fruta Chama...', ...),
    
    // Arcos
    RagDocument(id: 'arc-marineford-pt', content: 'A Guerra de Marineford...', ...),
  ];
}
```

### 4. GemmaService — Atualização

**Mudanças:**
- `sendMessage()` aceita `List<String>? ragContext`
- `maxTokens` normal: 1024 → **400**
- System prompt: adicionar instrução de brevidade quantificada

```dart
// system prompt (trecho adicionado):
"BREVIDADE: Responda em 1-2 frases para perguntas simples. "
"Máximo 80 palavras. Não repita a pergunta. Vá direto ao ponto."

// sendMessage atualizado:
Stream<String> sendMessage(String text, {
  String? styleInstruction,
  List<String>? ragContext,         // NOVO
}) {
  final contextBlock = ragContext?.isNotEmpty == true
    ? '[CONTEXT]\n${ragContext!.map((c) => '• $c').join('\n')}\n\n'
    : '';
  
  final promptText = styleInstruction != null
    ? '[Style: $styleInstruction]\n\n$contextBlock$text'
    : '$contextBlock$text';
    
  // ... resto igual
}
```

### 5. IGemmaService — Atualização

```dart
// Adicionar parâmetro opcional ao método existente:
Stream<String> sendMessage(String text, {
  String? styleInstruction,
  List<String>? ragContext,   // NOVO — opcional, não quebra callers existentes
});
```

---

## main.dart — FlutterGemma.initialize() atualizado

```dart
FlutterGemma.initialize(
  inferenceEngines: [FlutterGemmaLitert()],  // já existe
  embeddingBackends: [GemmaEmbeddings()],     // NOVO
  vectorStore: [SqliteVec()],                 // NOVO (sqlite-vec cross-platform)
);
```

> **Nota:** Nomes exatos das classes (`GemmaEmbeddings`, `SqliteVec`) devem ser verificados
> na documentação e código-fonte dos pacotes após instalação (T1.1).

---

## pubspec.yaml — Pacotes Adicionais

```yaml
# Adicionar (verificar versões exatas em pub.dev):
flutter_gemma_embeddings: ^1.0.0
flutter_gemma_rag_sqlite: ^1.0.0
```

---

## System Prompt Atualizado

### Inglês (antes vs depois)

**Antes:**
```
Keep responses clear, engaging, and no longer than a few paragraphs unless asked for detail.
```

**Depois:**
```
BREVITY RULES:
- For yes/no or "do you know X" questions: answer in 1–2 sentences MAX.
- For explanations: max 80 words unless the user explicitly asks for more detail.
- Never repeat the user's question. Never add preamble. Go straight to the answer.
- If asked about One Piece lore: use only the facts provided in [CONTEXT]. Do not invent.
```

---

## Arquivos Afetados / Criados

| Arquivo | Ação |
|---------|------|
| `pubspec.yaml` | Adicionar 2 pacotes |
| `lib/main.dart` | Atualizar `FlutterGemma.initialize()` |
| `lib/core/services/gemma/gemma_service.dart` | maxTokens 400, prompt atualizado, ragContext |
| `lib/core/services/gemma/i_gemma_service.dart` | Adicionar `ragContext` ao `sendMessage` |
| `lib/core/models/rag_document.dart` | **CRIAR** |
| `lib/core/services/rag/i_rag_service.dart` | **CRIAR** |
| `lib/core/services/rag/rag_service.dart` | **CRIAR** |
| `lib/core/services/rag/one_piece_knowledge_base.dart` | **CRIAR** |
| `lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart` | RAG integration |
| `lib/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart` | RAG lifecycle |
| `lib/app/di/core_module.dart` | Registrar IRAGService |

---

## Riscos

| Risco | Probabilidade | Mitigação |
|-------|--------------|-----------|
| Nomes de pacotes/classes incorretos | Média | Tarefa T1.1 é research-first — verificar pub.dev e README antes de codificar |
| `FlutterGemmaPlugin.instance.removeDocument()` não existe na API | Média | Alternativa: marcar docs de sessão com ID prefixado `sess-` e filtrar no search |
| RAG com modelo Qwen3 0.6B não melhora qualidade suficientemente | Baixa | Contexto injetado como texto puro não depende de fine-tuning — funciona com qualquer modelo |
| sqlite-vec causa aumento de tamanho do APK | Baixa | Incluído como plugin nativo; incremento esperado < 5MB |
| clearSession via filter API não suportada | Média | Rastrear IDs de sessão em memória (Set<String>) e deletar por ID |
