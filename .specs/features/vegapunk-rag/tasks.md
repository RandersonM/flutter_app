# Tasks: Vegapunk RAG

**Feature:** VGP-RAG  
**Status:** Planned  

---

## Fase 0 — Quick Fix: Brevidade (sem RAG, impacto imediato)

### T0 — Corrigir system prompt e maxTokens
**Goal:** Reduzir verbosidade do modelo sem nenhuma dependência nova  
**Files:**
- `lib/core/services/gemma/gemma_service.dart`

**Mudanças:**
1. `maxTokens` em modo normal: `1024` → `400`
2. `_promptEn`: substituir "no longer than a few paragraphs" por instrução quantificada:
   ```
   BREVITY RULES:
   - Yes/no or "do you know X" questions: 1–2 sentences MAX.
   - Explanations: max 80 words unless the user explicitly asks for more.
   - Never repeat the question. No preamble. Go straight to the answer.
   - For One Piece lore: use only facts you are certain about. If uncertain, say so briefly.
   ```
3. `_promptPt`: instrução equivalente em português:
   ```
   REGRAS DE BREVIDADE:
   - Perguntas de sim/não ou "você conhece X": máximo 1–2 frases.
   - Explicações: máximo 80 palavras, a menos que mais detalhes sejam pedidos.
   - Não repita a pergunta. Sem introdução. Vá direto ao ponto.
   - Para lore de One Piece: use apenas fatos que você tem certeza. Se incerto, diga brevemente.
   ```

**Requires:** VGP-RAG-01, VGP-RAG-02, VGP-RAG-03  
**Depends on:** —  
**Done when:**
- Pergunta "você conhece o Sanji?" gera resposta ≤ 80 palavras
- Pergunta "Luffy é capitão dos Chapéu de Palha?" gera 1–2 frases

---

## Fase 1 — Infraestrutura RAG

### T1.1 — Research: verificar nomes exatos dos pacotes
**Goal:** Confirmar nomes e versões corretos dos pacotes de embeddings e RAG no pub.dev antes de editar qualquer código  
**Files:** nenhum (research task)

**Verificar em pub.dev:**
- `flutter_gemma_embeddings` — existe? Versão atual?
- `flutter_gemma_rag_sqlite` — existe? Versão atual?
- Alternativa: pode estar dentro do pacote `flutter_gemma` como extensão

**Verificar no README/changelog do flutter_gemma:**
- Como é o `FlutterGemma.initialize()` com embeddings + vector store?
- Nomes exatos das classes: `GemmaEmbeddings`? `SqliteVec`? `SqliteVecVectorStore`?
- `FlutterGemmaPlugin.instance.addDocument()` — assinatura correta?
- `FlutterGemmaPlugin.instance.searchSimilar()` — retorna o quê? Tem `removeDocument`?

**Done when:** Documento de achados escrito como comentário em `rag_service.dart` na T2.1

---

### T1.2 — Adicionar pacotes ao pubspec.yaml
**Goal:** Instalar dependências RAG verificadas na T1.1  
**Files:**
- `pubspec.yaml`

**Mudança:** Adicionar as 2 dependências (nomes exatos da T1.1) e rodar `flutter pub get`

**Requires:** VGP-RAG-05, VGP-RAG-06  
**Depends on:** T1.1  
**Done when:** `flutter pub get` sem erros

---

### T1.3 — Atualizar FlutterGemma.initialize() no main.dart
**Goal:** Incluir backend de embeddings e vector store na inicialização do plugin  
**Files:**
- `lib/main.dart`

**Mudança:** Adicionar `embeddingBackends` e `vectorStore` ao `FlutterGemma.initialize()` existente (nomes das classes verificados na T1.1)

**Requires:** VGP-RAG-07  
**Depends on:** T1.1, T1.2  
**Done when:** App inicializa sem erro; plugin de embeddings disponível

---

## Fase 2 — RAG Service

