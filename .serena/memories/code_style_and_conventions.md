# Code Style and Conventions

## General Conventions
- **Architecture**: Atomic Design Pattern (atoms, molecules, organisms, templates, pages)
- **State Management**: Provider pattern with ChangeNotifier
- **Linting**: Uses `flutter_lints` package with default Flutter recommended rules

## Dart/Flutter Conventions

### Naming
- **Classes**: PascalCase (e.g., `TodoPage`, `CustomButton`)
- **Files**: snake_case matching class name (e.g., `todo_page.dart`, `custom_button.dart`)
- **Private members**: Prefix with underscore (e.g., `_currentTheme`, `_loadTheme`)
- **Constants**: camelCase for static const (e.g., `_themeKey`)

### Class Structure
1. Static constants
2. Instance fields (public then private)
3. Constructor
4. Public methods
5. Private methods
6. Getters/setters

### Widget Pattern
- Use `StatelessWidget` when no state is needed
- Use `StatefulWidget` for interactive components
- Always include `const` constructors when possible
- Use `super.key` parameter naming
- Use `required` for mandatory parameters

### Code Organization
- One widget class per file (with exceptions for private helper classes)
- Import order: Flutter SDK → External packages → Internal imports
- Use relative imports for internal files (e.g., `'../models/app_theme.dart'`)

### Error Handling
- Use try-catch blocks for async operations
- Gracefully handle errors with fallback values
- Use `debugPrint` for development logging
- Include comments explaining error handling strategy

### Documentation
- No comprehensive docstrings required
- Use inline comments for complex logic
- Comments should explain "why" not "what"

### Type Annotations
- Explicit return types for methods
- Type inference acceptable for local variables
- Nullable types marked with `?`
- Use `late` keyword for non-nullable fields initialized later

## Flutter-Specific Patterns

### State Management
- Services extend `ChangeNotifier`
- Call `notifyListeners()` after state changes
- Use `Provider` for dependency injection

### Async Operations
- Use `async`/`await` for asynchronous code
- Return `Future<void>` for async methods without return values
- Handle errors in async methods with try-catch

### Widget Composition
- Break down complex widgets into smaller reusable components
- Pass callbacks for event handling (e.g., `onPressed`, `onToggle`)
- Use named parameters for better readability