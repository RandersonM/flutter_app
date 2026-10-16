# Ask Vegapunk — Implementation Tasks

**Feature ID:** VEGAPUNK  
**Phase:** Tasks  
**Created:** 2026-06-24

---

## Execution Order

```
T1 → T2 → T3 (can parallel T4) → T4 → T5 → T6 → T7 → T8 → T9 → T10 → T11
```

Critical path: T1 → T2 → T3 → T5 → T6 → T7 → T8 → T9  
Parallel: T4 (i18n) can happen alongside T3

---

## T1 — Dependencies & Platform Setup

**Goal:** Add flutter_gemma packages and configure all platform files  
**Req:** VGP-01, VGP-02, VGP-27–VGP-31  
**Depends on:** None  
**Files:**
- `pubspec.yaml`
- `ios/Podfile`
- `ios/Runner/Info.plist`
- `ios/Runner/Runner.entitlements`
- `android/app/src/main/AndroidManifest.xml`
- `.env` and `.env.example`

**Steps:**

1. Add to `pubspec.yaml` under `dependencies`:
   ```yaml
   flutter_gemma: ^1.1.1
   flutter_gemma_mediapipe: ^1.1.1
   flutter_gemma_litertlm: ^1.1.1
   ```

2. In `ios/Podfile`:
   - Set `platform :ios, '16.0'` (check current value first)
   - Add `use_frameworks! :linkage => :static` before `target 'Runner'`
   - Add post-install block for litertlm dylib bundling (check flutter_gemma_litertlm README for exact snippet)

3. In `ios/Runner/Info.plist`, add:
   ```xml
   <key>UIFileSharingEnabled</key><true/>
   <key>LSSupportsOpeningDocumentsInPlace</key><true/>
   ```

4. In `ios/Runner/Runner.entitlements`, add:
   ```xml
   <key>com.apple.developer.kernel.increased-memory-limit</key><true/>
   ```

5. In `android/app/src/main/AndroidManifest.xml`, inside `<application>`:
   ```xml
   <uses-library android:name="libOpenCL.so" android:required="false"/>
   ```

6. In `.env` and `.env.example`, add:
   ```
   GEMMA_MODEL_URL=https://huggingface.co/Qwen/Qwen3-0.6B-mobile/resolve/main/Qwen3-0.6B-mobile.task
   GEMMA_MODEL_NAME=qwen3_0.6b.task
   ```
   > ⚠️ Verify the exact HuggingFace URL for Qwen3 0.6B `.task` format before adding. Check: https://huggingface.co/models?search=qwen3+task

7. Run `flutter pub get` and verify no conflicts

**Done when:**
- `flutter pub get` runs without errors
- `flutter analyze` produces no new issues from the platform config changes

---

## T2 — SDK Initialization in main.dart

**Goal:** Initialize FlutterGemma engines before runApp  
**Req:** VGP-01, VGP-02  
**Depends on:** T1  
**Files:**
- `lib/main.dart`

**Steps:**

1. Read `lib/main.dart` to find the initialization sequence
2. Add imports:
   ```dart
   import 'package:flutter_gemma/flutter_gemma.dart';
   import 'package:flutter_gemma_mediapipe/flutter_gemma_mediapipe.dart';
   import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
   ```
3. After `WidgetsFlutterBinding.ensureInitialized()` and dotenv load, add:
   ```dart
   FlutterGemma.initialize(
     inferenceEngines: const [
       MediaPipeEngine(),
       LiteRtLmEngine(),
     ],
     huggingFaceToken: dotenv.env['HUGGING_FACE_API_KEY'],
   );
   ```

**Done when:**
- App still launches without errors
- `flutter analyze` clean

---

## T3 — GemmaService

**Goal:** Create the core service that wraps the full flutter_gemma lifecycle  
**Req:** VGP-05, VGP-06, VGP-07  
**Depends on:** T2  
**Files:**
- `lib/core/services/gemma_service.dart` (NEW)
- `lib/app/di/core_module.dart` (MODIFIED)

