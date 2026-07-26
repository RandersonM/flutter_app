# Offline-First v1 — Design Document

> **Status**: Pronto para Tasks
> **Depende de**: spec.md aprovada

---

## Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────┐
│                  MaterialApp                     │
│  ┌───────────────────────────────────────────┐   │
│  │         OfflineBannerWrapper              │   │  ← Novo: escuta ConnectivityCubit
│  │  ┌─────────────────────────────────────┐  │   │
│  │  │           AppWrapper               │  │   │
│  │  │  (AuthBloc → Home/Login/Onboarding)│  │   │  ← Modificado: isSessionValid offline
│  │  └─────────────────────────────────────┘  │   │
│  └───────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘

ConnectivityCubit (GetIt singleton)
  └── emite bool isOnline
  └── debounce 1500ms
  └── usado por: OfflineBannerWrapper, HomeBloc, SearchInternetHandler, OfflineBlockerOverlay
```

---

## Componente 1 — ConnectivityCubit (novo singleton)

### Localização
```
lib/core/connectivity/
  ├── connectivity_cubit.dart
  ├── connectivity_state.dart
  └── i_connectivity_service.dart   (interface para testabilidade)
```

### Dependência
```yaml
# pubspec.yaml — adicionar:
connectivity_plus: ^6.1.0
```

### Design do Cubit

```dart
// connectivity_state.dart
sealed class ConnectivityState extends Equatable {
  const ConnectivityState();
}
class ConnectivityOnline extends ConnectivityState { ... }
class ConnectivityOffline extends ConnectivityState { ... }

