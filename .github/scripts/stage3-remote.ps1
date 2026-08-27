Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$publish = 'C:\Stage3-Work\artifacts\publish-v0.4.0-stage3'
$fixtureRoot = 'C:\Stage3-Work\artifacts\update-helper-fixtures-r1'
$installerFixtureOut = Join-Path $fixtureRoot 'installer'
$mainFixtureOut = Join-Path $fixtureRoot 'main'
$results = 'C:\Stage3-Work\logs\update-helper-disposable-r1'
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  if (Test-Path -LiteralPath $fixtureRoot) { throw "Fixture root already exists: $fixtureRoot" }
  if (Test-Path -LiteralPath $results) { throw "Results root already exists: $results" }
  New-Item -ItemType Directory -Force -Path $installerFixtureOut,$mainFixtureOut | Out-Null

  Write-Output 'FIXTURE_PUBLISH_BEGIN'
  dotnet publish .\tests\WindowsIntegration\InstallerFixture\RasoatHopDong.InstallerFixture.csproj -c Release -r win-x64 --self-contained true -o $installerFixtureOut --nologo
  if ($LASTEXITCODE -ne 0) { throw 'Installer fixture publish failed.' }
  dotnet publish .\tests\WindowsIntegration\MainProcessFixture\RasoatHopDong.MainProcessFixture.csproj -c Release -r win-x64 --self-contained true -o $mainFixtureOut --nologo
  if ($LASTEXITCODE -ne 0) { throw 'Main fixture publish failed.' }
  $installerFixture = Join-Path $installerFixtureOut 'RasoatHopDong.InstallerFixture.exe'
  $mainFixture = Join-Path $mainFixtureOut 'RasoatHopDong.App.exe'
  $helper = Join-Path $publish 'RasoatHopDong.UpdateHelper.exe'
  foreach ($required in @($installerFixture,$mainFixture,$helper)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Missing harness executable: $required" }
  }
  Write-Output "FIXTURE_INSTALLER_SHA256=$((Get-FileHash -LiteralPath $installerFixture -Algorithm SHA256).Hash.ToLowerInvariant())"
  Write-Output "FIXTURE_MAIN_SHA256=$((Get-FileHash -LiteralPath $mainFixture -Algorithm SHA256).Hash.ToLowerInvariant())"
  Write-Output "PRODUCTION_HELPER_SHA256=$((Get-FileHash -LiteralPath $helper -Algorithm SHA256).Hash.ToLowerInvariant())"
  Write-Output 'FIXTURE_PUBLISH_END'

  Write-Output 'UPDATE_HELPER_HARNESS_BEGIN'
  $harness = Join-Path $source 'scripts\test-update-helper-windows.ps1'
  & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $harness -ConfirmDisposableEnvironment -PublishedHelperPath $helper -InstallerFixturePath $installerFixture -MainProcessFixturePath $mainFixture -ResultsDirectory $results
  $code = $LASTEXITCODE
  Write-Output "UPDATE_HELPER_HARNESS_EXIT=$code"
  if ($code -ne 0) { throw "Update Helper disposable harness failed with exit code $code" }
  $report = Join-Path $results 'task-8.6.4-windows-results.json'
  if (-not (Test-Path -LiteralPath $report -PathType Leaf)) { throw 'Harness report is missing.' }
  $json = Get-Content -LiteralPath $report -Raw | ConvertFrom-Json
  foreach ($scenario in @($json.scenarios)) {
    Write-Output "SCENARIO=$($scenario.name) STATUS=$($scenario.status) INSTALLER_EXIT=$($scenario.installerExitCode) HELPER_EXIT=$($scenario.helperExitCode) REPLAY_EXIT=$($scenario.replayHelperExitCode)"
  }
  $failed = @($json.scenarios | Where-Object { $_.status -eq 'FAILED' })
  Write-Output "SCENARIOS_TOTAL=$(@($json.scenarios).Count) FAILED=$($failed.Count)"
  Write-Output "MANUAL_USER_CANCEL=$($json.manualUserCancel.status)"
  Write-Output "PRODUCTION_APP_RESTART=$($json.productionAppRestart.status)"
  if ($failed.Count -ne 0) { throw 'Harness JSON reports failed scenarios.' }
  Write-Output 'STAGE3_UPDATE_HELPER_DISPOSABLE=PASS'
  Write-Output 'UPDATE_HELPER_HARNESS_END'
}
finally { Pop-Location }
