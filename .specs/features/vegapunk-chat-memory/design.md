# Design: Vegapunk Chat Memory

Pré-requisito de leitura: `context.md` (correções C1–C3, decisão aberta D1) e
`spec.md` (requisitos VGP-MEM-*). Este documento assume ambos.

---

## Restrições de API verificadas (bloqueantes para o desenho abaixo)

Verificado no código-fonte instalado antes de desenhar qualquer coisa —
"Verification Over Assumption":

1. **Hive `Box<T>` decodifica todos os valores no `openBox`; `LazyBox<T>`
   não.** `BoxImpl.getAt` lê de `keystore.getAt(index)!.value` — valor já em
   memória (`~/.pub-cache/hive-2.2.3/lib/src/box/box_impl.dart:54-58`).
   `LazyBoxImpl.getAt` chama `backend.readValue(frame)` por chave, sob
   demanda (`lazy_box_impl.dart:45-48`). **Consequência para VGP-MEM-06**
   ("mensagens antigas não devem ser processadas"): a box de histórico
   **precisa** ser aberta com `Hive.openLazyBox<ChatMessage>`, não
   `Hive.openBox`. Isso é um desvio deliberado da convenção do resto do
   projeto (toda box hoje usa `openBox` eager) — justificado especificamente
   por esse requisito, e documentado no código.
2. **`LazyBox`/`Box` compartilham `add`, `length`, `keyAt`** via `BoxBase<E>`
   (`box_base.dart:93,62,87`) — o mesmo código de "pega os últimos N por
   posição" funciona em ambos; só o tipo de retorno de `getAt` muda
   (`E?` sync vs `Future<E?>`).
3. **`FlutterGemmaPlugin.searchSimilar` devolve `RetrievalResult{id, content,
   similarity, metadata}`** (já verificado em sessão anterior) — o `id`
   sobrevive à busca, então filtrar por prefixo depois da busca é viável sem
   mudar a escrita.
4. **`Filter`/`FilterSchema` não estão configurados** em
   `FlutterGemma.initialize()` (`lib/main.dart:58-63`) — confirmação de C3.
   Filtro no nível do banco não é uma opção sem uma mudança global separada.
5. **`clearVectorStore()` não tem escopo** — não existe uma variante "limpa só
   os documentos de lore" ou "só os de sessão" na API pública do plugin. Todo
   clear é total. O desenho abaixo (seção "Reconstrução após clear") existe
   para que isso nunca seja um problema visível ao usuário.

---

## Fase 1 — Persistência de histórico

### Arquitetura

```
VegapunkChatScreen
      │ getIt<VegapunkChatCubit>()..initialize()
      ▼
VegapunkChatCubit ──────────────► IVegapunkChatHistoryRepository (novo)
      │  (constructor injection,         │
      │   nunca getIt interno)           ▼
      │                          VegapunkChatHistoryRepository (novo, Hive)
      │                                  │
      ▼                                  ▼
IVegapunkChatRepository          Hive LazyBox<ChatMessage>
(já existe, gemma+rag+tools)     'vegapunk_chat_history' (novo)
```

`IVegapunkChatHistoryRepository` é uma nova interface — não um `I*Service`,
porque **"owns a feature's collection shape"** (a tabela de mensagens do
Vegapunk chat) é exatamente o critério de `I*Repository` do CLAUDE.md, mesmo
tendo uma única fonte (Hive). Vive em
`lib/features/vegapunk_chat/data/repository/`, ao lado de
`i_vegapunk_chat_repository.dart` já existente.

### Contrato

```dart
// lib/features/vegapunk_chat/data/repository/i_vegapunk_chat_history_repository.dart
abstract class IVegapunkChatHistoryRepository {
  /// Últimas [limit] mensagens, em ordem cronológica (mais antiga primeiro).
  /// Mensagens além de [limit] nunca são lidas do disco (VGP-MEM-06).
  Future<List<ChatMessage>> recentMessages({int limit = 20});

  /// Persiste uma mensagem (append). Chamado uma vez por turno de usuário e
  /// uma vez por turno de assistente, após o texto final ser commitado —
  /// nunca durante o streaming (VGP-MEM-01, spec "Edge cases").
  Future<void> appendMessage(ChatMessage message);

  /// Apaga todo o histórico persistido (VGP-MEM-08, chamado por `reset()`).
  Future<void> clear();
}
```

### `ChatMessage`: campos novos + adapter

