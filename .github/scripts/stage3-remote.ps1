Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$baselineTag = 'stage3-baseline-v0.4.0'
$expectedCatalogHash = '47af07851637f14da1ce615864cab213e26233eae32177a52a47e3b1f22ab364'
$phase1Candidate = 'D:\rasoathopdong-v0.4.0-phase1-final-closed-r13.zip'
$expectedPhase1Hash = '9eff2eebdfbb2f4fe786a6443606f9d1fb136293db89bae02199445848e2e39b'
$logRoot = 'C:\Stage3-Work\logs\stage3-integrity-ui-r1'
if (Test-Path -LiteralPath $logRoot) { throw "Integrity log root already exists: $logRoot" }
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

Push-Location $source
try {
  $head = (git rev-parse HEAD).Trim()
  $branch = (git branch --show-current).Trim()
  $baseline = (git rev-parse $baselineTag).Trim()
  Write-Output "SOURCE_HEAD=$head BRANCH=$branch BASELINE_TAG=$baselineTag BASELINE_SHA=$baseline"
  Write-Output 'STATUS_BEGIN'
  git status --short
  Write-Output 'STATUS_END'
  git diff --check
  if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed.' }

  $changed = @(git diff --name-status "$baseline..$head")
  Write-Output 'BASELINE_DIFF_BEGIN'
  $changed | ForEach-Object { Write-Output $_ }
  Write-Output 'BASELINE_DIFF_END'
  Write-Output 'HEAD_SHOW_BEGIN'
  git show --format=fuller --stat --oneline HEAD
  Write-Output 'HEAD_SHOW_END'

  $paths = @()
  foreach ($line in $changed) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split '\t'
    if ($parts.Count -ge 2) { $paths += $parts[-1].Replace('\','/') }
  }
  $productionPrefixes = @('src/','data/','eng/','scripts/','installer/','tools/')
  $productionChanges = @($paths | Where-Object {
    $p = $_
    @($productionPrefixes | Where-Object { $p.StartsWith($_,[StringComparison]::OrdinalIgnoreCase) }).Count -gt 0
  })
  $webChanges = @($paths | Where-Object { $_.StartsWith('src/RasoatHopDong.App/Web/',[StringComparison]::OrdinalIgnoreCase) })
  Write-Output "CHANGED_PATH_COUNT=$($paths.Count) PRODUCTION_PATH_CHANGES=$($productionChanges.Count) WEB_UI_CHANGES=$($webChanges.Count)"
  foreach ($p in $productionChanges) { Write-Output "PRODUCTION_CHANGED=$p" }
  foreach ($p in $webChanges) { Write-Output "WEB_CHANGED=$p" }

  $webDiffExit = 0
  git diff --quiet $baselineTag -- .\src\RasoatHopDong.App\Web
  $webDiffExit = $LASTEXITCODE
  Write-Output "WEB_TREE_DIFF_EXIT=$webDiffExit"
  if ($webDiffExit -ne 0) { throw 'Frozen Web UI differs from Stage3 baseline tag.' }

  function Run-UiTests([string]$configuration) {
    $log = Join-Path $logRoot ("ui-lock-" + $configuration.ToLowerInvariant() + '.log')
    $filter = 'FullyQualifiedName~Phase1FoundationImplementationTests.ProductAndUserFacingUiContracts_ShouldRemainLockedWhileTechnicalVersionsAdvance|FullyQualifiedName~Stage8CompareUiMarkupTests|FullyQualifiedName~WebViewBridgeTests|FullyQualifiedName~Maintenance14SettingsAndWindowTests'
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c $configuration --no-build --no-restore --nologo --filter $filter --logger 'console;verbosity=minimal' *> $log
    $code = $LASTEXITCODE
    $ErrorActionPreference = $old
    Write-Output "UI_LOCK_CONFIG=$configuration EXIT=$code"
    Get-Content -LiteralPath $log | Where-Object { $_ -match 'Passed!|Failed!|Total tests:|Skipped:' } | Select-Object -Last 8 | ForEach-Object { Write-Output $_ }
    if ($code -ne 0) { Get-Content -LiteralPath $log -Tail 120; throw "UI lock tests failed for $configuration" }
  }
  Run-UiTests 'Debug'
  Run-UiTests 'Release'
  Write-Output 'UI_LOCK=PASS'

  $catalog = '.\data\criteria-catalog\official-criteria-catalog.json'
  $manifest = '.\data\criteria-catalog\official-criteria-catalog-manifest.json'
  $migration = '.\data\criteria-catalog\criteria-catalog-migration-map.json'
  $catalogHash = (Get-FileHash -LiteralPath $catalog -Algorithm SHA256).Hash.ToLowerInvariant()
  $manifestHash = (Get-FileHash -LiteralPath $manifest -Algorithm SHA256).Hash.ToLowerInvariant()
  $migrationHash = (Get-FileHash -LiteralPath $migration -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Output "CATALOG_SHA256=$catalogHash EXPECTED=$expectedCatalogHash MATCH=$([bool]($catalogHash -ceq $expectedCatalogHash))"
  Write-Output "MANIFEST_SHA256=$manifestHash"
  Write-Output "MIGRATION_MAP_SHA256=$migrationHash"
  if ($catalogHash -cne $expectedCatalogHash) { throw 'Current official catalog hash differs from Phase2 accepted hash.' }

  if (Test-Path -LiteralPath $phase1Candidate -PathType Leaf) {
    $phase1Hash = (Get-FileHash -LiteralPath $phase1Candidate -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Output "PHASE1_ARCHIVE=$phase1Candidate SIZE=$((Get-Item -LiteralPath $phase1Candidate).Length) SHA256=$phase1Hash EXPECTED=$expectedPhase1Hash MATCH=$([bool]($phase1Hash -ceq $expectedPhase1Hash))"
  } else {
    Write-Output 'PHASE1_ARCHIVE=NOT_FOUND'
  }

  Get-Content .\eng\Version.props | ForEach-Object { if ($_ -match '<(AppVersion|EngineVersion|CriteriaCatalogVersion|DatabaseSchemaVersion|CriteriaSnapshotSchemaVersion|CriteriaCatalogMigrationMapSchemaVersion)>') { Write-Output $_.Trim() } }
  Write-Output 'STAGE3_SOURCE_INTEGRITY_UI=PASS'
}
finally { Pop-Location }
