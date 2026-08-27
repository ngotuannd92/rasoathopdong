Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$baselineTag = 'stage3-baseline-v0.4.0'
$expectedCatalog = '2faf9f56016e83101d6552deb15447e99e15aa00f1c6a5bf703df2b309baa3c1'
$expectedManifest = 'dd253d8613e41a4837fd4ba45f1aa5678820be9ff850a4269d20a9c360ea1283'
$expectedMigration = 'e06aa01e327841b6025141938dedd12348257b1ad6f62ea088645d0fa8788810'
$expectedTarget = '47af07851637f14da1ce615864cab213e26233eae32177a52a47e3b1f22ab364'
$logRoot = 'C:\Stage3-Work\logs\stage3-test-patch-integrity-r3'
if (Test-Path -LiteralPath $logRoot) { throw "Log root already exists: $logRoot" }
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

Push-Location $source
try {
  $head = (git rev-parse HEAD).Trim()
  $base = (git rev-parse $baselineTag).Trim()
  Write-Output "SOURCE_HEAD=$head BASELINE=$base BRANCH=$((git branch --show-current).Trim())"

  $trackedPycache = @(git ls-files 'scripts/__pycache__/*')
  $untrackedPycache = @(git ls-files --others --exclude-standard 'scripts/__pycache__/*')
  Write-Output "TRACKED_PYCACHE=$($trackedPycache.Count) UNTRACKED_PYCACHE=$($untrackedPycache.Count)"
  $trackedPycache | ForEach-Object { Write-Output "TRACKED_PYCACHE_PATH=$_" }
  foreach ($relative in $untrackedPycache) {
    $normalized = $relative.Replace('/','\')
    $full = Join-Path $source $normalized
    if (-not $full.StartsWith((Join-Path $source 'scripts\__pycache__'), [StringComparison]::OrdinalIgnoreCase)) { throw "Refusing generated-cache cleanup outside pycache: $full" }
    if (Test-Path -LiteralPath $full -PathType Leaf) { Remove-Item -LiteralPath $full -Force }
    Write-Output "REMOVED_UNTRACKED_PYCACHE=$relative"
  }
  Write-Output 'WORKTREE_STATUS_BEGIN'
  git status --short
  Write-Output 'WORKTREE_STATUS_END'
  $status = @(git status --porcelain)
  if ($status.Count -ne 0) { throw 'Worktree contains uncommitted or untracked content after generated-cache cleanup.' }
  git diff --check
  if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed.' }

  $files = @(
    'tests/RasoatHopDong.Tests/Stage7InstallerContractTests.cs',
    'tests/RasoatHopDong.Tests/Stage7PublishContractTests.cs'
  )
  Write-Output 'TEST_PATCH_DIFF_BEGIN'
  git diff --no-ext-diff --unified=80 "$baselineTag..HEAD" -- $files
  if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect Stage3 test patch.' }
  Write-Output 'TEST_PATCH_DIFF_END'

  $allChanged = @(git diff --name-only "$baselineTag..HEAD")
  $allowed = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
  foreach ($file in $files) { [void]$allowed.Add($file) }
  $unexpected = @($allChanged | Where-Object { -not $allowed.Contains($_.Replace('\','/')) })
  Write-Output "CHANGED_FILES=$($allChanged.Count) UNEXPECTED_CHANGED_FILES=$($unexpected.Count)"
  $allChanged | ForEach-Object { Write-Output "CHANGED=$_" }
  $unexpected | ForEach-Object { Write-Output "UNEXPECTED=$_" }
  if ($allChanged.Count -ne 2 -or $unexpected.Count -ne 0) { throw 'Stage3 tracked diff is not exactly the two approved test fixtures.' }

  git diff --quiet $baselineTag -- src data eng scripts installer tools
  $productionDiff = $LASTEXITCODE
  git diff --quiet $baselineTag -- src/RasoatHopDong.App/Web
  $webDiff = $LASTEXITCODE
  Write-Output "PRODUCTION_TREE_DIFF_EXIT=$productionDiff WEB_UI_DIFF_EXIT=$webDiff"
  if ($productionDiff -ne 0 -or $webDiff -ne 0) { throw 'Production or frozen Web UI changed relative to Stage3 baseline.' }

  function Assert-Hash([string]$path,[string]$expected,[string]$label) {
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Output "$label`_SHA256=$actual EXPECTED=$expected MATCH=$([bool]($actual -ceq $expected))"
    if ($actual -cne $expected) { throw "$label hash mismatch." }
  }
  Assert-Hash '.\data\criteria-catalog\official-criteria-catalog.json' $expectedCatalog 'CATALOG'
  Assert-Hash '.\data\criteria-catalog\official-criteria-catalog-manifest.json' $expectedManifest 'MANIFEST'
  Assert-Hash '.\data\criteria-catalog\criteria-catalog-migration-map.json' $expectedMigration 'MIGRATION_MAP'
  Assert-Hash '.\docs\criteria-rebuild-phase2\target-criteria-map.json' $expectedTarget 'TARGET_MAP'

  foreach ($pair in @(
    @('.\data\criteria-catalog\official-criteria-catalog.json','.\docs\criteria-rebuild-phase2\official-candidate\official-criteria-catalog.json','CATALOG_CANDIDATE'),
    @('.\data\criteria-catalog\official-criteria-catalog-manifest.json','.\docs\criteria-rebuild-phase2\official-candidate\official-criteria-catalog-manifest.json','MANIFEST_CANDIDATE'),
    @('.\data\criteria-catalog\criteria-catalog-migration-map.json','.\docs\criteria-rebuild-phase2\official-candidate\criteria-catalog-migration-map.json','MIGRATION_CANDIDATE'))) {
    $a = (Get-FileHash -LiteralPath $pair[0] -Algorithm SHA256).Hash.ToLowerInvariant()
    $b = (Get-FileHash -LiteralPath $pair[1] -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Output "$($pair[2])_MATCH=$([bool]($a -ceq $b)) CURRENT=$a CANDIDATE=$b"
    if ($a -cne $b) { throw "$($pair[2]) bytes differ." }
  }

  function Run-Targeted([string]$config) {
    $log = Join-Path $logRoot ("targeted-" + $config.ToLowerInvariant() + '.log')
    $filter = 'FullyQualifiedName~Stage7InstallerContractTests|FullyQualifiedName~Stage7PublishContractTests'
    $oldPref = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c $config --no-build --no-restore --nologo --filter $filter --logger 'console;verbosity=minimal' *> $log
    $code = $LASTEXITCODE
    $ErrorActionPreference = $oldPref
    Write-Output "TARGETED_CONFIG=$config EXIT=$code"
    Get-Content -LiteralPath $log | Where-Object { $_ -match 'Passed!|Failed!|Total tests:|Skipped:' } | Select-Object -Last 8 | ForEach-Object { Write-Output $_ }
    if ($code -ne 0) { Get-Content -LiteralPath $log -Tail 160; throw "Targeted Stage3 patch tests failed in $config." }
  }
  Run-Targeted 'Debug'
  Run-Targeted 'Release'

  Write-Output 'STAGE3_TEST_PATCH_AND_CURRENT_INTEGRITY=PASS'
}
finally { Pop-Location }
