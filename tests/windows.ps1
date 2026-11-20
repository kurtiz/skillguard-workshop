$ErrorActionPreference = 'Stop'
# The positive install ran in the previous workflow step. A corrupt offline archive
# must be rejected without replacing the verified executable.
$Binary = Join-Path $PWD '.tools/skillguard.exe'
$Before = (Get-FileHash -LiteralPath $Binary -Algorithm SHA256).Hash
$Bad = Join-Path $PWD '.tools/corrupt.tar.gz'
Set-Content -LiteralPath $Bad -Value 'deliberately corrupted test archive'
$Rejected = $false
try { & .\scripts\install.ps1 -Archive $Bad }
catch {
    if ($_.Exception.Message -notlike '*SHA-256 mismatch*') { throw }
    $Rejected = $true
}
if (-not $Rejected) { throw 'Corrupt archive was accepted.' }
if ((Get-FileHash -LiteralPath $Binary -Algorithm SHA256).Hash -ne $Before) { throw 'Previous installation changed.' }
& $Binary scan .\demo\clean\SKILL.md --quiet
if ($LASTEXITCODE -ne 0) { throw 'Clean teaching fixture failed.' }
& $Binary scan .\demo\injected\SKILL.md --quiet
if ($LASTEXITCODE -ne 1) { throw 'Injected teaching fixture did not fail as expected.' }
& $Binary scan .\demo\hidden\SKILL.md --quiet
if ($LASTEXITCODE -ne 0) { throw 'Hidden-character fixture did not complete as expected.' }
Write-Host 'Windows installer, checksum rejection and real fixture scans passed.'
exit 0
