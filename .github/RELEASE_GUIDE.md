# Release Guide

This project is configured with GitHub Actions to automatically build and distribute binaries for macOS and Windows when a new release is created.

## How to Create a Release

### Option 1: Using Git Tags
1. Create and push a new tag:
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

### Option 2: Using GitHub Releases UI
1. Go to your GitHub repository
2. Click on "Releases" in the right sidebar
3. Click "Create a new release"
4. Choose or create a new tag (e.g., `v1.0.1`)
5. Add release notes describing the changes
6. Click "Publish release"

## What Happens Automatically

When you create a release (either method), the GitHub Action will:

1. **Build macOS version**: Creates a `.dmg` file ready for distribution
2. **Build Windows version**: Creates a `.zip` file with the executable and dependencies
3. **Upload binaries**: Automatically attaches both files to the GitHub release
4. **Check release size**: Fails the build if a distributed archive exceeds its
   platform budget, and writes an archive/payload breakdown to the GitHub Actions
   job summary.

## Release Size Budget

The distributed archives have the following budgets, measured in decimal MB
(1 MB = 1,000,000 bytes):

| Platform | Archive | Budget |
| --- | --- | ---: |
| macOS | `tsubusu-macos.dmg` | 20 MB |
| Windows | `tsubusu-windows.zip` | 12 MB |

The current baseline, from the v1.0.5 release, is 19.7 MB for the macOS DMG
and 11.3 MB for the Windows ZIP. The initial goal is a safe 5–15% reduction
only when measurement identifies content that can be removed without changing
features, compatibility, signing, or maintainability. Flutter runtime files are
expected to be a substantial and necessary part of both payloads.

The initial inventory removed the unused direct `cupertino_icons` dependency;
the app does not reference `CupertinoIcons`. Its actual archive-size effect is
recorded by the next release job summary. No other dependency, platform runtime,
or packaging content is removed without a matching usage and release-size check.

Each release build reports the compressed archive size and a breakdown of the
uncompressed app payload in its job summary. The latter is diagnostic: it makes
the largest runtime, executable, asset, plugin, symbol, and packaging components
visible, but it is not compared directly with the compressed archive budget.

To reproduce the check locally after creating a release archive, run:

```bash
dart run tool/release_size_report.dart \
  --platform macos \
  --artifact tsubusu-macos.dmg \
  --payload build/macos/Build/Products/Release/tsubusu.app \
  --budget-mb 20
```

For a Windows release build, run the same command with `--platform windows`,
`--artifact tsubusu-windows.zip`,
`--payload build/windows/x64/runner/Release`, and `--budget-mb 12`.

If a feature genuinely requires a budget exception, document the measured
increase and reason in its pull request before changing the workflow budget.

## Binary Distribution

Users can download the binaries directly from the GitHub Releases page:
- **macOS users**: Download the `.dmg` file and drag the app to Applications
- **Windows users**: Download and extract the `.zip` file, then run the executable

## Version Numbering

Follow semantic versioning (e.g., `v1.0.0`, `v1.0.1`, `v2.0.0`) for your tags and releases.
