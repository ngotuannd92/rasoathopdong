Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$baseline = 'D:\rasoathopdong-v0.2.8-stage7-criteria-validation-implementation-r3.zip'
$expectedBaselineHash = '81bcd973cbbc8f48e16fb3b19d3d24de31422ff23baf21bf09497a1ddd93a7d6'
$tempRoot = 'C:\Stage3-Work\historical-temp-r1'

if (-not (Test-Path -LiteralPath $baseline -PathType Leaf)) { throw "Missing baseline: $baseline" }
if (Test-Path -LiteralPath $tempRoot) { throw "Owned historical temp already exists: $tempRoot" }
$actual = (Get-FileHash -LiteralPath $baseline -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Output "BASELINE_SHA256=$actual MATCH=$([bool]($actual -ceq $expectedBaselineHash))"
if ($actual -cne $expectedBaselineHash) { throw 'Historical baseline hash mismatch.' }
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

$oldTemp = $env:TEMP
$oldTmp = $env:TMP
$oldPath = $env:PATH
try {
  $env:TEMP = $tempRoot
  $env:TMP = $tempRoot
  $env:PATH = 'C:\Stage3-Work\pyenv\Scripts;' + $env:PATH
  $env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
  Write-Output "IDENTITY=$([Security.Principal.WindowsIdentity]::GetCurrent().Name) SESSION=$((Get-Process -Id $PID).SessionId)"
  Write-Output "TEMP=$env:TEMP TMP=$env:TMP DOTNET_TEMP=$([IO.Path]::GetTempPath())"
  Push-Location $source
  try {
    Write-Output 'HISTORICAL_BASELINE_BEGIN'
    $script = Join-Path $source 'scripts\verify-historical-baseline.ps1'
    & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $script -BaselineZipPath $baseline
    $code = $LASTEXITCODE
    Write-Output "HISTORICAL_VERIFIER_EXIT=$code"
    if ($code -ne 0) { throw "Historical verifier failed with exit code $code" }
    Write-Output 'STAGE0_TO_STAGE7_HISTORICAL=PASS'
    Write-Output 'HISTORICAL_BASELINE_END'
  }
  finally { Pop-Location }
}
finally {
  $env:TEMP = $oldTemp
  $env:TMP = $oldTmp
  $env:PATH = $oldPath
  if (Test-Path -LiteralPath $tempRoot -PathType Container) {
    $full = [IO.Path]::GetFullPath($tempRoot)
    if (-not $full.StartsWith('C:\Stage3-Work\historical-temp-', [StringComparison]::OrdinalIgnoreCase)) { throw "Refusing unexpected temp cleanup: $full" }
    Get-ChildItem -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 } | ForEach-Object { throw "Refusing reparse point cleanup: $($_.FullName)" }
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}
