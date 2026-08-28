Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  Write-Output 'MIGRATION_020_REFERENCES_BEGIN'
  Get-ChildItem .\tests\RasoatHopDong.Tests -File -Filter *.cs |
    Select-String -Pattern 'Migration020To030|PrepareMigrationFixture|STAGE2_PREPARE_MIGRATION_FIXTURE|catalog-0.2.0-schema3|0.2.0' |
    ForEach-Object { "{0}:{1}:{2}" -f $_.Path,$_.LineNumber,$_.Line.Trim() }
  Write-Output 'MIGRATION_020_REFERENCES_END'

  foreach ($p in @(
    '.\tests\RasoatHopDong.Tests\Stage2PostPromotionRuntimeGateTests.cs',
    '.\tests\RasoatHopDong.Tests\Stage2MigrationFixturePreparationTests.cs')) {
    if (Test-Path $p) {
      Write-Output "FILE_BEGIN=$p"
      $lines = Get-Content $p
      for ($i=0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match 'Migration020To030|PrepareMigrationFixture|STAGE2_PREPARE_MIGRATION_FIXTURE|catalog-0\.2\.0-schema3|0\.2\.0') {
          $start = [Math]::Max(0,$i-18)
          $end = [Math]::Min($lines.Count-1,$i+70)
          for ($j=$start; $j -le $end; $j++) { Write-Output ("{0,5}: {1}" -f ($j+1),$lines[$j]) }
          Write-Output '---'
        }
      }
      Write-Output "FILE_END=$p"
    }
  }
  Write-Output 'STAGE3_MIGRATION_020_LOGIC_INSPECTED=PASS'
}
finally { Pop-Location }
