Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$exactStage7 = 'rasoathopdong-v0.2.8-stage7-criteria-validation-implementation-r3.zip'
$exactStage7Hash = '81bcd973cbbc8f48e16fb3b19d3d24de31422ff23baf21bf09497a1ddd93a7d6'
$exactPhase1 = 'rasoathopdong-v0.4.0-phase1-final-closed-r13(20260818-173343).zip'
$exactPhase1Hash = '9eff2eebdfbb2f4fe786a6443606f9d1fb136293db89bae02199445848e2e39b'

Write-Output 'SESSION_DIAGNOSTICS_BEGIN'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$current = Get-Process -Id $PID
Write-Output "IDENTITY=$identity POWERSHELL_SESSION_ID=$($current.SessionId) USERNAME=$env:USERNAME USERPROFILE=$env:USERPROFILE"
Write-Output 'QUSER_BEGIN'
$old = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& quser.exe 2>&1 | ForEach-Object { Write-Output $_ }
Write-Output "QUSER_EXIT=$LASTEXITCODE"
Write-Output 'QUSER_END'
Write-Output 'EXPLORER_SESSIONS_BEGIN'
Get-Process explorer -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "EXPLORER_PID=$($_.Id) SESSION=$($_.SessionId)" }
Write-Output 'EXPLORER_SESSIONS_END'
$ErrorActionPreference = $old
Write-Output 'SESSION_DIAGNOSTICS_END'

Write-Output 'DRIVES_BEGIN'
Get-PSDrive -PSProvider FileSystem | ForEach-Object { Write-Output "DRIVE=$($_.Root) FREE=$($_.Free) USED=$($_.Used)" }
Write-Output 'DRIVES_END'

Write-Output 'BASELINE_SEARCH_BEGIN'
$roots = New-Object System.Collections.Generic.List[string]
foreach ($candidate in @('C:\Stage3-Work','C:\actions-runner','C:\Users','C:\Windows\ServiceProfiles','C:\Temp','C:\tmp')) {
  if (Test-Path -LiteralPath $candidate -PathType Container) { $roots.Add($candidate) }
}
foreach ($drive in Get-PSDrive -PSProvider FileSystem) {
  if ($drive.Root -and $drive.Root -ne 'C:\') { $roots.Add($drive.Root) }
}
$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$matches = New-Object System.Collections.Generic.List[object]
foreach ($root in $roots) {
  if (-not $seen.Add($root)) { continue }
  Write-Output "SEARCH_ROOT=$root"
  foreach ($name in @($exactStage7,$exactPhase1)) {
    Get-ChildItem -LiteralPath $root -Recurse -File -Filter $name -ErrorAction SilentlyContinue | ForEach-Object { $matches.Add($_) }
  }
}
if ($matches.Count -eq 0) {
  Write-Output 'EXACT_BASELINE_FILES_FOUND=0'
} else {
  foreach ($file in $matches) {
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $expected = if ($file.Name -ceq $exactStage7) { $exactStage7Hash } elseif ($file.Name -ceq $exactPhase1) { $exactPhase1Hash } else { '' }
    Write-Output "BASELINE_FILE=$($file.FullName) SIZE=$($file.Length) SHA256=$hash EXPECTED=$expected MATCH=$([bool]($hash -ceq $expected))"
  }
}
Write-Output 'BASELINE_SEARCH_END'

Write-Output 'HISTORICAL_CANDIDATE_NAMES_BEGIN'
foreach ($root in $roots) {
  Get-ChildItem -LiteralPath $root -Recurse -File -Include '*.zip' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'rasoathopdong.*(stage7|phase1|0\.2\.8|0\.2\.0|criteria-validation)' } |
    Select-Object -First 100 |
    ForEach-Object { Write-Output "CANDIDATE=$($_.FullName) SIZE=$($_.Length)" }
}
Write-Output 'HISTORICAL_CANDIDATE_NAMES_END'
