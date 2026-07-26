# Offline-First v1 — Tasks

> **Status**: Pronto para execução
> **Depende de**: spec.md + design.md aprovados

---

## Ordem de Execução

```
T1 → T2 → T3 → T4 → T5 → T6 → T7 → T8 → T9 → T10 → T11
```

Dependências críticas:
- T1 (ConnectivityCubit) deve ser concluída antes de T2, T5, T6, T7, T8
- T2 (Strings i18n) deve ser concluída antes de T7, T8
- T3 (Auth offline) é independente — pode ser feita em paralelo com T1/T2
- T4 (HomeBloc) depende de T1
- T5 (Banner) depende de T1 + T2
- T6 (OfflineBlocker) depende de T1 + T2
- T7, T8, T9, T10 — polishing e integração final

---

## T1 — ConnectivityCubit + DI

**Goal**: Criar o serviço de conectividade global com debounce, registrado como singleton no GetIt.

**Requirement**: OFFL-01, OFFL-03

**Files**:
- `pubspec.yaml` — adicionar `connectivity_plus: ^6.1.0`
- `lib/core/connectivity/connectivity_cubit.dart` [NEW]
- `lib/core/connectivity/connectivity_state.dart` [NEW]
- `lib/app/di/core_module.dart` — registrar `ConnectivityCubit`

**Dependencies**: Nenhuma

**Implementation steps**:

1. Adicionar `connectivity_plus: ^6.1.0` ao `pubspec.yaml` e rodar `flutter pub get`
2. Criar `connectivity_state.dart`:
   ```dart
   sealed class ConnectivityState extends Equatable { const ConnectivityState(); }
   class ConnectivityOnline extends ConnectivityState {
     const ConnectivityOnline();
     @override List<Object?> get props => [];
   }
   class ConnectivityOffline extends ConnectivityState {
     const ConnectivityOffline();
     @override List<Object?> get props => [];
   }
   ```
3. Criar `connectivity_cubit.dart` com:
   - `Connectivity().onConnectivityChanged` listener
   - Verificação inicial com `Connectivity().checkConnectivity()`
   - Debounce de 1500ms via `Timer`
   - `bool get isOnline => state is ConnectivityOnline`
   - `dispose()` cancela `StreamSubscription` e `Timer`
4. Em `core_module.dart`, adicionar:
   ```dart
   getIt.registerSingleton<ConnectivityCubit>(ConnectivityCubit());
   ```

**Done when**:
- [ ] `connectivity_plus` instalado sem conflito de versão
- [ ] `ConnectivityCubit` compila sem erros
- [ ] Singleton registrado no GetIt
- [ ] `flutter analyze` sem erros nos novos arquivos

**Commit**: `feat(connectivity): add ConnectivityCubit with debounce`

---

## T2 — Strings i18n

**Goal**: Adicionar todas as strings de offline em inglês e português.

**Requirement**: OFFL-11

**Files**:
- `lib/l10n/intl_en.arb`
- `lib/l10n/intl_pt.arb`

**Dependencies**: Nenhuma (pode ser feito em paralelo com T1)

**Implementation steps**:

1. Adicionar ao `intl_en.arb`:
   ```json
   "offlineBannerMessage": "You're offline. Some features are unavailable.",
   "@offlineBannerMessage": { "description": "Top banner shown when device has no internet" },
   "offlineScreenTitle": "No Internet Connection",
   "@offlineScreenTitle": { "description": "Title of offline blocker overlay" },
   "offlineScreenSubtitle": "This feature requires an internet connection. Please reconnect to continue.",
   "@offlineScreenSubtitle": { "description": "Subtitle of offline blocker overlay" }
   ```
2. Adicionar ao `intl_pt.arb`:
   ```json
   "offlineBannerMessage": "Você está offline. Algumas funções estão indisponíveis.",
   "offlineScreenTitle": "Sem Conexão com a Internet",
   "offlineScreenSubtitle": "Esta função requer conexão com a internet. Reconecte-se para continuar."
   ```
3. Rodar `flutter gen-l10n` para gerar `app_localizations.dart`

**Done when**:
- [ ] `flutter gen-l10n` executa sem erros
- [ ] `AppLocalizations.offlineBannerMessage` disponível para uso

**Commit**: `feat(i18n): add offline strings (en + pt)`

---

## T3 — Auth offline — isSessionValid() com fallback

**Goal**: Modificar `AuthService.isSessionValid()` para tolerar ausência de rede e não deslogar o usuário quando offline.

