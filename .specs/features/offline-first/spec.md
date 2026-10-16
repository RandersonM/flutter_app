# Offline-First v1 — Feature Specification

> **Versão**: 1.0 (revisada — escopo reduzido para v1)
> **Status**: Aprovada para Design

## Problem Statement

O OpFan depende de internet para quase tudo. Quando o usuário está offline, o app falha silenciosamente, trava em loading ou exibe erros genéricos sem nenhum contexto. A v1 resolve isso com três ações focadas: (1) sinalizar claramente que o app está offline com um banner persistente, (2) manter a sessão do usuário autenticada offline usando o token Firebase já cacheado em Hive, (3) garantir que Nami Finances e Vegapunk Chat continuem funcionando mesmo sem internet. Todas as outras telas simplesmente exibem um estado de bloqueio até que a conexão seja restaurada.

## Goals

- [ ] Detectar conectividade em tempo real e exibir um banner global quando offline
- [ ] Preservar a sessão autenticada offline sem pedir novo login
- [ ] Exibir a Home com placeholders e dados fake quando offline (não crash)
- [ ] Manter Nami Finances 100% funcional offline (Hive já é o backend real)
- [ ] Manter Vegapunk Chat 100% funcional offline (Gemma é local; `searchInternet` retorna erro legível)
- [ ] Bloquear todas as outras telas com um overlay de "sem internet" quando offline

## Out of Scope — v1

| Feature | Razão |
|---|---|
| Sync de finanças com Firestore | Nami Finances já usa Hive como storage primário; Firestore não está implementado |
| Persistência offline para Sanji Cooking, Zoro Workout, etc. | Fora do escopo v1; serão bloqueadas |
| Read-through cache para character/devil fruit browser | Complexidade desnecessária para v1 |
| Indicador de sync pendente | Não há sync na v1 |
| Autenticação offline (primeiro login) | Auth via Google/Firebase exige rede; apenas sessão existente é preservada |
| Background sync | iOS/Android restrições; fora do MVP |

---

## User Stories

### P1: Banner global de conectividade ⭐ MVP

**User Story**: Como usuário, quero ver um aviso claro quando estou sem internet, para entender por que algumas funcionalidades não estão disponíveis.

**Why P1**: É o fundamento de toda a experiência offline. Sem feedback visual, o usuário pensa que o app está com defeito.

**Acceptance Criteria**:

1. WHEN o dispositivo perde conexão THEN o sistema SHALL exibir um banner amarelo/laranja no topo da tela com mensagem localizada (en/pt) indicando ausência de internet
2. WHEN o banner é exibido THEN ele SHALL conter um ícone de wifi-off e o texto `offlineBannerMessage`
3. WHEN a conexão é restaurada THEN o banner SHALL desaparecer automaticamente sem ação do usuário
4. WHEN o evento de conectividade muda rapidamente (flicker) THEN o sistema SHALL debouncar a mudança por 1500ms antes de atualizar o banner
5. WHEN o banner está visível THEN ele SHALL ser exibido em todas as telas do app (via widget global no MaterialApp)

**Independent Test**: Modo avião → qualquer tela → banner amarelo aparece no topo. Voltar online → banner some.

---

### P1: Sessão offline — manter login ⭐ MVP

**User Story**: Como usuário autenticado, quero que o app me reconheça offline, para não ser redirecionado para a tela de login quando perco internet.

**Why P1**: É a preocupação #1 do usuário. Ser deslogado ao perder internet é uma péssima experiência.

**Context**: O `AuthService` já persiste `UserModel` no Hive box `auth_cache` e usa `FirebaseAuth` token. O problema é que `isSessionValid()` chama `getIdToken(true)` (força refresh — requer internet) e falha offline. Firebase Auth SDK mantém o usuário logado localmente por padrão, mas o `getIdToken(true)` força uma validação remota que falha sem rede.

**Acceptance Criteria**:

1. WHEN o usuário está autenticado e perde conexão THEN o `AuthBloc` SHALL continuar em estado `AuthAuthenticated` sem emitir `AuthUnauthenticated`
2. WHEN o app é iniciado offline e há um `UserModel` válido no Hive + `FirebaseAuth.currentUser != null` THEN o sistema SHALL considerar a sessão válida e emitir `AuthAuthenticated`
3. WHEN o app é iniciado offline e não há usuário cacheado no Hive THEN o sistema SHALL emitir `AuthUnauthenticated` e exibir a tela de login (com banner offline)
4. WHEN o `isSessionValid()` falha por `SocketException` ou erro de rede THEN o sistema SHALL tratar como "sessão válida local" se houver `UserModel` em cache e `FirebaseAuth.currentUser != null`
5. WHEN o usuário está em sessão offline e a conexão é restaurada THEN o sistema SHALL tentar silenciosamente renovar o token sem interromper a experiência do usuário

