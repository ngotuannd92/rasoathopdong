Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  Write-Output 'STAGE3_DOCS_BEGIN'
  Get-ChildItem .\docs -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^stage3|stage-3|phase3|phase-3' } | ForEach-Object {
    Write-Output "FILE=$($_.FullName) SIZE=$($_.Length)"
    Get-Content $_.FullName -TotalCount 500
    Write-Output "END_FILE=$($_.Name)"
  }
  Write-Output 'STAGE3_DOCS_END'
  Write-Output 'STAGE3_BASELINE_BEGIN'
  if (Test-Path .\.baseline\stage3-input-source-lock.json) { Get-Content .\.baseline\stage3-input-source-lock.json }
  Write-Output 'STAGE3_BASELINE_END'
  Write-Output 'STAGE3_TESTS_BEGIN'
  Get-ChildItem .\tests\RasoatHopDong.Tests -File -Filter *.cs | Where-Object { $_.Name -match 'Stage3|Phase3' } | ForEach-Object {
    Write-Output "FILE=$($_.FullName)"
    Select-String -LiteralPath $_.FullName -Pattern '\[Fact\]','\[Theory\]','public .*\(','Stage3','Phase3' | ForEach-Object { "{0}:{1}:{2}" -f $_.Path,$_.LineNumber,$_.Line.Trim() }
  }
  Write-Output 'STAGE3_TESTS_END'
  Write-Output 'VERSION_BEGIN'
  Get-Content .\eng\Version.props
  Write-Output 'VERSION_END'
}
finally { Pop-Location }
