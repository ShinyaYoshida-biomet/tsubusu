# Task Completion Checklist

When completing a coding task, follow these steps:

## 1. Code Quality Checks

### Run Static Analysis
```bash
flutter analyze
```
- Fix all errors and warnings
- Address lint issues following project conventions

### Format Code
Flutter auto-formats on save in most IDEs, but you can also run:
```bash
dart format lib/ test/
```

## 2. Testing

### Run Tests
```bash
flutter test
```
- Ensure all existing tests pass
- Add new tests for new functionality (if applicable)
- Test files are in `test/` directory

### Manual Testing
- Run the app: `flutter run -d macos`
- Test the changed functionality
- Verify no regressions in existing features
- Test on both macOS and Windows if cross-platform changes

## 3. Build Verification

### Test Release Build
```bash
flutter build macos --release
```
- Ensure the release build completes successfully
- No need to test Windows build locally unless Windows-specific changes

## 4. Git Workflow

### Review Changes
```bash
git status
git diff
```

### Commit Changes (if requested by user)
- Follow user's CLAUDE.md instructions
- No force options allowed
- Use descriptive commit messages

## 5. Documentation
- Update relevant documentation if needed
- Only create new .md files if explicitly requested
- Use `.issues` directory for issue/documentation files

## Notes
- **Permissions**: Can modify programming files (.dart, .py, .js, etc.) without asking
- **Git Commands**: Can use read-only git commands without permission (status, log, branch, diff)
- **Destructive Operations**: Always ask before force push, hard reset, or other destructive git operations
- **Platform**: Project primarily targets macOS (Darwin), with Windows support