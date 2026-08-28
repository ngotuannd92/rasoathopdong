Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$source='C:\Stage3-Work\source-current'
$test=Join-Path $source 'tests\RasoatHopDong.Tests\Stage2MigrationFixturePreparationTests.cs'
$post=Join-Path $source 'tests\RasoatHopDong.Tests\Stage2PostPromotionRuntimeGateTests.cs'
foreach($f in @($test,$post)){
  Write-Output "FILE_BEGIN=$f"
  if(-not(Test-Path -LiteralPath $f)){ throw "Missing $f" }
  Get-Content -LiteralPath $f -Raw
  Write-Output "FILE_END=$f"
}
Write-Output 'RELATED_REFS_BEGIN'
Get-ChildItem (Join-Path $source 'tests\RasoatHopDong.Tests') -File -Filter *.cs | Select-String -Pattern 'STAGE2_PREPARE_MIGRATION_FIXTURE|catalog-0\.2\.0-schema3|STAGE2_POST_PROMOTION|Migration020To030' | ForEach-Object { "{0}:{1}:{2}" -f $_.Path,$_.LineNumber,$_.Line.Trim() }
Write-Output 'RELATED_REFS_END'