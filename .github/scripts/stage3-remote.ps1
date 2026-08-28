Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$privateWork = 'C:\actions-runner\_work\rasoathopdong-stage10\rasoathopdong-stage10'
Write-Output "PRIVATE_WORK_EXISTS=$(Test-Path -LiteralPath $privateWork)"
if (-not (Test-Path -LiteralPath $privateWork)) { throw 'Private repo runner workspace not found.' }
Push-Location $privateWork
try {
  Write-Output "PRIVATE_HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  $resultPath = '.\.github\stage3-historical-020-result.txt'
  Write-Output "RESULT_EXISTS=$(Test-Path -LiteralPath $resultPath)"
  if (Test-Path -LiteralPath $resultPath) {
    Write-Output 'RESULT_BEGIN'
    Get-Content -LiteralPath $resultPath
    Write-Output 'RESULT_END'
  }
  Write-Output 'RECENT_COMMITS_BEGIN'
  git log -n 8 --format='%H|%ci|%s'
  Write-Output 'RECENT_COMMITS_END'
}
finally { Pop-Location }
