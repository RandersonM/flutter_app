# flutter_gemma — LLM On-Device (Chat Vegapunk & RAG)

> Ver também: [`gemini-cloud-ai-setup.md`](./gemini-cloud-ai-setup.md) para o Gemini **na nuvem** (tecnologia separada, usada para geração de texto/imagem). Este documento cobre o `flutter_gemma`, que roda o modelo **no dispositivo**, sem chamadas de rede após o download inicial.

## 1. O que é e por que existe no projeto

`flutter_gemma` é o plugin que embute um LLM (Gemma) rodando localmente no aparelho do usuário, via LiteRT (antigo TFLite). No OpFan ele alimenta o **Ask Vegapunk** — um chat com a persona do Dr. Vegapunk, com:

- Geração de texto por streaming, 100% local (nenhum dado do chat sai do dispositivo)
- **Function calling nativo** (ferramentas: `searchInternet`, `getUserProfile`, `getWorkoutHistory`, `saveWorkout`, `getCharacterInfo`)
- **RAG** (Retrieval-Augmented Generation) com uma base de conhecimento sobre One Piece + memória de sessão
- Um segundo consumidor independente: **Nami Finances**, que abre uma sessão própria no mesmo modelo. Ali o Dart escolhe e executa a ferramenta (`NamiIntentRouter`) e o modelo só narra o resultado; o RAG da Nami serve à ferramenta `findExpenses`

> **Restrições fixas (decisão de produto, não parâmetro de ajuste):** modelo **Gemma 4 E2B** e `maxTokens: 4096`. Pressão de memória se resolve com outras alavancas — ver `.claude/rules/ai-on-device.md`.

Motivação de produto (`.specs/features/vegapunk-chat/spec.md`): privacidade (dados financeiros/pessoais nunca saem do device), sem rate limit de API paga, e uma feature "de vitrine" para o app.

## 2. Pacotes no `pubspec.yaml`

```yaml
flutter_gemma: ^1.1.1
flutter_gemma_litertlm: ^1.0.2       # engine de inferência (.litertlm)
flutter_gemma_embeddings: ^1.0.1     # embeddings on-device (Gecko)
flutter_gemma_rag_sqlite: ^1.1.0     # vector store (sqlite-vec), inclui iOS
```

> Nota histórica: o spec original (`vegapunk-chat/design.md`) planejava `flutter_gemma_mediapipe` para arquivos `.task`. Na implementação real o projeto usa **apenas o backend LiteRT-LM** (`.litertlm`) — `flutter_gemma_mediapipe` nunca foi adicionado. Ao consultar os specs em `.specs/features/`, trate o `pubspec.yaml` e o código como fonte da verdade — os specs registram a *intenção* na época em que foram escritos, não necessariamente o estado final.

## 3. Onde está configurado

### 3.1 Inicialização do SDK — `lib/main.dart`

```dart
await FlutterGemma.initialize(
  huggingFaceToken: getIt<IEnvironmentService>().huggingFaceApiKey,
  inferenceEngines: [LiteRtLmEngine()],
  embeddingBackends: [LiteRtEmbeddingBackend()],
  vectorStore: SqliteVectorStore(),
);
```

Chamado após Firebase/Env/Theme, antes de `runApp()`. É síncrono/rápido — apenas registra os engines, não carrega o modelo.

### 3.2 Variáveis de ambiente (`.env`, via `--dart-define-from-file=.env`)

```env
HUGGING_FACE_API_KEY=hf_...              # token para baixar modelos gated no HuggingFace
GEMMA_MODEL_URL=https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm
GEMMA_MODEL_NAME=gemma-4-E2B-it.litertlm
```

Modelo **atualmente ativo em produção**: **Gemma 4 E2B** (~2B parâmetros efetivos, arquitetura MatFormer), formato `.litertlm`. O `.env.example` mantém uma alternativa mais leve comentada (`Gemma3-1B-IT`, ~2.4 GB, formato multi-prefill) para quem quiser trocar. A troca de modelo é **só configuração** — nenhum código precisa mudar (`GemmaService._determineModelType` deriva o tipo do nome do arquivo).

