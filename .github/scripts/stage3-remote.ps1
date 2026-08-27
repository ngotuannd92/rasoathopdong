Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$baseline = 'D:\rasoathopdong-v0.2.8-stage7-criteria-validation-implementation-r3.zip'
$expectedBaselineHash = '81bcd973cbbc8f48e16fb3b19d3d24de31422ff23baf21bf09497a1ddd93a7d6'
$results = 'C:\Stage3-Work\logs\verify-final-v0.4.0-r1'
$helper = 'C:\Stage3-Work\artifacts\publish-v0.4.0-stage3\RasoatHopDong.UpdateHelper.exe'
$installerFixture = 'C:\Stage3-Work\artifacts\update-helper-fixtures-r1\installer\RasoatHopDong.InstallerFixture.exe'
$mainFixture = 'C:\Stage3-Work\artifacts\update-helper-fixtures-r1\main\RasoatHopDong.App.exe'
$helperResults = Join-Path $results 'update-helper-harness'

foreach ($required in @($source,$baseline,$helper,$installerFixture,$mainFixture)) {
  if (-not (Test-Path -LiteralPath $required)) { throw "Required Stage3 input is missing: $required" }
}
if (Test-Path -LiteralPath $results) { throw "Final verification results directory already exists: $results" }
$actualBaselineHash = (Get-FileHash -LiteralPath $baseline -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Output "BASELINE_PATH=$baseline"
Write-Output "BASELINE_SHA256=$actualBaselineHash MATCH=$([bool]($actualBaselineHash -ceq $expectedBaselineHash))"
if ($actualBaselineHash -cne $expectedBaselineHash) { throw 'Exact historical baseline hash mismatch.' }

$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:PATH = 'C:\Stage3-Work\pyenv\Scripts;' + $env:PATH
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  Write-Output 'VERIFY_FINAL_BEGIN'
  $script = Join-Path $source 'scripts\verify-final.ps1'
  & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $script `
    -ResultsDirectory $results `
    -RunDisposableUpdateHelperHarness `
    -ConfirmDisposableEnvironment `
    -PublishedHelperPath $helper `
    -InstallerFixturePath $installerFixture `
    -MainProcessFixturePath $mainFixture `
    -UpdateHelperResultsDirectory $helperResults `
    -BaselineZipPath $baseline
  $code = $LASTEXITCODE
  Write-Output "VERIFY_FINAL_EXIT=$code"
  if ($code -ne 0) {
    Get-ChildItem -LiteralPath $results -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "RESULT_FILE=$($_.FullName) SIZE=$($_.Length)" }
    throw "verify-final.ps1 failed with exit code $code"
  }
  $summaryPath = Join-Path $results 'verification-summary.json'
  $inventoryPath = Join-Path $results 'verification-artifacts.jsonl'
  if (-not (Test-Path -LiteralPath $summaryPath -PathType Leaf)) { throw 'Final verification summary is missing.' }
  if (-not (Test-Path -LiteralPath $inventoryPath -PathType Leaf)) { throw 'Final verification artifact inventory is missing.' }
  $summary = Get-Content -LiteralPath $summaryPath -Raw | ConvertFrom-Json
  Write-Output "FINAL_STATUS=$($summary.status)"
  Write-Output "FINAL_VERSIONS_APP=$($summary.versions.appVersion) ENGINE=$($summary.versions.engineVersion) CATALOG=$($summary.versions.criteriaCatalogVersion) DB=$($summary.versions.databaseSchemaVersion)"
  Write-Output "FINAL_DEBUG_TOTAL=$($summary.debug.total) PASSED=$($summary.debug.passed) FAILED=$($summary.debug.failed) SKIPPED=$($summary.debug.skipped)"
  Write-Output "FINAL_RELEASE_TOTAL=$($summary.release.total) PASSED=$($summary.release.passed) FAILED=$($summary.release.failed) SKIPPED=$($summary.release.skipped)"
  Write-Output "FINAL_BUILD_DEBUG_WARNINGS=$($summary.build.debugWarnings) DEBUG_ERRORS=$($summary.build.debugErrors) RELEASE_WARNINGS=$($summary.build.releaseWarnings) RELEASE_ERRORS=$($summary.build.releaseErrors)"
  Write-Output "FINAL_ARTIFACT_COUNT=$($summary.artifacts.fileCount) INVENTORY_SHA256=$($summary.artifacts.inventorySha256)"
  Write-Output "SUMMARY_SHA256=$((Get-FileHash -LiteralPath $summaryPath -Algorithm SHA256).Hash.ToLowerInvariant())"
  Write-Output 'VERIFY_FINAL=PASS'
  Write-Output 'VERIFY_FINAL_END'
}
finally { Pop-Location }
