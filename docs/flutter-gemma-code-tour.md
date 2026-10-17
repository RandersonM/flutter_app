# Roteiro de código — flutter_gemma no OpFan

Companheiro da apresentação. Aqui está **o que abrir, em que ordem, e o que dizer** em cada arquivo — mais o detalhe que vale apontar com o dedo na tela.

> Referência conceitual: [`flutter-gemma-on-device.md`](./flutter-gemma-on-device.md).
> Este documento é o roteiro de demo; aquele é a documentação.

**Orçamento:** ~40 min de código. Se tiver 20, faça os blocos **0, 1 e 2** e cite os outros.

**Antes de começar:** abra as abas na ordem abaixo. Os números de linha foram conferidos contra o código em 16/10/2026 — se o arquivo mudou, procure pelo nome do método.

**Restrições fixas para citar:** modelo **Gemma 4 E2B** e `maxTokens: 4096` são decisões de produto, não parâmetros de ajuste (`.claude/rules/ai-on-device.md`).

| Bloco | Assunto | Prova o quê | Tempo |
|---|---|---|---|
| 0 | Setup | integrar custa 4 arquivos | 4 min |
| 1 | `GemmaService` | um dono, um modelo, N conversas | 10 min |
| 2 | Vegapunk | o chat **age** dentro do app | 12 min |
| 3 | RAG | busca semântica sem sair do aparelho | 7 min |
| 4 | Nami | o padrão oposto, e por que ele é melhor para números | 7 min |
| 5 | Bônus | a lição de prompt engineering que virou código | 3 min |

---

## Bloco 0 — Setup: integrar custa 4 arquivos

> **Mensagem do bloco:** não há servidor, não há SDK de nuvem, não há chave de API de inferência. São quatro dependências e uma chamada no boot.

### 1. [`pubspec.yaml`](../pubspec.yaml#L54-L57)

**Mostre:** linhas 54–57.

**A frase:** "Quatro pacotes. O primeiro é o core; os outros três são opt-in, e cada um traz só o peso nativo que ele precisa."

**O detalhe:** aponte que **não** existe `flutter_gemma_mediapipe` aqui. O projeto usa exclusivamente o backend LiteRT-LM (`.litertlm`) — ninguém no app usa modelo `.task`. Se alguém já leu os specs antigos em `.specs/`, é aqui que a intenção antiga e o código real divergem.

### 2. [`lib/main.dart`](../lib/main.dart#L55-L60)

**Mostre:** linhas 55–60.

**A frase:** "Uma chamada, depois do Firebase, antes do `runApp`. Ela **registra** os engines — não baixa nem carrega nada."

**O detalhe:** o app abre no mesmo tempo com ou sem modelo instalado. Vale dizer em voz alta, porque a suspeita natural da plateia é "então o app demora 2 GB para abrir?". O `huggingFaceToken` está aqui porque o modelo é *gated* no HuggingFace.

### 3. [`.env.example`](../.env.example#L15-L22)

**Mostre:** linhas 15–22.

**A frase:** "Qual modelo rodar é configuração, não código."

