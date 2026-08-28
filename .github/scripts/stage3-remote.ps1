Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$logRoot = 'C:\Stage3-Work\logs\stage3-final-regression'
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
Push-Location $source
try {
  $head = (git rev-parse HEAD).Trim()
  Write-Output "SOURCE_HEAD=$head BRANCH=$((git branch --show-current).Trim())"
  git diff --check
  if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed.' }
  function Run-Suite([string]$config) {
    $log = Join-Path $logRoot ('full-' + $config.ToLowerInvariant() + '.log')
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c $config --no-build --no-restore --nologo --logger 'console;verbosity=minimal' *> $log
    $code = $LASTEXITCODE
    $ErrorActionPreference = $old
    Write-Output "FULL_SUITE_CONFIG=$config EXIT=$code"
    Get-Content $log | Where-Object { $_ -match 'Passed!|Failed!|Total tests:|Skipped:' } | Select-Object -Last 12
    if ($code -ne 0) { Get-Content $log -Tail 200; throw "Full $config regression failed." }
  }
  Run-Suite 'Debug'
  Run-Suite 'Release'
  Write-Output 'STAGE3_FINAL_FULL_REGRESSION=PASS'
}
finally { Pop-Location }
