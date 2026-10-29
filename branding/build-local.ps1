# SPDX-FileCopyrightText: 2026 MSHost contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
param(
    [string]$JavaHome = 'C:\Program Files\Java\jdk-21.0.12',
    [string]$AndroidSdk = "$env:LOCALAPPDATA\Android\Sdk",
    [string]$OutputDir = 'D:\MSHost-Android-Build\dist',
    [switch]$MavenMirror,
    [switch]$Checks,
    [string]$TestDevice,
    [switch]$DeviceTests
)
$ErrorActionPreference = 'Stop'
$sourceRoot = Split-Path -Parent $PSScriptRoot
$java = Join-Path $JavaHome 'bin\java.exe'
if (-not (Test-Path -LiteralPath $java -PathType Leaf)) { throw "JDK is missing: $JavaHome" }
if (-not (Test-Path -LiteralPath $AndroidSdk -PathType Container)) { throw "Android SDK is missing: $AndroidSdk" }
$env:JAVA_HOME = $JavaHome
$env:ANDROID_HOME = $AndroidSdk
$env:DEBUG = ''
$tasks = @(':app:assembleGenericDebug')
if ($MavenMirror) { $tasks += '-PmshostMavenMirror=true' }
if ($Checks) { $tasks += @(':app:lintGenericDebug', ':app:spotbugsGplayDebug', ':app:detekt', ':app:spotlessKotlinCheck') }
if ($DeviceTests) {
    if (-not $TestDevice) { throw 'DeviceTests requires an explicit -TestDevice serial for a clean emulator.' }
    $adb = Join-Path $AndroidSdk 'platform-tools\adb.exe'
    $devices = @(& $adb devices | Where-Object { $_ -match '^([^\s]+)\s+device$' })
    if ($devices.Count -ne 1 -or $devices[0] -notmatch ('^' + [regex]::Escape($TestDevice) + '\s')) {
        throw 'Connect only the dedicated clean test emulator. Manual-test devices must be disconnected.'
    }
    $avd = & $adb -s $TestDevice emu avd name
    if ($avd -notcontains 'MSHost_Cloud_Automated') { throw 'Use a separate MSHost_Cloud_Automated AVD for tests.' }
    $accountText = & $adb -s $TestDevice shell dumpsys account
    if (($accountText -join "`n") -match 'type=io\.github\.bigshishka\.mshostcloud') {
        throw 'The emulator contains MSHost accounts; automated tests were not started.'
    }
    $env:ANDROID_SERIAL = $TestDevice
    $tasks += @(':app:connectedGenericDebugAndroidTest',
        '-Pandroid.testInstrumentationRunnerArguments.class=com.nextcloud.client.branding.MshostBrandingIT')
}
Push-Location $sourceRoot
try {
    $ErrorActionPreference = 'Continue'
    & $java '-Dorg.gradle.internal.http.socketTimeout=30000' '-Dorg.gradle.internal.http.connectionTimeout=30000' `
        -jar (Join-Path $sourceRoot 'gradle\wrapper\gradle-wrapper.jar') @tasks --console=plain
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($code -ne 0) { throw "Gradle failed with exit code $code" }
    $apkDir = Join-Path $sourceRoot 'app\build\outputs\apk\generic\debug'
    $metadata = Get-Content -LiteralPath (Join-Path $apkDir 'output-metadata.json') -Raw | ConvertFrom-Json
    if ($metadata.applicationId -ne 'io.github.bigshishka.mshostcloud') { throw 'Unexpected APK applicationId' }
    $version = $metadata.elements[0].versionName -replace '[^a-zA-Z0-9.]+', '-'
    $apkName = 'MSHost-Cloud-Android-' + $version + '-debug.apk'
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    $apk = Join-Path $OutputDir $apkName
    Copy-Item -LiteralPath (Join-Path $apkDir $metadata.elements[0].outputFile) -Destination $apk -Force
    $sha = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash.ToLowerInvariant()
    $utf8 = New-Object Text.UTF8Encoding($false)
    [IO.File]::WriteAllText((Join-Path $OutputDir 'SHA256SUMS.txt'), "$sha  $apkName`n", $utf8)
    $report = [ordered]@{
        product = 'MSHost Cloud Android'
        applicationId = $metadata.applicationId
        versionName = $metadata.elements[0].versionName
        versionCode = $metadata.elements[0].versionCode
        variant = 'genericDebug'
        signing = 'Android development/debug key; not a production release'
        apk = $apk
        sha256 = $sha
        sourceRevision = (& git -C $sourceRoot rev-parse HEAD)
        sourceModified = (@(& git -C $sourceRoot status --porcelain).Count -gt 0)
    }
    [IO.File]::WriteAllText((Join-Path $OutputDir 'build-result.json'), ($report | ConvertTo-Json) + "`n", $utf8)
    Write-Output "APK: $apk"
    Write-Output "SHA-256: $sha"
} finally { Pop-Location }
