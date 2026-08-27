Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
if (-not (Test-Path $source)) { throw "Missing source: $source" }
Push-Location $source
try {
  Write-Output "RUNNER=$env:RUNNER_NAME MACHINE=$env:COMPUTERNAME"
  Write-Output "HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  Write-Output 'MIGRATION_GATE_BEGIN'
  $paths = @(
    '.\tests\RasoatHopDong.Tests\Stage2PostPromotionRuntimeGateTests.cs',
    '.\tests\RasoatHopDong.Tests\Stage2MigrationFixturePreparationTests.cs'
  )
  foreach ($p in $paths) {
    if (Test-Path $p) { Write-Output "FILE=$p"; Get-Content $p -TotalCount 320 }
  }
  Write-Output 'UPGRADE_COORDINATOR_BEGIN'
  Get-ChildItem .\src -Recurse -File -Filter *.cs | Where-Object { $_.Name -match 'LocalDataUpgradeCoordinator|CriteriaCatalogMigration' } | ForEach-Object { Write-Output "FILE=$($_.FullName)"; Get-Content $_.FullName -TotalCount 360 }
  Write-Output 'UPGRADE_COORDINATOR_END'
  Write-Output 'MIGRATION_GATE_END'
}
finally { Pop-Location }
