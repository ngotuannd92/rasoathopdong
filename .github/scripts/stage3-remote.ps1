Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$baselineTag = 'stage3-baseline-v0.4.0'
Push-Location $source
try {
  $head = (git rev-parse HEAD).Trim()
  $base = (git rev-parse $baselineTag).Trim()
  Write-Output "SOURCE_HEAD=$head BASELINE=$base BRANCH=$((git branch --show-current).Trim())"

  $untrackedPycache = @(git ls-files --others --exclude-standard 'scripts/__pycache__/*')
  foreach ($relative in $untrackedPycache) {
    $full = Join-Path $source $relative.Replace('/','\')
    if (-not $full.StartsWith((Join-Path $source 'scripts\__pycache__'), [StringComparison]::OrdinalIgnoreCase)) { throw "Refusing cleanup outside pycache: $full" }
    Remove-Item -LiteralPath $full -Force -ErrorAction SilentlyContinue
  }
  $status = @(git status --porcelain)
  Write-Output "WORKTREE_STATUS_COUNT=$($status.Count)"
  if ($status.Count -ne 0) { $status; throw 'Worktree is not clean.' }
  git diff --check
  if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed.' }

  $allowed = @(
    'tests/RasoatHopDong.Tests/Stage7InstallerContractTests.cs',
    'tests/RasoatHopDong.Tests/Stage7PublishContractTests.cs'
  )
  $changed = @(git diff --name-only "$baselineTag..HEAD")
  $unexpected = @($changed | Where-Object { $allowed -notcontains $_.Replace('\','/') })
  Write-Output "CHANGED_FILES=$($changed.Count) UNEXPECTED_CHANGED_FILES=$($unexpected.Count)"
  $changed | ForEach-Object { Write-Output "CHANGED=$_" }
  if ($changed.Count -ne 2 -or $unexpected.Count -ne 0) { throw 'Tracked diff is not exactly the two approved Stage3 test fixtures.' }

  foreach ($scope in @('src','data','eng','scripts','installer','tools','src/RasoatHopDong.App/Web')) {
    git diff --quiet $baselineTag -- $scope
    $code = $LASTEXITCODE
    Write-Output "BASELINE_DIFF scope=$scope exit=$code"
    if ($code -ne 0) { throw "Baseline drift detected in $scope" }
  }

  foreach ($pair in @(
    @('.\data\criteria-catalog\official-criteria-catalog.json','.\docs\criteria-rebuild-phase2\official-candidate\official-criteria-catalog.json','CATALOG_CANDIDATE'),
    @('.\data\criteria-catalog\official-criteria-catalog-manifest.json','.\docs\criteria-rebuild-phase2\official-candidate\official-criteria-catalog-manifest.json','MANIFEST_CANDIDATE'),
    @('.\data\criteria-catalog\criteria-catalog-migration-map.json','.\docs\criteria-rebuild-phase2\official-candidate\criteria-catalog-migration-map.json','MIGRATION_CANDIDATE'))) {
    $a = (Get-FileHash -LiteralPath $pair[0] -Algorithm SHA256).Hash.ToLowerInvariant()
    $b = (Get-FileHash -LiteralPath $pair[1] -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Output "$($pair[2])_MATCH=$([bool]($a -ceq $b)) HASH=$a"
    if ($a -cne $b) { throw "$($pair[2]) bytes differ." }
  }

  Write-Output 'STAGE3_STATIC_INTEGRITY=PASS'
}
finally { Pop-Location }
