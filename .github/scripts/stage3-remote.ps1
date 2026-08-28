Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'
$expected='9eff2eebdfbb2f4fe786a6443606f9d1fb136293db89bae02199445848e2e39b'
$target='rasoathopdong-v0.4.0-phase1-final-closed-r13(20260818-173343).zip'
Write-Output "MACHINE=$env:COMPUTERNAME"
Write-Output 'DRIVES_BEGIN'
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object { "DRIVE=$($_.DeviceID) FREE=$($_.FreeSpace) SIZE=$($_.Size)" }
Write-Output 'DRIVES_END'
$roots=@('C:\Users\ngotu','C:\Stage3-Work')
foreach($d in (Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -ExpandProperty DeviceID)) { if($d -ne 'C:'){ $roots += ($d+'\') } }
$seen=@{}
Write-Output 'CANDIDATES_BEGIN'
foreach($r in $roots){
  if(-not (Test-Path -LiteralPath $r)){ continue }
  Write-Output "SEARCH_ROOT=$r"
  Get-ChildItem -LiteralPath $r -File -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq $target -or ($_.Extension -ieq '.zip' -and $_.Name -match 'rasoathopdong.*phase1') } |
    ForEach-Object {
      if($seen.ContainsKey($_.FullName)){ return }
      $seen[$_.FullName]=$true
      $sha=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
      "FILE={0}|SIZE={1}|SHA256={2}|EXPECTED_MATCH={3}" -f $_.FullName,$_.Length,$sha,($sha -eq $expected)
    }
}
Write-Output 'CANDIDATES_END'
Write-Output 'DONE'