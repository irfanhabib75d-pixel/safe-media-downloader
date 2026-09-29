# Automated Local Setup & Build Script for Windows
# Run this in PowerShell to download Flutter & JDK and build the APK

$ErrorActionPreference = "Stop"
$WorkingDir = "C:\tools"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Automated Environment Setup & APK Builder" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Create Tools directory
if (-not (Test-Path $WorkingDir)) {
    New-Item -ItemType Directory -Force -Path $WorkingDir | Out-Null
}

# 2. Check/Download Portable OpenJDK 17
$JdkDir = "$WorkingDir\jdk-17"
if (-not (Test-Path $JdkDir)) {
    Write-Host "[1/3] Downloading OpenJDK 17..." -ForegroundColor Green
    $JdkZip = "$WorkingDir\jdk17.zip"
    $JdkUrl = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jdk_x64_windows_hotspot_17.0.10_7.zip"
    Invoke-WebRequest -Uri $JdkUrl -OutFile $JdkZip
    Write-Host "Extracting OpenJDK 17..." -ForegroundColor Green
    Expand-Archive -Path $JdkZip -DestinationPath $WorkingDir -Force
    Rename-Item -Path "$WorkingDir\jdk-17.0.10+7" -NewName "jdk-17" -Force
    Remove-Item $JdkZip -Force
}

# 3. Check/Download Portable Flutter SDK
$FlutterDir = "$WorkingDir\flutter"
if (-not (Test-Path $FlutterDir)) {
    Write-Host "[2/3] Downloading Flutter SDK..." -ForegroundColor Green
    $FlutterZip = "$WorkingDir\flutter.zip"
    $FlutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip"
    Invoke-WebRequest -Uri $FlutterUrl -OutFile $FlutterZip
    Write-Host "Extracting Flutter SDK (this may take 2-3 minutes)..." -ForegroundColor Green
    tar -xf $FlutterZip -C $WorkingDir
    Remove-Item $FlutterZip -Force
}

# 4. Set Environment Variables for current session
$env:JAVA_HOME = $JdkDir
$env:PATH = "$FlutterDir\bin;$JdkDir\bin;$env:PATH"

# 5. Build Release APK
Write-Host "[3/3] Compiling Release APK..." -ForegroundColor Green
Set-Location -Path $PSScriptRoot
flutter pub get
flutter build apk --release

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " APK Build Complete!" -ForegroundColor Green
Write-Host " File location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
