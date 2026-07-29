# Tasks: Vegapunk Chat Memory

**Feature:** VGP-MEM
**Status:** Planned
**Pré-requisito:** ler `context.md` e `design.md` antes de executar qualquer
tarefa — em especial a decisão pendente D1, que bloqueia T24.

---

## Fase 1 — Persistência de histórico

### T1 — Reivindicar o bloco de typeId e estender `ChatMessage`
**Goal:** Adicionar `timestamp`/`satelliteId` ao model e os 2 adapters
(`ChatMessageAdapter`, `MessageRoleAdapter`), registrados em `HiveTypeIds`.
**Files:**
- `lib/core/storage/hive_type_ids.dart`
- `lib/features/vegapunk_chat/data/models/chat_message.dart`

**Reuse Targets:** padrão de model+adapter de `theme_model.dart` (model
simples) e `nami_finances_model.dart` (enum adapter, campo `DateTime`).
**Depends on:** —
**Requirement:** VGP-MEM-03, VGP-MEM-04, VGP-MEM-09
**Done when:**
- `HiveTypeIds.vegapunkChatMessage = 50`, `HiveTypeIds.vegapunkMessageRole = 51`,
  ambos em `HiveTypeIds.all`.
- Comentário de blocos atualizado (`50–59 vegapunk_chat`, `60+ unassigned`).
- `ChatMessage` compila com os 2 campos novos; construtores existentes que
  criam `ChatMessage(...)` no cubit são atualizados para passar `timestamp`
  (ver T4) — se isso quebrar antes de T4, é esperado; commit T1+T4 juntos se
  preferir um único commit.
- `flutter analyze` sem novos erros nos 2 arquivos.

**Commit Scope:** `feat(vegapunk-chat): add timestamp/satellite fields and Hive adapters to ChatMessage`

---

### T2 — Registrar os adapters em `HiveStorageService`
**Goal:** Os 2 novos adapters entram no loop de registro central.
**Files:**
- `lib/core/services/config/storage_service.dart`

**Depends on:** T1
**Requirement:** VGP-MEM-09
**Done when:**
- `HiveStorageService.adapters` inclui `_Registration<ChatMessage>(ChatMessageAdapter())`
  e `_Registration<MessageRole>(MessageRoleAdapter())`.
- `flutter test test/core/storage/hive_type_ids_test.dart` passa sem
  modificação no arquivo de teste (ele já cobre qualquer adapter novo
  automaticamente).

**Commit Scope:** mesmo commit de T1, ou um commit próprio
`chore(hive): register ChatMessage adapters`

---

