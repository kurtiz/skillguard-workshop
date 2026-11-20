# Installs the repository-pinned Windows release locally; no administrator rights or PATH edits.
[CmdletBinding()]
param([string]$Archive)
$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'Use sh scripts/install.sh on macOS or Linux.' }
$Root = Split-Path -Parent $PSScriptRoot
$Version = (Get-Content -LiteralPath (Join-Path $Root 'release/version.txt') -Raw).Trim()
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid pinned version.' }
try { $Architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString() }
catch { $Architecture = $env:PROCESSOR_ARCHITECTURE }
switch ($Architecture.ToLowerInvariant()) {
    { $_ -in 'x64', 'amd64' } { $Arch = 'amd64'; break }
    'arm64' { $Arch = 'arm64'; break }
    default { throw 'Supported Windows architectures: amd64 and arm64.' }
}
$Asset = "skillguard_${Version}_windows_${Arch}.tar.gz"
$MatchesForAsset = @(Get-Content -LiteralPath (Join-Path $Root 'release/checksums.txt') | Where-Object { ($_ -split '\s+')[-1] -ceq $Asset })
if ($MatchesForAsset.Count -ne 1) { throw 'Missing or duplicate release checksum.' }
$Expected = ($MatchesForAsset[0] -split '\s+')[0]
if ($Expected -cnotmatch '^[a-f0-9]{64}$') { throw 'Invalid release checksum.' }
$null = Get-Command tar.exe -ErrorAction Stop
$Tools = Join-Path $Root '.tools'
if ((Test-Path -LiteralPath $Tools) -and ((Get-Item -LiteralPath $Tools -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw '.tools must not be a link or junction.' }
$null = New-Item -ItemType Directory -Path $Tools -Force
$Destination = Join-Path $Tools 'skillguard.exe'
if ((Test-Path -LiteralPath $Destination) -and ((Get-Item -LiteralPath $Destination -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Install destination must not be a link.' }
$Work = Join-Path $Tools ('download.' + [Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $Work
$PreviousTls = [Net.ServicePointManager]::SecurityProtocol
try {
    $Downloaded = Join-Path $Work $Asset
    if ($Archive) { Copy-Item -LiteralPath $Archive -Destination $Downloaded }
    else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $Url = "https://github.com/OSSAfrica/skillguard/releases/download/v$Version/$Asset"
        Invoke-WebRequest -Uri $Url -OutFile $Downloaded -UseBasicParsing -TimeoutSec 120
    }
    if ((Get-Item -LiteralPath $Downloaded).Length -gt 67108864) { throw 'Archive exceeds the size limit.' }
    $Actual = (Get-FileHash -LiteralPath $Downloaded -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($Actual -cne $Expected) { throw 'SHA-256 mismatch. Nothing was installed; obtain the exact pinned release.' }
    Write-Host "Verified SHA-256 for $Asset"
    & tar.exe -xzf $Downloaded -C $Work skillguard.exe
    if ($LASTEXITCODE -ne 0) { throw 'Could not extract the expected binary.' }
    $Binary = Join-Path $Work 'skillguard.exe'
    $Info = Get-Item -LiteralPath $Binary -Force
    if ($Info.PSIsContainer -or ($Info.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Archive did not contain a regular executable.' }
    Move-Item -LiteralPath $Binary -Destination $Destination -Force
    $Reported = & $Destination --version
    if ($LASTEXITCODE -ne 0 -or $Reported -cne "skillguard version $Version") { throw 'Installed executable could not start or reported an unexpected version.' }
    Write-Host "Installed locally: $Destination"
    Write-Host $Reported
    Write-Host 'Next: follow WORKSHOP.md from this repository root.'
}
finally {
    [Net.ServicePointManager]::SecurityProtocol = $PreviousTls
    Remove-Item -LiteralPath $Work -Recurse -Force
}