**O detalhe:** mostre em seguida [`gemma_service.dart:96-128`](../lib/core/services/gemma/gemma_service.dart#L96-L128) — `_determineModelType` e `_determineModelFileType` derivam tudo do **nome do arquivo**. Tecnicamente trocar o modelo é editar duas linhas do `.env`; na prática o produto fixa o Gemma 4 E2B. (E não mostre o `.env` real — tem token de verdade.)

### 4. [`ios/Runner/Runner.entitlements`](../ios/Runner/Runner.entitlements) + [`AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml#L52-L57)

**Mostre:** o comentário inteiro do entitlements; no manifest, linhas 52–57.

**A frase:** "A única entitlement que importa é a `increased-memory-limit`. Sem ela o iOS encerra o processo durante o load e **não sobra erro Dart para capturar**."

**O detalhe (a melhor história de setup do projeto):** as duas entitlements irmãs ficaram de fora *de propósito* — a Apple não concede `extended-virtual-addressing` nem `increased-debugging-memory-limit` a *personal teams*, e mantê-las faz o provisioning falhar de saída. Está tudo escrito no comentário do arquivo, incluindo o que fazer se o projeto migrar para conta paga. No Android, o OpenCL é `required="false"`: acelera onde existe, não quebra onde não existe.

---

## Bloco 1 — `GemmaService`: um dono, um modelo, N conversas

> **Mensagem do bloco:** o modelo é o recurso caro do app. Existe exatamente um dono dele, e todo mundo passa por essa porta.

### 5. [`lib/core/services/gemma/i_gemma_service.dart`](../lib/core/services/gemma/i_gemma_service.dart)

**Mostre:** o arquivo inteiro (95 linhas) — leia como índice, não linha por linha.

**A frase:** "A interface é o mapa da feature: instalar, carregar, conversar, conversar em sessão isolada, devolver resultado de ferramenta, parar."

**O detalhe:** os dois pares de métodos —`sendMessage`/`sendSessionMessage` e `sendToolResult`/`sendSessionToolResult`. A existência do par é o que permite duas personas sobre um modelo. Leia em voz alta o docstring de [`sendSessionMessage`](../lib/core/services/gemma/i_gemma_service.dart#L51-L70): ele já explica *por que* existe ("e.g. Nami finances vs. Vegapunk") — é documentação que se sustenta sozinha.

### 6. [`gemma_service_status.dart`](../lib/core/services/gemma/gemma_service_status.dart)

**Mostre:** o arquivo inteiro (26 linhas).

**A frase:** "Cinco estados, `sealed class` — o `switch` no cubit é exaustivo, o compilador cobra estado novo."

**O detalhe:** `GemmaError` carrega `isInstallError`. Essa flag existe porque "falhou o download" (repetir faz sentido) e "falhou o load" (geralmente é memória) pedem telas diferentes.

### 7. [`gemma_service.dart:40-94`](../lib/core/services/gemma/gemma_service.dart#L40-L94) — `initialize` + `_refreshVegapunkChat` + `downloadModel`

**A frase:** "`initialize` pergunta se o arquivo já está no disco. Não está: `NotInstalled`. Está e o modelo não foi aberto: load. Já está aberto: só recria o chat do Vegapunk — reabrir a tela não recarrega o modelo nem derruba a sessão da Nami."

**O detalhe:** o builder fluente do download é bonito de mostrar —
`installModel(...).fromNetwork(url, token: ...).withProgress(cb).install()`. O `withProgress` alimenta a stream de status direto, então a barra de progresso da UI sai de graça.

### 8. [`gemma_service.dart:143-184`](../lib/core/services/gemma/gemma_service.dart#L143-L184) — memória e backend

**Mostre:** `_maxTokens`, `_backendPreference`, `_openModelWithFallback`.

**A frase:** "GPU primeiro por throughput; CPU como último recurso, para uma falha de init do Metal degradar a velocidade em vez de matar a feature."

**O detalhe:** leia o comentário de `_maxTokens` — o E2B suporta 128 K de contexto, e 4096 é escolha nossa, de memória em mobile. E aponte que `_openModelWithFallback` **rethrow** o último erro se os dois backends falharem: o chamador ainda emite `GemmaError`, ninguém continua silenciosamente sem modelo.

### 9. [`gemma_service.dart:186-238`](../lib/core/services/gemma/gemma_service.dart#L186-L238) — `_recreateChat` + `_createVegapunkChat` ⭐

**Este é o trecho mais importante do arquivo.** Se der para mostrar só um trecho do serviço, mostre este.

**A frase:** "Dois níveis de reset. `_recreateChat` é a recarga completa — reabre o modelo e só roda no `loadModel` (ou se um refresh falhar). `_createVegapunkChat` é onde vive toda a configuração do chat: tipo, temperatura, tools, tamanho de resposta. `resetChat` e a reentrada na tela passam só por ele, via `_refreshVegapunkChat`."

**O detalhe (aponte no `createChat`):**
- `temperature: 0.2` (0.15 no modo thinking) — baixa de propósito. Determinismo é o que faz o modelo emitir JSON de tool call confiável.
- `maxOutputTokens: 768` (512 no thinking) — trabalha em par com as `RESPONSE RULES` do prompt; mexer em um sem o outro não muda nada visível.
- `tools: _tools` + `supportsFunctionCalls` + `toolChoice: auto` — os três juntos ligam o function calling nativo.
- Regra da casa que vale enunciar: **nenhuma configuração de modelo pode ser escrita em dois lugares**, porque dois lugares divergem com o tempo.

Note também as sessões abertas sendo fechadas no topo de `_recreateChat`: elas estão amarradas à instância do modelo que vai ser substituída, então não sobrevivem a um reload — inclusive a da Nami. Por isso o refresh barato existe. Isso é o tipo de invariante que só aparece lendo o código.

### 10. [`gemma_service.dart:240-283`](../lib/core/services/gemma/gemma_service.dart#L240-L283) — `sendMessage`

**A frase:** "Um `StreamController` com `onCancel` que chama `stopGeneration`. Quem fecha a stream cancela a inferência — o botão de parar da UI é só um `cancel()`."

**O detalhe:** a montagem do prompt é `styleInstruction + ragContext + texto`. Guarde o `RagContextFraming` para o bloco 2 (item 25), onde ele rende mais.

### 11. [`gemma_service.dart:285-322`](../lib/core/services/gemma/gemma_service.dart#L285-L322) — `sendToolResult`

**A frase:** "A segunda passada. `Message.toolResponse` é API nativa do SDK — não é injeção de texto disfarçada."

### 12. [`gemma_service.dart:324-387`](../lib/core/services/gemma/gemma_service.dart#L324-L387) — `sendSessionMessage` ⭐

**A frase:** "É isso que permite a Nami existir sem um segundo modelo na memória: `model.openChat()` com system prompt próprio, guardado num mapa por `sessionId`, criado na primeira mensagem."

**O detalhe:** a sessão é criada *lazy*, na primeira mensagem, com os parâmetros daquela chamada. E o `closeSession` ([431–435](../lib/core/services/gemma/gemma_service.dart#L431-L435)) libera o KV cache quando a sheet fecha — uma sessão idle segurando cache é memória parada num aparelho que já está no limite.

### 13. [`lib/app/di/core_module.dart:150-205`](../lib/app/di/core_module.dart#L150-L205)

**A frase:** "As tools entram no serviço **antes** de qualquer chat ser criado."

**O detalhe:** mostre o comentário sobre ordem de registro. `IWebSearchService` → `FunctionRegistry` → `IGemmaService` (que faz `setTools`) → `IVegapunkChatRepository`. É uma cadeia em que a ordem importa de verdade, e o comentário no arquivo explica por quê. Bom momento para citar a regra do projeto: nenhum BLoC/Cubit chama `getIt` por dentro — tudo chega pelo construtor.

---

## Bloco 2 — Vegapunk: o chat age dentro do app

> **Mensagem do bloco:** function calling não é enfeite. O chat lê o perfil do usuário, lê o histórico de treino e **grava** treino novo.

### 14. [`tools/tool_handler.dart:37-57`](../lib/features/vegapunk_chat/tools/tool_handler.dart#L37-L57)

**A frase:** "`toFlutterGemmaTool()` gera o JSON Schema da ferramenta a partir do handler. Ninguém escreve schema à mão neste projeto."

**O detalhe:** a classe carrega descrição em PT **e** EN (`descriptionPt`). O modelo recebe a declaração no idioma do usuário — para um modelo de 2 B, isso muda a taxa de acerto na escolha da tool.

### 15. [`tools/handlers/get_user_profile_handler.dart`](../lib/features/vegapunk_chat/tools/handlers/get_user_profile_handler.dart) — um handler concreto

**Mostre:** o `execute` inteiro (a partir da linha 38).

**A frase:** "Um handler é: nome, descrição, parâmetros, e um `execute` que devolve `ToolResult`. Este lê o perfil do usuário autenticado."

**O detalhe:** `parameterDescriptions` é `{}` — tool sem argumento. Serve para mostrar que o schema acompanha o handler, mesmo vazio. **Guarde o conteúdo do payload para o bloco 5**: ele está sendo reescrito agora, e a mudança é a melhor lição de prompt engineering do projeto.

### 16. [`tools/function_registry.dart:59-64`](../lib/features/vegapunk_chat/tools/function_registry.dart#L59-L64)

**A frase:** "O registry mapeia nome → handler, e sabe se converter na lista de `Tool` do SDK."

**O detalhe:** existe também `systemPromptDeclarations()` logo abaixo — a forma antiga, de declarar as funções em texto no system prompt. Está marcada como fallback. Vale mostrar porque explica a evolução: **antes** se pedia por texto, **hoje** o SDK recebe schema estruturado.

### 17. [`tools/tool_intent_detector.dart`](../lib/features/vegapunk_chat/tools/tool_intent_detector.dart)

**Mostre:** `detect` (linha 16) e, se der tempo, `_matchesSaveWorkoutIntent` (linha 226).

**A frase:** "Antes de gastar uma passada de inferência, a gente olha a mensagem. 'Pesquise na internet sobre X' não precisa de um LLM para ser classificada."

**O detalhe:** o detector não só classifica, ele **extrai argumentos** — a query de busca em `_extractSearchQuery` (linha 148) e o nome do personagem em `_matchesCharacterIntent` (linha 245, confiança média: só sugere, não força). Quando a confiança é alta, esse é o caminho mais rápido percebido pelo usuário — a tool executa sem o modelo ter falado nada ainda.

### 18. [`data/repository/vegapunk_chat_repository.dart`](../lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart) ⭐ o coração da feature

Mostre em três paradas:

**(a) [linhas 82-133](../lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart#L82-L133) — camada 1.**
"Intenção de alta confiança: executa a tool, injeta o resultado como `[SEARCH RESULTS]`, e só então pede a resposta ao modelo." Aponte o truncamento em 1500 caracteres — contexto é orçamento.

**(b) [linhas 135-252](../lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart#L135-L252) — camadas 2 e 3.**
O `switch` sobre `ModelResponse` é o trecho mais didático do arquivo: `TextResponse` faz streaming, `FunctionCallResponse` é a chamada nativa, `ParallelFunctionCallResponse` é o lote (usamos a primeira), `ThinkingResponse` é descartada hoje. Depois vem a volta pelo `sendToolResult` e, se nada disso pegou, o `tryParse` do texto acumulado (linha 213).

**(c) [linhas 257-278](../lib/features/vegapunk_chat/data/repository/vegapunk_chat_repository.dart#L257-L278) — as sentinelas.**
"A repository precisa avisar a UI que uma ferramenta está rodando, sem conhecer a UI. Solução: tokens invisíveis na própria stream."
`\x00TOOL_START:<nome>\x00` e `\x00TOOL_DONE\x00` (`toolStartSentinel`, `toolDoneSentinel`, `parseToolName`). É a parte que as pessoas acham mais esperta — e a que mais gera pergunta. Tenha pronta a resposta: sim, é um canal lateral dentro da stream de texto; funciona porque `\x00` nunca aparece em texto gerado.

### 19. [`bloc/vegapunk_chat_cubit.dart:203-237`](../lib/features/vegapunk_chat/bloc/vegapunk_chat_cubit.dart#L203-L237)

**A frase:** "E aqui é o outro lado da sentinela: o cubit intercepta, põe `activeToolName` no estado, e o token nunca chega na bolha de mensagem."

**O detalhe (se sobrar tempo):** [linha 87](../lib/features/vegapunk_chat/bloc/vegapunk_chat_cubit.dart#L87) — `_initRag()` é chamado **sem `await`**. Baixar o modelo de embedding não pode travar a abertura do chat. É uma decisão de UX escrita no código, com comentário explicando. Logo acima, os tokens são emitidos em lotes de **80 ms** (linha 190) e um *watchdog* de **90 s** (`_generationTimeout`, linha 51) encerra uma geração travada.

### 20. [`presentation/vegapunk_chat_screen.dart:143-157`](../lib/features/vegapunk_chat/presentation/vegapunk_chat_screen.dart#L143-L157)

**A frase:** "Seletor de satélite, indicador de ferramenta ativa — a UI é só reflexo do estado."

**O detalhe:** os 7 satélites (Stella, Shaka, Lilith, Edison, Pythagoras, Atlas, York) mudam o estilo da resposta por `styleInstruction`, **sem** recriar o chat nem perder o histórico. E o `_ToolActivityIndicator` mostra o nome da ferramenta já traduzido — o mapeamento está por volta da [linha 487](../lib/features/vegapunk_chat/presentation/vegapunk_chat_screen.dart#L487).

### 21. [`presentation/widgets/model_download_overlay.dart`](../lib/features/vegapunk_chat/presentation/widgets/model_download_overlay.dart)

**Mostre:** o `switch` do `build`, no topo.

**A frase:** "Um LLM local significa que o usuário espera alguns GB na primeira vez. Isso não é detalhe de infra — é a primeira tela da feature, e tem tratamento próprio."

### 22. [`core/ai/prompts/personas/vegapunk_prompt.dart`](../lib/core/ai/prompts/personas/vegapunk_prompt.dart)

**Mostre:** o arquivo inteiro (58 linhas) — cabe na tela.

**A frase:** "Prompt curto, em seções numeradas, bilíngue. Modelo de 2 B responde muito melhor a regras enumeradas do que a prosa."

**O detalhe:** leia o docstring no topo — ele diz explicitamente que **não** há declaração de ferramenta no prompt, porque isso agora é o `tools` do `createChat`. É a documentação de uma decisão de arquitetura morando no arquivo certo.

### 23. [`core/ai/prompts/framing/rag_context_framing.dart`](../lib/core/ai/prompts/framing/rag_context_framing.dart)

**Mostre:** o arquivo inteiro (~30 linhas). **Ótimo fechamento de bloco.**

**A frase:** "Dois enquadramentos para o mesmo mecanismo. `loreReference` diz 'leia em silêncio, use só se for relevante'. `factualData` diz 'use estes dados diretamente'."

**O detalhe:** mesmo modelo, mesma stream, comportamento diferente — o que muda é a moldura do texto injetado. Vegapunk precisa de imersão (não pode recitar a base de conhecimento); Nami precisa citar número. Aponte também que as tags ficam **em inglês** nos dois idiomas, de propósito: o modelo aprende a reconhecer o mesmo marcador sempre.

---

## Bloco 3 — RAG: busca semântica sem sair do aparelho

> **Mensagem do bloco:** o plugin tem **um** vector store ativo por processo. Duas features usando RAG é o que dita a arquitetura aqui.

### 24. [`core/services/rag/rag_store_coordinator.dart`](../lib/core/services/rag/rag_store_coordinator.dart) ⭐ mostre inteiro

106 linhas, e o docstring de cabeçalho já conta a história toda. **Se você só puder mostrar um arquivo de RAG, é este.**

**A frase:** "O `ServiceRegistry` do plugin guarda um único `vectorStoreRepository`. Sem coordenação, a última feature a inicializar reaponta o ponteiro global para o próprio banco — e a busca da outra passa a consultar o banco errado, sem erro nenhum."

**O detalhe:**
- `withStore(owner, dbFile, op)` é uma **fila única**: a troca de store e a operação rodam juntas, uma por vez, então a outra feature não reaponta o store no meio de uma busca. A troca é memoizada: só reabre o SQLite quando a feature ativa muda. Chamada aninhada do mesmo dono roda direto (via `Zone`).
- `ensureEmbedderInstalled()` roda no máximo uma vez por processo — e resseta a memoização se falhar, para a próxima chamada tentar de novo.
- Leia o comentário das linhas 53–60 em voz alta: instalar o embedder **não basta**, é preciso chamar `getActiveEmbedder()`, senão as APIs de auto-embed falham com "no embedding model is active". É o tipo de detalhe que só se aprende batendo a cabeça, e está documentado no lugar certo.

**A regra para levar para casa:** ninguém chama `initializeVectorStore()` direto. Um `grep initializeVectorStore lib/` deve retornar **só** o coordinator — e isso é uma verificação que dá para fazer ao vivo.

### 25. [`core/services/rag/rag_service.dart`](../lib/core/services/rag/rag_service.dart)

**Mostre:** [20–42](../lib/core/services/rag/rag_service.dart#L20-L42) (cap e over-fetch), [81–87](../lib/core/services/rag/rag_service.dart#L81-L87) (`_inStore`), [169–223](../lib/core/services/rag/rag_service.dart#L169-L223) (`searchLore` / `searchSession` / `_scopedSearch`).

**A frase:** "Cada operação roda dentro da fila do coordinator, já apontada para o próprio banco — não só na inicialização."

**O detalhe:**
- O cap de 20 documentos de sessão tem um comentário longo e honesto explicando que o cap é em memória e **não** é reverificado no disco, porque o plugin só tem `clearVectorStore()` (sem delete por documento). Trade-off registrado, não esquecido.
- `_overFetchFactor = 4`: busca-se 4× o `topK` e filtra-se por namespace depois, porque pedir exatamente `topK` pode devolver zero resultados de sessão se as lore rankearem melhor. É um detalhe sutil de RAG que vale mostrar.

### 26. [`features/vegapunk_chat/data/knowledge/one_piece_knowledge_base.dart`](../lib/features/vegapunk_chat/data/knowledge/one_piece_knowledge_base.dart)

**Mostre:** [1–37](../lib/features/vegapunk_chat/data/knowledge/one_piece_knowledge_base.dart#L1-L37) e **um** `RagDocument` de exemplo ([38–47](../lib/features/vegapunk_chat/data/knowledge/one_piece_knowledge_base.dart#L38-L47)). Não role as 422 linhas.

**A frase:** "A base de conhecimento é código: `const` de `RagDocument`, bilíngue, agrupada por categoria — Vegapunk e satélites, personagens, frutas, arcos."

**O detalhe:** `getDocumentsForCategories` permite carregar só um subconjunto. E porque são `const`, existe um snapshot em memória que o `clearSession()` usa para restaurar a base depois de limpar a store inteira — que é a única forma de "apagar só a sessão" com um plugin que não tem delete por documento. A reindexação só acontece quando o *fingerprint* (ids ordenados) muda: mudar o texto de um documento exige mudar o id.

### 27. [`features/nami_finances/data/services/nami_rag_service.dart`](../lib/features/nami_finances/data/services/nami_rag_service.dart)

**Mostre:** [13–40](../lib/features/nami_finances/data/services/nami_rag_service.dart#L13-L40) (store por usuário, schema version, threshold) e [96–148](../lib/features/nami_finances/data/services/nami_rag_service.dart#L96-L148) (`syncMonth` / `_indexExpense`).

**A frase:** "O segundo consumidor, com `owner` e `.db` próprios. Cada despesa vira um documento indexado."

**O detalhe:** existe `_schemaVersion` com migração — quando o formato do documento muda, os antigos são reindexados. E `defaultThreshold = 0.55`: busca por semelhança precisa de um piso, senão qualquer coisa "casa" com qualquer coisa.

---

## Bloco 4 — Nami: o padrão oposto

> **Mensagem do bloco:** a mesma infraestrutura, uma escolha de arquitetura invertida. E para números, a invertida é a certa.

### 28. [`bloc/chat/nami_chat_bloc.dart:103-145`](../lib/features/nami_finances/bloc/chat/nami_chat_bloc.dart#L103-L145) — `_ensureGemmaReady`

**Comece por aqui**, é a parte que ninguém adivinha lendo de fora.

**A frase:** "A Nami é passageira do modelo. Ela espera o `GemmaReady` — e só dispara o `initialize()` se **ninguém** começou a carregar ainda."

**O detalhe:** leia o comentário: chamar `initialize()` com um load em curso recriaria o chat e **apagaria uma conversa do Vegapunk em andamento**. E o caminho triste vira `NamiChatFailure.modelNotInstalled`, que a sheet traduz para uma mensagem de produto (`namiChatModelNotInstalled`): *"Modelo de IA ainda não foi baixado — abra o chat do Vegapunk para instalá-lo."* Ou seja: o chat do Vegapunk é a superfície de instalação do modelo no app. Se o modelo já estiver em `GemmaError`, ela falha na hora (nenhum status novo viria sozinho), e 2 min sem status também viram `modelLoadFailed` — a sheet nunca fica presa no "Preparando Nami...".

### 29. [`bloc/chat/nami_intent_router.dart`](../lib/features/nami_finances/bloc/chat/nami_intent_router.dart) ⭐

**Mostre:** o docstring (linhas 6–13) e o `resolve` (a partir da 17).

**A frase:** "Aqui quem decide a ferramenta é o Dart, não o modelo. Função pura, testada."

**O detalhe:** o docstring explica *por que* — o modelo pequeno tende a "descrever" o uso de uma ferramenta sem emitir a chamada, e a deturpar números. Mostre a extração de valores: `"60 a 80 mil"` → usa o maior como preço (pior caso). Esse tipo de regra de negócio em Dart é testável de um jeito que prompt não é.

### 30. [`bloc/chat/nami_chat_bloc.dart:242-306`](../lib/features/nami_finances/bloc/chat/nami_chat_bloc.dart#L242-L306)

**Mostre:** `_generateAnswer` e depois `_stripToolCallJson`.

**A frase:** "Router decide, tool executa, resultado já formatado entra como contexto — e **nenhuma tool é anexada** à passada de geração. O modelo não tem por onde inventar uma chamada."

**O detalhe:** `_stripToolCallJson` é defesa em profundidade — se o modelo vazar JSON de tool call como prosa, é removido antes de chegar na tela, usando o mesmo parser do fallback. Bom exemplo de "assuma que o modelo pequeno vai errar e limpe depois".

### 31. [`tools/find_expenses_handler.dart`](../lib/features/nami_finances/tools/find_expenses_handler.dart)

**Mostre:** o docstring (linhas 12–31) e o `execute` (a partir da 86).

**A frase:** "Esta é a tool que justifica o RAG existir na Nami: achar 'aquela viagem pra praia' quando o usuário não sabe a data nem o valor."

**O detalhe:** o fluxo é `query → RAG → ids de despesa → dados reais`. O RAG **localiza**; os números vêm da fonte estruturada. Ninguém confia no embedding para devolver valor monetário.

### 32. [`presentation/widgets/nami_chat_sheet.dart`](../lib/features/nami_finances/presentation/widgets/nami_chat_sheet.dart)

**Mostre:** rápido, só para a plateia ver que é uma **bottom sheet**, não uma tela.

**A frase:** "A forma diz o que ela é: assistente contextual sobre os números que já estão na tela, não um destino para onde o usuário navega."

---

## Bloco 5 — Bônus: a lição de prompt engineering que virou código

> Esta mudança já está no código (era o diff "na bancada" na primeira versão deste roteiro). Mostre os dois arquivos.

### 33. [`core/ai/prompts/personas/vegapunk_prompt.dart`](../lib/core/ai/prompts/personas/vegapunk_prompt.dart#L22) — seção DATA RULES

Uma seção **DATA RULES** (linha 22) / **REGRAS DE DADOS** (linha 45):

> *"Nunca invente, chute ou altere nome, número ou fato vindo de [SEARCH RESULTS] ou resultado de ferramenta — repita exatamente como recebido. Se um campo disser 'not set' ou estiver ausente, diga que ainda não foi informado; nunca invente um valor."*

### 34. [`tools/handlers/get_user_profile_handler.dart:38-79`](../lib/features/vegapunk_chat/tools/handlers/get_user_profile_handler.dart#L38-L79)

**A frase:** "Instrução no prompt não bastou. A correção de verdade foi mudar o **formato do dado** entregue ao modelo."

Três mudanças, e cada uma tem uma razão:

| Antes | Depois | Por quê |
|---|---|---|
| `'heightCm': user.heightCm` (175) | `'height_formatted': '1.75 m'` | o modelo estava fazendo conversão de unidade — e errando. Entregue já convertido e ele só copia. |
| `'weightKg': user.weightKg` | `'weight_formatted': '72.5 kg'` | idem: arredondamento é decisão nossa, não dele |
| `null` | `'not set'` | `null` desaparece na serialização e o modelo preenche o buraco com invenção |
| — | campo `'note'` no payload | instrução **dentro** do resultado da tool, no ponto exato onde o dado é lido |

**A lição para fechar a apresentação:** com um modelo de 2 B, você não conserta alucinação só pedindo com mais firmeza no system prompt. Você conserta **não dando ao modelo nada para decidir** — nem conversão de unidade, nem arredondamento, nem o que fazer com um campo vazio. O mesmo princípio do router da Nami, aplicado num nível mais fino.

---

## Apêndice A — Testes para rodar ao vivo

Se a plateia perguntar "e como vocês garantem isso?", tudo isso roda sem device, em poucos segundos:

```bash
# tudo de uma vez — o que cabe numa demo ao vivo
fvm flutter test test/features/nami_finances/ test/core/services/rag/ test/features/vegapunk_chat/
```

Se quiser rodar um por vez, na ordem em que rendem mais conversa:

```bash
# a decisão de ferramenta da Nami — função pura, o caso mais testável da stack
fvm flutter test test/features/nami_finances/nami_intent_router_test.dart

# a matemática financeira que o modelo NÃO faz
fvm flutter test test/features/nami_finances/finance_math_test.dart

# o fallback textual de tool call
fvm flutter test test/features/nami_finances/tool_call_text_fallback_test.dart

# detector de intenção do Vegapunk (camada 1)
fvm flutter test test/features/vegapunk_chat/tools/tool_intent_detector_test.dart

# RAG: idempotência do knowledge base, reindexação de sessão, cap de documentos
fvm flutter test test/core/services/rag/rag_service_test.dart
fvm flutter test test/features/vegapunk_chat/
```

Dois nomes de teste que valem ler na saída, porque explicam a feature melhor que qualquer slide:

- `does not turn a trailing unanswered user message into a document`
- `only rebuilds up to maxSessionDocuments most recent turns`

O ponto a fazer: **o que é determinístico está testado** — router, matemática financeira, parser de tool call, detector de intenção, fingerprint do knowledge base, reindexação de sessão, round-trip do histórico em disco. (Ainda sem teste: `RagStoreCoordinator`.) O que depende do modelo é verificado no aparelho, e é justamente por isso que tanta lógica foi puxada para fora do modelo.

## Apêndice B — O que não mostrar

| Arquivo | Por quê |
|---|---|
| `.env` | tem token real do HuggingFace |
| `one_piece_knowledge_base.dart` inteiro | 422 linhas de conteúdo; mostre um `RagDocument` e siga |
| `tool_intent_detector.dart` inteiro | 302 linhas de regex; mostre `detect` e um `_matches*` |
| `l10n/app_localizations*.dart` | gerado, milhares de linhas |
| `.specs/features/vegapunk-chat/` | registra a intenção antiga (Qwen3 `.task`, mediapipe, RAG como "fase futura"). O topo do `design.md` resume o pipeline atual; o resto é histórico — o código é a fonte da verdade |
| `firebase_options.dart` | gerado |

## Apêndice C — Perguntas que vão aparecer

**"Quanto de RAM isso come?"**
O E2B com `maxTokens: 4096` é a maior fonte de pressão de memória do app. É decisão consciente: o modelo foi mantido pela qualidade de function calling e multilíngue. No iOS a `increased-memory-limit` é o que viabiliza o load.

**"O usuário baixa 2 GB? Ninguém vai usar."**
O download é sob demanda, só ao abrir o chat, com progresso e retry, e no Android usa foreground service acima de 500 MB. Quem nunca abre o Vegapunk nunca baixa nada — e o app abre igual.

**"Por que não usar Gemini para tudo e ser mais rápido?"**
Porque três das cinco ferramentas do Vegapunk leem ou escrevem dado corporal, e a Nami inteira roda sobre renda e extrato. A regra do projeto é: dado do usuário não sai do aparelho. O Gemini continua no app — para arte de personagem, arte de tripulação e receitas, onde o prompt não identifica ninguém.

**"Dá para trocar por um modelo menor?"**
Tecnicamente é só `.env` — o `_determineModelType` deriva do nome do arquivo. Mas é decisão de produto: foi avaliado e descartado, a perda em function calling e multilíngue não valeu o ganho de performance. Gemma 4 E2B e `maxTokens: 4096` ficam fixos; memória se resolve com entitlement, fallback GPU→CPU, menos sessões e saídas menores.

**"E se duas features usarem RAG ao mesmo tempo?"**
É exatamente o que o `RagStoreCoordinator` resolve. O plugin tem um store ativo por processo; o coordinator é o dono único do ponteiro, e cada serviço se reafirma antes de toda operação.

**"Por que a Nami não deixa o modelo escolher a ferramenta, como o Vegapunk?"**
Porque a resposta dela é numérica. Um modelo de 2 B tende a descrever o uso da ferramenta sem chamá-la, e a deturpar valores. Decidir em Dart e deixar o modelo só narrar é o caminho confiável — e testável.
