# flutter_gemma — LLM On-Device (Chat Vegapunk & RAG)

> Ver também: [`gemini-cloud-ai-setup.md`](./gemini-cloud-ai-setup.md) para o Gemini **na nuvem** (tecnologia separada, usada para geração de texto/imagem). Este documento cobre o `flutter_gemma`, que roda o modelo **no dispositivo**, sem chamadas de rede após o download inicial.

## 1. O que é e por que existe no projeto

`flutter_gemma` é o plugin que embute um LLM (Gemma) rodando localmente no aparelho do usuário, via LiteRT (antigo TFLite). No OpFan ele alimenta o **Ask Vegapunk** — um chat com a persona do Dr. Vegapunk, com:

- Geração de texto por streaming, 100% local (nenhum dado do chat sai do dispositivo)
- **Function calling nativo** (chamada de ferramentas: busca na web, perfil do usuário, histórico de treino)
- **RAG** (Retrieval-Augmented Generation) com uma base de conhecimento sobre One Piece + memória de sessão
- Um segundo consumidor independente: **Nami Finances**, que usa o mesmo motor RAG para responder perguntas sobre as finanças do próprio usuário, sem relação com o Vegapunk

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

### 3.2 Variáveis de ambiente (`.env`)

```env
HUGGING_FACE_API_KEY=hf_...              # token para baixar modelos gated no HuggingFace
GEMMA_MODEL_URL=https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm
GEMMA_MODEL_NAME=gemma-4-E2B-it.litertlm
```

Modelo **atualmente ativo em produção**: **Gemma 4 E2B** (~2B parâmetros efetivos, arquitetura MatFormer), formato `.litertlm`. O `.env.example` mantém uma alternativa mais leve comentada (`Gemma3-1B-IT`, ~2.4 GB, formato multi-prefill) para quem quiser trocar. A troca de modelo é **só configuração** — nenhum código precisa mudar (`GemmaService._determineModelType` deriva o tipo do nome do arquivo).

### 3.3 `GemmaService` — `lib/core/services/gemma/gemma_service.dart`

Serviço singleton (`IGemmaService`) que encapsula todo o ciclo de vida do plugin: instalação, carregamento, sessões de chat, streaming e function calling. Registrado em `lib/app/di/core_module.dart:115`:

```dart
getIt.registerLazySingleton<IGemmaService>(() {
  final gemma = GemmaService();
  final registry = getIt<FunctionRegistry>();
  gemma.setTools(registry.getTools());   // tools nativas do Gemma 4
  return gemma;
});
```

Estados expostos via `Stream<GemmaServiceStatus>` (`gemma_service_status.dart`): `GemmaNotInstalled`, `GemmaDownloading(progress)`, `GemmaLoading`, `GemmaReady`, `GemmaError`.

Dois modos de conversa, ambos passando por `_recreateChat()` (helper único que evita duplicação/desvio entre os dois — ver §6):
- **`sendMessage()`** — o chat singleton principal do Vegapunk (`temperature: 0.2`, `maxOutputTokens: 768`)
- **`sendSessionMessage(sessionId, ...)`** — chats independentes nomeados, cada um com seu próprio system prompt e histórico, sem contaminar o chat do Vegapunk. É esse o mecanismo que permite o Nami Finances ter sua própria "personalidade" de assistente sem herdar a persona do Vegapunk.

Sempre usa `preferredBackend: PreferredBackend.gpu` e `maxTokens: 4096` no modelo ativo.

### 3.4 Plataformas

| Plataforma | Configuração atual | Observação |
|---|---|---|
| iOS `Info.plist` | `UIFileSharingEnabled=true`, `LSSupportsOpeningDocumentsInPlace=true` | conforme spec |
| iOS `Runner.entitlements` | `increased-memory-limit`, `extended-virtual-addressing`, `increased-debugging-memory-limit` | mais permissivo que o spec original pedia |
| iOS `Podfile` | `use_frameworks!` **sem** `:linkage => :static`; `platform :ios` comentado (usa o default do Flutter) | **diverge do spec**, que pedia linking estático e iOS 16 mínimo explícito — ver §7 |
| Android `AndroidManifest.xml` | `libOpenCL.so`, `libOpenCL-car.so`, `libOpenCL-pixel.so` como `uses-library`/`uses-native-library` opcionais | aceleração GPU opcional, não obrigatória |
| Android `minSdkVersion` | 28 | em `android/app/build.gradle` |