**Independent Test**: Logar → modo avião → fechar o app → reabrir → verificar que vai direto para Home sem tela de login.

---

### P1: Home com placeholders offline ⭐ MVP

**User Story**: Como usuário offline, quero ver a Home carregada com conteúdo de placeholder, para saber que o app está funcionando mas sem dados reais.

**Why P1**: Sem isso, a Home ficaria em loading eterno ou exibiria erro, quebrado a experiência.

**Acceptance Criteria**:

1. WHEN o usuário abre a Home offline THEN o `HomeBloc` SHALL emitir `HomeOffline` em vez de tentar carregar dados remotos
2. WHEN o estado é `HomeOffline` THEN a Home SHALL exibir o card de personagem com dados estáticos de placeholder (nome "Monkey D. Luffy", bounty "1.500.000.000", imagem local do logo)
3. WHEN o estado é `HomeOffline` THEN as estatísticas SHALL exibir placeholders visuais shimmer ou valores "—"
4. WHEN o estado é `HomeOffline` THEN o banner dinâmico de vídeo SHALL ser ocultado ou substituído por uma imagem estática local
5. WHEN a conexão é restaurada THEN o `HomeBloc` SHALL recarregar os dados reais automaticamente

**Independent Test**: Modo avião → Home → card com "Monkey D. Luffy" e shimmer nas estatísticas. Sem erros, sem loading eterno.

---

### P1: Nami Finances funcional offline ⭐ MVP

**User Story**: Como usuário, quero acessar e editar minhas finanças offline, para não perder controle financeiro quando estou sem internet.

**Why P1**: O Hive já é o backend atual do Nami Finances — não há Firestore para este módulo. Logo, offline é o caso natural. Só precisamos garantir que o BLoC não tente nada de rede e que a navegação não seja bloqueada.

**Acceptance Criteria**:

1. WHEN o usuário navega para Nami Finances offline THEN a tela SHALL abrir normalmente (Hive não precisa de rede)
2. WHEN o usuário cria/edita finanças offline THEN o sistema SHALL salvar no Hive imediatamente, sem erros
3. WHEN o usuário está offline na tela de finanças THEN nenhum aviso de "sem internet" SHALL ser exibido (a feature é totalmente local)
4. WHEN o usuário está online na tela de finanças THEN o comportamento SHALL ser idêntico ao offline (Hive é sempre o storage)
5. WHEN qualquer operação Hive lança exceção (ex: storage cheio) THEN o `NamiFinancesBloc` SHALL emitir `NamiFinancesError` com mensagem amigável

**Independent Test**: Modo avião → abrir Nami Finances → criar entrada de receita e despesa → verificar que salvou → reabrir a tela → verificar dados persistidos.

---

### P1: Vegapunk Chat funcional offline ⭐ MVP

**User Story**: Como usuário, quero conversar com o Vegapunk Chat offline, para obter respostas sobre One Piece e dados do app sem depender de internet.

**Why P1**: Gemma roda on-device (sem rede). Só a `searchInternet` tool precisa de adaptação offline.

**Acceptance Criteria**:

1. WHEN o usuário abre o Vegapunk Chat offline THEN a tela SHALL inicializar normalmente (Gemma é local)
2. WHEN o usuário faz perguntas sobre One Piece offline THEN o sistema SHALL responder via RAG local (`OnePieceKnowledgeBase` + SQLite RAG)
3. WHEN o usuário pede uma busca na internet offline THEN a tool `searchInternet` SHALL retornar `ToolResult(isError: true, content: "offlineSearchUnavailable")` em vez de lançar exceção
4. WHEN a tool retorna `isError: true` THEN o Gemma SHALL gerar uma resposta alternativa explicando que está offline e sugerindo o que pode responder localmente
5. WHEN o usuário pergunta sobre perfil, treinos ou dados locais offline THEN as tools `getUserProfile` e `getWorkoutHistory` SHALL continuar funcionando normalmente (já usam Hive)

