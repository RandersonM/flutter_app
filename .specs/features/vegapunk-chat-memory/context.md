# Context & Decisions — Vegapunk Chat Memory

## Origem

Pedido do usuário: o Vegapunk chat deveria (1) lembrar do que foi conversado em
sessões passadas e (2) popular a tela com parte do histórico ao abrir, sem
carregar/processar mensagens muito antigas. Investigação prévia (nesta mesma
conversa) mostrou que hoje **nenhuma das duas coisas funciona**:

- `ChatMessage` nunca é persistida — `VegapunkChatCubit` é `registerFactory`
  (instância nova a cada abertura de tela) e sempre começa em
  `VegapunkChatReady()` com `messages: []`.
- A escrita de memória de sessão existe (`_rag.addDocument(...isSession: true)`
  a cada turno), mas `RAGService.setKnowledgeBase()` chama
  `FlutterGemmaPlugin.instance.clearVectorStore()` **incondicionalmente**, e
  `VegapunkChatCubit._initRag()` chama `setKnowledgeBase` a cada abertura de
  tela (o cubit é factory, `_ragInitialized` volta a `false`) — ou seja, toda
  vez que a tela abre, a memória de sessão inteira é apagada.

## Correções à formulação do pedido (não resolvidas silenciosamente)

### C1 — "Uma box por persona/satélite" não corresponde à arquitetura atual

O pedido original sugeria uma Hive box por persona/satélite. Verificado no
código: **existe uma única conversa compartilhada**, não uma por satélite.

- `VegapunkChatState.VegapunkChatReady.selectedSatellite` é um campo que troca
  via `changeSatellite()` — a lista `messages` é a mesma, não é reparticionada.
- `ChatMessage` (`lib/features/vegapunk_chat/data/models/chat_message.dart`)
  não tem nenhum campo de satélite/persona.
- O usuário pode trocar de satélite no meio da conversa e o histórico
  permanece o mesmo thread.

**Decisão:** uma única box de histórico para o Vegapunk chat (não por persona).
O satélite ativo no momento de cada resposta pode, opcionalmente, ser anotado
na mensagem persistida (ver spec VGP-MEM-04) para exibição futura, mas isso é
metadado de uma mensagem, não uma partição do histórico.

### C2 — O bloco de typeId sugerido (20–29) já está reservado

O pedido sugeria o bloco 20–29 para `vegapunk_chat`. Verificado em
`lib/core/storage/hive_type_ids.dart`: os blocos 20–29 (zoro_workout), 30–39
(sanji_cooking) e 40–49 (robin_knowledge) já estão **documentados e
reservados** para essas features (mesmo que hoje elas persistam via Firestore
e não tenham nenhum id realmente em uso — `HiveTypeIds.all` não lista nenhum
id desses blocos). Usar 20–29 colidiria com uma reserva existente na
documentação, mesmo sem colisão em runtime hoje.