## 4. RAG — arquitetura de dois consumidores compartilhando um vector store

`flutter_gemma`/`flutter_gemma_rag_sqlite` expõe **um único vector store ativo por processo** (não é multi-tenant). Duas features usam RAG de forma independente:

- **Vegapunk chat** → `RAGService` (`lib/core/services/rag/rag_service.dart`), base `opfan_rag.db`
- **Nami Finances** → `NamiRagService` (`lib/features/nami_finances/data/services/nami_rag_service.dart`), base `nami_finances_store.db`

Isso já causou um bug real de produção (ver `.specs/features/gemma-performance-audit/`): quem inicializava o vector store por último "roubava" o ponteiro global, e a busca da outra feature silenciosamente passava a consultar o banco errado (ou nenhum). A correção foi extrair um coordenador único:

**`RagStoreCoordinator`** (`lib/core/services/rag/rag_store_coordinator.dart`) — dono exclusivo de:
1. `ensureEmbedderInstalled()` — instala o modelo de embedding (Gecko 110M, ~64MB quantizado) uma única vez por processo, compartilhado pelas duas features.
2. `ensureActive(owner, dbFileName)` — reaponta o vector store global para o banco do `owner` atual; é *no-op* se o mesmo owner já está ativo, e só reabre o SQLite quando a feature ativa muda.

Cada serviço RAG chama `_ensureActiveStore()` (que delega ao coordinator) **antes de toda operação** — não só na inicialização — para se re-afirmar como dono se a outra feature foi usada nesse meio-tempo.

```
                      ┌────────────────────────┐
                      │   RagStoreCoordinator  │  (dono do embedder + do "active pointer")
                      └───────────┬────────────┘
              ensureActive(owner, dbFile) — memoizado
        ┌────────────────────┼────────────────────┐
        ▼                                          ▼
┌───────────────────┐                    ┌──────────────────────┐
│ RAGService         │                    │ NamiRagService        │
│ owner="vegapunk"    │                    │ owner="nami_finances" │
│ db=opfan_rag.db     │                    │ db=nami_finances_store.db │
└───────────────────┘                    └──────────────────────┘
```

### 4.1 Vegapunk — knowledge base + memória de sessão

- `OnePieceKnowledgeBase` — documentos seed sobre Vegapunk/satélites, personagens, frutas do diabo, arcos (bilíngue PT/EN), carregados uma vez por `VegapunkChatCubit.initialize()`.
- Após cada resposta, um documento de sessão (`isSession: true`) é adicionado com um atraso de 2s (para não competir com a inferência em andamento) — capado em **20 documentos por sessão** (`_maxSessionDocs`) para não degradar a latência de busca.
- `clearSession()` limpa a store inteira e **restaura a knowledge base** a partir de um snapshot em memória (não persiste a KB em disco separadamente).

### 4.2 Nami Finances — RAG sobre dados financeiros do próprio usuário

- Cada resumo mensal (`NamiFinancesModel`) é convertido em texto (`NamiRagService.summarize`) e sincronizado como documento — sem depender de LLM para gerar o resumo, é uma formatação determinística.
- `backfillIfNeeded()` resincroniza meses salvos antes da correção do coordinator (quando o embedder nunca era de fato ativado e a sincronização falhava silenciosamente).

## 5. Function calling — três camadas de defesa

O modelo Gemma 4 E2B (2B parâmetros) **nem sempre decide corretamente quando chamar uma ferramenta** — um comentário no próprio código documenta essa limitação conhecida. Por isso o `VegapunkChatRepository` (`lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart`) implementa três camadas, em ordem de prioridade:

1. **`ToolIntentDetector`** (heurística pré-modelo) — analisa a mensagem do usuário por padrões de texto (PT/EN) *antes* de qualquer chamada ao modelo. Alta confiança → executa a ferramenta direto, sem esperar o modelo decidir. Ex.: "pesquise na internet sobre X", "meu peso", "salvar treino".
2. **Function calling nativo do SDK Gemma 4** — o modelo emite `<|tool_call|>...</tool_call|>` estruturado, que o SDK parseia em `FunctionCallResponse`/`ParallelFunctionCallResponse` no stream.
3. **`FunctionExecutor.tryParse`** (fallback textual) — se o SDK não capturar a chamada estruturada, tenta parsear JSON solto no texto acumulado.

Ferramentas registradas em `FunctionRegistry` (`lib/app/di/core_module.dart:86-112`): `searchInternet` (Tavily), `getUserProfile`, `getWorkoutHistory`, `saveWorkout`, `getCharacterInfo`.

Resultado do tool call é injetado como `[SEARCH RESULTS]` no prompt (truncado em 1500 chars) e enviado de volta via `sendToolResult()` para a segunda passada do modelo gerar a resposta final. A UI recebe tokens sentinela invisíveis (`\x00SEARCHING_WEB\x00` / `\x00SEARCHING_DONE\x00`) para mostrar "pesquisando..." sem acoplar a repository à UI.

## 6. Bugs de performance já corrigidos (histórico útil para não reintroduzir)

Ver `.specs/features/gemma-performance-audit/` para a auditoria completa. Resumo do que foi corrigido:

| Problema | Causa raiz | Correção |
|---|---|---|
| Chat "novo" ficava mais lento que o inicial | `resetChat()` não passava `preferredBackend: gpu`, caía silenciosamente para CPU num modelo já pesado (E2B) | `_recreateChat()` único, usado por `loadModel` e `resetChat`, sempre com `gpu` |
| Nami/Vegapunk "roubavam" o vector store um do outro | `initializeVectorStore()` chamado direto por cada feature, sem coordenação — é um singleton global no plugin | `RagStoreCoordinator` (§4) |
| Sessão de RAG crescia sem limite | Nenhum cap nos documentos de sessão | Cap de 20 docs/sessão |
| Documento de sessão perdido em respostas rápidas seguidas | `Future.delayed(2s)` sem cancelamento — corrida com a próxima mensagem | `Timer` cancelável que se reagenda em vez de descartar |
| Model type hardcoded (`ModelType.gemma4`) | Dessincronizava se o modelo configurado mudasse | Deriva de `_determineModelType(env.gemmaModelName)` |

**Decisão de produto registrada**: o downgrade do modelo (E2B → algo mais leve) foi avaliado e **descartado deliberadamente** — a equipe optou por manter o Gemma 4 E2B pela qualidade de function calling e multilíngue, aceitando o custo de performance em troca.

## 7. Divergências entre o spec original e o código atual

Útil para quem for ler `.specs/features/vegapunk-chat/` esperando encontrar o estado atual — não vai encontrar. Principais desvios:

- **Modelo**: spec pedia Qwen3 0.6B `.task` (mobile-only); código real usa Gemma 4 E2B `.litertlm`.
- **Engine**: spec pedia `flutter_gemma_mediapipe` + `flutter_gemma_litertlm` como fallback desktop; código real usa **só** `flutter_gemma_litertlm`.
- **iOS linking**: spec pedia `use_frameworks! :linkage => :static` e `platform :ios, '16.0'` explícito; `Podfile` atual usa linking dinâmico padrão e não fixa a versão do iOS.
- **Escopo**: RAG e function calling eram "Fase 3/Out of Scope" no spec original — já estão implementados e em produção, junto com um segundo consumidor de RAG (Nami Finances) que nem constava no spec do Vegapunk.

Isso não é um problema em si — specs registram intenção no momento em que foram escritos — mas reforça: **para decisões de arquitetura, leia o código (`lib/core/services/gemma/`, `lib/core/services/rag/`) e o `pubspec.yaml`, não apenas `.specs/`**.