### T3 — `IVegapunkChatHistoryRepository` + implementação Hive
**Goal:** Repositório com `recentMessages`, `appendMessage`, `clear`, usando
`LazyBox<ChatMessage>` (não `Box` — ver design.md, restrição #1).
**Files:**
- `lib/features/vegapunk_chat/data/repository/i_vegapunk_chat_history_repository.dart` (novo)
- `lib/features/vegapunk_chat/data/repository/vegapunk_chat_history_repository.dart` (novo)

**Reuse Targets:** estratégia de recuperação de box corrompida de
`FeaturedCharacterRepository._initHive`.
**Depends on:** T2
**Requirement:** VGP-MEM-01, VGP-MEM-02, VGP-MEM-05, VGP-MEM-06, VGP-MEM-07, VGP-MEM-08
**Done when:**
- `recentMessages(limit: 20)` com uma box de 200 mensagens só chama
  `box.getAt` 20 vezes (verificável via teste com um fake/spy de contagem —
  ver T5).
- `recentMessages` devolve em ordem cronológica crescente.
- `appendMessage` não reescreve a box inteira (`box.add`, não `box.putAll`).
- Box corrompida → `recentMessages` devolve `[]` em vez de lançar.

**Commit Scope:** `feat(vegapunk-chat): add Hive-backed chat history repository`

---

### T4 — Fiar o histórico no `VegapunkChatCubit`
**Goal:** Construtor recebe o repositório; `initialize()` carrega histórico;
`GemmaReady` semeia `VegapunkChatReady` com ele; envio/commit de mensagem
persiste; `reset()` limpa o histórico.
**Files:**
- `lib/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart`

**Depends on:** T3
**Requirement:** VGP-MEM-05, VGP-MEM-07, VGP-MEM-08, VGP-MEM-10
**Done when:**
- Construtor: `required IVegapunkChatHistoryRepository historyRepository` —
  nenhuma chamada a `getIt` dentro da classe (grep `getIt<` no arquivo deve
  continuar vazio, como já é hoje).
- `initialize()` dispara `_loadHistory()` sem bloquear
  `_repository.initializeModel(...)`.
- Branch `GemmaReady()` em `_onModelStatus` usa `_loadedHistory` no lugar de
  `VegapunkChatReady()` vazio, só quando **não** havia estado `Ready` anterior
  (preservar o comportamento já existente de "preserve messages if already
  ready" — não regredir esse caso).
- Mensagem de usuário (em `sendMessage`) e mensagem de assistente (em
  `_commitStreamingMessage`) chamam `_historyRepository.appendMessage(...)`
  com o texto final — nunca com `streamingToken` parcial.
- `reset()` chama `_historyRepository.clear()` além do já existente
  `_rag.clearSession()`.

**Commit Scope:** `feat(vegapunk-chat): load and persist chat history in VegapunkChatCubit`

---

### T5 — DI: registrar o repositório e atualizar o factory do cubit
**Goal:** `IVegapunkChatHistoryRepository` resolvível via `getIt`;
`VegapunkChatCubit` factory passa a nova dependência.
**Files:**
- `lib/app/di/core_module.dart`
- `lib/app/di/features_module.dart`

**Depends on:** T3, T4
**Requirement:** VGP-MEM-10
**Done when:**
- `getIt<IVegapunkChatHistoryRepository>()` resolve sem erro (checagem
  manual ou teste de smoke do container — ver o padrão de verificação
  cruzada `getIt<T>` vs. `register*<T>` já usado nesta sessão para achar
  bugs de DI silenciosos).
- `flutter analyze` sem erro em ambos os arquivos.

**Commit Scope:** `chore(di): wire IVegapunkChatHistoryRepository`

---

### T6 — Testes: repositório de histórico
**Goal:** Cobrir o contrato de `IVegapunkChatHistoryRepository` sem depender
do plugin flutter_gemma nem de mockito codegen (padrão já usado em
`test/features/nami_finances/find_expenses_handler_test.dart`).
**Files:**
- `test/features/vegapunk_chat/data/vegapunk_chat_history_repository_test.dart` (novo)

**Depends on:** T3
**Requirement:** VGP-MEM-01, VGP-MEM-05, VGP-MEM-06, VGP-MEM-07, VGP-MEM-08
**Done when:**
- **Verificado: não há precedente de teste com Hive real neste projeto** —
  nenhum uso de `Hive.init`/`hive_test` em `test/`, e `hive_test` não está no
  `pubspec.yaml`. Este é o primeiro; documentar a técnica escolhida em
  comentário no topo do arquivo de teste para servir de precedente aos
  próximos. Caminho recomendado (verificar no README do pacote `hive` antes
  de finalizar, não assumir): `Hive.init(tempDir.path)` — **não**
  `Hive.initFlutter()`, que depende de `path_provider`/channels de platform
  indisponíveis em `flutter_test` puro — seguido de
  `Hive.registerAdapter(ChatMessageAdapter())` e
  `Hive.registerAdapter(MessageRoleAdapter())` direto no `setUp`, sem passar
  por `HiveStorageService.initialize()` inteiro. `tearDown` remove o
  diretório temporário.
- Cobrir:
  - `recentMessages` respeita `limit` e ordem cronológica.
  - Persistência sobrevive a "reabrir" a box (fechar e reabrir a mesma
    instância `Hive`, mesmo diretório temporário).
  - `clear()` esvazia e `recentMessages` volta a `[]`.
  - Com N > limit mensagens, `recentMessages(limit: k)` devolve exatamente
    as `k` mais recentes, na ordem certa — verificação funcional direta (não
    é preciso instrumentar contagem de leitura; o teste de que `getAt` é
    lazy já está coberto por design.md via análise do código-fonte do
    pacote `hive`, não precisa ser reprovado aqui).
- `flutter test test/features/vegapunk_chat/data/vegapunk_chat_history_repository_test.dart`
  passa.

**Commit Scope:** `test(vegapunk-chat): cover chat history repository contract`

---

### T7 — Testes: cubit carrega e persiste histórico
**Goal:** `VegapunkChatCubit` com um fake `IVegapunkChatHistoryRepository`
comprova que `initialize()` popula `messages` e que enviar/commitar persiste.
**Files:**
- `test/features/vegapunk_chat/cubit/vegapunk_chat_cubit_history_test.dart` (novo)

**Reuse Targets:** fakes escritos à mão, mesmo estilo de
`test/features/nami_finances/find_expenses_handler_test.dart`.
**Depends on:** T4
**Requirement:** VGP-MEM-05, VGP-MEM-07, VGP-MEM-08
**Done when:**
- Fake repository pré-populado → após `initialize()` + status `GemmaReady`
  simulado, `state.messages` contém o histórico do fake, na ordem certa.
- Enviar uma mensagem → fake repository recebe `appendMessage` com o texto
  do usuário.
- `reset()` → fake repository recebe `clear()`.

**Commit Scope:** `test(vegapunk-chat): cover cubit history load/persist`

---

## Marco Fase 1

**Entregável:** histórico de chat sobrevive a reabrir a tela e a reiniciar o
app; últimas 20 mensagens aparecem na ordem certa; mensagens antigas nunca são
lidas. Fase 2 não começa até T1–T7 estarem mescladas e `flutter analyze` +
`flutter test` limpos.

---

## Fase 2 — Memória semântica de longo prazo

### T20 — `IRAGService`: `search` → `searchLore`/`searchSession`
**Goal:** Trocar a interface; nenhuma implementação ainda (só o contrato).
**Files:**
- `lib/core/services/rag/i_rag_service.dart`

**Depends on:** — (independente da Fase 1; pode rodar em paralelo com T1–T7
se preferir, mas T25 depende de T4 estar mesclada)
**Requirement:** VGP-MEM-22, VGP-MEM-23
**Done when:**
- `search()` removido; `searchLore`/`searchSession` adicionados com
  `topK`/`threshold` default conforme design.md.
- `RAGService` (implementação) ainda não compila — esperado, T21 resolve.

**Commit Scope:** pode ir junto com T21 num único commit (interface +
implementação), já que um sem o outro deixa o build quebrado.

---

### T21 — `RAGService`: fingerprint idempotente + busca com escopo
**Goal:** Implementar `searchLore`/`searchSession` (over-fetch + filtro por
prefixo) e tornar `setKnowledgeBase` idempotente via fingerprint em Hive.
**Files:**
- `lib/core/services/rag/rag_service.dart`

**Reuse Targets:** padrão de meta box + fingerprint de
`NamiRagService`/`_schemaVersion`.
**Depends on:** T20
**Requirement:** VGP-MEM-20, VGP-MEM-21, VGP-MEM-23, VGP-MEM-24
**Done when:**
- Chamar `setKnowledgeBase` duas vezes com a mesma lista de docs → segunda
  chamada não invoca `clearVectorStore` (verificável com um fake/spy do
  plugin — ver T23 para a estratégia de teste, já que `FlutterGemmaPlugin`
  não é mockável diretamente sem um wrapper; se necessário, extrair um ponto
  de indireção mínimo só para isso).
- Chamar com lista diferente → invoca `clearVectorStore` e grava o novo
  fingerprint.
- `searchSession`/`searchLore` filtram corretamente por prefixo `sess:` e
  respeitam `threshold` (nenhum resultado abaixo dele é devolvido).
- `RAGService` expõe o hook `_onKnowledgeBaseReloaded` (setter público ou
  parâmetro de construtor — decidir na implementação; construtor é preferível
  por não deixar o serviço em estado parcialmente configurado) chamado
  sempre que `clearVectorStore` roda dentro de `setKnowledgeBase`.

**Commit Scope:** `feat(rag): make setKnowledgeBase idempotent and split lore/session search`

---

### T22 — `VegapunkChatCubit`/`VegapunkChatRepository`: usar as buscas com escopo
**Goal:** Os 2 call sites de `_rag.search(text, topK: 2)` em
`VegapunkChatRepository` chamam `searchLore` + `searchSession` e combinam o
resultado; ids de sessão passam a usar prefixo `sess:`.
**Files:**
- `lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart`
- `lib/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart` (`_addSessionDocument`)

**Depends on:** T21
**Requirement:** VGP-MEM-22, VGP-MEM-23, VGP-MEM-24
**Done when:**
- `_addSessionDocument` gera `id: 'sess:${_uuid.v4()}'` (dois-pontos).
- Os 2 pontos em `vegapunk_chat_repository.dart` combinam
  `searchLore(...)` + `searchSession(...)` no `ragContext` enviado ao Gemma.
- Uma pergunta sem nenhum contexto de sessão relevante não injeta documentos
  de sessão de baixa relevância (comportamento coberto em T23).

**Commit Scope:** `feat(vegapunk-chat): scope RAG search to lore vs session namespaces`

---

### T23 — Testes: `RAGService` fingerprint + busca com escopo
**Goal:** Cobrir T21/T22 sem o plugin real.
**Files:**
- `test/core/services/rag/rag_service_test.dart` (novo)

**Reuse Targets:** fakes escritos à mão; se `FlutterGemmaPlugin.instance` não
for injetável/mockável diretamente, este teste pode precisar de um pequeno
wrapper de indireção em `RAGService` (`@visibleForTesting` ou uma interface
interna) — decisão de implementação a resolver na execução, documentando o
porquê se um wrapper for necessário.
**Depends on:** T21
**Requirement:** VGP-MEM-20, VGP-MEM-21, VGP-MEM-24
**Done when:**
- Fingerprint idêntico → sem clear. Fingerprint diferente → clear + novo
  fingerprint gravado.
- `searchSession` com tudo abaixo do threshold → `[]`, não os N menos-ruins.

**Commit Scope:** `test(rag): cover setKnowledgeBase idempotency and scoped search`

---

### T24 — 🚧 GATE DE DECISÃO — Política de retenção de documentos de sessão (D1)
**Goal:** Não é uma tarefa de implementação — é o ponto de checagem
obrigatório antes de implementar `_pairsToRagDocuments`/reindexação
(design.md, seção "Reconstrução após clear"). **Não prosseguir para T25 sem
uma escolha explícita do usuário entre as opções A/B/C descritas em
`context.md`, D1.**
**Files:** nenhum
**Depends on:** T4 (precisa de `timestamp` persistido para as opções B/C)
**Requirement:** VGP-MEM-27
**Done when:**
- Uma opção (A, B ou C) foi escolhida e registrada em `context.md` (mover de
  "Decisão de produto pendente" para uma seção "Decidido em <data>").
- Se B ou C: os detalhes que faltam (N dias de expiração para B; tamanho do
  lote e prompt de sumarização para C) foram especificados antes de T25
  começar.

**Commit Scope:** nenhum (atualização de documentação apenas —
`docs(spec): record D1 decision`)

---

### T25 — Reconstrução da sessão a partir do histórico persistido
**Goal:** Implementar `_reindexSessionFromHistory`/`_pairsToRagDocuments` no
cubit, aplicando a política escolhida em T24, e ligá-la como o callback
`_onKnowledgeBaseReloaded` do `RAGService`, chamada também uma vez no cold
start (`initialize()`).
**Files:**
- `lib/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart`
- `lib/app/di/features_module.dart` (se o hook for setado no momento da
  construção do cubit/repository)

**Depends on:** T22, T24
**Requirement:** VGP-MEM-25, VGP-MEM-26, VGP-MEM-27
**Done when:**
- `RAGService` não importa nenhum tipo de `features/vegapunk_chat/` (grep de
  import cruzado deve ficar vazio — é o teste mais direto para VGP-MEM-26).
- Reindexação a partir de um histórico vazio é no-op, sem erro.
- Reindexação a partir de um histórico populado gera documentos com prefixo
  `sess:`, respeitando a política de retenção escolhida em T24 (contagem
  máxima, corte por idade, ou resultado de sumarização — conforme aplicável).
- Após um `clearVectorStore` disparado por mudança de fingerprint da KB,
  `searchSession` volta a encontrar conteúdo da conversa no turno seguinte
  (não fica permanentemente vazio até reabrir o app).

**Commit Scope:** `feat(vegapunk-chat): reindex session memory from persisted history after any vector-store clear`

---

### T26 — Testes: reconstrução end-to-end (fakes)
**Goal:** Provar a promessa central da Fase 2 com fakes — sem depender do
plugin real, sem depender de dispositivo.
**Files:**
- `test/features/vegapunk_chat/cubit/vegapunk_chat_memory_test.dart` (novo)

**Depends on:** T25
**Requirement:** VGP-MEM-25, VGP-MEM-27
**Done when:**
- Cenário: histórico populado (fake repo) + `RAGService` fake que simula um
  `clearVectorStore` → depois da reconstrução, uma busca de sessão fake
  encontra o conteúdo esperado.
- Cenário: histórico vazio → reconstrução não lança, não adiciona documentos.

**Commit Scope:** `test(vegapunk-chat): cover session memory reconstruction from history`

---

## Marco Fase 2

**Entregável:** reabrir a tela do chat repetidamente na mesma instalação do
app não apaga mais a memória de conversa; perguntas de acompanhamento
recuperam contexto de sessão relevante sem competir por vagas de busca com a
base de lore; "sem contexto de sessão relevante" é um resultado distinguível
de "houve um erro".

---

## Ordem de execução recomendada

```
T1 → T2 → T3 → T4 → T5 → T6 → T7        (Fase 1 — shippable sozinha)
                              │
                              ▼
                T20 → T21 → T22 → T23    (Fase 2a — idempotência + namespace,
                              │           não depende de D1)
                              ▼
                       T24 (gate) → T25 → T26   (Fase 2b — depende de D1)
```

T20–T23 podem começar antes de T1–T7 terminarem (dependência de dados é só de
T25 em diante em relação a T4). Se a prioridade for "parar o sangramento" da
memória de sessão o quanto antes, T20–T23 isoladas já entregam VGP-MEM-20/21 —
o `setKnowledgeBase` para de apagar tudo a cada abertura — mesmo sem T25
(a reconstrução fica para depois; a sessão simplesmente começa vazia após um
clear raro, em vez de ser apagada a cada abertura de tela, que é o bug
principal reportado).