**Decisão:** `vegapunk_chat` reivindica o bloco **50–59** (o próximo livre,
conforme o próprio comentário do arquivo: *"50+ — unassigned — claim the next
block and document it here"*).

### C3 — Separar namespaces via `Filter`/`FilterSchema` do flutter_gemma: investigado e descartado para este escopo

O plugin `flutter_gemma` expõe `Filter`/`FieldEquals` em `searchSimilar()`,
que pareceria a ferramenta certa para separar documentos de lore vs. sessão no
nível do banco. Verificado:

- Um filtro só é honrado sobre campos declarados via `FilterSchema`, passada
  **uma única vez, globalmente**, em `FlutterGemma.initialize(filterSchema:
  ...)` (`service_registry.dart`, `flutter_gemma.dart`).
- `lib/main.dart` chama `FlutterGemma.initialize(...)` **sem** `filterSchema`
  → `FilterSchema` vazia é o padrão → *"filters are a safe no-op"* em **todo**
  o app, incluindo o store do `NamiRagService`.
- Declarar um `FilterSchema` agora seria uma mudança global, cross-feature
  (afeta o store do Nami também), não uma mudança local ao Vegapunk.

**Decisão:** namespace por **prefixo de id** + filtragem no cliente — o mesmo
padrão já validado em `NamiRagService`/`FindExpensesHandler`
(`exp:` prefix, checado em `result.id.startsWith(...)`). `Filter`/
`FilterSchema` fica documentado como otimização futura, fora de escopo aqui
porque exigiria coordenação com todos os consumidores do RAG compartilhado.

## D1 — Decidido em 2026-07-26

**Escolha: Opção A — manter `_maxSessionDocs = 20` como teto global, aceitar a
nova semântica ("últimas 20 trocas de toda a história do app", não "desta
sessão").** Motivo explícito do usuário: zero trabalho extra. Sem expiração
por idade (Opção B) e sem sumarização (Opção C) — nenhuma das duas entra no
escopo desta feature.

Consequência direta para T25: `_reindexSessionFromHistory` usa o histórico
persistido (Fase 1) só até `_maxSessionDocs` turnos mais recentes — a mesma
constante já existente em `RAGService`, sem nenhum conceito novo de
retenção/expiração/resumo.

<details>
<summary>Registro original da decisão pendente (histórico)</summary>

**D1 — Política de retenção de documentos de sessão.**

`_maxSessionDocs = 20` foi desenhado para o escopo de **uma sessão** (o cubit
recriava tudo a cada abertura, então "20" sempre significava "as últimas 20
trocas desta conversa, desde que a tela abriu"). Ao tornar a memória
persistente entre reaberturas e reinícios do app, esse mesmo número passa a
significar **"lembrar das últimas 20 trocas de toda a história do app"** — uma
semântica de produto bem diferente, que não foi pedida explicitamente.

Três caminhos, apresentados em `spec.md` sem escolha default:

- **Opção A — Manter o teto, aceitar a nova semântica.** Simples, zero
  trabalho extra. Memória de longo prazo fica rasa (só as ~20 trocas mais
  recentes de sempre).
- **Opção B — Expirar por idade.** Documentos de sessão mais antigos que N
  dias são descartados na próxima escrita. Memória "recente", não "eterna".
  Precisa de timestamp na mensagem (que a persistência do Fase 1 já dá de
  graça).
- **Opção C — Sumarização periódica.** Ao ultrapassar o teto, um lote de
  turnos antigos é resumido em 1 documento novo (custo: 1 chamada extra ao
  Gemma). Memória de longo prazo rica, mas complexidade e custo de latência
  reais.

Esta decisão **bloqueia apenas** a tarefa de retenção da Fase 2 (ver
`tasks.md`, T24) — todo o resto do desenho (persistência de mensagens,
correção do `clearVectorStore`, split de namespace) é independente e não
espera por ela.

</details>

## Loose end da Fase 1 — corrigido junto com a Fase 2

`ChatMessage.satelliteId` (VGP-MEM-04) existia no model/adapter desde a Fase 1
mas nunca era preenchido nos dois pontos de construção em
`VegapunkChatCubit` — sempre `null`. Corrigido junto com T22 (mesmo ponto do
código sendo tocado para o prefixo `sess:`): ambos os construtores passam
`satelliteId: ready.selectedSatellite.name` (mensagens do usuário continuam
`null` — o campo é metadado de quem *respondeu*, não de quem perguntou).

## Avaliação de complexidade

**Complex** — toca persistência (Hive, área não-fragile mas cross-cutting via
`HiveTypeIds`), DI (`features_module.dart`/`core_module.dart`), muda o
comportamento de um serviço existente (`RAGService`) usado por outra feature
via infraestrutura compartilhada (`RagStoreCoordinator`), e tem ambiguidade de
produto real (D1) que não deve ser resolvida por engenharia sozinha.
→ Workflow completo: Specify → Design → Tasks → Execute, em duas fases
independentemente entregáveis.

## Verified Ground Truth (verificado no código, 2026-07-26)

- `HiveTypeIds.all` hoje: `{0, 1, 2, 10, 11, 12, 13, 14, 15}`. Bloco 50+ livre.
- `HiveStorageService.adapters` usa o padrão `_Registration<T>(Adapter())` —
  **não** um `List<TypeAdapter<dynamic>>` bruto (isso já foi um bug real desta
  sessão: `T` inferido como `dynamic` fazia todo write cair no primeiro
  adapter registrado). Todo novo adapter deve seguir esse padrão.
- `ChatMessage` (`lib/features/vegapunk_chat/data/models/chat_message.dart`):
  `id: String`, `text: String`, `role: MessageRole {user, assistant}`. Sem
  timestamp hoje — precisa ser adicionado para D1/Opção B e para ordenação
  determinística no load.
- `VegapunkChatCubit` é `getIt.registerFactory` (`features_module.dart:133`) —
  nova instância a cada `BlocProvider.create`. `IVegapunkChatRepository` e
  `IRAGService` são `registerLazySingleton` (`core_module.dart:101,148`) —
  singletons verdadeiros, sobrevivem entre aberturas de tela.
- Lista de mensagens é renderizada em ordem cronológica direta (sem
  `reverse: true`), `items = state.messages`, index 0 = mais antiga
  (`vegapunk_chat_screen.dart:191-195`).
- `IRAGService.search(query, {topK})` é chamado em exatamente 2 lugares, ambos
  em `VegapunkChatRepository` (`vegapunk_chat_repository.dart:108,125`), cada
  um já limitado a `topK: 2` — hoje uma única busca sem distinção lore/sessão.
- `RagDocument` (`lib/core/models/rag/rag_document.dart`) já tem `id`,
  `content`, `category`, `language`, `topic`, `isSession` — não precisa de novo
  campo para namespace, só de convenção de prefixo no `id`.
- `OnePieceKnowledgeBase.documents` tem 36 docs com ids literais estáveis
  (`vgp-001-pt`, etc.), sem prefixo hoje. Mensagens de sessão hoje usam prefixo
  `'sess-${uuid}'` (hífen). Convenção nova adotada: dois pontos (`kb:`/`sess:`),
  igual ao `exp:` do Nami — só os ids de sessão precisam trocar de hífen para
  dois-pontos; os 36 ids da KB **não** precisam ser reescritos (ver
  `design.md`, seção "Namespace por prefixo").
- `FlutterGemma.initialize(...)` em `lib/main.dart:58-63` não passa
  `filterSchema` → confirma C3.
- `RagStoreCoordinator` (`lib/core/services/rag/rag_store_coordinator.dart`)
  já resolve "um único vector store ativo por processo" entre Vegapunk e Nami
  — este desenho não precisa (e não deve) duplicar essa coordenação.