## 8. Como configurar / melhorar (guia prático)

### Trocar o modelo
1. Edite `GEMMA_MODEL_URL`/`GEMMA_MODEL_NAME` no `.env` (ou use a alternativa já comentada `Gemma3-1B-IT`).
2. Nenhuma mudança de código é necessária — `_determineModelType`/`_determineModelFileType` derivam do nome do arquivo. Modelos suportados hoje: Gemma (`gemma-it`/`gemma4`), Qwen/Qwen3, DeepSeek, Phi, Llama, FunctionGemma, SmolLM (`general`).
3. Meça tokens/s num device de referência antes/depois — a diferença entre um modelo "E2B" (MatFormer, footprint maior que o nome sugere) e um dense 1B é substancial.

### Ajustar comportamento do chat
- **Tom/persona**: `lib/core/ai/prompts/personas/vegapunk_prompt.dart` — prompt curto e baseado em regras numeradas funciona melhor que prosa longa para modelos pequenos.
- **Brevidade**: `maxOutputTokens` em `_recreateChat()` (768 normal / 512 thinking) e as `RESPONSE RULES` do prompt trabalham juntos — mudar um sem o outro tende a não ter efeito visível.
- **Satélites** (variações de estilo dentro do mesmo chat): `vegapunk_satellite_prompt.dart` + `VegapunkSatellitePrompt.forMessage()`.

### Adicionar uma nova ferramenta (function calling)
1. Implemente um `ToolHandler` e registre em `FunctionRegistry` (`core_module.dart`).
2. Se a ferramenta tem gatilhos de linguagem natural previsíveis, adicione um `_matchesXIntent` em `ToolIntentDetector` para resposta instantânea sem esperar o modelo decidir.
3. Teste os três caminhos: intent-detector direto, function call nativo do SDK, e fallback textual — os três devem convergir para o mesmo resultado.

### Adicionar uma nova feature com RAG próprio
1. Crie um serviço dedicado (como `NamiRagService`) com seu próprio `owner` id e nome de arquivo `.db`.
2. **Nunca** chame `FlutterGemmaPlugin.instance.initializeVectorStore()` diretamente — sempre via `RagStoreCoordinator.ensureActive(owner, dbFileName)`, e chame isso antes de **toda** operação de leitura/escrita, não só na inicialização.
3. Se a feature precisa de um "assistente" com persona própria (não misturado ao Vegapunk), use `GemmaService.sendSessionMessage(sessionId, ...)` em vez do `sendMessage()` singleton.

### Diagnosticar lentidão
- Confirme se o backend resolvido é GPU (log em `_recreateChat`, ou instrumentar antes/depois conforme o plano de verificação em `.specs/features/gemma-performance-audit/design.md`).
- Compare tokens/s: cold start vs. após `reset()` — hoje devem ser equivalentes (bug do §6 já corrigido); se divergirem de novo, é regressão.
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
- **`.specs/` desatualizado em relação ao código**: quem só ler os specs do Vegapunk vai achar que RAG e function calling são "trabalho futuro" — não são. Vale atualizar os specs ou ao menos linkar para este documento.
- **Divergência de config de plataforma iOS** (linking dinâmico + sem `platform :ios` fixo) em relação ao que o spec original pedia — funciona hoje, mas não foi validado/documentado que a app-store review não vai exigir o linking estático eventualmente conforme o app cresce.
- **Estado global do plugin (`ServiceRegistry` interno)**: o `RagStoreCoordinator` mitiga isso para o vector store, mas é um padrão do próprio `flutter_gemma` (instância "ativa" única também para modelo e embedder) que qualquer feature nova precisa respeitar manualmente — não há guarda-corrilhos automático do compilador contra reintroduzir o bug original.
- **Sem testes automatizados** cobrindo o fluxo de function calling ou o coordinator de RAG (a spec do Vegapunk lista um teste de Cubit como tarefa, mas os componentes mais arriscados — `RagStoreCoordinator`, `ToolIntentDetector`, o loop de 3 camadas — não têm teste unitário visível no repositório).
