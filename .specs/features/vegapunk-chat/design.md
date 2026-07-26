# Ask Vegapunk — Architecture Design

**Feature ID:** VEGAPUNK  
**Phase:** Design  
**Created:** 2026-06-24

---

## Data Flow

```
VegapunkChatScreen
       │
       ▼
VegapunkChatCubit  ──────────────────────────────────────┐
       │                                                  │
       ▼                                                  │
VegapunkChatRepository                                    │
       │                                                  │
       ▼                                                  │
GemmaService (core singleton)                             │
       │                                                  │
       ▼                                                  ▼
FlutterGemma SDK ◄── Model file (.task) ◄── HuggingFace download
  (on-device)         app/documents/
```

---

## Directory Structure

```
lib/
├── core/
│   └── services/
│       └── gemma_service.dart          # NEW — wraps FlutterGemma SDK
│
├── features/
│   └── vegapunk_chat/
│       ├── vegapunk_chat_routes.dart   # NEW
│       ├── cubit/
│       │   ├── vegapunk_chat_cubit.dart    # NEW
│       │   └── vegapunk_chat_state.dart    # NEW
│       ├── data/
│       │   └── vegapunk_chat_repository.dart  # NEW
│       └── presentation/
│           ├── vegapunk_chat_screen.dart   # NEW
│           └── widgets/
│               ├── chat_message_bubble.dart     # NEW
│               ├── chat_input_bar.dart          # NEW
│               ├── model_download_overlay.dart  # NEW
│               └── streaming_text.dart          # NEW
│
├── app/
│   └── di/
│       ├── core_module.dart        # MODIFIED — register GemmaService
│       └── features_module.dart    # MODIFIED — register VegapunkChatCubit
│
├── shared/
│   └── utils/
│       └── app_routes.dart         # MODIFIED — add vegapunkChat route
│
└── l10n/
    ├── intl_en.arb                 # MODIFIED — add new keys
    └── intl_pt.arb                 # MODIFIED — add new keys
```

**Platform files:**
```
android/app/src/main/AndroidManifest.xml   # MODIFIED — OpenCL GPU support
ios/Runner/Info.plist                       # MODIFIED — UIFileSharingEnabled
ios/Runner/Runner.entitlements             # MODIFIED — memory entitlements
ios/Podfile                                # MODIFIED — static linking + min iOS 16
pubspec.yaml                               # MODIFIED — add flutter_gemma deps
.env / .env.example                        # MODIFIED — GEMMA_MODEL_URL, GEMMA_MODEL_NAME
```

---

## GemmaService

**Location:** `lib/core/services/gemma_service.dart`  
**DI:** Singleton (registered in `core_module.dart`)  
**Responsibility:** Owns the entire flutter_gemma lifecycle — initialization, model download, model loading, and chat session creation.

```dart
// Public interface
class GemmaService {
  // Model status stream — UI can listen to download/load progress
  Stream<GemmaServiceStatus> get statusStream;
  GemmaServiceStatus get currentStatus;

  // One-time SDK initialization (called from main.dart or injection.dart)
  Future<void> initialize();

  // Download model if not cached; emits progress via statusStream
  Future<void> ensureModelReady();

  // Start a new chat session with Vegapunk system prompt
  Future<GemmaChatSession> createVegapunkSession();

  // Check if model file exists in documents directory
  Future<bool> isModelDownloaded();

  // Clean up active model from memory
  Future<void> disposeActiveModel();
}
```

**GemmaServiceStatus sealed class:**
```dart
sealed class GemmaServiceStatus {}
class GemmaIdle extends GemmaServiceStatus {}
class GemmaDownloading extends GemmaServiceStatus {
  final double progress; // 0.0 to 1.0
}
class GemmaModelLoading extends GemmaServiceStatus {}
class GemmaReady extends GemmaServiceStatus {}
class GemmaError extends GemmaServiceStatus {
  final String message;
  final bool isRetryable;
}
```

**GemmaChatSession wrapper:**
```dart
class GemmaChatSession {
  // Send a user message and stream tokens
  Stream<String> sendMessage(String text);

  // Dispose the session (free memory)
  Future<void> dispose();
}
```

**SDK initialization flow:**
```dart
FlutterGemma.initialize(
  inferenceEngines: const [MediaPipeEngine()],
  huggingFaceToken: dotenv.env['HUGGING_FACE_API_KEY']!,
);
```

