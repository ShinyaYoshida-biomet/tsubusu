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

## Binary Distribution

Users can download the binaries directly from the GitHub Releases page:
- **macOS users**: Download the `.dmg` file and drag the app to Applications
- **Windows users**: Download and extract the `.zip` file, then run the executable

## Version Numbering

Follow semantic versioning (e.g., `v1.0.0`, `v1.0.1`, `v2.0.0`) for your tags and releases.