**Steps:**

1. Create `lib/core/services/gemma_service.dart`:

   - `GemmaServiceStatus` sealed class with states: `GemmaIdle`, `GemmaDownloading(double progress)`, `GemmaModelLoading`, `GemmaReady`, `GemmaError(String message, bool isRetryable)`
   - `GemmaChatSession` wrapper class that holds the flutter_gemma `Chat` object and exposes `Stream<String> sendMessage(String text)` and `Future<void> dispose()`
   - `GemmaService` class:
     - Constructor receives `EnvironmentService`
     - `StreamController<GemmaServiceStatus>` for status broadcast
     - `Future<void> initialize()` — checks if model exists on disk
     - `Future<void> ensureModelReady()` — downloads if needed, loads model
     - `Future<bool> isModelDownloaded()` — checks app documents directory for `GEMMA_MODEL_NAME`
     - `Future<GemmaChatSession> createVegapunkSession()` — creates chat with system prompt
     - `Future<void> disposeActiveModel()`

2. Implement `isModelDownloaded()` using `path_provider` (`getApplicationDocumentsDirectory()`) + `dart:io` `File.exists()`

3. Implement download using `FlutterGemma.installModel().fromNetwork()` with progress callback

4. Implement model loading: `FlutterGemma.getActiveModel(maxTokens: 2048, preferredBackend: PreferredBackend.gpu)`

5. Implement `createVegapunkSession()`:
   - Uses `model.createChat()`
   - Sends initial system instruction as first message (if flutter_gemma supports it via systemPrompt param; otherwise send it as first hidden user/model exchange)

6. Register in `core_module.dart`:
   ```dart
   getIt.registerLazySingleton<GemmaService>(() => GemmaService(
     environmentService: getIt<EnvironmentService>(),
   ));
   ```

**Done when:**
- `flutter analyze` clean
- Unit test: `GemmaService` initializes without error in test environment (mock EnvironmentService)

---

## T4 — Localization Keys (parallel with T3)

**Goal:** Add all i18n keys for Vegapunk chat  
**Req:** VGP-19  
**Depends on:** None  
**Files:**
- `lib/l10n/intl_en.arb`
- `lib/l10n/intl_pt.arb`

**Keys to add** (add to both files):

| Key | EN | PT |
|-----|----|----|
| `vegapunk` | `Vegapunk` | `Vegapunk` |
| `vegapunkChatTitle` | `Ask Vegapunk` | `Pergunte ao Vegapunk` |
| `vegapunkChatHint` | `Ask anything...` | `Pergunte qualquer coisa...` |
| `vegapunkModelDownloadTitle` | `Downloading Vegapunk's brain` | `Baixando o cérebro do Vegapunk` |
| `vegapunkModelDownloadSubtitle` | `One-time download (~586 MB). The model runs fully on your device.` | `Download único (~586 MB). O modelo roda completamente no seu dispositivo.` |
| `vegapunkModelLoadingTitle` | `Activating Vegapunk...` | `Ativando Vegapunk...` |
| `vegapunkModelErrorTitle` | `Vegapunk failed to initialize` | `Vegapunk falhou ao inicializar` |
| `vegapunkRetry` | `Retry` | `Tentar novamente` |
| `vegapunkCancel` | `Cancel` | `Cancelar` |
| `vegapunkChatEmpty` | `Vegapunk is ready. Ask me anything.` | `Vegapunk está pronto. Me pergunte qualquer coisa.` |

After adding, run `flutter gen-l10n` to verify generation.

**Done when:**
- `flutter gen-l10n` succeeds
- All keys appear in generated `AppLocalizations`

---

## T5 — VegapunkChatRepository + Cubit State