**Model download flow:**
```dart
await FlutterGemma.installModel(modelType: ModelType.custom)
  .fromNetwork(
    dotenv.env['GEMMA_MODEL_URL']!,
    token: dotenv.env['HUGGING_FACE_API_KEY'],
  )
  .withProgress((progress) => _emitStatus(GemmaDownloading(progress / 100)))
  .install();
```

**Chat session creation:**
```dart
final model = await FlutterGemma.getActiveModel(
  maxTokens: 2048,
  preferredBackend: PreferredBackend.gpu,
);
final chat = await model.createChat(
  systemPrompt: _vegapunkSystemPrompt,
);
```

---

## VegapunkChatCubit

**Location:** `lib/features/vegapunk_chat/cubit/`  
**Type:** Cubit (no complex event branching — sequential state transitions)  
**DI:** Factory (one per screen lifecycle)

### State

```dart
sealed class VegapunkChatState {}

class VegapunkChatInitial extends VegapunkChatState {}

class VegapunkChatModelDownloading extends VegapunkChatState {
  final double progress; // 0.0 to 1.0
}

class VegapunkChatModelLoading extends VegapunkChatState {}

class VegapunkChatReady extends VegapunkChatState {
  final List<ChatMessage> messages;
}

class VegapunkChatGenerating extends VegapunkChatState {
  final List<ChatMessage> messages;
  final String partialResponse; // growing as tokens stream in
}

class VegapunkChatError extends VegapunkChatState {
  final List<ChatMessage> messages;
  final String errorMessage;
  final bool isRetryable;
}
```

### ChatMessage model

```dart
class ChatMessage {
  final String id;        // uuid
  final String text;
  final bool isUser;
  final DateTime timestamp;
}
```

### Cubit methods

```dart
class VegapunkChatCubit extends Cubit<VegapunkChatState> {
  Future<void> initializeChat();    // checks model, downloads if needed, loads
  Future<void> sendMessage(String text);  // sends + streams response
  void cancelGeneration();          // cancels current stream
  Future<void> retryModelDownload();
}
```

---

## VegapunkChatRepository

**Location:** `lib/features/vegapunk_chat/data/`  
**Responsibility:** Bridges Cubit to GemmaService, owns the active `GemmaChatSession`

```dart
class VegapunkChatRepository {
  final GemmaService _gemmaService;
  GemmaChatSession? _session;

  // Initializes model and creates session
  Future<void> openSession();

  // Sends message and returns token stream
  Stream<String> sendMessage(String text);

  // Closes session
  Future<void> closeSession();
}
```

---

## Navigation Changes

### BottomNavigation (`bottom_navigation.dart`)

**Change:** Replace `BottomNavigationPages.knowledge` with `BottomNavigationPages.vegapunkChat`

```dart
// Before
enum BottomNavigationPages { home, finances, workout, cooking, knowledge }

// After
enum BottomNavigationPages { home, finances, workout, cooking, vegapunkChat }
```

The 5th tab switch case:
```dart
BottomNavigationPages.vegapunkChat => (
  l10n.vegapunk,               // new i18n key
  PhosphorIconsRegular.robot,  // robot icon
),
```

Route navigation:
```dart
case BottomNavigationPages.vegapunkChat:
  await Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.vegapunkChat,
    ModalRoute.withName(AppRoutes.vegapunkChat),
  );
```

### UserDrawerContent (`user_drawer_content.dart`)

Add Planner tile after the existing "Duels" entry:
```dart
_buildFuturisticListTile(
  context,
  icon: PhosphorIconsRegular.book,
  title: AppLocalizations.of(context)!.planner,  // existing key
  onTap: () => Navigator.pushNamed(context, AppRoutes.knowledge),
),
```

### AppRoutes (`app_routes.dart`)

```dart
static const String vegapunkChat = '/vegapunk-chat';
```

---

## Platform Configuration Checklist

### iOS (`ios/Podfile`)
```ruby
platform :ios, '16.0'       # bump from current (check current value)
use_frameworks! :linkage => :static
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>UIFileSharingEnabled</key><true/>
<key>LSSupportsOpeningDocumentsInPlace</key><true/>
```

