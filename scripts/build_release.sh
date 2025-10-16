#!/bin/bash
# Build script for Linux/Mac that auto-increments version and builds APK

echo "========================================"
echo "Building My Book Library Release APK"
echo "========================================"

# Optional: Bump version (uncomment the line you want)
# dart scripts/bump_version.dart patch
# dart scripts/bump_version.dart minor
# dart scripts/bump_version.dart major

echo ""
echo "Cleaning previous builds..."
flutter clean

echo ""
echo "Getting dependencies..."
flutter pub get

echo ""
echo "Building release APK..."
flutter build apk --release

echo ""
echo "========================================"
echo "Build Complete!"
echo "========================================"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
echo ""

# Get version from pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
echo "Version: $VERSION"

# Optional: Copy and rename APK with version
# cp build/app/outputs/flutter-apk/app-release.apk "releases/my_book_library-v${VERSION}.apk"