### T2.1 — Criar RagDocument model
**Goal:** Estrutura de dados para documentos do vector store  
**Files:**
- `lib/core/models/rag_document.dart` (**CRIAR**)

**Estrutura:**
```dart
class RagDocument {
  final String id;
  final String content;
  final String category;  // 'character', 'devil_fruit', 'arc', 'vegapunk', 'session'
  final String language;  // 'en', 'pt', 'both'
  final String topic;
  final bool isSession;
}
```

**Requires:** VGP-RAG-10  
**Depends on:** —  
**Done when:** Classe compila, `metadataJson` retorna JSON válido

---

### T2.2 — Criar IRAGService e RAGService
**Goal:** Camada de abstração + implementação do vector store  
**Files:**
- `lib/core/services/rag/i_rag_service.dart` (**CRIAR**)
- `lib/core/services/rag/rag_service.dart` (**CRIAR**)

**Interface:**
```dart
abstract class IRAGService {
  Future<void> initialize();
  Future<void> addDocument(RagDocument doc);
  Future<void> addDocumentBatch(List<RagDocument> docs);
  Future<List<String>> search(String query, {int topK = 3});
  Future<void> clearSession();
}
```

**Implementação:**
- Usa `FlutterGemmaPlugin.instance.addDocument()` e `.searchSimilar()`
- `clearSession()`: rastreia IDs de sessão em `Set<String> _sessionIds` e remove por ID (não depende de filter API)
- Trata erros com `debugPrint` e retorna `[]` em falha de search (degradação graciosa)

**Requires:** VGP-RAG-08, VGP-RAG-09, VGP-RAG-11, VGP-RAG-12  
**Depends on:** T1.1, T1.3, T2.1  
**Done when:** `addDocument` e `search` funcionam com documentos de teste; `clearSession` não remove docs permanentes

---

### T2.3 — Criar OnePieceKnowledgeBase
**Goal:** Seed documents com fatos verificados de One Piece  
**Files:**
- `lib/core/services/rag/one_piece_knowledge_base.dart` (**CRIAR**)

**Categorias e documentos mínimos (PT + EN para cada):**

| Categoria | Docs PT | Docs EN |
|-----------|---------|---------|
| vegapunk | Vegapunk + 6 satélites | Vegapunk + 6 satellites |
| character | Luffy, Zoro, Nami, Usopp, Sanji, Chopper, Robin, Franky, Brook | idem |
| devil_fruit | Gomu Gomu, Mera Mera, Hie Hie, Yami Yami, Gura Gura | idem |
| arc | Marineford, Dressrosa, Whole Cake Island, Wano, Egghead | idem |

**Restrição:** Apenas fatos do manga/anime canônico — sem especulação ou fillers.

**Requires:** VGP-RAG-13, VGP-RAG-14  
**Depends on:** T2.1  
**Done when:** `OnePieceKnowledgeBase.documents` tem ≥ 30 documentos; todos compilam

---

### T2.4 — Registrar IRAGService no DI
**Goal:** Tornar RAGService injetável via GetIt  
**Files:**
- `lib/app/di/core_module.dart`

**Mudança:**
```dart
getIt.registerLazySingleton<IRAGService>(() => RAGService());
```

**Depends on:** T2.2  
**Done when:** `getIt<IRAGService>()` funciona sem erro

---

## Fase 3 — Integração

### T3.1 — Atualizar IGemmaService e GemmaService
**Goal:** Injetar RAG context no prompt antes de cada geração  
**Files:**
- `lib/core/services/gemma/i_gemma_service.dart`
- `lib/core/services/gemma/gemma_service.dart`

**Mudanças em `i_gemma_service.dart`:**
```dart
Stream<String> sendMessage(
  String text, {
  String? styleInstruction,
  List<String>? ragContext,   // NOVO — opcional
});
```

