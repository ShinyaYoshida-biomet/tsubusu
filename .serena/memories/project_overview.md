# Tsubusu - Project Overview

## Purpose
Tsubusu is a minimal ToDo app for macOS and Windows, inspired by Stickies but focused on task management. It provides a clean, desktop-native experience for managing todo lists with support for multiple windows.

## Tech Stack
- **Framework**: Flutter (3.29.3+)
- **Language**: Dart (3.7.2+)
- **Platform**: macOS and Windows desktop applications
- **Key Dependencies**:
  - `provider` (6.1.2) - State management
  - `shared_preferences` (2.2.2) - Local data persistence
  - `desktop_multi_window` (0.2.1) - Multi-window support
  - `cupertino_icons` (1.0.8) - iOS-style icons
- **Dev Dependencies**:
  - `flutter_test` - Testing framework
  - `flutter_lints` (5.0.0) - Linting rules

## Project Structure
```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── todo.dart               # Todo data model
│   └── app_theme.dart          # Theme configuration
├── providers/                   # State management
│   └── theme_provider.dart     # Theme state provider
├── services/                    # Business logic
│   ├── window_todo_service.dart # Todo management per window
│   └── window_manager.dart      # Window management
└── widgets/                     # UI components (Atomic Design)
    ├── atoms/                  # Basic UI elements
    ├── molecules/              # Composite components
    ├── organisms/              # Complex components
    ├── templates/              # Page layouts
    └── pages/                  # Full pages
        └── todo_page.dart

test/                           # Test files
├── widget_test.dart
├── todo_service_test.dart
├── completion_animation_test.dart
└── window_manager_test.dart
```

## Features
- Multiple independent todo list windows
- Task completion with animations
- Theme customization (Forest, Ocean, etc.)
- Persistent storage per window
- Drag-and-drop reordering
- Resizable completed tasks section