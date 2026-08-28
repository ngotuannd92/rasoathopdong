Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$old='C:\Stage3-Work\historical\phase1-final-closed-r13\rasoathopdong-v0.4.0-phase1-final-closed-r13'
$cur='C:\Stage3-Work\source-current'
Write-Output "OLD_EXISTS=$(Test-Path -LiteralPath $old)"
$oldProj=Join-Path $old 'tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj'
$curProj=Join-Path $cur 'tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj'
Write-Output 'OLD_CSPROJ_BEGIN'; Get-Content -LiteralPath $oldProj -Raw; Write-Output 'OLD_CSPROJ_END'
Write-Output 'CURRENT_CSPROJ_BEGIN'; Get-Content -LiteralPath $curProj -Raw; Write-Output 'CURRENT_CSPROJ_END'
$names=@('AppDataSqliteConnectionFactory','EmbeddedOfficialCriteriaCatalogSource','LocalDataUpgradeCoordinator','CriteriaService','CriteriaWorkingSetImporter','ReviewService','CompareService','CompareHistoryService','SettingsStorage','ProductVersionInfo')
foreach($n in $names){
  $m=@(Get-ChildItem -LiteralPath (Join-Path $old 'src') -Recurse -File -Filter *.cs | Select-String -SimpleMatch $n | Select-Object -First 1)
  Write-Output "OLD_SYMBOL=$n EXISTS=$($m.Count -gt 0) LOC=$($(if($m.Count){$m[0].Path+':'+$m[0].LineNumber}else{''}))"
}
$assets=@(
 'docs\criteria-rebuild-phase2\working-set-candidates\stage2-service-candidate.json',
 'docs\criteria-rebuild-phase2\corpus\service-balanced.docx',
 'docs\criteria-rebuild-phase2\corpus\service-became-passed-before.docx',
 'docs\criteria-rebuild-phase2\corpus\service-became-passed-after.docx'
)
foreach($rel in $assets){ Write-Output "ASSET=$rel OLD=$(Test-Path -LiteralPath (Join-Path $old $rel)) CURRENT=$(Test-Path -LiteralPath (Join-Path $cur $rel))" }
Write-Output 'DONE'