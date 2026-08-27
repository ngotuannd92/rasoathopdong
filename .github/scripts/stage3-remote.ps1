Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
if (-not (Test-Path $source)) { throw "Missing source: $source" }
Push-Location $source
try {
  Write-Output "RUNNER=$env:RUNNER_NAME MACHINE=$env:COMPUTERNAME"
  Write-Output "HEAD=$((git rev-parse HEAD).Trim())"
  Write-Output "BRANCH=$((git branch --show-current).Trim())"
  Write-Output 'REMOTES_BEGIN'
  git remote -v
  Write-Output 'REMOTES_END'
  Write-Output 'STATUS_BEGIN'
  git status --short
  Write-Output 'STATUS_END'
  Write-Output 'VERSION_BEGIN'
  Get-Content .\eng\Version.props
  Write-Output 'VERSION_END'
  Write-Output 'MIGRATION_TEST_BEGIN'
  Get-Content .\tests\RasoatHopDong.Tests\Stage2MigrationFixturePreparationTests.cs -TotalCount 180
  Write-Output 'MIGRATION_TEST_END'
}
finally { Pop-Location }
