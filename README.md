# Tsubusu

A minimal ToDo app for macOS, inspired by Stickies but focused on task management.

## Demo

https://github.com/user-attachments/assets/772b74af-0626-4b41-9ece-1aaccb1ae112

## Download

**📦 Ready-to-use binaries available!**

Download the latest version from [Releases](https://github.com/ShinyaYoshida-biomet/tsubusu/releases):
- **macOS**: Download `tsubusu-macos.dmg`
- **Windows**: Download `tsubusu-windows.zip`

⚠️ **macOS Security Warning**: When you first open the app, macOS will show a security dialog. **DO NOT click "OK"**. Instead, right-click the app in Finder and select "Open".

## Development

To run the app:

```bash
flutter run -d macos
```

### Mobile foundation (Android and iOS)

The Android and iOS platform projects are committed so mobile work can start
without regenerating platform files. This foundation supports the current local
todo experience; it does not include release signing, notifications, widgets,
or sync.

Prerequisites:

- Flutter 3.29.3 and Dart 3.7.2 (the versions used by CI)
- Android Studio with an Android SDK and emulator/device for Android
- Xcode and CocoaPods, plus an iOS Simulator/device, for iOS (macOS only)

Use a connected device or simulator identifier from `flutter devices`:

```bash
flutter pub get
flutter run -d <android-device-id>
flutter run -d <ios-device-id>
```

Build checks (release distribution/signing remains intentionally out of scope):

```bash
flutter build apk --debug
flutter build ios --debug --no-codesign
```

### Generated artifacts and cleanup

Build output and tool state are generated locally and must not be committed.
Use the cleanup tool instead of a broad command such as `git clean`, which can
remove unrelated ignored files.

The same safe commands are available through `make` (using the project's FVM
Flutter/Dart SDK by default):

```bash
make clean-generated
make clean-generated-full
make clean-generated-dry-run
```

For the usual clean build, remove only Flutter/Dart build state:

```bash
dart run tool/clean_generated.dart --normal
flutter pub get
flutter run -d macos
```

For a fully reproducible desktop environment, also remove generated CocoaPods
and platform ephemeral files before regenerating them from the committed
lockfiles on the next platform build:

```bash
dart run tool/clean_generated.dart --full
flutter pub get
flutter run -d macos
```

Add `--dry-run` to either command to review the exact paths first. Normal
cleanup removes `build/`, `coverage/`, `.dart_tool/`, and Flutter's generated
plugin state. Full cleanup additionally removes only regenerated Android
Gradle state, iOS/macOS Pods and Flutter ephemeral files, and Windows Flutter
ephemeral files. The commands do not target source files, `pubspec.lock`,
Podfile locks, Xcode project configuration, entitlements/signing configuration,
credentials, or app user data.

## Requirements

- Flutter SDK (3.29.3 or later)
- Dart SDK (3.7.2 or later)
- macOS development environment
- Xcode (for macOS development)
- Android Studio and Android SDK (for Android development)
- Xcode and CocoaPods (for iOS development)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
