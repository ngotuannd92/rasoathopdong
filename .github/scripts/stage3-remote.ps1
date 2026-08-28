Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$archive='D:\rasoathopdong-v0.4.0-phase1-final-closed-r13.zip'
$expected='9eff2eebdfbb2f4fe786a6443606f9d1fb136293db89bae02199445848e2e39b'
$historical='C:\Stage3-Work\historical\phase1-final-closed-r13'
$sha=(Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Output "ARCHIVE=$archive"
Write-Output "ARCHIVE_SHA256=$sha"
if($sha -ne $expected){ throw "Historical archive SHA mismatch" }
if(Test-Path -LiteralPath $historical){ Remove-Item -LiteralPath $historical -Recurse -Force }
New-Item -ItemType Directory -Path $historical -Force | Out-Null
Expand-Archive -LiteralPath $archive -DestinationPath $historical -Force
$versionFiles=@(Get-ChildItem -LiteralPath $historical -Recurse -File -Filter Version.props | Where-Object { $_.FullName -match '[\\/]eng[\\/]Version\.props$' })
Write-Output "VERSION_FILE_COUNT=$($versionFiles.Count)"
if($versionFiles.Count -ne 1){ $versionFiles.FullName | ForEach-Object { Write-Output "VERSION_CANDIDATE=$_" }; throw "Expected exactly one eng/Version.props" }
$vf=$versionFiles[0].FullName
$sourceRoot=Split-Path -Parent (Split-Path -Parent $vf)
[xml]$x=Get-Content -LiteralPath $vf -Raw
$p=$x.Project.PropertyGroup | Select-Object -First 1
$contract=[ordered]@{
 AppVersion=[string]$p.AppVersion
 EngineVersion=[string]$p.EngineVersion
 CriteriaCatalogVersion=[string]$p.CriteriaCatalogVersion
 DatabaseSchemaVersion=[string]$p.DatabaseSchemaVersion
 CriteriaSnapshotSchemaVersion=[string]$p.CriteriaSnapshotSchemaVersion
 OfficialCriteriaCatalogSchemaVersion=[string]$p.OfficialCriteriaCatalogSchemaVersion
 OfficialCriteriaCatalogManifestSchemaVersion=[string]$p.OfficialCriteriaCatalogManifestSchemaVersion
 CriteriaCatalogMigrationMapSchemaVersion=[string]$p.CriteriaCatalogMigrationMapSchemaVersion
}
Write-Output "HISTORICAL_SOURCE_ROOT=$sourceRoot"
Write-Output ($contract | ConvertTo-Json -Compress)
if($contract.AppVersion -ne '0.4.0' -or $contract.EngineVersion -ne '0.3.0' -or $contract.CriteriaCatalogVersion -ne '0.2.0' -or $contract.DatabaseSchemaVersion -ne '3' -or $contract.CriteriaSnapshotSchemaVersion -ne '4' -or $contract.OfficialCriteriaCatalogSchemaVersion -ne '2' -or $contract.OfficialCriteriaCatalogManifestSchemaVersion -ne '2' -or $contract.CriteriaCatalogMigrationMapSchemaVersion -ne '2') { throw 'Historical source contract mismatch' }
$prep=Join-Path $sourceRoot 'tests\RasoatHopDong.Tests\Stage2MigrationFixturePreparationTests.cs'
Write-Output "PREP_TEST_EXISTS=$(Test-Path -LiteralPath $prep)"
if(-not (Test-Path -LiteralPath $prep)){ throw 'Fixture preparation test missing in authentic source' }
Write-Output 'AUTHENTIC_PHASE1_SOURCE_VERIFIED=PASS'