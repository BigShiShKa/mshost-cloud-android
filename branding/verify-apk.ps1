# SPDX-FileCopyrightText: 2026 MSHost contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
param(
    [Parameter(Mandatory=$true)][string]$Apk,
    [string]$AndroidSdk = "$env:LOCALAPPDATA\Android\Sdk",
    [string]$JavaHome = 'C:\Program Files\Java\jdk-21.0.12'
)
$ErrorActionPreference = 'Stop'
$env:JAVA_HOME = $JavaHome
$tools = Join-Path $AndroidSdk 'build-tools\36.0.0'
if (-not (Test-Path -LiteralPath $Apk -PathType Leaf)) { throw 'APK is missing' }
$badging = & (Join-Path $tools 'aapt.exe') dump badging $Apk
if ($LASTEXITCODE -ne 0) { throw 'APK badging failed' }
if (-not ($badging -match "^package: name='io.github.bigshishka.mshostcloud'")) { throw 'Wrong APK identity' }
if (-not ($badging -match "^application-label:'MSHost Cloud'")) { throw 'Wrong APK label' }
if (-not ($badging -match "^sdkVersion:'28'")) { throw 'Unexpected minimum Android version' }
$manifest = & (Join-Path $tools 'aapt.exe') dump xmltree $Apk AndroidManifest.xml
if ($LASTEXITCODE -ne 0) { throw 'APK manifest cannot be read' }
$table = & (Join-Path $tools 'aapt2.exe') dump resources $Apk
if ($LASTEXITCODE -ne 0) { throw 'APK resource table cannot be read' }
$resourceValues = @{}
$resourceId = ''
foreach ($line in $table) {
    if ($line -match '^\s+resource (0x[0-9a-f]+) string/') { $resourceId = $matches[1] }
    elseif ($line -match '^\s+resource ') { $resourceId = '' }
    elseif ($resourceId -and $line -match '^\s+\(\) "([^"\r\n]*)"') { $resourceValues[$resourceId] = $matches[1] }
}
$authorities = @($manifest | Where-Object { $_ -match 'android:authorities' } | ForEach-Object {
    if ($_ -match '=@(0x[0-9a-f]+)') {
        if (-not $resourceValues.ContainsKey($matches[1])) { throw 'Provider authority resource cannot be resolved' }
        $resourceValues[$matches[1]]
    } elseif ($_ -match '="([^"]+)"') { $matches[1] }
    else { throw 'Provider authority cannot be parsed' }
})
if ($authorities.Count -lt 5 -or @($authorities | Where-Object { -not $_.StartsWith('io.github.bigshishka.mshostcloud.') }).Count -gt 0) {
    throw 'APK contains an unexpected content-provider authority'
}
if (@($authorities | Sort-Object -Unique).Count -ne $authorities.Count) { throw 'Duplicate provider authorities' }
$signer = Join-Path $tools 'lib\apksigner.jar'
$signature = & (Join-Path $JavaHome 'bin\java.exe') -jar $signer verify --verbose --print-certs $Apk
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed' }
$badging | Where-Object { $_ -match '^(package:|application-label:|sdkVersion:|targetSdkVersion:|native-code:)' }
$signature | Where-Object { $_ -match 'Signer #1 certificate DN:|Signer #1 certificate SHA-256 digest:|Verified using' }
Write-Output 'APK identity, label, minimum SDK, isolated providers and cryptographic signature verified.'
