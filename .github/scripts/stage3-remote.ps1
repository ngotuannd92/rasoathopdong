Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
if (-not (Test-Path $source)) { throw "Missing source: $source" }
Push-Location $source
try {
  Write-Output "RUNNER=$env:RUNNER_NAME MACHINE=$env:COMPUTERNAME"
  Write-Output "HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  Write-Output 'PRIVATE_REMOTE_ACCESS_BEGIN'
  $old = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  git ls-remote https://github.com/ngotuannd92/rasoathopdong-stage10.git HEAD 2>&1 | Select-Object -First 20
  $code = $LASTEXITCODE
  $ErrorActionPreference = $old
  Write-Output "PRIVATE_REMOTE_ACCESS_EXIT=$code"
  Write-Output 'PRIVATE_REMOTE_ACCESS_END'
  Write-Output 'MIGRATION_REFERENCES_BEGIN'
  Get-ChildItem .\src,.\tests -Recurse -File -Include *.cs | Select-String -Pattern 'CriteriaCatalogVersion|Migration020To030|PrepareCatalog020Schema3Fixture|LocalDataUpgradeCoordinator|CriteriaCatalogMigrationMapSchemaVersion' | Select-Object -First 220 | ForEach-Object { "{0}:{1}:{2}" -f $_.Path,$_.LineNumber,$_.Line.Trim() }
  Write-Output 'MIGRATION_REFERENCES_END'
}
finally { Pop-Location }
