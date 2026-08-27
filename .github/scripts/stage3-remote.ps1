Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$logRoot = 'C:\Stage3-Work\logs\stage3-runner-fixtures-release'
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim())"
  function Run-Class([string]$name,[string]$filter) {
    $log = Join-Path $logRoot ($name + '.log')
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c Release --no-build --no-restore --nologo --filter $filter --logger 'console;verbosity=minimal' *> $log
    $code = $LASTEXITCODE
    $ErrorActionPreference = $old
    Write-Output "GATE=$name EXIT=$code"
    Get-Content $log | Where-Object { $_ -match 'Passed!|Failed!|Total tests:|Skipped:' } | Select-Object -Last 12
    if ($code -ne 0) { Get-Content $log -Tail 180; throw "$name failed." }
  }
  Run-Class 'installer-release' 'FullyQualifiedName~Stage7InstallerContractTests'
  Run-Class 'publish-release' 'FullyQualifiedName~Stage7PublishContractTests'
  Write-Output 'STAGE3_RUNNER_FIXTURES_RELEASE=PASS'
}
finally { Pop-Location }