// connectivity_cubit.dart
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(const ConnectivityOnline()) {
    _init();
  }

  StreamSubscription? _sub;
  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 1500);

  void _init() {
    _sub = Connectivity().onConnectivityChanged.listen(_onChanged);
    // Verificar estado inicial
    Connectivity().checkConnectivity().then(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        emit(const ConnectivityOnline());
      } else {
        emit(const ConnectivityOffline());
      }
    });
  }

  bool get isOnline => state is ConnectivityOnline;

  @override
  Future<void> close() {
    _debounce?.cancel();
    _sub?.cancel();
    return super.close();
  }
}
```

### Registro no DI
```dart
// core_module.dart
getIt.registerSingleton<ConnectivityCubit>(ConnectivityCubit());
```

---

## Componente 2 — OfflineBannerWrapper (novo atom widget)

### Localização
```
lib/shared/widgets/atoms/offline_banner.dart
```

### Design

```dart
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
              if (state is ConnectivityOffline) {
                return _OfflineBanner();  // banner amarelo/laranja
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
```

### Aparência do Banner
- **Cor**: `Colors.orange.shade700` ou `amber`
- **Ícone**: `PhosphorIconsRegular.wifiSlash`
- **Texto**: `AppLocalizations.of(context)!.offlineBannerMessage`
- **Altura**: fixo ~40px, sem botões
- **Animação**: `AnimatedSwitcher` com `FadeTransition` (200ms)

### Integração no MaterialApp
```dart
// main.dart / app.dart
MaterialApp(
  home: OfflineBannerWrapper(child: AppWrapper()),
  ...
)
```

---

## Componente 3 — Sessão Offline (modificar AuthService)

### Problema
`isSessionValid()` atual chama `getIdToken(true)` que força refresh remoto — falha sem rede.

### Solução
Adicionar fallback offline:

```dart
// auth_service.dart
@override
Future<bool> isSessionValid() async {
  try {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return false;

    // Tentar refresh online
    await firebaseUser.getIdToken(true);

    final cachedUser = currentUser;
    if (cachedUser == null || cachedUser.uid != firebaseUser.uid) {
      return false;
    }
    return true;
  } on SocketException catch (_) {
    // Offline: aceitar sessão local se Firebase já tem o usuário
    debugPrint('AuthService: Offline — using cached session');
    return _isLocalSessionValid();
  } catch (e) {
    // Outros erros de rede (FirebaseException network-request-failed)
    if (_isNetworkError(e)) {
      debugPrint('AuthService: Network error — using cached session');
      return _isLocalSessionValid();
    }
    debugPrint('AuthService: Session validation error - $e');
    return false;
  }
}

bool _isLocalSessionValid() {
  final firebaseUser = _firebaseAuth.currentUser;
  final cachedUser = currentUser; // Hive
  return firebaseUser != null &&
         cachedUser != null &&
         firebaseUser.uid == cachedUser.uid;
}

bool _isNetworkError(Object e) {
  final msg = e.toString().toLowerCase();
  return msg.contains('network') ||
         msg.contains('socket') ||
         msg.contains('connection') ||
         msg.contains('unavailable');
}
```

> **Nota de segurança**: O Firebase Auth SDK mantém o usuário em cache local. `currentUser != null` sem refresh significa que o token local pode estar expirado, mas o SDK renova automaticamente quando a rede volta. Isso é o comportamento padrão de apps móveis.

---

## Componente 4 — HomeBloc (modificar)

### Novo estado `HomeOffline`

```dart
// home_state.dart — adicionar:
class HomeOffline extends HomeState {
  const HomeOffline();
}
```

### Modificar `LoadFeaturedCharacter`

```dart
// home_bloc.dart
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

### Evento `ConnectivityRestored` (recarregar ao voltar online)

```dart
// home_event.dart — adicionar:
class ConnectivityRestored extends HomeEvent {
  const ConnectivityRestored();
}

// home_bloc.dart — registrar e tratar:
on<ConnectivityRestored>((event, emit) async {
  add(const LoadFeaturedCharacter());
});
```

### HomeScreen — render de placeholder

```dart
// home_screen.dart — em _buildCharacterCard:
if (state is HomeOffline) {
  return CharacterInfoCard(
    characterName: 'Monkey D. Luffy',
    characterBounty: '฿1.500.000.000',
    characterImage: 'assets/logo/splash_logo.png',
    characterDescription: null,
    onTap: () {},
    isPlaceholder: true,  // novo parâmetro opcional para shimmer
  );
}
```

```dart
// home_screen.dart — observar ConnectivityCubit para restaurar:
BlocListener<ConnectivityCubit, ConnectivityState>(
  listener: (context, state) {
    if (state is ConnectivityOnline) {
      context.read<HomeBloc>().add(const ConnectivityRestored());
    }
  },
  child: /* ... body ... */
)
```

---

## Componente 5 — OfflineBlockerOverlay (novo organism widget)

### Localização
```
lib/shared/widgets/organisms/offline_blocker_overlay.dart
```

### Design

```dart
class OfflineBlockerOverlay extends StatelessWidget {
  final Widget child;
  final bool isOfflineBlocked;  // true = bloqueia quando offline

  const OfflineBlockerOverlay({
    required this.child,
    this.isOfflineBlocked = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        final isOffline = state is ConnectivityOffline;
        return Stack(
          children: [
            child,
            if (isOffline && isOfflineBlocked)
              _OfflineOverlay(),
          ],
        );
      },
    );
  }
}

class _OfflineOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsRegular.wifiSlash, size: 64, 
                 color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.offlineScreenTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.offlineScreenSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Uso nas telas bloqueadas

```dart
// sanji_cooking_screen.dart (e demais telas bloqueadas)
@override
Widget build(BuildContext context) {
  return BlocProvider.value(
    value: getIt<ConnectivityCubit>(),
    child: OfflineBlockerOverlay(
      child: Scaffold(/* conteúdo normal */),
    ),
  );
}
```

**Telas que recebem `OfflineBlockerOverlay`**:
- `SanjiCookingScreen`
- `ZoroWorkoutScreen`
- `CustomCharacterScreen`
- `RobinKnowledgeScreen`
- `DuelsScreen`
- `CrewsScreen`
- `OnePieceScreen` (character browser)
- `DevilFruitScreen`
- `YoutubeScreen`
- `ProfileScreen` (apenas seção de edição)

---

## Componente 6 — SearchInternetHandler (modificar)

### Problema
`SearchInternetHandler.handle()` faz chamada HTTP. Offline → lança exception → chat trava.

### Solução

```dart
// search_internet_handler.dart
@override
Future<ToolResult> handle(Map<String, dynamic> args) async {
  // Guard offline ANTES de tentar a requisição
  final connectivity = getIt<ConnectivityCubit>();
  if (!connectivity.isOnline) {
    return ToolResult(
      isError: true,
      content: 'offline_search_unavailable',  // chave i18n — Gemma usa em inglês
    );
  }

  // ... lógica existente de busca
}
```

> **Nota**: O Gemma recebe `isError: true` + content descritivo. O system prompt já instrui o modelo a formular resposta alternativa quando uma tool retorna erro.

---

## Strings i18n Necessárias

### `lib/l10n/intl_en.arb` — adicionar:

```json
"offlineBannerMessage": "You're offline. Some features are unavailable.",
"@offlineBannerMessage": { "description": "Top banner shown when device has no internet" },

"offlineScreenTitle": "No Internet Connection",
"@offlineScreenTitle": { "description": "Title of offline blocker overlay" },

"offlineScreenSubtitle": "This feature requires an internet connection. Please reconnect to continue.",
"@offlineScreenSubtitle": { "description": "Subtitle of offline blocker overlay" }
```

### `lib/l10n/intl_pt.arb` — adicionar:

```json
"offlineBannerMessage": "Você está offline. Algumas funções estão indisponíveis.",
"offlineScreenTitle": "Sem Conexão com a Internet",
"offlineScreenSubtitle": "Esta função requer conexão com a internet. Reconecte-se para continuar."
```

---

## Hive TypeIds — Estado Atual (sem alterações v1)

| TypeId | Modelo | Local |
|---|---|---|
| 10 | `NamiFinancesModel` | `nami_finances_model.dart` |
| 11 | `MonthlyIncomeModel` | `nami_finances_model.dart` |
| 12 | `ExpenseModel` | `nami_finances_model.dart` |
| 13 | `ExpenseCategoryAdapter` | `nami_finances_model.dart` |

> Nenhum novo TypeId na v1. Nami Finances já usa Hive corretamente.

---

## Fluxo de Dados — Sessão Offline

```
App abre sem internet
  └── AuthService.init()
        └── Hive box 'auth_cache' abre (local, sem rede)
        └── cachedUser = box.get('current_user')   ← UserModel
        └── firebaseUser = FirebaseAuth.currentUser  ← persiste local no SDK
  └── AuthBloc._onAuthStarted()
        └── isSessionValid()
              └── getIdToken(true) → SocketException!
              └── fallback: _isLocalSessionValid()
                    └── firebaseUser != null && cachedUser != null && uid matches
                    └── retorna true
        └── checkAuthStatus() → cachedUser do Hive
        └── emit AuthAuthenticated(user: cachedUser) ✓
```

---

## Fluxo de Dados — Home Offline

```
HomeBloc recebe LoadFeaturedCharacter
  └── ConnectivityCubit.isOnline == false
  └── emit HomeOffline()

HomeScreen.BlocBuilder recebe HomeOffline
  └── _buildCharacterCard → CharacterInfoCard com placeholder
  └── _buildCharacterStatistics → StatisticsGrid com "—"
  └── DynamicBanner → substituído por SizedBox.shrink()

ConnectivityCubit emite ConnectivityOnline (rede volta)
  └── BlocListener em HomeScreen
  └── HomeBloc.add(ConnectivityRestored())
  └── LoadFeaturedCharacter() → dados reais
```

---

## Dependência de Packages

```yaml
# pubspec.yaml — único package novo:
connectivity_plus: ^6.1.0
```

Compatibilidade verificada:
- `connectivity_plus` 6.x não conflita com `dio`, `firebase_core`, `flutter_bloc` nas versões atuais do pubspec.

---

## Diagrama de Componentes

```
ConnectivityCubit (singleton)
  │
  ├── OfflineBannerWrapper (sempre ativo, global)
  │
  ├── HomeBloc (LoadFeaturedCharacter → HomeOffline se offline)
  │     └── HomeScreen (placeholder quando HomeOffline)
  │
  ├── OfflineBlockerOverlay (nas telas bloqueadas)
  │     └── 10 telas: Sanji, Zoro, etc.
  │
  └── SearchInternetHandler (guard offline → ToolResult.isError)

AuthService (modificado)
  └── isSessionValid() → fallback _isLocalSessionValid() quando SocketException
```
