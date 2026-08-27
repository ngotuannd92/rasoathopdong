Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$hashA = '47af07851637f14da1ce615864cab213e26233eae32177a52a47e3b1f22ab364'
$hashB = '2faf9f56016e83101d6552deb15447e99e15aa00f1c6a5bf703df2b309baa3c1'
$phase1Candidate = 'D:\rasoathopdong-v0.4.0-phase1-final-closed-r13.zip'
$expectedPhase1Hash = '9eff2eebdfbb2f4fe786a6443606f9d1fb136293db89bae02199445848e2e39b'

Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim()) BASELINE=$((git rev-parse stage3-baseline-v0.4.0).Trim())"
  Write-Output 'HASH_REFERENCES_BEGIN'
  Get-ChildItem .\docs,.\evidence,.\.baseline -Recurse -File -Include *.json,*.md,*.txt -ErrorAction SilentlyContinue |
    ForEach-Object {
      $hits = Select-String -LiteralPath $_.FullName -Pattern $hashA,$hashB -SimpleMatch -ErrorAction SilentlyContinue
      foreach ($hit in $hits) { Write-Output "HIT=$($hit.Path):$($hit.LineNumber):$($hit.Line.Trim())" }
    }
  Write-Output 'HASH_REFERENCES_END'

  Write-Output 'PHASE2_ACCEPTANCE_HASH_FIELDS_BEGIN'
  foreach ($file in @(
    '.\docs\criteria-rebuild-phase2\phase2-final-acceptance.json',
    '.\docs\criteria-rebuild-phase2\phase2-runtime-gate-evidence.json',
    '.\docs\criteria-rebuild-phase2\phase2-current-static-acceptance.json',
    '.\docs\criteria-rebuild-phase2\phase2-before-lock.json')) {
    if (Test-Path -LiteralPath $file) {
      Write-Output "FILE=$file"
      Get-Content -LiteralPath $file | Select-String -Pattern 'sha','hash','catalog','manifest','migration','175','45','0.3.0' | ForEach-Object { Write-Output $_.Line.Trim() }
    }
  }
  Write-Output 'PHASE2_ACCEPTANCE_HASH_FIELDS_END'

  Write-Output 'CATALOG_FILE_HASHES_BEGIN'
  foreach ($file in @(
    '.\data\criteria-catalog\official-criteria-catalog.json',
    '.\data\criteria-catalog\official-criteria-catalog-manifest.json',
    '.\data\criteria-catalog\criteria-catalog-migration-map.json',
    '.\docs\criteria-rebuild-phase2\official-candidate\official-criteria-catalog.json',
    '.\docs\criteria-rebuild-phase2\official-candidate\official-criteria-catalog-manifest.json',
    '.\docs\criteria-rebuild-phase2\official-candidate\criteria-catalog-migration-map.json',
    '.\docs\criteria-rebuild-phase2\target-criteria-map.json')) {
    if (Test-Path -LiteralPath $file -PathType Leaf) {
      Write-Output "FILE_HASH=$file SHA256=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()) SIZE=$((Get-Item -LiteralPath $file).Length)"
    }
  }
  Write-Output 'CATALOG_FILE_HASHES_END'

  if (Test-Path -LiteralPath $phase1Candidate -PathType Leaf) {
    $h = (Get-FileHash -LiteralPath $phase1Candidate -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Output "PHASE1_ARCHIVE=$phase1Candidate SIZE=$((Get-Item -LiteralPath $phase1Candidate).Length) SHA256=$h EXPECTED=$expectedPhase1Hash MATCH=$([bool]($h -ceq $expectedPhase1Hash))"
  } else { Write-Output 'PHASE1_ARCHIVE=NOT_FOUND' }

  Write-Output 'PYCACHE_BEGIN'
  $trackedPycache = @(git ls-files 'scripts/__pycache__/*')
  $untrackedPycache = @(git ls-files --others --exclude-standard 'scripts/__pycache__/*')
  Write-Output "TRACKED_PYCACHE=$($trackedPycache.Count) UNTRACKED_PYCACHE=$($untrackedPycache.Count)"
  $untrackedPycache | ForEach-Object { Write-Output "UNTRACKED=$_" }
  if ($trackedPycache.Count -eq 0 -and $untrackedPycache.Count -gt 0) {
    Remove-Item -LiteralPath '.\scripts\__pycache__' -Recurse -Force
  }
  Write-Output 'STATUS_AFTER_CLEANUP_BEGIN'
  git status --short
  Write-Output 'STATUS_AFTER_CLEANUP_END'
  Write-Output 'PYCACHE_END'
}
finally { Pop-Location }