### 3.3 `GemmaService` — `lib/core/services/gemma/gemma_service.dart`

Serviço lazy singleton (`IGemmaService`, `i_gemma_service.dart`) que encapsula todo o ciclo de vida do plugin: instalação, carregamento, sessões de chat, streaming e function calling. Registrado em `lib/app/di/core_module.dart` (bloco `registerLazySingleton<IGemmaService>`):

```dart
getIt.registerLazySingleton<IGemmaService>(() {
  final gemma = GemmaService(
    env: getIt<IEnvironmentService>(),
    localeService: getIt<ILocaleService>(),
  );
  final registry = getIt<FunctionRegistry>();
  gemma.setTools(registry.getTools());   // tools nativas, antes de qualquer load
  return gemma;
});
```

Estados expostos via `Stream<GemmaServiceStatus>` (`gemma_service_status.dart`, `sealed`): `GemmaNotInstalled`, `GemmaDownloading(progress)`, `GemmaLoading`, `GemmaReady`, `GemmaError(error, isInstallError)`.

Ciclo de vida:
- **`initialize()`** — modelo não instalado → `GemmaNotInstalled`; instalado mas não aberto → `loadModel()`; já aberto → só `_refreshVegapunkChat()` (recria o chat do Vegapunk com o locale atual, **sem** reabrir o modelo nem fechar sessões).
- **`downloadModel()`** — `FlutterGemma.installModel(...).fromNetwork(GEMMA_MODEL_URL, token)` com progresso, depois `loadModel()`.
- **`loadModel()` → `_recreateChat()`** — recarga completa: fecha o chat **e todas as sessões nomeadas** (inclusive a da Nami), reabre o modelo via `_openModelWithFallback()` e cria o chat do Vegapunk.
- **`resetChat()`** — também usa `_refreshVegapunkChat()`; só cai no `_recreateChat()` se o refresh falhar.

Dois tipos de conversa sobre o mesmo modelo:
- **`sendMessage()` / `sendToolResult()`** — o chat singleton do Vegapunk, criado em `_createVegapunkChat()` (`temperature` 0.2, ou 0.15 no modo thinking; `maxOutputTokens` 768, ou 512 no thinking; tools nativas + `ToolChoice.auto`).
- **`sendSessionMessage(sessionId, ...)` / `sendSessionToolResult()` / `closeSession()`** — chats independentes nomeados (`model.openChat`), criados na primeira mensagem, cada um com seu system prompt e histórico (`temperature` 0.2 com tools, 0.3 sem; `maxOutputTokens` padrão 512). É o mecanismo que dá à Nami a própria persona. Feche a sessão no `close()` do BLoC.

Não há lock de geração: uma geração por vez é responsabilidade de quem chama (os cubits/BLoCs controlam `isGenerating`). Cancelar a stream chama `stopGeneration()`.

O modelo abre com `maxTokens: 4096` e backend **GPU com fallback para CPU** (`_backendPreference` + `_openModelWithFallback`): se o init do Metal/GPU falhar, abre em CPU; se os dois falharem, relança o erro e o status vira `GemmaError`.

### 3.4 Plataformas

| Plataforma | Configuração atual | Observação |
|---|---|---|
| iOS `Info.plist` | `UIFileSharingEnabled=true`, `LSSupportsOpeningDocumentsInPlace=true` | conforme spec |
| iOS `Runner.entitlements` | **só** `com.apple.developer.kernel.increased-memory-limit` | `extended-virtual-addressing` e `increased-debugging-memory-limit` foram removidas de propósito: a Apple não as concede a *personal teams* e o provisioning falha (comentário no próprio arquivo) |
| iOS `Podfile` | `platform :ios, '16.0'`; `use_frameworks!` **sem** `:linkage => :static` | linking dinâmico diverge do spec, que pedia estático — ver §7 |
| Android `AndroidManifest.xml` | `libOpenCL.so`, `libOpenCL-car.so`, `libOpenCL-pixel.so` como `uses-library`/`uses-native-library` opcionais | aceleração GPU opcional, não obrigatória |
| Android `minSdkVersion` | 28 | em `android/app/build.gradle` |

