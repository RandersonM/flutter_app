# Spec: Vegapunk Chat Memory

**Feature ID:** VGP-MEM
**Status:** Draft
**Predecessor:** `.specs/features/vegapunk-rag/spec.md` (RAG já implementado)
**Contexto:** ver `context.md` — leia antes: contém 3 correções ao pedido
original e 1 decisão de produto ainda aberta (D1).

---

## Visão geral

O Vegapunk chat hoje começa **sempre vazio** ao abrir a tela, e a memória de
sessão (RAG) é **apagada a cada abertura**. Esta spec cobre duas capacidades
relacionadas, mas entregáveis independentemente:

- **Fase 1 — Persistência de histórico.** Mensagens sobrevivem ao fechar a
  tela e ao reiniciar o app; a tela reabre populada com as últimas N.
- **Fase 2 — Memória semântica de longo prazo.** O RAG de sessão para de ser
  apagado a cada abertura, passa a ser reconstruível a partir do histórico
  persistido, e para de disputar espaço de busca com a base de lore.

A Fase 1 entrega valor sozinha (é o que o usuário pediu explicitamente: "abrir
a tela populada com parte das mensagens passadas"). A Fase 2 é o que faz o
Vegapunk de fato "lembrar" semanticamente entre sessões — sem ela, a Fase 1
sozinha só resolve a UI, não a memória do modelo.

---

## Fora de escopo

- Paginação de histórico antigo (scroll-back carregando mais do que as N
  mensagens iniciais) — o desenho não deve impedir isso depois (ver
  `design.md`), mas não é entregue aqui.
- Sincronização de histórico entre dispositivos (Firestore) — hoje tudo em
  Vegapunk chat é local/on-device; este desenho mantém isso.
- Resolver `Filter`/`FilterSchema` do flutter_gemma para filtragem no nível do
  banco (ver `context.md`, C3) — permanece filtragem no cliente por prefixo.
- Sumarização de turnos antigos via LLM — só entra se D1/Opção C for escolhida
  (ver `context.md`).

---

## Fase 1 — Persistência de histórico

### Requisitos

| ID | Requisito |
|----|-----------|
| VGP-MEM-01 | O sistema SHALL persistir cada `ChatMessage` enviada/recebida em uma Hive box dedicada ao Vegapunk chat, sobrevivendo ao fechar a tela e a reinícios do app |
| VGP-MEM-02 | A persistência SHALL usar **uma única box** para todo o histórico do Vegapunk chat — não uma box por satélite/persona (ver `context.md`, C1) |
| VGP-MEM-03 | `ChatMessage` SHALL ganhar um campo `timestamp` (não existe hoje), necessário para ordenação determinística e para a política de retenção da Fase 2 |
| VGP-MEM-04 | `ChatMessage` SHALL opcionalmente registrar qual satélite estava ativo quando a mensagem foi gerada (metadado de exibição futura; não particiona o histórico) |
| VGP-MEM-05 | Ao abrir a tela do chat, o sistema SHALL carregar as últimas **N=20** mensagens (configurável) em ordem cronológica (mais antiga → mais recente) e popular `VegapunkChatReady.messages` com elas |
| VGP-MEM-06 | Mensagens além das últimas N SHALL permanecer no disco, não lidas — nenhum processamento (leitura, parse, embedding) deve tocar nelas no caminho de abertura de tela |
| VGP-MEM-07 | Novas mensagens enviadas durante a sessão SHALL ser persistidas de forma incremental (append), não por reescrita da box inteira |
| VGP-MEM-08 | `reset()` do chat (botão de limpar conversa) SHALL limpar o histórico persistido, não só o estado em memória |
| VGP-MEM-09 | O novo Hive typeId SHALL ser reivindicado no bloco **50–59** em `HiveTypeIds`, seguindo o padrão `_Registration<T>` já existente em `HiveStorageService.adapters` |
| VGP-MEM-10 | A carga do histórico SHALL ser feita através de uma interface abstrata (`I*Repository`), injetada no `VegapunkChatCubit` via construtor — nunca via `getIt` dentro do cubit |

### Critérios de aceite

- Enviar 3 mensagens, fechar a tela (`pop`), reabrir → as 3 mensagens aparecem
  na ordem correta, sem duplicação.
- Matar o processo do app (não só navegar), reabrir → mesmo resultado.
- Com 200 mensagens no histórico, abrir a tela carrega só as últimas 20 — sem
  spike perceptível de tempo de abertura em relação a uma box com 20 mensagens
  no total.
- Apertar "limpar conversa" e reabrir a tela → histórico vazio, não as
  mensagens antigas voltando.

### Edge cases

- Box vazia (primeira abertura de todas) → `messages: []`, comportamento
  idêntico ao atual.
- Mensagem sendo escrita no meio de um `close()` do cubit (usuário sai durante
  o streaming) → o turno em andamento não deve ser persistido pela metade;
  só o texto final commitado (`_commitStreamingMessage`) é gravado.
- Corrupção/erro de leitura da box (mesma classe de falha que
  `FeaturedCharacterRepository._initHive` já trata) → cair para histórico
  vazio em vez de propagar exceção e quebrar a abertura da tela.

---

## Fase 2 — Memória semântica de longo prazo

### Requisitos

| ID | Requisito |
|----|-----------|
| VGP-MEM-20 | `RAGService.setKnowledgeBase()` SHALL se tornar idempotente: só executar `clearVectorStore()` + recarregar quando o conjunto de categorias solicitado (ou o conteúdo da KB) mudou desde a última chamada, usando um fingerprint persistido em Hive (mesmo padrão de `NamiRagService`/`_schemaVersion`) |
| VGP-MEM-21 | A chamada de `setKnowledgeBase` com as mesmas categorias de antes (o caso comum: tela sempre abre sem `targetCategories`) SHALL ser um no-op após a primeira vez — sem apagar documentos de sessão |
| VGP-MEM-22 | Documentos de sessão (RAG) SHALL usar prefixo de id `sess:` (trocando o `sess-` atual); documentos de lore mantêm seus ids atuais sem prefixo — ver `context.md` para por que não é preciso reescrever os 36 ids da KB |
| VGP-MEM-23 | `VegapunkChatRepository` SHALL substituir a única busca `_rag.search(text, topK: 2)` por **duas buscas com escopo próprio**: lore (sem prefixo `sess:`) e sessão (prefixo `sess:`), cada uma com seu `topK` e um `threshold` mínimo de similaridade |
| VGP-MEM-24 | Quando a busca de sessão não retorna nada acima do `threshold`, isso SHALL ser tratado como "sem contexto de conversa relevante" — um resultado válido, não uma falha nem um fallback para trazer os 2 documentos menos ruins |
| VGP-MEM-25 | Ao abrir a tela (ou após um `clearVectorStore` disparado por mudança de categoria), o índice de sessão SHALL poder ser reconstruído a partir do histórico persistido na Fase 1 — não depender só do buffer de turno em memória, que hoje é a única fonte e se perde ao trocar de cubit |
| VGP-MEM-26 | A reconstrução do índice de sessão (VGP-MEM-25) SHALL viver na camada de feature (Vegapunk), não em `RAGService` — `RAGService` é um serviço genérico (`core/services/rag/`) e não deve importar tipos de `features/vegapunk_chat/` |
| VGP-MEM-27 | **[PENDENTE DE DECISÃO — ver `context.md`, D1]** A política de retenção de documentos de sessão SHALL seguir a opção escolhida entre: (A) manter `_maxSessionDocs=20` como teto global; (B) expirar por idade usando `timestamp` (VGP-MEM-03); (C) sumarizar lotes antigos em menos documentos. Nenhuma opção é o default até decisão explícita |

### Critérios de aceite

- Abrir a tela do chat 5 vezes em sequência (sem reiniciar o app) → documentos
  de sessão gravados na 1ª abertura ainda são encontrados por busca semântica
  na 5ª.
- Perguntar algo que só faz sentido com contexto de uma troca anterior na
  mesma sessão → a resposta usa esse contexto (via `searchSession`), não é
  substituída por 2 documentos de lore genéricos.
- Perguntar algo sem nenhum contexto de conversa prévio relevante → nenhum
  documento de sessão de baixa relevância é injetado; o prompt segue só com
  lore (ou vazio, se lore também não bater).
- Trocar `targetCategories` de uma abertura para outra (fluxo hoje não usado
  pela UI, mas suportado pela API) → a KB é recarregada corretamente para o
  novo conjunto, sem lixo do conjunto anterior.

### Edge cases

- Primeira execução após esta feature ser publicada (fingerprint inexistente)
  → tratar como "mudou", fazer o clear+load normal uma vez, gravar o
  fingerprint.
- `clearVectorStore()` falha (erro de I/O do SQLite) → mesmo tratamento de
  erro que `RAGService` já tem hoje (log + estado degradado, nunca propaga
  para quebrar o chat).
- Reconstrução do índice de sessão (VGP-MEM-25) chamada com histórico vazio
  (usuário nunca conversou antes) → no-op, sem erro.

---

## Rastreabilidade

| Requisito | Componente principal |
|---|---|
| VGP-MEM-01..04, 09 | `ChatMessage` model + adapter, `HiveTypeIds` |
| VGP-MEM-02, 05, 06, 08, 10 | `IVegapunkChatHistoryRepository` (novo) |
| VGP-MEM-05, 07 | `VegapunkChatCubit` |
| VGP-MEM-20, 21 | `RAGService.setKnowledgeBase` |
| VGP-MEM-22, 23, 24 | `IRAGService` (interface), `VegapunkChatRepository` |
| VGP-MEM-25, 26 | `VegapunkChatCubit` (orquestração), `IVegapunkChatHistoryRepository` |
| VGP-MEM-27 | Depende da decisão D1 — componente a definir |