`ChatMessage` ganha `timestamp` (VGP-MEM-03) e `satelliteId` opcional
(VGP-MEM-04). O padrão do repositório é model + `TypeAdapter` escritos à mão
no mesmo arquivo (ver `theme_model.dart`, `nami_finances_model.dart`) — sem
`hive_generator` no projeto.

```dart
// lib/features/vegapunk_chat/data/models/chat_message.dart
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/storage/hive_type_ids.dart';

enum MessageRole { user, assistant }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.satelliteId,
  });

  final String id;
  final String text;
  final MessageRole role;

  /// Quando a mensagem foi criada. Necessário para ordenação determinística
  /// no load do histórico e para a política de retenção da Fase 2 (VGP-MEM-27).
  final DateTime timestamp;

  /// Nome do `VegapunkSatellite` ativo quando esta mensagem foi gerada (null
  /// para mensagens do usuário). Metadado de exibição — não particiona o
  /// histórico (ver context.md, C1).
  final String? satelliteId;

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  ChatMessage copyWith({String? text}) => ChatMessage(
    id: id,
    text: text ?? this.text,
    role: role,
    timestamp: timestamp,
    satelliteId: satelliteId,
  );

  @override
  List<Object?> get props => [id, text, role, timestamp, satelliteId];
}

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = HiveTypeIds.vegapunkChatMessage;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      id: fields[0] as String,
      text: fields[1] as String,
      role: fields[2] as MessageRole,
      timestamp: fields[3] as DateTime,
      satelliteId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.satelliteId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageRoleAdapter extends TypeAdapter<MessageRole> {
  @override
  final int typeId = HiveTypeIds.vegapunkMessageRole;

  @override
  MessageRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageRole.user;
      case 1:
        return MessageRole.assistant;
      default:
        return MessageRole.user;
    }
  }

  @override
  void write(BinaryWriter writer, MessageRole obj) {
    switch (obj) {
      case MessageRole.user:
        writer.writeByte(0);
        break;
      case MessageRole.assistant:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
```

`writer.write(obj.role)` funciona porque `MessageRoleAdapter` fica registrado
— o mesmo mecanismo já usado para `ExpenseCategory`/`ReservePurpose` dentro de
`NamiFinancesModel`.

### `HiveTypeIds`: novo bloco

```dart
// lib/core/storage/hive_type_ids.dart — adições
///   50–59  vegapunk_chat
static const int vegapunkChatMessage = 50;
static const int vegapunkMessageRole = 51;

// em HiveTypeIds.all, adicionar:
vegapunkChatMessage,
vegapunkMessageRole,
```

E atualizar o comentário do bloco de blocos (`0–9 core ... 50+ unassigned`)
para `50–59 vegapunk_chat`, `60+ unassigned`. `test/core/storage/
hive_type_ids_test.dart` já cobre duplicidade/órfãos/dynamic sem nenhuma
mudança — os testes existentes passam a validar os 2 novos ids automaticamente
uma vez que `HiveStorageService.adapters` os registre.

### `HiveStorageService`: registrar os 2 adapters

```dart
// lib/core/services/config/storage_service.dart — dentro de `adapters`:
_Registration<ChatMessage>(ChatMessageAdapter()),
_Registration<MessageRole>(MessageRoleAdapter()),
```

Seguindo o padrão `_Registration<T>` já existente (não `TypeAdapter<dynamic>`
— ver o comentário no próprio arquivo sobre por que isso já foi um bug real).

### `VegapunkChatHistoryRepository`: implementação