**Mudanças em `gemma_service.dart`:**
```dart
// sendMessage():
final contextBlock = ragContext?.isNotEmpty == true
    ? '[CONTEXT]\n${ragContext!.map((c) => '• $c').join('\n')}\n\n'
    : '';

final promptText = styleInstruction != null && styleInstruction.isNotEmpty
    ? '[Style Instruction: $styleInstruction]\n\n$contextBlock$text'
    : '$contextBlock$text';
```

**Requires:** VGP-RAG-16, VGP-RAG-17  
**Depends on:** T2.2  
**Done when:** `sendMessage` com `ragContext: ['fato 1']` inclui o fato no prompt (verificável via debugPrint)

---

### T3.2 — Atualizar VegapunkChatRepository
**Goal:** Orquestrar busca RAG antes de cada geração  
**Files:**
- `lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart`

**Mudanças:**
1. Injetar `IRAGService` via `getIt<IRAGService>()`
2. Em `sendMessage()`:
   ```dart
   final ragContext = await _ragService.search(text, topK: 3);
   return _gemmaService.sendMessage(text, 
     styleInstruction: styleInstruction, 
     ragContext: ragContext,
   );
   ```

**Requires:** VGP-RAG-18  
**Depends on:** T2.4, T3.1  
**Done when:** Debug log mostra contexto RAG antes de cada geração

---

### T3.3 — Atualizar VegapunkChatCubit
**Goal:** Gerenciar ciclo de vida RAG e memória conversacional  
**Files:**
- `lib/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart`

**Mudanças:**
1. Injetar `IRAGService` via `getIt<IRAGService>()`
2. Em `initialize()`: após `repository.initializeModel()`, chamar:
   ```dart
   await _ragService.initialize();
   await _ragService.addDocumentBatch(OnePieceKnowledgeBase.documents);
   ```
3. Após cada resposta completa (stream done), adicionar doc de sessão:
   ```dart
   await _ragService.addDocument(RagDocument(
     id: 'sess-${const Uuid().v4()}',
     content: 'User asked: $userText. Answer: $fullResponse',
     category: 'session', language: 'both', topic: 'session',
     isSession: true,
   ));
   ```
4. Em `reset()`: chamar `_ragService.clearSession()` antes de recarregar modelo

**Requires:** VGP-RAG-15, VGP-RAG-19, VGP-RAG-20  
**Depends on:** T2.3, T2.4, T3.2  
**Done when:**
- Knowledge base carregada na inicialização (log: "RAG: X docs carregados")
- Doc de sessão adicionado após cada exchange
- `reset()` limpa sessão mas mantém knowledge base

---

## Resumo de Dependências

```
T0  ──────────────────────────────────── (independente, roda primeiro)

T1.1 (research)
  └─► T1.2 (pubspec)
        └─► T1.3 (main.dart init)

T2.1 (RagDocument)
  └─► T2.2 (RAGService) ◄── T1.1, T1.3
        └─► T2.3 (KnowledgeBase)
        └─► T2.4 (DI)
              └─► T3.2 (Repository) ◄── T3.1 (GemmaService)
                    └─► T3.3 (Cubit) ◄── T2.3, T2.4
```

---

## Ordem de Execução Recomendada

1. **T0** — Roda agora, melhoria imediata sem dependências
2. **T1.1** — Research (10–15 min, verificar pub.dev + README)
3. **T1.2 → T1.3** — Pacotes + init
4. **T2.1 → T2.4** — Infraestrutura RAG
5. **T3.1 → T3.3** — Integração final

**Estimativa total:** 4–6h de implementação após T1.1 (research pode variar)

---

## Commit Scope Sugerido

```
fix(gemma): tighten system prompt brevity constraints and reduce maxTokens (T0)
feat(rag): add RagDocument model and IRAGService interface (T2.1-T2.2)
feat(rag): implement OnePieceKnowledgeBase seed documents (T2.3)
feat(rag): integrate RAG context injection into GemmaService (T3.1)
feat(vegapunk): wire RAG pipeline into chat repository and cubit (T3.2-T3.3)
```
