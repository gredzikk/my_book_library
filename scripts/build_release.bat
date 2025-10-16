@echo off
REM Build script for Windows that auto-increments version and builds APK

echo ========================================
echo Building My Book Library Release APK
echo ========================================

REM Optional: Bump version (uncomment the line you want)
REM dart scripts\bump_version.dart patch
REM dart scripts\bump_version.dart minor
REM dart scripts\bump_version.dart major

echo.
echo Cleaning previous builds...
call flutter clean

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Building release APK...
call flutter build apk --release

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo APK location: build\app\outputs\flutter-apk\app-release.apk
echo.

REM Optional: Copy and rename APK with version
for /f "tokens=2" %%i in ('findstr /r "^version:" pubspec.yaml') do set VERSION=%%i
echo Version: %VERSION%

