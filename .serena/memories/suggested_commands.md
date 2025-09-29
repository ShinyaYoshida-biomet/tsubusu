# Suggested Commands

## Development Commands

### Running the Application
```bash
# Run on macOS (primary platform)
flutter run -d macos

# Run on Windows
flutter run -d windows

# Run with hot reload enabled (default)
flutter run -d macos
```

### Dependencies
```bash
# Get/update dependencies
flutter pub get

# Update dependencies to latest compatible versions
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

### Building
```bash
# Build macOS release
flutter build macos --release

# Build Windows release
flutter build windows --release
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/todo_service_test.dart

# Run with coverage
flutter test --coverage
```

### Linting and Analysis
```bash
# Run static analysis
flutter analyze

# Fix auto-fixable lint issues
dart fix --apply
```

## Git Commands (Darwin/macOS)
```bash
# Check status
git status

# View commit history
git log --oneline -10

# View changes
git diff

# View branches
git branch -a

# Create new branch
git branch <branch-name>

# Switch branch
git checkout <branch-name>
```

## System Utilities (macOS/Darwin)
```bash
# List files
ls -la

# Find files
find . -name "*.dart"

# Search in files (macOS uses BSD grep)
grep -r "pattern" lib/

# Show file contents
cat <file>

# Change directory
cd <directory>
```

## Release Process
- Tags trigger automated builds via GitHub Actions
- macOS: Creates DMG file
- Windows: Creates ZIP file
- Both uploaded to GitHub Releases automatically