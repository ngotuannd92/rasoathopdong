Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$old='C:\Stage3-Work\historical\phase1-final-closed-r13\rasoathopdong-v0.4.0-phase1-final-closed-r13'
$cur='C:\Stage3-Work\source-current'
$h='C:\Stage3-Work\historical\phase1-fixture-harness-src'
$fixture='C:\Stage3-Work\fixtures\stage2-runtime-authentic'
if(Test-Path -LiteralPath $h){ Remove-Item -LiteralPath $h -Recurse -Force }
New-Item -ItemType Directory -Path $h -Force | Out-Null
& robocopy $old $h /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
if($LASTEXITCODE -ge 8){ throw "robocopy failed: $LASTEXITCODE" }
$prepRel='tests\RasoatHopDong.Tests\Stage2MigrationFixturePreparationTests.cs'
Copy-Item -LiteralPath (Join-Path $cur $prepRel) -Destination (Join-Path $h $prepRel) -Force
$assets=@(
 'docs\criteria-rebuild-phase2\working-set-candidates\stage2-service-candidate.json',
 'docs\criteria-rebuild-phase2\corpus\service-balanced.docx',
 'docs\criteria-rebuild-phase2\corpus\service-became-passed-before.docx',
 'docs\criteria-rebuild-phase2\corpus\service-became-passed-after.docx'
)
foreach($rel in $assets){ $dst=Join-Path $h $rel; New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null; Copy-Item -LiteralPath (Join-Path $cur $rel) -Destination $dst -Force }
$prov=[ordered]@{
 schemaVersion=1; purpose='stage3-authentic-020-fixture-harness';
 authenticArchive='D:\rasoathopdong-v0.4.0-phase1-final-closed-r13.zip';
 authenticArchiveSha256='9eff2eebdfbb2f4fe786a6443606f9d1fb136293db89bae02199445848e2e39b';
 authenticSourceRoot=$old; harnessRoot=$h;
 productionVersionPropsSha256=(Get-FileHash -LiteralPath (Join-Path $h 'eng\Version.props') -Algorithm SHA256).Hash.ToLowerInvariant();
 injectedTestSourceSha256=(Get-FileHash -LiteralPath (Join-Path $h $prepRel) -Algorithm SHA256).Hash.ToLowerInvariant();
 testInputs=@($assets | ForEach-Object { [ordered]@{path=$_;sha256=(Get-FileHash -LiteralPath (Join-Path $h $_) -Algorithm SHA256).Hash.ToLowerInvariant()} })
}
$provPath='C:\Stage3-Work\state\stage3-authentic-020-fixture-provenance.json'
$prov | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $provPath -Encoding UTF8
if(Test-Path -LiteralPath $fixture){ Remove-Item -LiteralPath $fixture -Recurse -Force }
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
$env:STAGE2_PREPARE_MIGRATION_FIXTURE='1'
$env:STAGE2_RUNTIME_FIXTURE_DIR=$fixture
Write-Output 'PREP_RELEASE_BEGIN'
& dotnet test (Join-Path $h 'tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj') -c Release --filter 'FullyQualifiedName~Stage2MigrationFixturePreparationTests.PrepareCatalog020Schema3Fixture_WithCustomWorkingSetHistoryAndSettings' --no-restore --verbosity minimal
$code=$LASTEXITCODE
Write-Output "PREP_RELEASE_EXIT=$code"
if($code -ne 0){ exit $code }
$appData=Join-Path $fixture 'catalog-0.2.0-schema3'
Write-Output "FIXTURE_EXISTS=$(Test-Path -LiteralPath $appData)"
Write-Output "FIXTURE_MANIFEST_EXISTS=$(Test-Path -LiteralPath (Join-Path $appData 'fixture-manifest.json'))"
Get-ChildItem -LiteralPath $appData -File | ForEach-Object { "FIXTURE_FILE=$($_.Name)|SIZE=$($_.Length)|SHA256=$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())" }
Write-Output "PROVENANCE_SHA256=$((Get-FileHash -LiteralPath $provPath -Algorithm SHA256).Hash.ToLowerInvariant())"
Write-Output 'AUTHENTIC_020_FIXTURE_PREP=PASS'