**Goal:** Create data layer and state classes  
**Req:** VGP-13, VGP-16  
**Depends on:** T3  
**Files:**
- `lib/features/vegapunk_chat/data/vegapunk_chat_repository.dart` (NEW)
- `lib/features/vegapunk_chat/cubit/vegapunk_chat_state.dart` (NEW)

**Steps:**

1. Create `vegapunk_chat_state.dart`:
   - `ChatMessage` data class: `id` (UUID), `text`, `isUser`, `timestamp`
   - Sealed `VegapunkChatState` with variants per design.md

2. Create `vegapunk_chat_repository.dart`:
   - Holds reference to `GemmaService` and active `GemmaChatSession?`
   - `Future<void> openSession()` — delegates to `GemmaService.ensureModelReady()` then `createVegapunkSession()`
   - `Stream<String> sendMessage(String text)` — delegates to session
   - `Future<void> closeSession()` — calls `session.dispose()`

**Done when:**
- `flutter analyze` clean
- State variants compile correctly

---

## T6 — VegapunkChatCubit

**Goal:** Implement the cubit orchestrating model loading + streaming chat  
**Req:** VGP-08–VGP-21  
**Depends on:** T4, T5  
**Files:**
- `lib/features/vegapunk_chat/cubit/vegapunk_chat_cubit.dart` (NEW)
- `lib/app/di/features_module.dart` (MODIFIED)

**Steps:**

1. Create `VegapunkChatCubit extends Cubit<VegapunkChatState>`:

   **`initializeChat()`:**
   - Subscribe to `GemmaService.statusStream`
   - `GemmaIdle/GemmaReady`: call `repository.openSession()`, emit `VegapunkChatReady([])`
   - `GemmaDownloading`: emit `VegapunkChatModelDownloading(progress)`
   - `GemmaModelLoading`: emit `VegapunkChatModelLoading()`
   - `GemmaError`: emit `VegapunkChatError([], message, isRetryable)`

   **`sendMessage(String text)`:**
   - Guard: only if state is `VegapunkChatReady`
   - Append user message to messages list
   - Emit `VegapunkChatGenerating(messages, '')`
   - Listen to `repository.sendMessage(text)` stream:
     - On data: emit `VegapunkChatGenerating(messages, partialResponse += token)`
     - On done: append full Vegapunk message, emit `VegapunkChatReady(messages)`
     - On error: emit `VegapunkChatError(messages, error, true)`

   **`cancelGeneration()`:**
   - Cancel active stream subscription
   - Emit `VegapunkChatReady(messages)` with whatever was generated

   **`retryModelDownload()`:**
   - Call `GemmaService.ensureModelReady()` again

2. Register in `features_module.dart`:
   ```dart
   getIt.registerFactory<VegapunkChatCubit>(() => VegapunkChatCubit(
     VegapunkChatRepository(gemmaService: getIt<GemmaService>()),
   ));
   ```

3. Override `close()` to call `repository.closeSession()` and cancel stream subscriptions

**Done when:**
- `flutter analyze` clean
- State transitions compile correctly

---

## T7 — Presentation Widgets

**Goal:** Build the reusable sub-widgets for the chat screen  
**Req:** VGP-13, VGP-17–VGP-21  
**Depends on:** T6  
**Files:**
- `lib/features/vegapunk_chat/presentation/widgets/chat_message_bubble.dart` (NEW)
- `lib/features/vegapunk_chat/presentation/widgets/chat_input_bar.dart` (NEW)
- `lib/features/vegapunk_chat/presentation/widgets/model_download_overlay.dart` (NEW)
- `lib/features/vegapunk_chat/presentation/widgets/streaming_text.dart` (NEW)

**Widget specs:**

**`ChatMessageBubble`:**
- Props: `ChatMessage message`, `bool isStreaming`
- User messages: right-aligned, primary color bubble
- Vegapunk messages: left-aligned, surface container bubble with a small Vegapunk avatar/icon
- If `isStreaming`: show blinking cursor after last character

