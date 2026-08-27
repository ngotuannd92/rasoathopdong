Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$fixtureRoot = 'C:\Stage3-Work\fixtures\stage2-runtime'
$fixture = Join-Path $fixtureRoot 'catalog-0.2.0-schema3'
Write-Output "FIXTURE_ROOT_EXISTS=$(Test-Path $fixtureRoot)"
Write-Output "FIXTURE_EXISTS=$(Test-Path $fixture)"
if (Test-Path $fixture) {
  $manifest = Join-Path $fixture 'fixture-manifest.json'
  $db = Join-Path $fixture 'appdata.sqlite'
  Write-Output "FIXTURE_MANIFEST_EXISTS=$(Test-Path $manifest)"
  Write-Output "FIXTURE_DB_EXISTS=$(Test-Path $db)"
  if (Test-Path $manifest) { Get-Content $manifest }
  if (Test-Path $db) {
    Write-Output "FIXTURE_DB_SIZE=$((Get-Item $db).Length)"
    Write-Output "FIXTURE_DB_SHA256=$((Get-FileHash $db -Algorithm SHA256).Hash.ToLowerInvariant())"
  }
  Write-Output 'FIXTURE_FILES_BEGIN'
  Get-ChildItem $fixture -File | Select-Object Name,Length | Format-Table -AutoSize
  Write-Output 'FIXTURE_FILES_END'
}
