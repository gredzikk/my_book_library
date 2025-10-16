# PowerShell build script with version management
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('patch', 'minor', 'major', 'none')]
    [string]$BumpType = 'none'
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building My Book Library Release APK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Bump version if requested
if ($BumpType -ne 'none') {
    Write-Host "Bumping $BumpType version..." -ForegroundColor Yellow
    dart scripts/bump_version.dart $BumpType
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to bump version" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Get current version
$version = (Select-String -Path "pubspec.yaml" -Pattern "^version:\s*(.+)").Matches.Groups[1].Value.Trim()
Write-Host "Current Version: $version" -ForegroundColor Green
Write-Host ""

# Clean
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Flutter clean failed" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Flutter pub get failed" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Build
Write-Host "Building release APK..." -ForegroundColor Yellow
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Build failed" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Success
Write-Host "========================================" -ForegroundColor Green
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Version: $version" -ForegroundColor Cyan
Write-Host "APK Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan

# Optional: Copy to releases folder with version name
$releasesDir = "releases"
if (-not (Test-Path $releasesDir)) {
    New-Item -ItemType Directory -Path $releasesDir | Out-Null
}

$versionedApk = "$releasesDir\my_book_library-v$version.apk"
Copy-Item "build\app\outputs\flutter-apk\app-release.apk" $versionedApk -Force
Write-Host "Copied to: $versionedApk" -ForegroundColor Cyan
Write-Host ""

# Show file size
$size = (Get-Item $versionedApk).Length / 1MB
Write-Host ("APK Size: {0:N2} MB" -f $size) -ForegroundColor Yellow

