Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$installer = 'C:\Stage3-Work\artifacts\installer-v0.4.0-stage3-r1\rasoathopdong-setup-0.4.0.exe'
$publish = 'C:\Stage3-Work\artifacts\publish-v0.4.0-stage3'
$recoveryRoot = 'C:\Stage3-Work\install-smoke\v0.4.0-r1'
$installRoot = 'C:\Stage3-Work\install-smoke\v0.4.0-r2'
$logRoot = 'C:\Stage3-Work\logs\installer-lifecycle-r2'
$appIdKeyName = '{80FFBA2A-9310-4855-8DC1-C026B40AAF2D}_is1'
$webViewClient = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'

if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) { throw "Missing installer: $installer" }
if (-not (Test-Path -LiteralPath $publish -PathType Container)) { throw "Missing publish: $publish" }
if (Test-Path -LiteralPath $installRoot) { throw "Disposable r2 install root already exists: $installRoot" }
if (Test-Path -LiteralPath $logRoot) { throw "Disposable r2 log root already exists: $logRoot" }
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

function Get-ProductRegistryKeys {
  $paths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$appIdKeyName",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$appIdKeyName",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$appIdKeyName"
  )
  return @($paths | Where-Object { Test-Path -LiteralPath $_ })
}

function Start-And-Wait {
  param([string]$FilePath,[string[]]$Arguments,[string]$WorkingDirectory)
  $process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -WorkingDirectory $WorkingDirectory -PassThru -Wait
  try { return $process.ExitCode } finally { $process.Dispose() }
}

Write-Output 'R1_RECOVERY_BEGIN'
$setupProcesses = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like 'rasoathopdong-setup-*' -or $_.ProcessName -like 'unins*' })
Write-Output "R1_ACTIVE_SETUP_OR_UNINSTALL=$($setupProcesses.Count)"
if ($setupProcesses.Count -ne 0) {
  $deadline = [DateTimeOffset]::UtcNow.AddSeconds(30)
  while (@(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like 'rasoathopdong-setup-*' -or $_.ProcessName -like 'unins*' }).Count -ne 0 -and [DateTimeOffset]::UtcNow -lt $deadline) { Start-Sleep -Milliseconds 250 }
  if (@(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like 'rasoathopdong-setup-*' -or $_.ProcessName -like 'unins*' }).Count -ne 0) { throw 'Prior installer process is still active after bounded wait.' }
}
$r1Entries = @(Get-ProductRegistryKeys)
$r1App = Join-Path $recoveryRoot 'RasoatHopDong.App.exe'
$r1Uninstaller = Join-Path $recoveryRoot 'unins000.exe'
Write-Output "R1_REGISTRY_ENTRIES=$($r1Entries.Count) R1_ROOT_EXISTS=$([bool](Test-Path -LiteralPath $recoveryRoot)) R1_APP_EXISTS=$([bool](Test-Path -LiteralPath $r1App)) R1_UNINSTALLER_EXISTS=$([bool](Test-Path -LiteralPath $r1Uninstaller))"
if ($r1Entries.Count -gt 0 -or (Test-Path -LiteralPath $r1Uninstaller -PathType Leaf)) {
  if (-not (Test-Path -LiteralPath $r1Uninstaller -PathType Leaf)) { throw 'R1 is registered but its uninstaller is missing.' }
  $recoveryLog = Join-Path $logRoot 'recovery-r1-uninstall.log'
  $recoveryCode = Start-And-Wait -FilePath $r1Uninstaller -Arguments @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART',"/LOG=$recoveryLog") -WorkingDirectory $recoveryRoot
  Write-Output "R1_RECOVERY_UNINSTALL_EXIT=$recoveryCode"
  if ($recoveryCode -ne 0) { throw "R1 recovery uninstaller returned $recoveryCode" }
  Start-Sleep -Milliseconds 750
}
$r1EntriesAfter = @(Get-ProductRegistryKeys)
Write-Output "R1_REGISTRY_AFTER=$($r1EntriesAfter.Count) R1_APP_AFTER=$([bool](Test-Path -LiteralPath $r1App))"
if ($r1EntriesAfter.Count -ne 0 -or (Test-Path -LiteralPath $r1App)) { throw 'R1 recovery did not reach clean product state.' }
Write-Output 'R1_RECOVERY=PASS'
Write-Output 'R1_RECOVERY_END'