**`StreamingText`:**
- Props: `String text`, `bool isActive`
- Renders text, shows animated cursor while `isActive`

**`ChatInputBar`:**
- Props: `bool enabled`, `VoidCallback onSend`, `TextEditingController controller`
- Text field + send button
- When `enabled = false`: show pulsing "Vegapunk is thinking..." indicator instead
- When generating: show stop/cancel button instead of send

**`ModelDownloadOverlay`:**
- Props: `double progress`, `String title`, `String subtitle`, `VoidCallback onCancel`
- Full-screen overlay (not blocking entire app, just the chat area)
- Progress bar with percentage
- Cancel button

**Done when:**
- Widgets render without errors in isolation
- `flutter analyze` clean

---

## T8 — VegapunkChatScreen

**Goal:** Assemble the full chat screen  
**Req:** VGP-08–VGP-21, VGP-25  
**Depends on:** T7  
**Files:**
- `lib/features/vegapunk_chat/presentation/vegapunk_chat_screen.dart` (NEW)
- `lib/features/vegapunk_chat/vegapunk_chat_routes.dart` (NEW)

**Steps:**

1. Create `vegapunk_chat_routes.dart`:
   ```dart
   class VegapunkChatRoutes {
     static const String vegapunkChat = '/vegapunk-chat';
     static Route onGenerateRoute(RouteSettings settings) {
       return MaterialPageRoute(
         builder: (_) => BlocProvider(
           create: (_) => getIt<VegapunkChatCubit>()..initializeChat(),
           child: const VegapunkChatScreen(),
         ),
       );
     }
   }
   ```

2. Create `VegapunkChatScreen`:
   - `BlocBuilder<VegapunkChatCubit, VegapunkChatState>` at root
   - `VegapunkChatModelDownloading`: show `ModelDownloadOverlay`
   - `VegapunkChatModelLoading`: show centered loading with l10n.vegapunkModelLoadingTitle
   - `VegapunkChatError` with `isRetryable = true`: show error + retry button
   - `VegapunkChatReady` with empty messages: show `vegapunkChatEmpty` hint text
   - `VegapunkChatReady` / `VegapunkChatGenerating` with messages:
     - `ListView.builder` auto-scrolled to bottom
     - Each item: `ChatMessageBubble`
     - If last message is Vegapunk + state is Generating: `isStreaming = true`
   - Bottom: `ChatInputBar` — disabled when generating

3. Auto-scroll controller: `ScrollController` that calls `scrollToBottom()` whenever messages change

**Done when:**
- Screen mounts without error in the emulator/device
- `flutter analyze` clean

---

## T9 — Navigation Changes

**Goal:** Wire up routing, replace Planner tab, add Planner to drawer  
**Req:** VGP-22–VGP-26  
**Depends on:** T8  
**Files:**
- `lib/shared/utils/app_routes.dart` (MODIFIED)
- `lib/shared/widgets/organisms/bottom_navigation.dart` (MODIFIED)
- `lib/features/home/presentation/widgets/user_drawer_content.dart` (MODIFIED)
- `lib/core/auth/app_wrapper.dart` (check route registration location)

**Steps:**

1. In `app_routes.dart`, add:
   ```dart
   static const String vegapunkChat = '/vegapunk-chat';
   ```

2. Register route in the route generator (check `app_wrapper.dart` or `app_routes.dart` for `onGenerateRoute` / switch):
   ```dart
   case AppRoutes.vegapunkChat:
     return VegapunkChatRoutes.onGenerateRoute(settings);
   ```

3. In `bottom_navigation.dart`:
   - Rename enum value: `knowledge` → `vegapunkChat`
   - Update `_pages` list (position 4)
   - Update `_navigateToPage` switch: add `vegapunkChat` case
   - Update `_buildNavigationItem` switch: add `vegapunkChat` case with icon `PhosphorIconsRegular.robot` and label `l10n.vegapunk`
   - Remove `knowledge` case

