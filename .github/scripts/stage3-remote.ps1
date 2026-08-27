Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
Push-Location $source
try {
  Write-Output 'GIT_HISTORY_BEGIN'
  git log --all --decorate --oneline -n 220
  Write-Output 'GIT_HISTORY_END'
  Write-Output 'VERSION_HISTORY_BEGIN'
  $commits = git log --all --format='%H' -- eng/Version.props
  foreach ($c in $commits | Select-Object -First 80) {
    $line = git show "$c`:eng/Version.props" 2>$null | Select-String -Pattern '<CriteriaCatalogVersion>|<EngineVersion>|<DatabaseSchemaVersion>|<CriteriaCatalogMigrationMapSchemaVersion>' | ForEach-Object { $_.Line.Trim() }
    Write-Output "COMMIT=$c $($line -join ' ')"
  }
  Write-Output 'VERSION_HISTORY_END'
}
finally { Pop-Location }
