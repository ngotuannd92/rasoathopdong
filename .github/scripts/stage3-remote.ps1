Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$src='C:\Stage3-Work\source-current'
$proj=Join-Path $src 'tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj'
$fixture='C:\Stage3-Work\fixtures\stage2-runtime-authentic'
$env:STAGE2_POST_PROMOTION='1'
$env:STAGE2_RUNTIME_FIXTURE_DIR=$fixture
foreach($cfg in @('Debug','Release')){
  Write-Output "POST_PROMOTION_${cfg}_BEGIN"
  & dotnet test $proj -c $cfg --filter 'FullyQualifiedName~Stage2PostPromotionRuntimeGateTests' --no-restore --verbosity minimal
  $code=$LASTEXITCODE
  Write-Output "POST_PROMOTION_${cfg}_EXIT=$code"
  if($code -ne 0){ exit $code }
}
Write-Output 'AUTHENTIC_MIGRATION_020_TO_030_GATE=PASS'