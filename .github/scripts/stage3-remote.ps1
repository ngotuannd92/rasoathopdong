Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$logRoot = 'C:\Stage3-Work\logs\stage3-regression'
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim())"
  Write-Output "SOURCE_BRANCH=$((git branch --show-current).Trim())"
  git diff --check
  dotnet restore .\rasoathopdong.sln --nologo 2>&1 | Tee-Object -FilePath (Join-Path $logRoot 'restore.log')
  dotnet build .\rasoathopdong.sln -c Debug --no-restore --nologo 2>&1 | Tee-Object -FilePath (Join-Path $logRoot 'build-debug.log')
  dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c Debug --no-build --no-restore --nologo --logger 'console;verbosity=minimal' 2>&1 | Tee-Object -FilePath (Join-Path $logRoot 'test-debug.log')
  dotnet build .\rasoathopdong.sln -c Release --no-restore --nologo 2>&1 | Tee-Object -FilePath (Join-Path $logRoot 'build-release.log')
  dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c Release --no-build --no-restore --nologo --logger 'console;verbosity=minimal' 2>&1 | Tee-Object -FilePath (Join-Path $logRoot 'test-release.log')
  Write-Output 'FULL_REGRESSION_BASELINE=PASS'
}
finally { Pop-Location }