## 4. RAG — arquitetura de dois consumidores compartilhando um vector store

`flutter_gemma`/`flutter_gemma_rag_sqlite` expõe **um único vector store ativo por processo** (não é multi-tenant). Duas features usam RAG de forma independente:

- **Vegapunk chat** → `RAGService` (`lib/core/services/rag/rag_service.dart`), base `opfan_rag_<uid>.db`
- **Nami Finances** → `NamiRagService` (`lib/features/nami_finances/data/services/nami_rag_service.dart`), base `nami_finances_store_<uid>.db`

Cada usuário tem o próprio arquivo (`IUserStorageService.userDatabaseFileName`; `guest` sem login), e o nome do arquivo é o `owner` no coordinator — trocar de conta reabre o store.

Isso já causou um bug real de produção (ver `.specs/features/gemma-performance-audit/`): quem inicializava o vector store por último "roubava" o ponteiro global, e a busca da outra feature silenciosamente passava a consultar o banco errado (ou nenhum). A correção foi extrair um coordenador único:

**`RagStoreCoordinator`** (`lib/core/services/rag/rag_store_coordinator.dart`) — dono exclusivo de:
1. `ensureEmbedderInstalled()` — instala o modelo de embedding (Gecko 110M, ~64MB quantizado) uma única vez por processo, compartilhado pelas duas features.
2. `withStore(owner, dbFileName, operação)` — reaponta o vector store global para o banco do `owner` (no-op se ele já está ativo; só reabre o SQLite quando a feature ativa muda) e roda a operação. As chamadas entram numa fila: troca + operação rodam juntas, uma por vez, então a outra feature não consegue reapontar o store no meio de uma busca ou escrita. Uma chamada aninhada do mesmo owner roda direto; aninhar outro owner é erro.

Cada serviço RAG passa **toda operação** no store por `_inStore(...)` (que delega ao `withStore`) — não só a inicialização. A geração de embeddings, que não usa o store, fica fora da fila.

```
                      ┌────────────────────────┐
                      │   RagStoreCoordinator  │  (dono do embedder + do "active pointer")
                      └───────────┬────────────┘
          withStore(owner, dbFile, op) — fila única
        ┌────────────────────┼────────────────────┐
        ▼                                          ▼
┌───────────────────┐                    ┌──────────────────────┐
│ RAGService         │                    │ NamiRagService        │
│ owner=db do usuário │                    │ owner=db do usuário   │
│ opfan_rag_<uid>.db  │                    │ nami_finances_store_<uid>.db │
└───────────────────┘                    └──────────────────────┘
```

### 4.1 Vegapunk — knowledge base + memória de sessão

- `OnePieceKnowledgeBase` (`lib/features/vegapunk_chat/data/knowledge/one_piece_knowledge_base.dart`) — documentos seed sobre Vegapunk/satélites, personagens, frutas do diabo (bilíngue PT/EN), enviados por `VegapunkChatCubit._initRag()` (chamado **sem `await`** em `initialize()`). `RAGService.setKnowledgeBase` só reindexa quando o *fingerprint* (ids ordenados) muda — **mudar o texto de um documento exige mudar o id**.
- Após cada resposta, um documento de sessão (prefixo `sess:`, `"User asked…\nAnswer:…"`, resposta truncada em 512 chars) é agendado com um `Timer` de 2 s (para não competir com a inferência) — capado em **20 documentos por processo** (`_maxSessionDocs`).
- A busca é separada: `searchLore` e `searchSession`, cada uma com seu `topK` (over-fetch 4× e filtro por namespace).
- `clearSession()` limpa a store inteira e **restaura a knowledge base** a partir de um snapshot em memória. Quando a store é limpa por mudança de KB, o hook `setOnStoreCleared` reconstrói os documentos de sessão a partir do histórico em Hive.
- O histórico do chat fica num Hive `LazyBox` cifrado e por usuário (`vegapunk_chat_history_<uid>`); as últimas 20 mensagens são carregadas **só para exibição** — não são reenviadas ao modelo.

