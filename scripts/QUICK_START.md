# Quick Version Management Cheat Sheet

## 🚀 Quick Commands

### Increment Version & Build

```bash
# 1. Bump version (choose one)
dart scripts/bump_version.dart patch   # Bug fixes: 1.0.0 → 1.0.1
dart scripts/bump_version.dart minor   # New features: 1.0.0 → 1.1.0
dart scripts/bump_version.dart major   # Breaking changes: 1.0.0 → 2.0.0

# 2. Build APK
flutter build apk --release
```

### One-Command Build

**PowerShell (Windows - Recommended):**
```powershell
# Build only (no version bump)
.\scripts\build_release.ps1

# Build with automatic version bump
.\scripts\build_release.ps1 -BumpType patch   # Bug fix
.\scripts\build_release.ps1 -BumpType minor   # New feature
.\scripts\build_release.ps1 -BumpType major   # Breaking change
```

**CMD (Windows):**
```cmd
scripts\build_release.bat
```

**Linux/Mac:**
```bash
./scripts/build_release.sh
```

To enable auto-bump in `.bat` or `.sh` scripts, edit the script and uncomment one of these lines:
- `dart scripts\bump_version.dart patch`
- `dart scripts\bump_version.dart minor`
- `dart scripts\bump_version.dart major`

## 📍 Find Your APK

After building, your APK is here:
```
build/app/outputs/flutter-apk/app-release.apk
```

## 🔄 How Auto-Versioning Works

1. **Manual Control (Default)**: Edit `version:` in `pubspec.yaml`
2. **Script-Based**: Run `dart scripts/bump_version.dart [type]`
3. **Git-Based Auto**: If no build number in pubspec, uses git commit count

## 📋 Current Version

Check your current version:
```bash
grep "^version:" pubspec.yaml
```

## ✅ Pre-Release Checklist

- [ ] Bump version: `dart scripts/bump_version.dart [type]`
- [ ] Commit version change: `git commit -am "Bump version to X.Y.Z"`
- [ ] Build APK: `flutter build apk --release`
- [ ] Test APK on device
- [ ] Tag release: `git tag vX.Y.Z`
- [ ] Push: `git push && git push --tags`

## 🎯 Examples

```bash
# Scenario 1: Fixed a bug
dart scripts/bump_version.dart patch      # 1.0.0+1 → 1.0.1+2
flutter build apk --release

# Scenario 2: Added new feature
dart scripts/bump_version.dart minor      # 1.0.1+2 → 1.1.0+3
flutter build apk --release

# Scenario 3: Major redesign
dart scripts/bump_version.dart major      # 1.1.0+3 → 2.0.0+4
flutter build apk --release
```

## 🆘 Troubleshooting

**Script not found?**
```bash
# Make sure you're in the project root
cd C:\dev\flutter_dev\mybooklibrary\my_book_library
```

**Permission denied (Linux/Mac)?**
```bash
chmod +x scripts/build_release.sh
```

**Want to manually set version?**
```bash
# Edit pubspec.yaml, line 4:
version: 2.5.0+10
```

---

For detailed documentation, see: `scripts/VERSION_MANAGEMENT.md`

