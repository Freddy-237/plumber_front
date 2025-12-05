# Patch script: insert namespace into record plugin's android module build.gradle
# Usage: From PowerShell run: .\scripts\patch_record_namespace.ps1
# This script will:
#  - Locate the `record` plugin folder in the local pub cache
#  - Read android/src/main/AndroidManifest.xml to extract the package name
#  - Backup the plugin's build.gradle to build.gradle.bak
#  - Insert a `namespace '<package>'` line into the `android {` block if not present

$ErrorActionPreference = 'Stop'

Write-Host "Locating pub cache..."
$pubCacheBase = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dartlang.org'
if (-not (Test-Path $pubCacheBase)) {
    Write-Error "Pub cache not found at $pubCacheBase. Are you using the default pub cache location?"
    exit 1
}

# Find record plugin folder (record-<version>)
$recordDirs = Get-ChildItem -Path $pubCacheBase -Directory -Filter 'record-*' -ErrorAction SilentlyContinue
if (!$recordDirs -or $recordDirs.Count -eq 0) {
    Write-Error "Could not find a 'record-*' directory in pub cache. Ensure the plugin is installed (in pubspec.yaml) and run 'flutter pub get'."
    exit 1
}

# Use the newest record folder (highest modified time)
$recordDir = $recordDirs | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Write-Host "Found record plugin at: $($recordDir.FullName)"

$androidManifest = Join-Path $recordDir.FullName 'android\src\main\AndroidManifest.xml'
$buildGradle = Join-Path $recordDir.FullName 'android\build.gradle'

if (-not (Test-Path $androidManifest)) {
    Write-Error "AndroidManifest.xml not found at $androidManifest"
    exit 1
}
if (-not (Test-Path $buildGradle)) {
    Write-Error "build.gradle not found at $buildGradle"
    exit 1
}

# Read package from AndroidManifest.xml
$manifestContent = Get-Content -Raw -Path $androidManifest
$packageMatch = [regex]::Match($manifestContent, 'package=["'](?<pkg>[^"']+)["']')
if (-not $packageMatch.Success) {
    Write-Error "Could not locate 'package' attribute in AndroidManifest.xml. Please open the file and check the package value."
    exit 1
}

$pkg = $packageMatch.Groups['pkg'].Value
Write-Host "Detected package in AndroidManifest: $pkg"

# Read build.gradle and check for existing namespace
$gradleText = Get-Content -Raw -Path $buildGradle -Encoding UTF8
if ($gradleText -match "namespace\s*['\""]$pkg['\""]") {
    Write-Host "build.gradle already contains namespace '$pkg'. No change needed."
    exit 0
}

# Backup build.gradle
$backup = "$buildGradle.bak"
if (-not (Test-Path $backup)) {
    Copy-Item -Path $buildGradle -Destination $backup -Force
    Write-Host "Backed up build.gradle to $backup"
} else {
    Write-Host "Backup already exists at $backup"
}

# Insert namespace line into the first 'android {' block if possible
$pattern = 'android\s*\{'
if ($gradleText -notmatch $pattern) {
    Write-Error "Could not find an 'android {' block in build.gradle. Manual edit is required."
    exit 1
}

# Build the namespace insertion string
$namespaceLine = "    namespace '$pkg'\n"

# Insert namespace immediately after the opening android { line
$gradleText = [regex]::Replace($gradleText, $pattern, "android {`n$namespaceLine", 1)

# Write the modified gradle
Set-Content -Path $buildGradle -Value $gradleText -Encoding UTF8
Write-Host "Inserted namespace '$pkg' into $buildGradle"
Write-Host "Done. Now run the following commands in your project root (PowerShell):"
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter analyze"
Write-Host "  flutter run"

Write-Host "If anything goes wrong you can restore the original file from: $backup"