**Requirement**: OFFL-04, OFFL-05

**Files**:
- `lib/core/services/auth_db/auth_service.dart`

**Dependencies**: Nenhuma (independente de T1)

**Implementation steps**:

1. Importar `dart:io` para usar `SocketException`
2. Modificar `isSessionValid()`:
   ```dart
   @override
   Future<bool> isSessionValid() async {
     try {
       final firebaseUser = _firebaseAuth.currentUser;
       if (firebaseUser == null) return false;
       await firebaseUser.getIdToken(true);
       final cachedUser = currentUser;
       if (cachedUser == null || cachedUser.uid != firebaseUser.uid) return false;
       return true;
     } on SocketException catch (_) {
       debugPrint('AuthService: Offline — validating cached session locally');
       return _isLocalSessionValid();
     } catch (e) {
       if (_isNetworkError(e)) {
         debugPrint('AuthService: Network error — validating cached session locally');
         return _isLocalSessionValid();
       }
       debugPrint('AuthService: Session validation error - $e');
       return false;
     }
   }
   
   bool _isLocalSessionValid() {
     final firebaseUser = _firebaseAuth.currentUser;
     final cachedUser = currentUser;
     return firebaseUser != null &&
            cachedUser != null &&
            firebaseUser.uid == cachedUser.uid;
   }
   
   bool _isNetworkError(Object e) {
     final msg = e.toString().toLowerCase();
     return msg.contains('network') ||
            msg.contains('socket') ||
            msg.contains('failed host lookup') ||
            msg.contains('connection') ||
            msg.contains('unavailable');
   }
   ```
3. Verificar se `AuthBloc._onAuthStarted` trata corretamente o `true` offline (não deve precisar de mudança)

**Done when**:
- [ ] `isSessionValid()` retorna `true` quando offline + usuário cacheado presente
- [ ] `isSessionValid()` retorna `false` quando offline + sem usuário no cache
- [ ] Sem regressão no fluxo online
- [ ] `flutter analyze` sem erros

**Commit**: `fix(auth): preserve session when offline using cached credentials`

---

## T4 — HomeBloc — estado HomeOffline + evento ConnectivityRestored

**Goal**: Adicionar suporte a estado offline no HomeBloc para que a Home não fique em loading eterno offline.

**Requirement**: OFFL-06

**Files**:
- `lib/features/home/bloc/home_state.dart`
- `lib/features/home/bloc/home_event.dart`
- `lib/features/home/bloc/home_bloc.dart`

**Dependencies**: T1 (ConnectivityCubit deve estar no GetIt)

**Implementation steps**:

1. `home_state.dart` — adicionar:
   ```dart
   class HomeOffline extends HomeState {
     const HomeOffline();
     @override List<Object?> get props => [];
   }
   ```
2. `home_event.dart` — adicionar:
   ```dart
   class ConnectivityRestored extends HomeEvent {
     const ConnectivityRestored();
   }
   ```
3. `home_bloc.dart` — registrar handler:
   ```dart
   on<ConnectivityRestored>((event, emit) {
     add(const LoadFeaturedCharacter());
   });
   ```
4. `home_bloc.dart` — modificar `_onLoadFeaturedCharacter`:
   ```dart
   Future<void> _onLoadFeaturedCharacter(
     LoadFeaturedCharacter event,
     Emitter<HomeState> emit,
   ) async {
     final connectivity = getIt<ConnectivityCubit>();
     if (!connectivity.isOnline) {
       emit(const HomeOffline());
       return;
     }
     emit(HomeLoading());
     try {
       final character = await _repository.getFeaturedCharacter();
       emit(HomeLoaded(featuredCharacter: character));
     } catch (e) {
       emit(HomeError(message: e.toString()));
     }
   }
   ```
5. Fazer o mesmo check para `LoadRandomCharacter` e `SelectCharacter` se relevante

**Done when**:
- [ ] `HomeOffline` state existe e é emitido quando offline
- [ ] `ConnectivityRestored` dispara reload automático
- [ ] `flutter analyze` sem erros

**Commit**: `feat(home): add HomeOffline state and ConnectivityRestored event`

---

## T5 — OfflineBannerWrapper (banner global)

**Goal**: Criar o banner amarelo global que aparece no topo de todas as telas quando offline.

**Requirement**: OFFL-02

**Files**:
- `lib/shared/widgets/atoms/offline_banner.dart` [NEW]
- `lib/main.dart` ou `lib/app/app.dart` — wrapping do AppWrapper

