Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$h='C:\Stage3-Work\historical\phase1-fixture-harness-src'
$fixture='C:\Stage3-Work\fixtures\stage2-runtime-authentic'
$proj=Join-Path $h 'tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj'
$env:STAGE2_PREPARE_MIGRATION_FIXTURE='1'
$env:STAGE2_RUNTIME_FIXTURE_DIR=$fixture
Write-Output 'RESTORE_BEGIN'
& dotnet restore $proj --verbosity minimal
if($LASTEXITCODE -ne 0){ exit $LASTEXITCODE }
Write-Output 'RESTORE_PASS'
Write-Output 'PREP_RELEASE_BEGIN'
& dotnet test $proj -c Release --filter 'FullyQualifiedName~Stage2MigrationFixturePreparationTests.PrepareCatalog020Schema3Fixture_WithCustomWorkingSetHistoryAndSettings' --no-restore --verbosity minimal
$code=$LASTEXITCODE
Write-Output "PREP_RELEASE_EXIT=$code"
if($code -ne 0){ exit $code }
$appData=Join-Path $fixture 'catalog-0.2.0-schema3'
Write-Output "FIXTURE_EXISTS=$(Test-Path -LiteralPath $appData)"
Write-Output "FIXTURE_MANIFEST_EXISTS=$(Test-Path -LiteralPath (Join-Path $appData 'fixture-manifest.json'))"
Get-ChildItem -LiteralPath $appData -File | ForEach-Object { "FIXTURE_FILE=$($_.Name)|SIZE=$($_.Length)|SHA256=$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())" }
$prov='C:\Stage3-Work\state\stage3-authentic-020-fixture-provenance.json'
Write-Output "PROVENANCE_SHA256=$((Get-FileHash -LiteralPath $prov -Algorithm SHA256).Hash.ToLowerInvariant())"
Write-Output 'AUTHENTIC_020_FIXTURE_PREP=PASS'