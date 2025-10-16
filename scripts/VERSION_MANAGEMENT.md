# Version Management Guide

## Overview

This project uses automated version management for APK releases. The version is controlled in `pubspec.yaml` and automatically used during builds.

## Current Version System

- **Version Format**: `MAJOR.MINOR.PATCH+BUILD_NUMBER`
- **Example**: `1.0.0+1`
  - `1.0.0` = Version name (shown to users)
  - `1` = Build number (internal, must increment for each release)

## Auto-Increment Options

### Option 1: Git Commit Count (Automatic)

The `android/app/build.gradle.kts` is configured to automatically use git commit count as the build number if not specified in `pubspec.yaml`.

**How it works:**
- If you specify a build number in `pubspec.yaml` (e.g., `1.0.0+5`), it uses that
- If you omit the build number (e.g., `1.0.0`), it uses git commit count
- Every new commit automatically increments the build number

**Pros:**
- No manual intervention needed
- Build numbers always increase
- Tied to git history

**Cons:**
- Build number might be higher than expected
- Different branches might have different counts

### Option 2: Manual Script Bump (Recommended)

Use the provided `bump_version.dart` script to increment versions semantically:

```bash
# Increment patch version (1.0.0 → 1.0.1)
dart scripts/bump_version.dart patch

# Increment minor version (1.0.1 → 1.1.0)
dart scripts/bump_version.dart minor

# Increment major version (1.1.0 → 2.0.0)
dart scripts/bump_version.dart major
```

Each command automatically increments the build number as well.

## Building Release APKs

### Quick Build (Windows)

```cmd
scripts\build_release.bat
```

### Quick Build (Linux/Mac)

```bash
chmod +x scripts/build_release.sh
./scripts/build_release.sh
```

### Manual Build

```bash
# 1. (Optional) Bump version
dart scripts/bump_version.dart patch

# 2. Build APK
flutter build apk --release

# 3. Find your APK at:
# build/app/outputs/flutter-apk/app-release.apk
```

## Version Guidelines

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.x.x): Breaking changes, incompatible API changes
- **MINOR** (x.1.x): New features, backward compatible
- **PATCH** (x.x.1): Bug fixes, backward compatible

## Best Practices

1. **Before each release:**
   - Run `dart scripts/bump_version.dart [type]`
   - Commit the version change
   - Build the APK
   - Tag the release in git: `git tag v1.0.0`

2. **For Google Play Store:**
   - Build number MUST increase with each upload
   - Version name should follow semantic versioning

3. **Keep a changelog:**
   - Document what changed in each version
   - Update `CHANGELOG.md` before releasing

## Troubleshooting

### Build number not incrementing

If using git-based auto-increment, make sure:
- You're in a git repository
- You have commits in your history
- Git is available in your PATH

### Manual override

You can always override the version when building:

```bash
flutter build apk --build-name=1.2.3 --build-number=42
```

## Examples

```bash
# Starting from version 1.0.0+1

# Fix a bug
dart scripts/bump_version.dart patch  # → 1.0.1+2

# Add new feature
dart scripts/bump_version.dart minor  # → 1.1.0+3

# Major rewrite
dart scripts/bump_version.dart major  # → 2.0.0+4

# Build the APK
flutter build apk --release
```

