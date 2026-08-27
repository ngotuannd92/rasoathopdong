Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$logRoot = 'C:\Stage3-Work\logs\stage3-compatibility'
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
Push-Location $source
try {
  function Run-Test([string]$name,[string]$config,[string]$filter) {
    $log = Join-Path $logRoot ($name + '-' + $config.ToLowerInvariant() + '.log')
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c $config --no-build --no-restore --nologo --filter $filter --logger 'console;verbosity=minimal' *> $log
    $code = $LASTEXITCODE
    $ErrorActionPreference = $old
    Write-Output "GATE=$name CONFIG=$config EXIT=$code"
    Get-Content $log | Where-Object { $_ -match 'Passed!|Failed!|Total tests:|Skipped:' } | Select-Object -Last 8
    if ($code -ne 0) { Get-Content $log -Tail 120; throw "$name $config failed." }
  }
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim())"
  $data = 'FullyQualifiedName~History|FullyQualifiedName~WorkingSet|FullyQualifiedName~LocalDataUpgrade|FullyQualifiedName~Migration|FullyQualifiedName~CriteriaRestore|FullyQualifiedName~SettingsStorage'
  $release = 'FullyQualifiedName~Export|FullyQualifiedName~Update|FullyQualifiedName~Installer|FullyQualifiedName~Publish|FullyQualifiedName~Recovery'
  Run-Test 'data-safety-compatibility' 'Debug' $data
  Run-Test 'data-safety-compatibility' 'Release' $data
  Run-Test 'release-paths-backend' 'Debug' $release
  Run-Test 'release-paths-backend' 'Release' $release
  $env:STAGE2_POST_PROMOTION = '1'
  $mig010 = 'FullyQualifiedName~Stage2PostPromotionRuntimeGateTests.Migration010To030_ShouldUseDirectAuthorizedTransitionAndPreserveCustomData'
  Run-Test 'legacy-010-to-030' 'Debug' $mig010
  Run-Test 'legacy-010-to-030' 'Release' $mig010
  Write-Output 'STAGE3_COMPATIBILITY_BACKEND=PASS'
}
finally {
  $env:STAGE2_POST_PROMOTION = $null
  Pop-Location
}