**Independent Test**: Modo avião → Vegapunk Chat → "Quem é o Zoro?" → resposta correta via RAG. "Pesquise na internet sobre One Piece" → resposta informando que está offline.

---

### P1: Outras telas bloqueadas offline ⭐ MVP

**User Story**: Como usuário offline, quero ver uma tela de bloqueio clara nas features que precisam de internet, para entender que não posso acessar aquele conteúdo agora.

**Why P1**: Sem bloqueio, o usuário verá erros, loading eterno ou crashes em telas que dependem de rede.

**Features bloqueadas offline**:
- Sanji Cooking, Zoro Workout, Custom Character
- Robin Knowledge, Duels, Crews
- One Piece character browser, Devil Fruit browser
- YouTube, Profile (edição)

**Acceptance Criteria**:

1. WHEN o usuário tenta navegar para uma tela bloqueada offline THEN o sistema SHALL permitir a navegação mas exibir um overlay de "sem internet" sobre a tela
2. WHEN o overlay é exibido THEN ele SHALL conter: ícone de wifi-off, título `offlineScreenTitle`, subtítulo `offlineScreenSubtitle`, e o botão não deve navegar para nenhum lugar
3. WHEN a conexão é restaurada e o usuário ainda está na tela bloqueada THEN o overlay SHALL desaparecer e o conteúdo real SHALL carregar automaticamente
4. WHEN o overlay está visível THEN a BottomNavigation SHALL continuar funcional para navegar para telas offline-capable

**Independent Test**: Modo avião → navegar para Sanji Cooking → overlay de bloqueio. Voltar online → overlay some, conteúdo carrega.

---

## Edge Cases

- WHEN `getIdToken(true)` falha por `SocketException` THEN `isSessionValid()` SHALL retornar `true` se houver UserModel no Hive E FirebaseAuth.currentUser não for null
- WHEN o app abre offline pela primeira vez (sem sessão cacheada) THEN a tela de login SHALL ser exibida com o banner offline e o botão de login desabilitado ou com aviso
- WHEN o evento de conectividade oscila rapidamente THEN o debounce de 1500ms SHALL evitar múltiplos re-renders
- WHEN o Hive lança `HiveError` em Nami Finances THEN o BLoC SHALL capturar e emitir estado de erro localizado sem crash
- WHEN o Vegapunk Chat recebe `ToolResult(isError: true)` offline THEN o modelo SHALL formular resposta alternativa (não deixar o chat travar)
- WHEN a Home está em estado `HomeOffline` e a rede volta THEN um evento `ConnectivityRestored` SHALL ser adicionado ao `HomeBloc` para recarregar

---

## Requirement Traceability

| ID | Story | Status |
|---|---|---|
| OFFL-01 | P1: ConnectivityService + Cubit global | Pending |
| OFFL-02 | P1: Banner global de offline na UI | Pending |
| OFFL-03 | P1: Debounce do evento de conectividade | Pending |
| OFFL-04 | P1: `isSessionValid()` tolerante a rede | Pending |
| OFFL-05 | P1: `AuthBloc._onAuthStarted` com fallback offline | Pending |
| OFFL-06 | P1: `HomeBloc` — novo estado `HomeOffline` | Pending |
| OFFL-07 | P1: `HomeScreen` — render com placeholder quando `HomeOffline` | Pending |
| OFFL-08 | P1: Nami Finances — verificar ausência de chamadas de rede | Pending |
| OFFL-09 | P1: `SearchInternetHandler` — guard offline | Pending |
| OFFL-10 | P1: `OfflineBlockerOverlay` — widget reutilizável | Pending |
| OFFL-11 | P1: Strings i18n (en + pt) para todos os textos de offline | Pending |

**Coverage**: 11 requisitos, todos P1.

---

## Success Criteria

- [ ] App não crasha em nenhuma tela em modo avião
- [ ] Usuário autenticado não é redirecionado para login quando offline
- [ ] Home exibe placeholders (não loading eterno) offline
- [ ] Nami Finances abre e salva dados normalmente offline
- [ ] Vegapunk Chat responde perguntas locais offline
- [ ] `searchInternet` offline retorna resposta legível (não exception)
- [ ] Telas bloqueadas exibem overlay claro (não erro genérico)
- [ ] `flutter analyze` zero erros após implementação
- [ ] Todos os textos novos presentes em `intl_en.arb` e `intl_pt.arb`