### iOS (`ios/Runner/Runner.entitlements`)
```xml
<key>com.apple.developer.kernel.increased-memory-limit</key><true/>
```

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Optional: GPU acceleration via OpenCL -->
<uses-library android:name="libOpenCL.so" android:required="false"/>
```

### `pubspec.yaml`
```yaml
dependencies:
  flutter_gemma: ^1.1.1
  flutter_gemma_mediapipe: ^1.1.1   # .task format (Android + iOS + Web)
  flutter_gemma_litertlm: ^1.1.1    # .litertlm format (Desktop fallback)
```

---

## Localization Keys

### `intl_en.arb` (and `intl_pt.arb`)

| Key | EN | PT |
|-----|----|----|
| `vegapunk` | `"Vegapunk"` | `"Vegapunk"` |
| `vegapunkChatTitle` | `"Ask Vegapunk"` | `"Pergunte ao Vegapunk"` |
| `vegapunkChatHint` | `"Ask anything..."` | `"Pergunte qualquer coisa..."` |
| `vegapunkModelDownloadTitle` | `"Downloading Vegapunk's brain"` | `"Baixando o cérebro do Vegapunk"` |
| `vegapunkModelDownloadSubtitle` | `"One-time download (~586 MB). The model will run fully on your device."` | `"Download único (~586 MB). O modelo rodará completamente no seu dispositivo."` |
| `vegapunkModelLoadingTitle` | `"Activating Vegapunk..."` | `"Ativando Vegapunk..."` |
| `vegapunkModelErrorTitle` | `"Vegapunk failed to initialize"` | `"Vegapunk falhou ao inicializar"` |
| `vegapunkRetry` | `"Retry"` | `"Tentar novamente"` |
| `vegapunkCancel` | `"Cancel"` | `"Cancelar"` |
| `vegapunkChatEmpty` | `"Vegapunk is ready. What would you like to know?"` | `"Vegapunk está pronto. O que você gostaria de saber?"` |

---

## Dependency Registration

### `core_module.dart`
```dart
// Singleton — initialized once, shared across features
getIt.registerLazySingleton<GemmaService>(() => GemmaService(
  environmentService: getIt<EnvironmentService>(),
));
```

### `features_module.dart`
```dart
// Factory — one per screen lifecycle
getIt.registerFactory<VegapunkChatCubit>(() => VegapunkChatCubit(
  VegapunkChatRepository(gemmaService: getIt<GemmaService>()),
));
```

---

## SDK Initialization Point

`FlutterGemma.initialize()` must be called before `runApp()`. The cleanest place is in `main.dart`, after `WidgetsFlutterBinding.ensureInitialized()` and alongside Firebase init.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  FlutterGemma.initialize(
    inferenceEngines: const [
      MediaPipeEngine(),
      LiteRtLmEngine(),   // desktop fallback
    ],
    huggingFaceToken: dotenv.env['HUGGING_FACE_API_KEY'],
  );
  
  runApp(const App());
}
```

> Note: `FlutterGemma.initialize()` is synchronous and non-blocking — it only registers engines, does not load the model.

---

## Token Streaming Architecture

The `generateChatResponseAsync()` returns a `Stream<InferenceResponse>`. The Cubit listens to the stream and emits `VegapunkChatGenerating` on each token, accumulating the partial response, then transitions to `VegapunkChatReady` with the final message on stream completion.

```
User sends message
       │
Cubit.sendMessage()
       │
Repository.sendMessage()  →  GemmaChatSession.sendMessage()
       │                              │
       │◄── Stream<String> (tokens) ──┘
       │
For each token:
  emit VegapunkChatGenerating(messages, partialResponse += token)
       │
Stream complete:
  append full message to messages list
  emit VegapunkChatReady(messages)
```

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| Model too large for low-end Android devices | Medium | High | Document SmolLM 135MB as opt-in fallback; detect available storage before download |
| iOS memory entitlement rejected by App Store | Low | High | Entitlement is standard for on-device ML apps; well-documented |
| HuggingFace token expires or model URL changes | Low | Medium | Store URL in `.env` so it can be updated without code changes |
| Model download interrupted mid-way | Medium | Medium | flutter_gemma handles partial downloads; retry mechanism in spec |
| Generation performance too slow on older devices | Medium | Medium | Phase 1 uses Qwen3 0.6B (smallest quality model); SmolLM fallback available |
| Concurrent generation sessions | Low | Low | flutter_gemma serializes generation automatically |
