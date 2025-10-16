# 📦 Version Management & Build Scripts

This directory contains tools for managing app versions and building release APKs for My Book Library.

## 📁 Files Overview

| File | Purpose |
|------|---------|
| `bump_version.dart` | Script to increment version numbers in pubspec.yaml |
| `build_release.ps1` | PowerShell build script (Windows - Recommended) |
| `build_release.bat` | Batch build script (Windows) |
| `build_release.sh` | Bash build script (Linux/Mac) |
| `QUICK_START.md` | Quick reference guide |
| `VERSION_MANAGEMENT.md` | Detailed version management guide |

## 🚀 Quick Start

For a quick reference, see **[QUICK_START.md](QUICK_START.md)**

For detailed documentation, see **[VERSION_MANAGEMENT.md](VERSION_MANAGEMENT.md)**

## ⚡ Most Common Commands

### Bump Version & Build

```powershell
# PowerShell (Windows) - One command to bump and build!
.\scripts\build_release.ps1 -BumpType patch
```

### Manual Version Control

```bash
# 1. Increment version
dart scripts/bump_version.dart patch   # 1.0.0+1 → 1.0.1+2

# 2. Build
flutter build apk --release
```

## 🎯 Version Format

Versions follow this format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`

Example: `1.2.3+45`
- `1` = Major version (breaking changes)
- `2` = Minor version (new features)
- `3` = Patch version (bug fixes)
- `45` = Build number (must increment each release)

## 🔧 Automatic Version Incrementing

The project supports **three** methods of version management:

### 1. Manual (Full Control)
Edit `pubspec.yaml` directly:
```yaml
version: 1.0.0+1
```

### 2. Script-Based (Recommended)
Use the bump script:
```bash
dart scripts/bump_version.dart [patch|minor|major]
```

### 3. Git-Based (Automatic)
The Android build is configured to use git commit count if no build number is specified in `pubspec.yaml`.

## 🏗️ Build Scripts

### PowerShell (Windows - Best Option)

```powershell
# Build without version bump
.\scripts\build_release.ps1

# Build with version bump
.\scripts\build_release.ps1 -BumpType patch
.\scripts\build_release.ps1 -BumpType minor
.\scripts\build_release.ps1 -BumpType major
```

**Features:**
- ✅ Parameter-based version bumping
- ✅ Error checking
- ✅ Colored output
- ✅ Automatic APK copying to `releases/` folder
- ✅ Shows APK size

### Batch Script (Windows)

```cmd
scripts\build_release.bat
```

Edit the script to uncomment the version bump line you want.

### Bash Script (Linux/Mac)

```bash
chmod +x scripts/build_release.sh
./scripts/build_release.sh
```

Edit the script to uncomment the version bump line you want.

## 📍 Output Locations

After building:

1. **Main APK**: `build/app/outputs/flutter-apk/app-release.apk`
2. **Versioned Copy** (PowerShell script): `releases/my_book_library-vX.Y.Z+N.apk`

## 🔄 Workflow Example

### Scenario: You fixed a bug

```powershell
# 1. Make your code changes
# ... edit files ...

# 2. Build with automatic version increment
.\scripts\build_release.ps1 -BumpType patch

# 3. Test the APK
# ... install and test on device ...

# 4. Commit and tag
git add .
git commit -m "Fix: Bug description"
git tag v1.0.1
git push && git push --tags
```

## 📊 Version History Example

```
v1.0.0+1   - Initial release
v1.0.1+2   - Fixed login bug
v1.0.2+3   - Fixed crash on book details
v1.1.0+4   - Added genre filtering
v1.1.1+5   - Performance improvements
v2.0.0+6   - Major UI redesign
```

## 🆘 Troubleshooting

### "Script not found"
Make sure you're in the project root:
```bash
cd C:\dev\flutter_dev\mybooklibrary\my_book_library
```

### PowerShell Execution Policy Error
Run PowerShell as Administrator:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Build Fails
1. Check Flutter is in PATH: `flutter --version`
2. Clean and retry: `flutter clean && flutter pub get`
3. Check Android SDK is installed

## 🎓 Best Practices

1. **Always increment build number** for each Play Store upload
2. **Use semantic versioning** for version names
3. **Test APKs** before releasing
4. **Tag releases** in git: `git tag vX.Y.Z`
5. **Keep a changelog** documenting changes
6. **Commit version bumps** separately from features

## 📚 Related Files

- `pubspec.yaml` - Contains the version number
- `android/app/build.gradle.kts` - Android build configuration with auto-increment logic
- `.gitignore` - Excludes `releases/` folder from version control

## 🔗 Additional Resources

- [Flutter Build & Release Docs](https://docs.flutter.dev/deployment/android)
- [Semantic Versioning](https://semver.org/)
- [Android Version Codes](https://developer.android.com/studio/publish/versioning)

---

**Need Help?** Check `QUICK_START.md` for a cheat sheet or `VERSION_MANAGEMENT.md` for detailed docs.

