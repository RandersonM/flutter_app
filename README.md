# Flutter App - One Piece Characters

This is a Flutter application that displays One Piece characters with their information, including a calculator and counter features.

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
├── core/                    # Business logic and providers
├── l10n/                    # Localization files
├── screens/                 # UI screens
│   ├── calculator/         # Calculator functionality
│   ├── counter/            # Simple counter
│   ├── one_piece/          # One Piece characters
│   └── splash/             # Splash screen
└── shared/                 # Shared widgets and utilities
```

## 🚀 Getting Started

1. **Clone the repository**
2. **Install Flutter version**: `fvm install`
3. **Get dependencies**: `fvm flutter pub get`
4. **Generate code**: `fvm flutter packages pub run build_runner build`
5. **Run the app**: `fvm flutter run`

## 📱 Features

- **Counter**: Simple increment/decrement counter
- **Calculator**: Basic mathematical operations
- **One Piece**: Browse and search One Piece characters
- **Internationalization**: English and Portuguese support
- **Responsive Design**: Works on different screen sizes

## 🔧 Technical Details

- **Flutter Version**: 3.22.3 (managed by FVM)
- **Dart Version**: 3.4.4
- **State Management**: Provider
- **Localization**: flutter_localizations
- **Code Generation**: build_runner, json_serializable

## 🤝 Contributing

1. Make sure you're using the correct Flutter version with FVM
2. Run `fvm flutter analyze` before committing
3. Follow the existing code style and structure

---

*Last updated: Flutter 3.22.3 with FVM support*
