Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$expectedName = 'rasoathopdong-v0.4.0-phase1-final-closed-r13(20260818-173343).zip'
$expectedHash = '9eff2eebdfbb2f4fe786a6443606f9d1fb136293db89bae02199445848e2e39b'
$roots = @('C:\Stage3-Work', "$env:USERPROFILE\Downloads", "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents") | Where-Object { Test-Path $_ } | Select-Object -Unique
$matches = foreach ($root in $roots) {
  Get-ChildItem -LiteralPath $root -Recurse -File -Filter $expectedName -ErrorAction SilentlyContinue
}
if (-not $matches) {
  Write-Output 'BASELINE_ARCHIVE=NOT_FOUND'
  exit 0
}
foreach ($file in $matches) {
  $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Output "BASELINE_ARCHIVE=$($file.FullName)"
  Write-Output "BASELINE_SIZE=$($file.Length)"
  Write-Output "BASELINE_SHA256=$hash"
  Write-Output "BASELINE_HASH_MATCH=$([bool]($hash -eq $expectedHash))"
}
