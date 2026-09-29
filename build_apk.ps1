# Safe Media Downloader - APK Build Script for Windows
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host " Building Safe Media Downloader Release APK..." -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# 1. Check if Flutter is installed
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Host "[ERROR] Flutter SDK is not installed or not added to your system PATH." -ForegroundColor Red
    Write-Host "Please download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Write-Host "Make sure Android Studio with Command-line Tools and JDK 17 are installed." -ForegroundColor Yellow
    Exit 1
}

# 2. Get dependencies
Write-Host "`n[1/3] Fetching Flutter dependencies..." -ForegroundColor Green
flutter pub get

# 3. Clean previous builds
Write-Host "`n[2/3] Cleaning previous build cache..." -ForegroundColor Green
flutter clean
flutter pub get

# 4. Build Release APK
Write-Host "`n[3/3] Compiling Release APK (ARM64 & ARM32)..." -ForegroundColor Green
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n========================================================" -ForegroundColor Green
    Write-Host " SUCCESS! APK has been compiled successfully:" -ForegroundColor Green
    Write-Host " Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Build failed. Please check the logs above." -ForegroundColor Red
}
