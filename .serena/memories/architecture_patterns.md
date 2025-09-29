# Architecture and Design Patterns

## Overall Architecture
Tsubusu follows Flutter best practices with Provider for state management and Atomic Design for UI component organization.

## Design Patterns

### 1. Atomic Design Pattern
UI components are organized hierarchically:

- **Atoms** (`lib/widgets/atoms/`): Basic building blocks
  - `CustomButton`, `CustomTextField`, `CustomText`
  - `IconButtonAtom`, `AnimatedCheckbox`
  - `CompletionAnimation`

- **Molecules** (`lib/widgets/molecules/`): Combinations of atoms
  - `TodoItem`: Single todo item with checkbox and actions
  - `AddTodoForm`: Input form for adding todos
  - `SettingsDialog`: Theme selection dialog

- **Organisms** (`lib/widgets/organisms/`): Complex components
  - `AppHeader`: Window title and main input
  - `TodoList`: Complete todo list with sections

- **Pages** (`lib/widgets/pages/`): Full-page views
  - `TodoPage`: Main todo list page

### 2. Provider Pattern (State Management)
- **Providers** extend `ChangeNotifier`
- Services notify listeners on state changes
- Widgets consume providers via `context.watch<Provider>()`

Key Providers:
- `ThemeProvider`: Global theme state
- `WindowTodoService`: Per-window todo list state

### 3. Service Layer Pattern
Business logic is separated into service classes:

- **WindowTodoService**: Manages todo CRUD operations per window
  - Persists data using SharedPreferences
  - Window-specific storage keys
  - Emits notifications on changes

- **WindowManager**: Handles multi-window functionality
  - Creates and manages multiple independent windows
  - Each window has its own `WindowTodoService` instance

### 4. Repository Pattern (Implicit)
Data persistence is handled through services:
- SharedPreferences for key-value storage
- JSON serialization for complex objects
- Window-scoped data separation

### 5. Model Pattern
Data models are simple classes with:
- Immutable fields (or controlled mutability)
- `copyWith` method for updates
- `toJson`/`fromJson` for serialization

Example: `Todo` model
- Unique ID generation
- JSON serialization
- Immutable copying

## Multi-Window Architecture
- Each window is independent
- Window-specific data storage using window ID
- Desktop-specific multi-window library (`desktop_multi_window`)
- Main window can spawn additional windows

## Theming Architecture
- Predefined theme configurations (`AppTheme`)
- Theme types as enum (`ThemeType`)
- Global theme state via `ThemeProvider`
- Theme persistence across app restarts
- Easy theme switching without restart

## Data Flow
1. User interacts with Widget
2. Widget calls method on Service (via Provider)
3. Service updates internal state
4. Service persists to SharedPreferences
5. Service calls `notifyListeners()`
6. Provider rebuilds dependent widgets
7. Widgets reflect new state

## Key Principles
- Separation of concerns (UI, logic, data)
- Single responsibility per class
- Composition over inheritance
- Reactive state updates
- Immutable data models where practical