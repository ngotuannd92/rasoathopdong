Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
Push-Location $source
try {
  Write-Output 'BASELINE_CANDIDATES_BEGIN'
  Get-ChildItem . -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in '.json','.md','.props','.zip' } |
    ForEach-Object {
      if ($_.Extension -eq '.zip') {
        if ($_.Name -match 'phase1|0\.2\.0|baseline|closed|r13') { "ZIP=$($_.FullName) SIZE=$($_.Length)" }
      } else {
        $hit = Select-String -LiteralPath $_.FullName -Pattern '0.2.0','phase1-final-closed','9eff2eebdfbb2f4fe786a6443606f9d1fb136293db89bae02199445848e2e39b' -SimpleMatch -Quiet -ErrorAction SilentlyContinue
        if ($hit) { "FILE=$($_.FullName) SIZE=$($_.Length)" }
      }
    } | Select-Object -First 180
  Write-Output 'BASELINE_CANDIDATES_END'
  Write-Output 'BASELINE_DIRS_BEGIN'
  Get-ChildItem .\.baseline,.\docs\criteria-rebuild-phase2 -Force -ErrorAction SilentlyContinue | Select-Object FullName,Length,LastWriteTime | Format-Table -AutoSize
  Write-Output 'BASELINE_DIRS_END'
}
finally { Pop-Location }
