Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim())"
  $log = 'C:\Stage3-Work\logs\stage3-publish-fixture-debug.log'
  $old = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c Debug --no-build --no-restore --nologo --filter 'FullyQualifiedName~Stage7PublishContractTests' --logger 'console;verbosity=minimal' *> $log
  $code = $LASTEXITCODE
  $ErrorActionPreference = $old
  Write-Output "PUBLISH_FIXTURE_DEBUG_EXIT=$code"
  Get-Content $log | Where-Object { $_ -match 'Passed!|Failed!|Total tests:|Skipped:' } | Select-Object -Last 12
  if ($code -ne 0) { Get-Content $log -Tail 180; throw 'Stage7PublishContractTests Debug failed.' }
  Write-Output 'STAGE3_PUBLISH_FIXTURE_DEBUG=PASS'
}
finally { Pop-Location }
