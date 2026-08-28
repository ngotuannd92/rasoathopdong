Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$stateDir = 'C:\Stage3-Work\state'
$statePath = Join-Path $stateDir 'stage3-verification-checkpoint.json'
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
Push-Location $source
try {
  $head = (git rev-parse HEAD).Trim()
  $branch = (git branch --show-current).Trim()
  $status = @(git status --porcelain)
  if ($head -ne '550510636c212c8b77e29ff2434317e566d66fe9') { throw "Unexpected source HEAD: $head" }
  if ($status.Count -ne 0) { $status; throw 'Source worktree is not clean.' }

  $checkpoint = [ordered]@{
    schemaVersion = 1
    recordedAtUtc = [DateTime]::UtcNow.ToString('o')
    runner = [ordered]@{
      name = $env:RUNNER_NAME
      machine = $env:COMPUTERNAME
      os = $env:RUNNER_OS
      arch = $env:RUNNER_ARCH
    }
    source = [ordered]@{
      path = $source
      head = $head
      branch = $branch
      baselineTag = 'stage3-baseline-v0.4.0'
      baselineCommit = 'a183b606d571055d7f5b5b7d39604cea454d9759'
      worktreeClean = $true
      trackedChangesFromBaseline = @(
        'tests/RasoatHopDong.Tests/Stage7InstallerContractTests.cs',
        'tests/RasoatHopDong.Tests/Stage7PublishContractTests.cs'
      )
      productionTreeChanged = $false
      frozenWebUiChanged = $false
    }
    verification = [ordered]@{
      debugFullRegression = '2197/2197 PASS; 0 failed; 0 skipped'
      releaseFullRegression = '2197/2197 PASS; 0 failed; 0 skipped'
      debugBuild = 'PASS; 0 warnings; 0 errors'
      releaseBuild = 'PASS; 0 warnings; 0 errors'
      phase2Static = '5548/5548 PASS'
      phase2ContentQuality = '4282 checks / 175 criteria PASS'
      phase2TargetedSemantics = '701 cases / 175 criteria PASS'
      phase2CompareCorpus = '8 pairs; all transitions PASS'
      phase2GoldenSemantics = '90 expectations PASS; 2 OCR runtime documents separately verified on Windows'
      exactOfficialE2E = '9/9 PASS in Debug and Release'
      realWindowsOcr = '2/2 PASS in Debug and Release'
      productionPdfPaths = '3/3 PASS in Debug and Release'
      dataSafetyCompatibility = '277/277 PASS in Debug and Release'
      releaseUpdateExportInstallerBackend = '977/977 PASS in Debug and Release'
      migration010To030 = '1/1 PASS in Debug and Release'
      stage7InstallerFixturePatch = '16/16 PASS in Debug and Release'
      stage7PublishFixturePatch = '29/29 PASS in Debug and Release'
      staticIntegrity = 'PASS; production/data/eng/scripts/installer/tools/Web UI unchanged from baseline'
    }
    migration020To030 = [ordered]@{
      status = 'BLOCKED_MISSING_AUTHENTIC_HISTORICAL_FIXTURE_SOURCE'
      requiredSourceContract = [ordered]@{
        criteriaCatalogVersion = '0.2.0'
        databaseSchemaVersion = '3'
        criteriaCatalogMigrationMapSchemaVersion = '2'
      }
      knownHistoricalPrivateCommit = '2cd394d543e2e0b0bca9f7c4a1103484a6c63629'
      knownHistoricalPrivateCommitContract = [ordered]@{
        criteriaCatalogVersion = '0.2.0'
        databaseSchemaVersion = '2'
        criteriaCatalogMigrationMapSchemaVersion = '1'
      }
      expectedArchiveName = 'rasoathopdong-v0.4.0-phase1-final-closed-r13(20260818-173343).zip'
      expectedArchiveSha256 = '9eff2eebdfbb2f4fe786a6443606f9d1fb136293db89bae02199445848e2e39b'
      archiveFoundOnStage3 = $false
      archiveFoundInChatLibrary = $false
      archiveFoundInCurrentContainer = $false
      syntheticFixtureAllowed = $false
      reason = 'Fixture preparation test explicitly requires an authentic 0.2.0 source with DB schema 3 and migration-map schema 2. Current 0.3.0 source and known private Stage10 source do not satisfy that contract.'
    }
    closure = [ordered]@{
      productionDefectFound = $false
      productionPatchApplied = $false
      userFacingUiChanged = $false
      stage3FullyClosed = $false
      onlyOpenGate = 'Migration 0.2.0 -> 0.3.0 against authentic Phase1 historical fixture'
    }
  }
  $checkpoint | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8
  Write-Output "CHECKPOINT_PATH=$statePath"
  Write-Output "CHECKPOINT_SHA256=$((Get-FileHash -LiteralPath $statePath -Algorithm SHA256).Hash.ToLowerInvariant())"
  Get-Content -LiteralPath $statePath
  Write-Output 'STAGE3_CHECKPOINT_RECORDED=PASS'
}
finally { Pop-Location }