4. In all screens that use `BottomNavigation(BottomNavigationPages.knowledge)`:
   - Search codebase for `BottomNavigationPages.knowledge` and replace with `BottomNavigationPages.vegapunkChat`
   - Add `BottomNavigation(BottomNavigationPages.vegapunkChat)` to `VegapunkChatScreen`

5. In `user_drawer_content.dart`, add after the Duels tile:
   ```dart
   _buildFuturisticListTile(
     context,
     icon: PhosphorIconsRegular.book,
     title: AppLocalizations.of(context)!.planner,
     onTap: () => Navigator.pushNamed(context, AppRoutes.knowledge),
   ),
   ```

**Done when:**
- Tapping Vegapunk tab navigates to `/vegapunk-chat`
- Opening the hamburger menu shows Planner entry
- Tapping Planner in drawer navigates to `/knowledge`
- `RobinKnowledgeScreen` still uses its own `BottomNavigation` with knowledge page — update that too

---

## T10 — Smoke Test on Device

**Goal:** Verify the full user journey works on a real device / emulator  
**Req:** All  
**Depends on:** T9  

**Test cases:**

1. **Cold start → tap Vegapunk tab**
   - [ ] Download overlay appears with size (~586 MB)
   - [ ] Cancel button works (returns to idle)
   - [ ] Download starts, progress updates
   - [ ] After download: "Activating Vegapunk..." appears
   - [ ] Chat ready state shown

2. **Send a message**
   - [ ] User bubble appears immediately
   - [ ] Vegapunk typing indicator visible
   - [ ] Tokens stream in with cursor
   - [ ] Input disabled during generation
   - [ ] On complete: input re-enabled

3. **Cancel generation**
   - [ ] Stop button visible during generation
   - [ ] Pressing stop ends stream, partial response kept

4. **Second app launch** (model already downloaded)
   - [ ] No download overlay
   - [ ] Model loads directly to "Activating Vegapunk..." → ready

5. **Navigation**
   - [ ] Bottom nav tab 5 shows robot icon + "Vegapunk"
   - [ ] Hamburger menu shows Planner entry
   - [ ] Planner entry navigates to Robin Knowledge screen

6. **Error handling**
   - [ ] Simulate download failure → retry option appears
   - [ ] App doesn't crash on model error

---

## T11 — Write BLoC Unit Test

**Goal:** At least one unit test for VegapunkChatCubit  
**Req:** Feature dev checklist  
**Depends on:** T6  
**Files:**
- `test/features/vegapunk_chat/vegapunk_chat_cubit_test.dart` (NEW)

**Test cases:**
- `initializeChat()` with already-downloaded model → emits `VegapunkChatReady([])`
- `initializeChat()` with model not present → emits `VegapunkChatModelDownloading`
- `sendMessage()` with mocked stream → emits `Generating` then `Ready` with both messages
- `cancelGeneration()` during streaming → state becomes `Ready` with partial text

**Done when:**
- `flutter test test/features/vegapunk_chat/` passes

---

## Commit Plan

| Task | Commit message |
|------|---------------|
| T1 | `chore: add flutter_gemma dependencies and configure platform targets` |
| T2 | `feat(gemma): initialize FlutterGemma engines in main.dart` |
| T3 | `feat(gemma): implement GemmaService with download and session management` |
| T4 | `feat(i18n): add vegapunk chat localization keys` |
| T5 | `feat(vegapunk): add repository and chat state classes` |
| T6 | `feat(vegapunk): implement VegapunkChatCubit with streaming support` |
| T7 | `feat(vegapunk): add chat presentation widgets` |
| T8 | `feat(vegapunk): implement VegapunkChatScreen` |
| T9 | `feat(nav): replace Planner tab with Ask Vegapunk, move Planner to drawer` |
| T10 | `test(vegapunk): verify full user journey on device` |
| T11 | `test(vegapunk): add VegapunkChatCubit unit tests` |
