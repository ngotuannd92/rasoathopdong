Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$probeProfile = 'C:\Stage3-Work\historical-profile-probe'
$staleTemp = 'C:\Stage3-Work\historical-temp-r1'

Write-Output 'KNOWN_FOLDER_PROBE_BEGIN'
Write-Output "IDENTITY=$([Security.Principal.WindowsIdentity]::GetCurrent().Name)"
Write-Output "BEFORE_LOCALAPPDATA_ENV=$env:LOCALAPPDATA"
Write-Output "BEFORE_USERPROFILE_ENV=$env:USERPROFILE"
Write-Output "BEFORE_SPECIAL_LOCALAPPDATA=$([Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData))"
if (Test-Path -LiteralPath $probeProfile) { throw "Probe profile already exists: $probeProfile" }
New-Item -ItemType Directory -Force -Path (Join-Path $probeProfile 'AppData\Local'),(Join-Path $probeProfile 'AppData\Roaming') | Out-Null
$oldLocal = $env:LOCALAPPDATA; $oldApp = $env:APPDATA; $oldProfile = $env:USERPROFILE; $oldHome = $env:HOME
try {
  $env:LOCALAPPDATA = Join-Path $probeProfile 'AppData\Local'
  $env:APPDATA = Join-Path $probeProfile 'AppData\Roaming'
  $env:USERPROFILE = $probeProfile
  $env:HOME = $probeProfile
  Write-Output "PARENT_AFTER_ENV_SPECIAL=$([Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData))"
  $child = & powershell.exe -NoProfile -NonInteractive -Command '[Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData); $env:LOCALAPPDATA; $env:USERPROFILE'
  $child | ForEach-Object { Write-Output "CHILD_VALUE=$_" }
}
finally {
  $env:LOCALAPPDATA=$oldLocal; $env:APPDATA=$oldApp; $env:USERPROFILE=$oldProfile; $env:HOME=$oldHome
  Remove-Item -LiteralPath $probeProfile -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Output 'KNOWN_FOLDER_PROBE_END'

Write-Output 'STALE_TEMP_CLEANUP_BEGIN'
if (Test-Path -LiteralPath $staleTemp -PathType Container) {
  $full = [IO.Path]::GetFullPath($staleTemp)
  if ($full -cne 'C:\Stage3-Work\historical-temp-r1') { throw "Unexpected stale temp path: $full" }
  $reparse = @(Get-ChildItem -LiteralPath $staleTemp -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 })
  if ($reparse.Count -ne 0) { throw "Refusing stale temp cleanup with reparse points: $($reparse[0].FullName)" }
  for ($i=1; $i -le 20; $i++) {
    try { Remove-Item -LiteralPath $staleTemp -Recurse -Force -ErrorAction Stop; break }
    catch { if ($i -eq 20) { throw }; Start-Sleep -Milliseconds 500 }
  }
}
Write-Output "STALE_TEMP_REMAINS=$([bool](Test-Path -LiteralPath $staleTemp))"
Write-Output 'STALE_TEMP_CLEANUP_END'
