Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$baseline = 'D:\rasoathopdong-v0.2.8-stage7-criteria-validation-implementation-r3.zip'
$expectedBaselineHash = '81bcd973cbbc8f48e16fb3b19d3d24de31422ff23baf21bf09497a1ddd93a7d6'
$tempRoot = 'C:\Stage3-Work\historical-temp-r2'
$profileRoot = 'C:\Stage3-Work\historical-profile-r2'

foreach ($path in @($tempRoot,$profileRoot)) { if (Test-Path -LiteralPath $path) { throw "Owned test path already exists: $path" } }
if (-not (Test-Path -LiteralPath $baseline -PathType Leaf)) { throw "Missing baseline: $baseline" }
$actual = (Get-FileHash -LiteralPath $baseline -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Output "BASELINE_SHA256=$actual MATCH=$([bool]($actual -ceq $expectedBaselineHash))"
if ($actual -cne $expectedBaselineHash) { throw 'Historical baseline hash mismatch.' }
New-Item -ItemType Directory -Force -Path $tempRoot,(Join-Path $profileRoot 'AppData\Local'),(Join-Path $profileRoot 'AppData\Roaming'),(Join-Path $profileRoot '.dotnet') | Out-Null

$names = @('TEMP','TMP','LOCALAPPDATA','APPDATA','USERPROFILE','HOME','DOTNET_CLI_HOME','PATH')
$old = @{}
foreach ($name in $names) { $old[$name] = [Environment]::GetEnvironmentVariable($name,'Process') }
try {
  $env:TEMP = $tempRoot
  $env:TMP = $tempRoot
  $env:LOCALAPPDATA = Join-Path $profileRoot 'AppData\Local'
  $env:APPDATA = Join-Path $profileRoot 'AppData\Roaming'
  $env:USERPROFILE = $profileRoot
  $env:HOME = $profileRoot
  $env:DOTNET_CLI_HOME = Join-Path $profileRoot '.dotnet'
  $env:PATH = 'C:\Stage3-Work\pyenv\Scripts;' + $env:PATH
  $env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
  $env:DOTNET_NOLOGO = '1'
  Write-Output "IDENTITY=$([Security.Principal.WindowsIdentity]::GetCurrent().Name) SESSION=$((Get-Process -Id $PID).SessionId)"
  Write-Output "PARENT_SPECIAL_LOCALAPPDATA=$([Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData))"
  $childFolders = & powershell.exe -NoProfile -NonInteractive -Command '[Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData); [IO.Path]::GetTempPath(); $env:USERPROFILE'
  $childFolders | ForEach-Object { Write-Output "CHILD_FOLDER=$_" }
  if ($childFolders[0] -cne $env:LOCALAPPDATA) { throw 'Child process LocalApplicationData did not relocate to the owned profile.' }

  Push-Location $source
  try {
    Write-Output 'HISTORICAL_BASELINE_R2_BEGIN'
    $script = Join-Path $source 'scripts\verify-historical-baseline.ps1'
    & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $script -BaselineZipPath $baseline
    $code = $LASTEXITCODE
    Write-Output "HISTORICAL_VERIFIER_EXIT=$code"
    if ($code -ne 0) { throw "Historical verifier failed with exit code $code" }
    Write-Output 'STAGE0_TO_STAGE7_HISTORICAL=PASS'
    Write-Output 'HISTORICAL_BASELINE_R2_END'
  }
  finally { Pop-Location }
}
finally {
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  dotnet build-server shutdown *> $null
  $ErrorActionPreference = $oldPreference
  Start-Sleep -Milliseconds 1000
  foreach ($name in $names) { [Environment]::SetEnvironmentVariable($name,$old[$name],'Process') }
  foreach ($path in @($tempRoot,$profileRoot)) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { continue }
    $full = [IO.Path]::GetFullPath($path)
    if (-not $full.StartsWith('C:\Stage3-Work\historical-', [StringComparison]::OrdinalIgnoreCase)) { throw "Refusing unexpected cleanup path: $full" }
    $reparse = @(Get-ChildItem -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 })
    if ($reparse.Count -ne 0) { throw "Refusing cleanup with reparse point: $($reparse[0].FullName)" }
    for ($i=1; $i -le 20; $i++) {
      try { Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop; break }
      catch { if ($i -eq 20) { Write-Warning "Owned test path could not be fully removed: $path :: $($_.Exception.Message)" }; Start-Sleep -Milliseconds 500 }
    }
    Write-Output "CLEANUP_PATH=$path REMAINS=$([bool](Test-Path -LiteralPath $path))"
  }
}