### 4.2 Nami Finances — RAG sobre dados financeiros do próprio usuário

- `NamiRagService.syncMonth` indexa **cada despesa** do mês (`_indexExpense`) como documento; `_schemaVersion` força reindexação quando o formato muda.
- A ferramenta `findExpenses` usa o RAG só para **localizar** ids de despesa (limiar `defaultThreshold = 0.55`); os valores vêm dos registros estruturados e a soma é feita em Dart.
- `backfillIfNeeded()` sincroniza meses já salvos na primeira abertura do chat.

## 5. Function calling — três camadas de defesa

O modelo Gemma 4 E2B (2B parâmetros efetivos) **nem sempre decide corretamente quando chamar uma ferramenta** — muitas vezes *descreve* a chamada em vez de emiti-la. Por isso o `VegapunkChatRepository` (`lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart`) implementa três camadas, em ordem de prioridade:

1. **`ToolIntentDetector`** (heurística pré-modelo) — analisa a mensagem do usuário por padrões de texto (PT/EN) *antes* de qualquer chamada ao modelo. Alta confiança → executa a ferramenta direto, sem esperar o modelo decidir. Ex.: "pesquise na internet sobre X", "meu peso", "salvar treino".
2. **Function calling nativo do SDK Gemma 4** — o modelo emite `<|tool_call|>...</tool_call|>` estruturado, que o SDK parseia em `FunctionCallResponse`/`ParallelFunctionCallResponse` no stream.
3. **`FunctionExecutor.tryParse`** (fallback textual) — se o SDK não capturar a chamada estruturada, tenta parsear JSON solto no texto acumulado.

Ferramentas registradas no `FunctionRegistry` padrão (`lib/app/di/core_module.dart`, bloco `registerLazySingleton<FunctionRegistry>`): `searchInternet` (Tavily), `getUserProfile`, `getWorkoutHistory`, `saveWorkout`, `getCharacterInfo`. A Nami tem um registry próprio (`kNamiToolsRegistry` em `features_module.dart`).

O resultado da ferramenta é truncado em 1500 chars. Nas camadas 1 e 3 ele entra num novo `sendMessage()` como bloco `[SEARCH RESULTS for "<tool>"]`; na camada 2 volta ao modelo via `sendToolResult()` (`Message.toolResponse`, API nativa) para a segunda passada. A UI recebe tokens sentinela invisíveis — `\x00TOOL_START:<nome>\x00` e `\x00TOOL_DONE\x00` (`VegapunkChatRepository.toolStartSentinel` / `toolDoneSentinel` / `parseToolName`) — e o `VegapunkChatCubit` (`lib/features/vegapunk_chat/bloc/vegapunk_chat_cubit.dart`) os converte em `activeToolName` no estado, sem acoplar a repository à UI.

## 6. Bugs de performance já corrigidos (histórico útil para não reintroduzir)

Ver `.specs/features/gemma-performance-audit/` para a auditoria completa. Resumo do que foi corrigido:

| Problema | Causa raiz | Correção |
|---|---|---|
| Chat "novo" ficava mais lento que o inicial | `resetChat()` não passava `preferredBackend: gpu`, caía silenciosamente para CPU num modelo já pesado (E2B) | Abertura do modelo centralizada em `_openModelWithFallback()` (GPU primeiro, CPU só se a GPU falhar); `resetChat` hoje nem reabre o modelo (`_refreshVegapunkChat`) |
| Abrir o Vegapunk fechava a sessão da Nami | `initialize()` recarregava o modelo a cada abertura da tela | Com o modelo já aberto, `initialize()` só recria o chat do Vegapunk; a Nami só chama `initialize()` a partir de `GemmaNotInstalled` |
| Nami/Vegapunk "roubavam" o vector store um do outro | `initializeVectorStore()` chamado direto por cada feature, sem coordenação — é um singleton global no plugin | `RagStoreCoordinator` (§4) |
| Sessão de RAG crescia sem limite | Nenhum cap nos documentos de sessão | Cap de 20 docs/sessão |
| Documento de sessão perdido em respostas rápidas seguidas | `Future.delayed(2s)` sem cancelamento — corrida com a próxima mensagem | `Timer` cancelável que se reagenda em vez de descartar |
| Model type hardcoded (`ModelType.gemma4`) | Dessincronizava se o modelo configurado mudasse | Deriva de `_determineModelType(env.gemmaModelName)` |