```dart
// lib/features/vegapunk_chat/data/repository/vegapunk_chat_history_repository.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/chat_message.dart';
import 'i_vegapunk_chat_history_repository.dart';

class VegapunkChatHistoryRepository implements IVegapunkChatHistoryRepository {
  static const String _boxName = 'vegapunk_chat_history';

  LazyBox<ChatMessage>? _box;

  /// Mesma estratégia de recuperação de `FeaturedCharacterRepository._initHive`:
  /// uma box corrompida cai para histórico vazio em vez de propagar exceção
  /// e quebrar a abertura da tela (spec, "Edge cases").
  Future<LazyBox<ChatMessage>> _openBox() async {
    final existing = _box;
    if (existing != null) return existing;

    try {
      _box = Hive.isBoxOpen(_boxName)
          ? Hive.lazyBox<ChatMessage>(_boxName)
          : await Hive.openLazyBox<ChatMessage>(_boxName);
    } catch (e) {
      debugPrint('VegapunkChatHistoryRepository: box corrupted, resetting: $e');
      if (Hive.isBoxOpen(_boxName)) {
        await Hive.box(_boxName).deleteFromDisk();
      } else {
        await Hive.deleteBoxFromDisk(_boxName);
      }
      _box = await Hive.openLazyBox<ChatMessage>(_boxName);
    }
    return _box!;
  }

  @override
  Future<List<ChatMessage>> recentMessages({int limit = 20}) async {
    final box = await _openBox();
    final total = box.length;
    if (total == 0) return const [];

    final start = total > limit ? total - limit : 0;
    // Lê só as posições pedidas — `LazyBox.getAt` decodifica sob demanda
    // (ver "Restrições de API verificadas", item 1). Mensagens antes de
    // `start` nunca são tocadas.
    final result = <ChatMessage>[];
    for (var i = start; i < total; i++) {
      final message = await box.getAt(i);
      if (message != null) result.add(message);
    }
    return result;
  }

  @override
  Future<void> appendMessage(ChatMessage message) async {
    final box = await _openBox();
    await box.add(message);
  }

  @override
  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }
}
```

`recentMessages` já devolve em ordem cronológica (índice crescente = inserção
crescente = mais antiga → mais recente), casando direto com o que
`vegapunk_chat_screen.dart` espera (`items = state.messages`, sem
`reverse: true`).

### `VegapunkChatCubit`: onde a leitura e a escrita entram

Duas mudanças pontuais, não uma reescrita:

1. **Construtor** ganha `required IVegapunkChatHistoryRepository
   historyRepository` (injeção por construtor — nenhuma chamada a `getIt`
   dentro do cubit, conforme a regra do CLAUDE.md já em vigor neste
   arquivo).

2. **`initialize()`** carrega o histórico e guarda num campo privado; a
   emissão de `VegapunkChatReady` — que hoje só acontece dentro de
   `_onModelStatus` quando `GemmaReady()` chega — passa a semear esse
   histórico em vez de começar vazio:

```dart
List<ChatMessage> _loadedHistory = const [];

Future<void> initialize({List<String>? targetCategories}) async {
  if (targetCategories != null) _targetCategories = targetCategories;

  // Carrega o histórico em paralelo com o load do modelo — não é bloqueado
  // por ele. Concluído tipicamente antes do modelo (é leitura local de ~20
  // registros), mas o código não assume isso.
  unawaited(_loadHistory());

  await _repository.initializeModel(isThinkingMode: _isThinkingMode);
  // ignore: unawaited_futures
  _initRag();
}

Future<void> _loadHistory() async {
  _loadedHistory = await _historyRepository.recentMessages();
}
```

E em `_onModelStatus`, o branch que hoje cria um `VegapunkChatReady` do zero:

```dart
// ANTES
} else {
  emit(VegapunkChatReady(isThinkingMode: _isThinkingMode));
}

// DEPOIS
} else {
  emit(VegapunkChatReady(
    messages: _loadedHistory,
    isThinkingMode: _isThinkingMode,
  ));
}
```

3. **Persistência incremental.** `_commitStreamingMessage()` (onde o turno do
   assistente é fechado) e o ponto em `sendMessage()` onde `userMsg` é
   adicionado ao estado ganham uma chamada `_historyRepository.appendMessage(...)`
   ao lado da atualização de estado — não em vez dela. Nenhuma mudança na
   forma como o estado em memória funciona hoje.

4. **`reset()`** ganha `await _historyRepository.clear();` ao lado do
   `_rag.clearSession()` já existente (VGP-MEM-08).

### DI

```dart
// lib/app/di/core_module.dart — junto às outras I*Repository (mesmo padrão
// de CrewRepository/CustomCharacterRepository já registrados aqui)
getIt.registerLazySingleton<IVegapunkChatHistoryRepository>(
  () => VegapunkChatHistoryRepository(),
);
```

```dart
// lib/app/di/features_module.dart — dentro do factory já existente de
// VegapunkChatCubit
getIt.registerFactory<VegapunkChatCubit>(
  () => VegapunkChatCubit(
    repository: getIt<IVegapunkChatRepository>(),
    ragService: getIt<IRAGService>(),
    historyRepository: getIt<IVegapunkChatHistoryRepository>(), // novo
  ),
);
```

### Sequência — abrir a tela

