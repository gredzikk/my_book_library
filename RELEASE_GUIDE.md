# 🚀 Release Guide for My Book Library

Complete guide for building and releasing APKs of My Book Library.

## 📋 Prerequisites

- [x] Flutter SDK installed and in PATH
- [x] Android SDK configured
- [x] Git installed (for auto-versioning)
- [x] Device or emulator for testing

## 🎯 Quick Release (Recommended)

The fastest way to create a release:

```powershell
# PowerShell - Windows
.\scripts\build_release.ps1 -BumpType patch
```

This single command will:
1. ✅ Increment the version (patch: bug fix)
2. ✅ Clean previous builds
3. ✅ Get dependencies
4. ✅ Build release APK
5. ✅ Copy APK to `releases/` with version name
6. ✅ Show APK size and location

## 📖 Step-by-Step Release Process

### 1. Decide Version Type

Choose based on your changes:

- **Patch** (1.0.0 → 1.0.1): Bug fixes only
- **Minor** (1.0.0 → 1.1.0): New features, backward compatible
- **Major** (1.0.0 → 2.0.0): Breaking changes

### 2. Update Changelog

Edit `CHANGELOG.md`:

```markdown
## [1.1.0] - 2025-10-16

### Added
- Genre filtering on home screen

### Fixed
- Fixed crash when deleting books
```

### 3. Bump Version

Choose your platform:

**PowerShell (Windows):**
```powershell
.\scripts\build_release.ps1 -BumpType minor
```

**Manual:**
```bash
dart scripts/bump_version.dart minor
flutter build apk --release
```

### 4. Test the APK

```bash
# Install on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# Or from releases folder
adb install releases/my_book_library-v1.1.0+3.apk
```

Test critical features:
- [ ] Authentication works
- [ ] Books load correctly
- [ ] Add/Edit book functions
- [ ] Search and filtering
- [ ] Book details display

### 5. Commit and Tag

```bash
git add .
git commit -m "Release v1.1.0"
git tag v1.1.0
git push origin main
git push origin v1.1.0
```

### 6. Distribute

- Upload to Google Play Console
- Share APK directly with testers
- Create GitHub release (if using GitHub)

## 🛠️ Available Scripts

### Build Scripts

| Platform | Script | Features |
|----------|--------|----------|
| PowerShell | `.\scripts\build_release.ps1 -BumpType patch` | ⭐ Best option, full automation |
| Batch | `scripts\build_release.bat` | Simple, requires manual version bump |
| Bash | `./scripts/build_release.sh` | Linux/Mac, requires manual version bump |

### Version Scripts

```bash
# Increment version numbers
dart scripts/bump_version.dart patch   # 1.0.0+1 → 1.0.1+2
dart scripts/bump_version.dart minor   # 1.0.0+1 → 1.1.0+2
dart scripts/bump_version.dart major   # 1.0.0+1 → 2.0.0+2
```

## 📍 File Locations

After building, find your files here:

```
build/app/outputs/flutter-apk/app-release.apk     # Main APK
releases/my_book_library-vX.Y.Z+N.apk             # Versioned copy (PowerShell only)
```

## 🔍 Version Information

### Current Version
```bash
# Check current version
grep "^version:" pubspec.yaml
```

### Version Format
```
version: 1.2.3+45
         │ │ │  └─ Build number (increments each build)
         │ │ └──── Patch (bug fixes)
         │ └────── Minor (new features)
         └──────── Major (breaking changes)
```

## 📊 Version History Template

Keep track in `CHANGELOG.md`:

```
v1.0.0+1   - Initial release
v1.0.1+2   - Bug fixes
v1.1.0+3   - New genre feature
v2.0.0+4   - Complete redesign
```

## ⚙️ Build Configurations

### Release Build (Default)
```bash
flutter build apk --release
```
- Optimized for production
- Signed with debug key (change for production!)
- Minimum size

### Debug Build
```bash
flutter build apk --debug
```
- Includes debugging symbols
- Larger file size
- Allows debugging

### Profile Build
```bash
flutter build apk --profile
```
- Performance profiling
- Optimized but with profiling tools

### Split APKs (Smaller Size)
```bash
flutter build apk --split-per-abi
```
Generates separate APKs for:
- `arm64-v8a` (64-bit ARM)
- `armeabi-v7a` (32-bit ARM)
- `x86_64` (64-bit Intel)

## 🔐 Setting Up Release Signing

For production releases, you need a proper signing key:

### 1. Create Keystore

```bash
keytool -genkey -v -keystore ~/my_book_library.keystore -alias my_book_library -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Create `android/key.properties`

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=my_book_library
storeFile=C:/path/to/my_book_library.keystore
```

### 3. Update `android/app/build.gradle.kts`

See [Flutter signing docs](https://docs.flutter.dev/deployment/android#signing-the-app) for details.

## ✅ Pre-Release Checklist

Before every release:

- [ ] All features tested
- [ ] No critical bugs
- [ ] Version incremented
- [ ] CHANGELOG.md updated
- [ ] APK built successfully
- [ ] APK tested on device
- [ ] Code committed to git
- [ ] Release tagged in git
- [ ] APK uploaded/distributed

## 🆘 Troubleshooting

### Build Fails

```bash
# Clean and retry
flutter clean
flutter pub get
flutter build apk --release
```

### Version Not Updating

Check these files:
1. `pubspec.yaml` - version line
2. `android/app/build.gradle.kts` - versionCode/versionName

### APK Won't Install

- Check if old version is installed (uninstall first)
- Check Android version compatibility
- Check signature (debug vs release)

### Script Permission Denied (PowerShell)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Script Not Found

Make sure you're in project root:
```bash
cd C:\dev\flutter_dev\mybooklibrary\my_book_library
```

## 📚 Documentation

- **Quick Start**: `scripts/QUICK_START.md`
- **Version Management**: `scripts/VERSION_MANAGEMENT.md`
- **Scripts README**: `scripts/README.md`
- **Changelog**: `CHANGELOG.md`

## 🔗 External Resources

- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Google Play Publishing](https://support.google.com/googleplay/android-developer/answer/9859152)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

---

**Happy Releasing! 🎉**

For questions or issues, refer to the documentation in the `scripts/` folder.