**Decisão de produto registrada**: o downgrade do modelo (E2B → algo mais leve) foi avaliado e **descartado deliberadamente** — a equipe optou por manter o Gemma 4 E2B pela qualidade de function calling e multilíngue, aceitando o custo de performance em troca.

## 7. Divergências entre o spec original e o código atual

Útil para quem for ler `.specs/features/vegapunk-chat/` esperando encontrar o estado atual — não vai encontrar. Principais desvios:

- **Modelo**: spec pedia Qwen3 0.6B `.task` (mobile-only); código real usa Gemma 4 E2B `.litertlm`.
- **Engine**: spec pedia `flutter_gemma_mediapipe` + `flutter_gemma_litertlm` como fallback desktop; código real usa **só** `flutter_gemma_litertlm`.
- **iOS linking**: spec pedia `use_frameworks! :linkage => :static`; o `Podfile` atual fixa `platform :ios, '16.0'` mas usa linking dinâmico padrão.
- **Entitlements iOS**: só `increased-memory-limit` (as variantes de debugging/virtual addressing não são concedidas a personal teams).
- **Pipeline**: o spec previa um chat simples; o código tem detector de intenção → function call nativo → fallback textual, satélites, RAG de sessão e histórico em Hive. Resumo atual no topo de `.specs/features/vegapunk-chat/design.md`.
- **Escopo**: RAG e function calling eram "Fase 3/Out of Scope" no spec original — já estão implementados e em produção, junto com um segundo consumidor de RAG (Nami Finances) que nem constava no spec do Vegapunk.

Isso não é um problema em si — specs registram intenção no momento em que foram escritos — mas reforça: **para decisões de arquitetura, leia o código (`lib/core/services/gemma/`, `lib/core/services/rag/`) e o `pubspec.yaml`, não apenas `.specs/`**.

## 8. Como configurar / melhorar (guia prático)

### Trocar o modelo
O produto fixa o **Gemma 4 E2B** e `maxTokens: 4096` — não troque por um modelo menor nem reduza o contexto para resolver memória. Tecnicamente a troca é só configuração (útil para experimentos locais):
1. Edite `GEMMA_MODEL_URL`/`GEMMA_MODEL_NAME` no `.env` (o `.env.example` tem a alternativa comentada `Gemma3-1B-IT`).
2. `_determineModelType`/`_determineModelFileType` derivam do nome do arquivo. Tipos reconhecidos: Gemma (`gemmaIt`/`gemma4`), Qwen/Qwen3, DeepSeek, Phi, Llama, FunctionGemma, SmolLM (`general`).
3. Meça tokens/s num device de referência antes/depois — a diferença entre um modelo "E2B" (MatFormer, footprint maior que o nome sugere) e um dense 1B é substancial.

### Ajustar comportamento do chat
- **Tom/persona**: `lib/core/ai/prompts/personas/vegapunk_prompt.dart` — prompt curto e baseado em regras numeradas funciona melhor que prosa longa para modelos pequenos.
- **Brevidade**: `maxOutputTokens` em `_createVegapunkChat()` (768 normal / 512 thinking) e as `RESPONSE RULES` do prompt trabalham juntos — mudar um sem o outro tende a não ter efeito visível.
- **Satélites** (variações de estilo dentro do mesmo chat): `vegapunk_satellite_prompt.dart` + `VegapunkSatellitePrompt.forMessage()`.

