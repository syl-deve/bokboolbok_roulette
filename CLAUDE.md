# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**복불복룰렛 (Bokboolbok Roulette)** — A cross-platform roulette/lottery Flutter app published on Google Play Store. Package ID: `com.malee.bokboolbok_roulette`.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run app (default device)
flutter run

# Run on specific platform
flutter run -d android
flutter run -d chrome

# Build release APK
flutter build apk --release

# Analyze code
flutter analyze

# Regenerate localization files (after editing .arb files)
flutter gen-l10n

# Regenerate app icons (after changing assets/icon/app_icon.png)
dart run flutter_launcher_icons
```

## Architecture

The app is a **single-file monolith** — almost all logic lives in `lib/main.dart` (~1,550 lines). There is no separate screen/widget/service directory structure.

### Key classes in `lib/main.dart`

| Class | Line | Purpose |
|---|---|---|
| `AdHelper` | ~141 | Google Mobile Ads initialization + interstitial ad lifecycle |
| `MyBannerAd` | ~194 | Banner ad widget |
| `Player` | ~239 | Data model for a participant |
| `Preset` | ~243 | Data model for a preset (name + player list) |
| `PlayerProvider` | ~248 | `ChangeNotifier` — owns participant list, presets, win history, SharedPreferences persistence |
| `HomeScreen` / `_HomeScreenState` | ~325/332 | Main UI: roulette wheel, spin logic, winner selection, confetti |
| `_PresetSheet` | ~960 | Draggable bottom sheet for saving/loading/deleting presets |
| `_HistorySheet` | ~1100 | Draggable bottom sheet showing win history/stats |
| `_WinnerDialog` | ~1380 | Dialog displayed when a winner is selected |

### State management

Provider pattern. `PlayerProvider` is the single source of truth — registered at the root via `ChangeNotifierProvider`. Widgets consume it via `context.watch<PlayerProvider>()` / `context.read<PlayerProvider>()`.

### Persistence

`SharedPreferences` — participant list, presets, and win history are serialized/deserialized in `PlayerProvider`.

- `players` key: `List<String>`
- `history` key: `String` (`name:count|name:count|…`)
- `presets` key: `List<String>` (each entry: `presetName\x00player1\x00player2\x00…`)

### Localization

ARB files in `lib/l10n/`. Supported locales: `ko`, `en`, `ja`, `zh`. After editing `.arb` files, run `flutter gen-l10n` to regenerate the Dart delegates. Config is in `l10n.yaml`.

### Ads

- Banner ad: displayed at bottom of `HomeScreen`
- Interstitial ad: triggered after spin via `AdHelper`
- Test device ID is hardcoded for development; production uses real AdMob IDs

### Android build

- Gradle uses Kotlin DSL (`build.gradle.kts`)
- Release signing uses `my-release-key.jks` (do not commit the keystore password)
- NDK version: 27.0.12077973
- Min SDK: 21

## File Notes

- `lib/main-250*.dart` files are historical backups — not compiled
- `my-release-key.jks` is the Android release keystore — keep credentials secure
- `assets/icon/app_icon.png` is the single source icon used for all platforms via `flutter_launcher_icons`
