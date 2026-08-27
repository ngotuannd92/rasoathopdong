Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$logRoot = 'C:\Stage3-Work\logs\stage3-core-e2e'
$py = 'C:\Stage3-Work\pyenv\Scripts\python.exe'
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
if (-not (Test-Path $py)) { throw 'Stage3 verifier environment is missing.' }
Push-Location $source
try {
  function Run-Native([string]$name,[scriptblock]$command) {
    $log = Join-Path $logRoot ($name + '.log')
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $command *> $log
    $code = $LASTEXITCODE
    $ErrorActionPreference = $old
    Write-Output "GATE=$name EXIT=$code"
    if ($code -ne 0) {
      Get-Content $log -Tail 100 -ErrorAction SilentlyContinue
      throw "$name failed."
    }
    Get-Content $log -ErrorAction SilentlyContinue | Where-Object { $_ -match 'Passed!|Failed!|Total tests:|PASS|PASSED|pending|Pending' } | Select-Object -Last 20
  }
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim())"
  Run-Native 'phase2-static' { & $py .\scripts\verify-phase2-static.py }
  Run-Native 'phase2-content-quality' { & $py .\scripts\verify-phase2-content-quality.py }
  Run-Native 'phase2-targeted-semantics' { & $py .\scripts\verify-phase2-targeted-semantics.py }
  Run-Native 'phase2-compare-corpus' { & $py .\scripts\verify-phase2-compare-corpus.py }
  Run-Native 'phase2-golden-semantics' { & $py .\scripts\verify-phase2-golden-semantics.py }
  $env:STAGE2_POST_PROMOTION = '1'
  $exactFilter = 'FullyQualifiedName~Stage2PostPromotionRuntimeGateTests.ExactOfficialReviewGolden|FullyQualifiedName~Stage2PostPromotionRuntimeGateTests.ExactOfficialCompareCorpus|FullyQualifiedName~Stage2PostPromotionRuntimeGateTests.ExactOfficialBenchmarkV3|FullyQualifiedName~Stage2PostPromotionRuntimeGateTests.ExactOfficialHistoryAndExports'
  Run-Native 'exact-official-e2e-debug' { dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c Debug --no-build --no-restore --nologo --filter $exactFilter --logger 'console;verbosity=minimal' }
  Run-Native 'exact-official-e2e-release' { dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c Release --no-build --no-restore --nologo --filter $exactFilter --logger 'console;verbosity=minimal' }
  Write-Output 'STAGE3_CORE_E2E_CURRENT=PASS'
}
finally {
  $env:STAGE2_POST_PROMOTION = $null
  Pop-Location
}
