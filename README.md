# OpFan — One Piece Fan App

A Flutter app for One Piece fans: character browser, custom characters, Devil Fruit database, crews, duels, a personal finance tracker, workout planner, cooking recipes, and an on-device AI chat (**Ask Vegapunk**, powered by `flutter_gemma`). Firebase for auth/data, BLoC/Cubit for state, GetIt for DI. Localized in English and Portuguese.

📚 **Documentation index:** [`docs/README.md`](docs/README.md) — setup guides (Firebase, Firestore, YouTube API, Gemini AI, flutter_gemma) and links to architecture specs.
🤖 **AI assistant guide:** [`CLAUDE.md`](CLAUDE.md) — full architecture, conventions, and stack reference (also used by Claude Code).

## 🛠️ Development Setup

### Prerequisites

- [FVM (Flutter Version Management)](https://fvm.app/) installed
- iOS/Android development environment setup

### Flutter Version Management (FVM)

This project uses FVM to ensure all developers use the same Flutter version.

#### First-time setup:

1. **Install FVM** (if not already installed):
   ```bash
   dart pub global activate fvm
   ```

2. **Install the project's Flutter version**:
   ```bash
   fvm install
   ```

3. **Use the project's Flutter version**:
   ```bash
   fvm use
   ```

#### Daily Development Commands:

Instead of using `flutter` directly, use `fvm flutter`:

```bash
# Install dependencies
fvm flutter pub get

# Run the app
fvm flutter run

# Build for iOS
fvm flutter build ios

# Build for Android
fvm flutter build apk

# Run tests
fvm flutter test

# Analyze code
fvm flutter analyze
```

#### VS Code Setup:

If you're using VS Code, add this to your `.vscode/settings.json`:

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk"
}
```

### Project Structure

```
lib/
├── app/di/                  # GetIt dependency injection modules
├── core/                    # Auth, models, services (Gemini, Gemma/RAG, Firestore, etc.), theme, locale
├── features/                # 18 feature modules (one_piece, vegapunk_chat, nami_finances, zoro_workout, …)
├── shared/                  # Atomic-design widgets (atoms/molecules/organisms) and utils
└── l10n/                    # ARB localization files (en, pt)
```

See [`CLAUDE.md`](CLAUDE.md) for the full architecture reference.

## 🚀 Getting Started

1. **Clone the repository**
2. **Install Flutter version**: `fvm install`
3. **Get dependencies**: `fvm flutter pub get`
4. **Generate code**: `fvm flutter packages pub run build_runner build`
5. **Run the app**: `fvm flutter run`

## 📱 Features

- **One Piece**: Browse and search characters, Devil Fruits, crews, custom characters
- **Ask Vegapunk**: On-device AI chat (`flutter_gemma`) with RAG and function calling — see [`docs/flutter-gemma-on-device.md`](docs/flutter-gemma-on-device.md)
- **Nami Finances**: Personal finance tracker with its own on-device RAG assistant
- **Zoro Workout / Sanji Cooking / Robin Knowledge**: planners, recipes, trivia
- **Duels, Calculator**: utility features
- **Internationalization**: English and Portuguese support

## 🔧 Technical Details

- **Flutter**: >=3.27.0 (managed by FVM)
- **Dart**: >=3.12.0
- **State Management**: flutter_bloc (BLoC/Cubit)
- **Dependency Injection**: get_it
- **Backend**: Firebase (Auth, Firestore, Cloud Functions, FCM)
- **AI**: `google_generative_ai` (Gemini, cloud) + `flutter_gemma` (on-device)
- **Localization**: flutter_localizations + ARB files
- **Code Generation**: build_runner, json_serializable, hive_generator

## 🤝 Contributing

1. Make sure you're using the correct Flutter version with FVM
2. Run `fvm flutter analyze` before committing
3. Follow the existing code style and structure

---

*Last updated: 2026-07-06*