```
Screen.build() → getIt<VegapunkChatCubit>()..initialize()
                        │
                        ├─► _loadHistory() ──► historyRepo.recentMessages(20)
                        │                            │ (LazyBox, só as últimas 20)
                        │                            ▼
                        │                     _loadedHistory = [...]
                        │
                        └─► _repository.initializeModel() ──► GemmaLoading
                                                                    │
                                                              (alguns segundos)
                                                                    ▼
                                                               GemmaReady
                                                                    │
                                                                    ▼
                                          emit(VegapunkChatReady(messages: _loadedHistory))
```

Se o usuário conseguir enviar uma mensagem antes de `GemmaReady` chegar, o
`sendMessage()` já checa `if (state is! VegapunkChatReady) return;` — mesmo
guard que já existe hoje, sem mudança.

---

## Fase 2 — Memória semântica de longo prazo

### `IRAGService`: interface revisada

`search()` é **substituído** (não mantido como legado) por dois métodos com
escopo próprio — os únicos dois call sites de `search()` estão ambos em
`VegapunkChatRepository`, no mesmo arquivo; não há outro consumidor a
preservar.

```dart
// lib/core/services/rag/i_rag_service.dart
abstract class IRAGService {
  Future<void> initialize();
  Future<void> addDocument(RagDocument doc);
  Future<void> addDocumentBatch(List<RagDocument> docs);
  Future<void> clearSession();
  Future<void> setKnowledgeBase(List<RagDocument> docs);

  /// Busca só na base de lore (documentos sem o prefixo `sess:`).
  Future<List<String>> searchLore(String query, {int topK = 2, double threshold = 0.5});

  /// Busca só na memória de conversa (documentos com prefixo `sess:`).
  /// Lista vazia é um resultado válido — "nada relevante na conversa" — não
  /// um erro (VGP-MEM-24).
  Future<List<String>> searchSession(String query, {int topK = 2, double threshold = 0.5});
}
```

`RagDocument` não precisa de novo campo — o namespace vive inteiramente na
convenção de `id` (VGP-MEM-22), a mesma decisão já validada em
`NamiRagService`/`_expenseIdPrefix`.

### Por que `List<String>`, não algo mais rico (assimetria deliberada com o Nami)

`NamiRagService.findExpenses` devolve `ExpenseMatch` (id + similaridade)
porque o chamador (`FindExpensesHandler`) precisa do id para somar valores
exatos depois. Aqui, o único chamador (`VegapunkChatRepository`) só injeta o
texto recuperado num prompt — nunca precisa do id de volta. Manter
`List<String>` evita um contrato mais rico sem consumidor real.

### Namespace por prefixo — sem reescrever a KB

- Documentos de sessão passam a usar `'sess:${uuid.v4()}'` (dois-pontos, no
  lugar do `'sess-${uuid.v4()}'` atual — mudança de uma linha em
  `VegapunkChatCubit._addSessionDocument`).
- Documentos da KB (`OnePieceKnowledgeBase`, 36 ids literais como
  `'vgp-001-pt'`) **não são reescritos**. `searchLore` filtra por **exclusão**
  (`!id.startsWith('sess:')`), não por um prefixo `kb:` positivo — qualquer
  documento que não seja de sessão é, por definição, lore, no estado atual do
  sistema (só existem essas duas categorias de documento hoje). Se uma
  terceira categoria aparecer no futuro, este filtro por exclusão precisa
  virar um filtro positivo por prefixo `kb:` nesse momento — registrado aqui
  para não ser esquecido.

### Implementação: over-fetch antes de filtrar

Pedir `topK: 2` diretamente ao plugin e filtrar depois pode devolver **zero**
resultados mesmo havendo 3 documentos de sessão relevantes fora do top-2 geral
(lore pode dominar o ranking bruto). Mesmo problema e mesma solução já
aplicada em `NamiRagService.findExpenses` — pedir mais, filtrar, cortar:

```dart
// lib/core/services/rag/rag_service.dart
static const int _overFetchFactor = 4;

@override
Future<List<String>> searchLore(String query, {int topK = 2, double threshold = 0.5}) =>
    _scopedSearch(query, topK: topK, threshold: threshold, isSession: false);

@override
Future<List<String>> searchSession(String query, {int topK = 2, double threshold = 0.5}) =>
    _scopedSearch(query, topK: topK, threshold: threshold, isSession: true);

Future<List<String>> _scopedSearch(
  String query, {
  required int topK,
  required double threshold,
  required bool isSession,
}) async {
  if (query.trim().isEmpty || !await _ensureActiveStore()) return const [];

  try {
    final raw = await FlutterGemmaPlugin.instance.searchSimilar(
      query: query,
      topK: topK * _overFetchFactor,
      threshold: threshold,
    );
    // Filtra pelo namespace do próprio serviço e corta em topK. Sem
    // dependência de NamiRagService — cada serviço filtra pelo seu prefixo,
    // sem acoplamento entre features.
    return raw
        .where((r) => r.id.startsWith('sess:') == isSession)
        .take(topK)
        .map((r) => r.content)
        .toList();
  } catch (e) {
    debugPrint('RAGService: scoped search error: $e');
    return const [];
  }
}
```

### `setKnowledgeBase`: idempotência por fingerprint do conjunto de ids

Mesma estrutura de `NamiRagService` (meta box Hive + comparação antes de
agir), mas o fingerprint aqui é sobre **o conjunto de ids recebido**, não uma
versão de código — `RAGService` não precisa saber o que é "categoria", só
precisa saber se a lista de documentos pedida é a mesma de antes:

```dart
// lib/core/services/rag/rag_service.dart
static const String _metaBoxName = 'vegapunk_rag_index_meta';
static const String _kbFingerprintKey = 'kb_fingerprint';

Box<dynamic>? _metaBox;
Future<Box<dynamic>> _meta() async => _metaBox ??= await Hive.openBox<dynamic>(_metaBoxName);

String _fingerprint(List<RagDocument> docs) {
  final ids = docs.map((d) => d.id).toList()..sort();
  return ids.join('|');
}

@override
Future<void> setKnowledgeBase(List<RagDocument> docs) async {
  if (!await _ensureActiveStore()) return;

  final meta = await _meta();
  final fingerprint = _fingerprint(docs);
  if (meta.get(_kbFingerprintKey) == fingerprint) {
    debugPrint('RAGService: KB unchanged, skipping clear+reload');
    return; // VGP-MEM-21 — no-op, documentos de sessão preservados
  }

  debugPrint('RAGService: KB fingerprint changed, reloading…');
  await FlutterGemmaPlugin.instance.clearVectorStore(); // limpa TUDO (item 5, restrições)
  _knowledgeBaseDocs = [];
  _sessionDocCount = 0;
  if (docs.isNotEmpty) await addDocumentBatch(docs);
  await meta.put(_kbFingerprintKey, fingerprint);

  // clearVectorStore() não tem escopo (restrição #5) — qualquer clear apaga
  // sessão também. Em vez de tentar evitar isso, sempre reconstruímos a
  // sessão a partir do histórico persistido depois de qualquer clear. Ver
  // "Reconstrução após clear" abaixo — mesma rotina usada no cold start.
  await _onKnowledgeBaseReloaded?.call();
}
```

`_onKnowledgeBaseReloaded` é um callback opcional, setado pela camada de
feature (ver próxima seção) — `RAGService` dispara o hook sem saber o que ele
faz, preservando VGP-MEM-26 (core não importa tipos de `features/`).

### Reconstrução após clear — unifica VGP-MEM-20, 21 e 25