**Dependencies**: T1, T2

**Implementation steps**:

1. Criar `offline_banner.dart`:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_bloc/flutter_bloc.dart';
   import 'package:opfan/core/connectivity/connectivity_cubit.dart';
   import 'package:opfan/app/di/injection.dart';
   import 'package:opfan/l10n/app_localizations.dart';
   import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
   import 'package:opfan/shared/widgets/atoms/app_icon.dart';

   class OfflineBannerWrapper extends StatelessWidget {
     final Widget child;
     const OfflineBannerWrapper({required this.child, super.key});

     @override
     Widget build(BuildContext context) {
       return BlocProvider.value(
         value: getIt<ConnectivityCubit>(),
         child: Column(
           children: [
             BlocBuilder<ConnectivityCubit, ConnectivityState>(
               builder: (context, state) {
                 return AnimatedSwitcher(
                   duration: const Duration(milliseconds: 200),
                   child: state is ConnectivityOffline
                       ? _OfflineBanner(key: const ValueKey('offline'))
                       : const SizedBox.shrink(key: ValueKey('online')),
                 );
               },
             ),
             Expanded(child: child),
           ],
         ),
       );
     }
   }

   class _OfflineBanner extends StatelessWidget {
     const _OfflineBanner({super.key});

     @override
     Widget build(BuildContext context) {
       return Container(
         width: double.infinity,
         color: Colors.orange.shade700,
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         child: SafeArea(
           bottom: false,
           child: Row(
             children: [
               const AppIcon(PhosphorIconsRegular.wifiSlash,
                   size: 16, color: Colors.white),
               const SizedBox(width: 8),
               Expanded(
                 child: Text(
                   AppLocalizations.of(context)!.offlineBannerMessage,
                   style: const TextStyle(
                     color: Colors.white,
                     fontSize: 13,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
               ),
             ],
           ),
         ),
       );
     }
   }
   ```
2. Encontrar onde o `AppWrapper` é renderizado no `MaterialApp` (provavelmente em `main.dart` ou arquivo de app)
3. Envolver o `AppWrapper` com `OfflineBannerWrapper`:
   ```dart
   home: OfflineBannerWrapper(child: AppWrapper())
   ```
   ou se for routing:
   ```dart
   builder: (context, child) => OfflineBannerWrapper(child: child ?? const SizedBox())
   ```

**Done when**:
- [ ] Banner aparece ao colocar em modo avião
- [ ] Banner desaparece ao voltar online
- [ ] Animação de fade funciona (200ms)
- [ ] `SafeArea` correto (não sobrepor status bar)
- [ ] `flutter analyze` sem erros

**Commit**: `feat(ui): add global offline banner with connectivity detection`

---

## T6 — HomeScreen — render com placeholder offline

**Goal**: Fazer a HomeScreen exibir dados de placeholder quando `HomeOffline`, sem erros e sem loading eterno.

**Requirement**: OFFL-07

**Files**:
- `lib/features/home/presentation/home_screen.dart`

**Dependencies**: T1, T2, T4

**Implementation steps**:

1. Adicionar `BlocProvider.value` para `ConnectivityCubit` no `MultiBlocProvider` da HomeScreen:
   ```dart
   BlocProvider.value(value: getIt<ConnectivityCubit>()),
   ```
2. Adicionar `BlocListener` para `ConnectivityCubit` no body que dispara `ConnectivityRestored`:
   ```dart
   BlocListener<ConnectivityCubit, ConnectivityState>(
     listener: (context, state) {
       if (state is ConnectivityOnline) {
         context.read<HomeBloc>().add(const ConnectivityRestored());
       }
     },
   )
   ```
   Usar `MultiBlocListener` se já houver outros listeners.
3. Em `_buildCharacterCard`, adicionar case para `HomeOffline`:
   ```dart
   if (state is HomeOffline) {
     return CharacterInfoCard(
       characterName: 'Monkey D. Luffy',
       characterBounty: '฿1.500.000.000',
       characterImage: 'assets/logo/splash_logo.png',
       onTap: () {},
     );
   }
   ```
4. Em `_buildCharacterStatistics`, adicionar case para `HomeOffline`:
   ```dart
   if (state is HomeOffline) {
     return StatisticsGrid(
       title: AppLocalizations.of(context)!.statistics,
       statistics: [
         StatisticData(label: AppLocalizations.of(context)!.status, value: '—', icon: PhosphorIconsRegular.flag),
         StatisticData(label: AppLocalizations.of(context)!.crew(0), value: '—', svgPath: 'assets/logo/ship-crew.svg'),
         StatisticData(label: AppLocalizations.of(context)!.signo, value: '—', icon: PhosphorIconsRegular.star),
       ],
     );
   }
   ```
5. Verificar se `DynamicBanner` e `LoadRandomCharacter` / `SelectCharacter` botões devem ser desabilitados quando `HomeOffline` (desabilitar `onPressed` com `null`)

**Done when**:
- [ ] Home exibe placeholder offline sem erros
- [ ] Botões de "aleatório" e "selecionar" desabilitados offline
- [ ] Ao voltar online, dados reais carregam automaticamente
- [ ] `flutter analyze` sem erros

**Commit**: `feat(home): show offline placeholder when ConnectivityOffline`

---

## T7 — OfflineBlockerOverlay (widget reutilizável)

**Goal**: Criar o overlay de bloqueio e aplicá-lo nas telas que precisam de internet.

**Requirement**: OFFL-10

**Files**:
- `lib/shared/widgets/organisms/offline_blocker_overlay.dart` [NEW]
- `lib/features/sanji_cooking/presentation/sanji_cooking_screen.dart`
- `lib/features/zoro_workout/presentation/zoro_workout_screen.dart`
- `lib/features/custom_character/presentation/custom_character_screen.dart`
- `lib/features/robin_knowledge/presentation/robin_knowledge_screen.dart`
- `lib/features/duels/presentation/duels_screen.dart`
- `lib/features/crews/presentation/crews_screen.dart`
- `lib/features/one_piece/presentation/one_piece_screen.dart`
- `lib/features/devil_fruit/presentation/devil_fruit_screen.dart`
- `lib/features/youtube/presentation/youtube_screen.dart`

**Dependencies**: T1, T2

**Implementation steps**:

1. Criar `offline_blocker_overlay.dart` conforme design.md
2. Para cada tela listada acima:
   - Adicionar `BlocProvider.value(value: getIt<ConnectivityCubit>())` se não houver
   - Envolver o `Scaffold` com `OfflineBlockerOverlay`
   - Verificar que o `BottomNavigation` fica FORA do overlay (dentro do Scaffold, não bloqueado)

> **Estratégia**: O overlay usa `Stack`, então o Scaffold (incluindo BottomNavigation) fica renderizado atrás. O overlay de conteúdo bloqueia apenas o body, não o bottomNavigationBar.

**Alternativa mais simples**: O overlay pode ficar dentro do `body` do Scaffold, não sobre ele. Isso preserva a AppBar e BottomNavigation automaticamente:

```dart
body: Stack(
  children: [
    /* conteúdo real */,
    if (isOffline) _OfflineOverlay(),
  ],
)
```

**Done when**:
- [ ] `OfflineBlockerOverlay` criado e compilando
- [ ] Aplicado em todas as 10 telas listadas
- [ ] BottomNavigation continua funcional quando overlay está visível
- [ ] Overlay desaparece ao voltar online
- [ ] `flutter analyze` sem erros

**Commit**: `feat(ui): add OfflineBlockerOverlay to internet-required screens`

---

## T8 — SearchInternetHandler — guard offline

**Goal**: Impedir que `searchInternet` lance exceção quando offline e retornar `ToolResult` legível para o Gemma.

**Requirement**: OFFL-09

**Files**:
- `lib/features/vegapunk_chat/tools/handlers/search_internet_handler.dart`

**Dependencies**: T1

**Implementation steps**:

1. Injetar `ConnectivityCubit` no handler (via GetIt, sem modificar construtor se possível):
   ```dart
   @override
   Future<ToolResult> handle(Map<String, dynamic> args) async {
     if (!getIt<ConnectivityCubit>().isOnline) {
       return const ToolResult(
         isError: true,
         content: 'No internet connection. I cannot search the web right now. '
                  'I can answer questions about One Piece characters, your profile, '
                  'and workout history using local data.',
       );
     }
     // ... lógica existente
   }
   ```
2. Verificar que `ToolResult` tem o campo `isError` e `content` conforme esperado (ver `lib/features/vegapunk_chat/tools/models/tool_call.dart` ou equivalente)

**Done when**:
- [ ] Offline → `searchInternet` retorna `ToolResult(isError: true)` com mensagem legível
- [ ] Online → comportamento inalterado
- [ ] Vegapunk Chat não trava quando pesquisa offline
- [ ] `flutter analyze` sem erros

**Commit**: `fix(vegapunk): guard searchInternet tool against offline requests`

---

## T9 — Nami Finances — verificação de ausência de chamadas de rede

**Goal**: Auditar Nami Finances para garantir que não há chamadas de rede que causem erros offline.

**Requirement**: OFFL-08

**Files** (apenas leitura/auditoria, sem alterações esperadas):
- `lib/core/services/finances/nami_finances_service.dart`
- `lib/features/nami_finances/bloc/nami_finances_bloc.dart`
- `lib/features/nami_finances/presentation/` — telas

**Implementation steps**:

1. Revisar `NamiFinancesService` — confirmar que todas as operações usam apenas Hive (sem Firestore ou HTTP calls)
2. Revisar `NamiFinancesBloc` — confirmar que não há `IFirestoreService` ou `Dio` injetados
3. Se `NamiFinancesScreen` acessa serviços de rede (ex: busca sugestões online), envolver apenas esses componentes com check de conectividade
4. **Se tudo for apenas Hive**: nenhuma alteração necessária — documentar como "auditado e ok"

**Done when**:
- [ ] Auditoria concluída — relatório em comentário de PR ou commit
- [ ] Nenhuma chamada de rede encontrada (ou tratadas com guard de conectividade)
- [ ] Nami Finances abre, cria e lista dados normalmente em modo avião

**Commit**: `chore(finances): audit offline safety — no network calls confirmed`

---

## T10 — flutter gen-l10n + flutter analyze final

**Goal**: Gerar localizações e garantir zero erros de análise estática.

**Requirement**: OFFL-11

**Files**: gerados automaticamente

**Dependencies**: T2 (strings adicionadas) + todos os outros tasks

**Implementation steps**:

1. Rodar `flutter gen-l10n`
2. Rodar `flutter analyze`
3. Corrigir qualquer erro ou warning introduzido nesta feature
4. Rodar `flutter pub get` se houve mudanças no pubspec

**Done when**:
- [ ] `flutter gen-l10n` sem erros
- [ ] `flutter analyze` retorna zero erros (warnings tolerados)

**Commit**: `chore: run gen-l10n and fix analyze warnings`

---

## T11 — Teste Manual End-to-End

**Goal**: Verificar todos os critérios de sucesso da spec manualmente em dispositivo físico ou simulador.

**Checklist de teste**:

| Cenário | Esperado | Status |
|---|---|---|
| Logar → modo avião → fechar app → reabrir | Home abre, não vai para Login | ☐ |
| Modo avião → qualquer tela | Banner laranja no topo | ☐ |
| Voltar online | Banner some automaticamente | ☐ |
| Modo avião → Home | Placeholder Luffy + estatísticas com "—" | ☐ |
| Voltar online na Home | Dados reais carregam | ☐ |
| Modo avião → Nami Finances | Abre normalmente, dados do Hive | ☐ |
| Modo avião → criar transação Nami | Salva sem erro | ☐ |
| Modo avião → Vegapunk Chat → "quem é o Luffy?" | Resposta via RAG local | ☐ |
| Modo avião → Vegapunk Chat → "pesquise na internet..." | Resposta offline legível | ☐ |
| Modo avião → Sanji Cooking | Overlay de bloqueio visível | ☐ |
| Modo avião → overlay Sanji → BottomNav | Navegar para Home funciona | ☐ |
| Voltar online em tela bloqueada | Overlay some, conteúdo carrega | ☐ |
| Modo avião → app sem sessão prévia | Tela de Login (banner offline) | ☐ |
| `flutter analyze` | Zero erros | ☐ |

**Done when**: Todos os checkboxes marcados.

**Commit**: `test(manual): all offline-first v1 scenarios verified`

---

## Resumo dos Commits

```
feat(connectivity): add ConnectivityCubit with debounce
feat(i18n): add offline strings (en + pt)
fix(auth): preserve session when offline using cached credentials
feat(home): add HomeOffline state and ConnectivityRestored event
feat(ui): add global offline banner with connectivity detection
feat(home): show offline placeholder when ConnectivityOffline
feat(ui): add OfflineBlockerOverlay to internet-required screens
fix(vegapunk): guard searchInternet tool against offline requests
chore(finances): audit offline safety — no network calls confirmed
chore: run gen-l10n and fix analyze warnings
```