$webViewPaths = @(
  "HKLM:\Software\WOW6432Node\Microsoft\EdgeUpdate\Clients\$webViewClient",
  "HKCU:\Software\Microsoft\EdgeUpdate\Clients\$webViewClient"
)
$webViewVersion = $null
foreach ($path in $webViewPaths) {
  $props = Get-ItemProperty -LiteralPath $path -Name pv -ErrorAction SilentlyContinue
  $value = if ($null -ne $props) { $props.pv } else { $null }
  if (-not [string]::IsNullOrWhiteSpace([string]$value) -and [string]$value -ne '0.0.0.0') { $webViewVersion = [string]$value; Write-Output "WEBVIEW_INSTALLED_PATH=$path VERSION=$webViewVersion"; break }
}
if ([string]::IsNullOrWhiteSpace($webViewVersion)) { Write-Output 'INSTALLER_LIFECYCLE=NOT_RUN_WEBVIEW2_ABSENT'; exit 0 }
if (@(Get-ProductRegistryKeys).Count -ne 0) { throw 'Product registration exists after recovery; refusing r2 install.' }

$setupLog = Join-Path $logRoot 'setup-r2.log'
$uninstallLog = Join-Path $logRoot 'uninstall-r2.log'
Write-Output 'INSTALL_R2_BEGIN'
$installCode = Start-And-Wait -FilePath $installer -Arguments @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/NOICONS',"/DIR=$installRoot", "/LOG=$setupLog") -WorkingDirectory (Split-Path -Parent $installer)
Write-Output "INSTALL_R2_EXIT=$installCode"
if ($installCode -ne 0) { if (Test-Path $setupLog) { Get-Content $setupLog -Tail 120 }; throw "Installer r2 returned $installCode" }

$appInstalled = Join-Path $installRoot 'RasoatHopDong.App.exe'
$helperInstalled = Join-Path $installRoot 'RasoatHopDong.UpdateHelper.exe'
$uninstaller = Join-Path $installRoot 'unins000.exe'
foreach ($required in @($appInstalled,$helperInstalled,$uninstaller)) { if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Installed file missing: $required" } }
$appInstalledHash = (Get-FileHash -LiteralPath $appInstalled -Algorithm SHA256).Hash.ToLowerInvariant()
$appPublishHash = (Get-FileHash -LiteralPath (Join-Path $publish 'RasoatHopDong.App.exe') -Algorithm SHA256).Hash.ToLowerInvariant()
$helperInstalledHash = (Get-FileHash -LiteralPath $helperInstalled -Algorithm SHA256).Hash.ToLowerInvariant()
$helperPublishHash = (Get-FileHash -LiteralPath (Join-Path $publish 'RasoatHopDong.UpdateHelper.exe') -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Output "APP_HASH_MATCH=$([bool]($appInstalledHash -ceq $appPublishHash)) SHA256=$appInstalledHash"
Write-Output "HELPER_HASH_MATCH=$([bool]($helperInstalledHash -ceq $helperPublishHash)) SHA256=$helperInstalledHash"
if ($appInstalledHash -cne $appPublishHash -or $helperInstalledHash -cne $helperPublishHash) { throw 'Installed executable hash does not match validated publish.' }
$postInstallEntries = @(Get-ProductRegistryKeys)
Write-Output "POST_INSTALL_PRODUCT_ENTRIES=$($postInstallEntries.Count)"
if ($postInstallEntries.Count -ne 1) { throw "Expected one uninstall registration after install; found $($postInstallEntries.Count)." }
Write-Output 'INSTALL_R2_VALIDATED=PASS'

Write-Output 'UNINSTALL_R2_BEGIN'
$uninstallCode = Start-And-Wait -FilePath $uninstaller -Arguments @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART',"/LOG=$uninstallLog") -WorkingDirectory $installRoot
Write-Output "UNINSTALL_R2_EXIT=$uninstallCode"
if ($uninstallCode -ne 0) { if (Test-Path $uninstallLog) { Get-Content $uninstallLog -Tail 120 }; throw "Uninstaller r2 returned $uninstallCode" }
Start-Sleep -Milliseconds 750
$postUninstallEntries = @(Get-ProductRegistryKeys)
Write-Output "POST_UNINSTALL_PRODUCT_ENTRIES=$($postUninstallEntries.Count)"
Write-Output "APP_REMAINS=$([bool](Test-Path -LiteralPath $appInstalled)) HELPER_REMAINS=$([bool](Test-Path -LiteralPath $helperInstalled))"
if ($postUninstallEntries.Count -ne 0 -or (Test-Path -LiteralPath $appInstalled) -or (Test-Path -LiteralPath $helperInstalled)) { throw 'Uninstall r2 did not fully remove product registration/files.' }
Write-Output 'UNINSTALL_R2_VALIDATED=PASS'
Write-Output 'STAGE3_INSTALLER_LIFECYCLE=PASS'