Em vez de tentar impedir que um clear apague a sessão (a API não permite:
restrição #5), a sessão é sempre **reconstruível**: uma rotina na camada de
feature lê o histórico persistido (Fase 1) e reindexa como documentos `sess:`.
Isso cobre três gatilhos com o mesmo código:

1. Cold start do app (índice em memória do plugin está vazio de qualquer
   forma — todo processo novo começa com vector store vazio até popular).
2. Fingerprint da KB mudou → `clearVectorStore()` disparado por
   `setKnowledgeBase`.
3. Falha recuperada de `clearSession`/erro do plugin (caso raro).

```dart
// lib/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart
Future<void> _reindexSessionFromHistory() async {
  final history = await _historyRepository.recentMessages(
    limit: /* teto de retenção — ver spec VGP-MEM-27, D1 em context.md */,
  );
  if (history.isEmpty) return;

  // Agrupa em pares usuário→assistente, mesmo formato de conteúdo que
  // `_addSessionDocument` já grava hoje por turno.
  final docs = _pairsToRagDocuments(history);
  await _rag.addDocumentBatch(docs);
}
```

Chamado uma vez em `initialize()` (após `_initRag`/`setKnowledgeBase`
resolverem) e passado como o callback `_onKnowledgeBaseReloaded` para o
`RAGService` no momento da injeção — por isso o callback existe: sem ele,
`RAGService` teria que importar `ChatMessage`/`IVegapunkChatHistoryRepository`
para reconstruir sozinho, violando VGP-MEM-26.

`_pairsToRagDocuments` é exatamente o ponto que a decisão D1 (context.md)
determina: quantos pares, de que forma (resumidos ou verbatim), com que
critério de corte. **Esta função é intencionalmente deixada como stub aqui**
— ver `tasks.md`, T24.

### Sequência — pergunta do usuário com as duas buscas

```
sendMessage(text)
      │
      ├─► searchLore(text, topK: 2)      ──► ["doc lore A", "doc lore B"]
      ├─► searchSession(text, topK: 2)   ──► [] ou ["troca anterior relevante"]
      │
      ▼
ragContext = [...loreResults, ...sessionResults]   // vazio de sessão é válido
      │
      ▼
Gemma.sendMessage(text, ragContext: ragContext)
```

`VegapunkChatRepository` troca as duas chamadas atuais (linhas 108 e 125,
ambas `_rag.search(text, topK: 2)`) por essa dupla busca, nos dois pontos do
método onde hoje existe uma chamada.

---

## Arquivos afetados (resumo)

| Arquivo | Mudança |
|---|---|
| `lib/core/storage/hive_type_ids.dart` | + bloco 50–59 |
| `lib/core/services/config/storage_service.dart` | + 2 `_Registration<T>` |
| `lib/features/vegapunk_chat/data/models/chat_message.dart` | + `timestamp`, `satelliteId`, + 2 adapters |
| `lib/features/vegapunk_chat/data/repository/i_vegapunk_chat_history_repository.dart` | **novo** |
| `lib/features/vegapunk_chat/data/repository/vegapunk_chat_history_repository.dart` | **novo** |
| `lib/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart` | + histórico no construtor, `initialize()`, `_commitStreamingMessage`, `sendMessage`, `reset()`, `_reindexSessionFromHistory` |
| `lib/app/di/core_module.dart` | + registro de `IVegapunkChatHistoryRepository` |
| `lib/app/di/features_module.dart` | `VegapunkChatCubit` factory ganha `historyRepository` |
| `lib/core/services/rag/i_rag_service.dart` | `search` → `searchLore`/`searchSession` |
| `lib/core/services/rag/rag_service.dart` | fingerprint idempotente, over-fetch+filtro, hook `_onKnowledgeBaseReloaded` |
| `lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart` | 2 call sites de `_rag.search` → `searchLore`+`searchSession` |

Nenhuma mudança em `NamiRagService`/`INamiRagService` — namespace e
idempotência são conceitos por-serviço, não compartilhados via
`RagStoreCoordinator` (que só decide qual arquivo SQLite está ativo).

---

## Alternativas consideradas e descartadas

| Alternativa | Por que não |
|---|---|
| `Filter`/`FilterSchema` do flutter_gemma para separar lore/sessão no banco | Exigiria `filterSchema` global em `main.dart`, afetando o store do Nami também — mudança cross-feature fora de escopo (context.md, C3) |
| Uma Hive box por satélite/persona | Não existe "uma conversa por satélite" no app — é uma conversa com persona trocável (context.md, C1) |
| Reescrever os 36 ids da KB com prefixo `kb:` | Filtro por exclusão (`!startsWith('sess:')`) resolve sem tocar em conteúdo estável já em produção |
| `RAGService` lendo o Hive de histórico diretamente para reconstruir a sessão | Violaria a regra de `core/services/` não depender de tipos de `features/` (VGP-MEM-26) — resolvido via callback injetado pela feature |
| Manter `search()` como método legado ao lado dos dois novos | Zero consumidores restantes depois da migração dos 2 call sites — manter seria código morto, não compatibilidade |

---

## Riscos residuais (aceitos, não bloqueantes)

- **Mudança de `targetCategories` em produção ainda limpa a sessão uma vez.**
  Aceito porque essa via não é usada pela UI hoje (rota sempre constrói
  `VegapunkChatScreen()` sem argumentos) — e mesmo quando usada, a
  reconstrução a partir do Hive (VGP-MEM-25) devolve a sessão no próximo
  turno, não a perde permanentemente.
- **`LazyBox` é um padrão novo no projeto.** Só usado aqui, com justificativa
  específica (VGP-MEM-06). Não propor generalizar para outras boxes sem o
  mesmo requisito de "não processar histórico antigo".