### Adicionar uma nova ferramenta (function calling)
1. Implemente um `ToolHandler` (descrições EN + PT, valores `*_formatted` prontos, saída abaixo de ~1500 chars; nunca lance exceção de `execute`) e registre no registry certo (`core_module.dart` para o Vegapunk, `kNamiToolsRegistry` para a Nami).
2. Torne-a alcançável de forma determinística: um `_matchesXIntent` em `ToolIntentDetector` (Vegapunk) ou um ramo no `NamiIntentRouter` (Nami).
3. Teste o handler (Dart puro) e o roteamento; no Vegapunk, os três caminhos (intent direto, function call nativo, fallback textual) devem convergir para o mesmo resultado.

### Adicionar uma nova feature com RAG próprio
1. Crie um serviço dedicado (como `NamiRagService`) com seu próprio `owner` id e nome de arquivo `.db`.
2. **Nunca** chame `FlutterGemmaPlugin.instance.initializeVectorStore()` diretamente — sempre via `RagStoreCoordinator.withStore(owner, dbFileName, operação)`, com **toda** leitura/escrita dentro da operação, não só a inicialização.
3. Se a feature precisa de um "assistente" com persona própria (não misturado ao Vegapunk), use `GemmaService.sendSessionMessage(sessionId, ...)` em vez do `sendMessage()` singleton.

### Diagnosticar lentidão
- Confirme se o backend resolvido é GPU (`_openModelWithFallback` loga quando cai para CPU), ou instrumente conforme o plano em `.specs/features/gemma-performance-audit/design.md`.
- Compare tokens/s: cold start vs. após `reset()` — hoje devem ser equivalentes (bug do §6 já corrigido); se divergirem de novo, é regressão.
- Se o app some durante a geração sem erro Dart, suspeite primeiro de OOM (iOS mata o processo sem exceção capturável).
- Verifique se alguma feature RAG está inicializando o vector store fora do `RagStoreCoordinator` (grep por `initializeVectorStore` deve retornar só o coordinator).

## 9. Pontos fortes e pontos de atenção

### Pontos fortes
- **Privacidade real**: nenhum dado de chat, perfil ou financeiro sai do dispositivo depois do download do modelo — diferencial de produto genuíno, não apenas marketing.
- **Function calling em 3 camadas** é uma solução de engenharia sólida para uma limitação real e documentada do modelo (2B params não é confiável para tool-use puro) — cobre o caso feliz (SDK nativo) e dois fallbacks graciosos.
- **`RagStoreCoordinator`** resolve corretamente um problema de estado global compartilhado entre features que, sem essa camada, teria sido uma fonte recorrente de bugs "funciona sozinho, quebra quando as duas features são usadas juntas".
- **Sessões independentes** (`sendSessionMessage`) permitem múltiplas "personalidades"/históricos de IA no app sem duplicar a infraestrutura de carregamento de modelo — só uma instância de modelo pesado em memória, várias conversas lógicas por cima.
- Sem custo de API por request e sem rate limiting externo — ao contrário do Gemini na nuvem (15 req/hora).

### Pontos de atenção
- **Tamanho do modelo em disco/memória**: Gemma 4 E2B é uma escolha consciente, mas continua sendo a maior fonte de risco de performance em devices de entrada — já documentado e aceito como trade-off, não um bug.
- **`.specs/` desatualizado em relação ao código**: os specs originais do Vegapunk tratam RAG e function calling como "trabalho futuro". O `design.md` agora abre com um resumo do pipeline atual; o resto do arquivo é histórico.
- **Linking dinâmico no iOS** (o spec pedia estático) — funciona hoje, mas não foi validado que continuará assim conforme o app cresce.
- **Estado global do plugin (`ServiceRegistry` interno)**: o `RagStoreCoordinator` mitiga isso para o vector store, mas é um padrão do próprio `flutter_gemma` (instância "ativa" única também para modelo e embedder) que qualquer feature nova precisa respeitar manualmente — não há guarda-corrilhos automático do compilador contra reintroduzir o bug original.
- **Cobertura de testes parcial**: há testes para `RAGService`, histórico/reindexação do cubit, `ToolIntentDetector`, handlers e o router da Nami (`test/core/services/rag/`, `test/features/vegapunk_chat/`, `test/features/nami_finances/`), mas não para o `RagStoreCoordinator` nem para o loop de 3 camadas da repository.
