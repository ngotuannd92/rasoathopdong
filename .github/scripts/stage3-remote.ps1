Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$installer = 'C:\Stage3-Work\artifacts\installer-v0.4.0-stage3-r1\rasoathopdong-setup-0.4.0.exe'
$publish = 'C:\Stage3-Work\artifacts\publish-v0.4.0-stage3'
$recoveryRoot = 'C:\Stage3-Work\install-smoke\v0.4.0-r1'
$installRoot = 'C:\Stage3-Work\install-smoke\v0.4.0-r3'
$logRoot = 'C:\Stage3-Work\logs\installer-lifecycle-r3'
$r1LogRoot = 'C:\Stage3-Work\logs\installer-lifecycle-r1'
$appIdKeyName = '{80FFBA2A-9310-4855-8DC1-C026B40AAF2D}_is1'
$webViewClient = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'

if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) { throw "Missing installer: $installer" }
if (-not (Test-Path -LiteralPath $publish -PathType Container)) { throw "Missing publish: $publish" }
if (Test-Path -LiteralPath $installRoot) { throw "Disposable r3 install root already exists: $installRoot" }
if (Test-Path -LiteralPath $logRoot) { throw "Disposable r3 log root already exists: $logRoot" }
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

Write-Output 'R1_PARTIAL_RECOVERY_BEGIN'
$active = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like 'rasoathopdong-setup-*' -or $_.ProcessName -like 'unins*' })
Write-Output "R1_ACTIVE_SETUP_OR_UNINSTALL=$($active.Count)"
if ($active.Count -ne 0) { throw 'Refusing cleanup while setup or uninstaller is active.' }
$r1Entries = @(Get-ProductRegistryKeys)
$r1App = Join-Path $recoveryRoot 'RasoatHopDong.App.exe'
Write-Output "R1_REGISTRY_ENTRIES=$($r1Entries.Count) R1_ROOT_EXISTS=$([bool](Test-Path -LiteralPath $recoveryRoot)) R1_APP_EXISTS=$([bool](Test-Path -LiteralPath $r1App))"
if ($r1Entries.Count -ne 0 -or (Test-Path -LiteralPath $r1App)) { throw 'R1 is not a safe partial-install cleanup candidate.' }
if (Test-Path -LiteralPath $recoveryRoot -PathType Container) {
  $rootFull = [IO.Path]::GetFullPath($recoveryRoot).TrimEnd('\') + '\'
  $items = @(Get-ChildItem -LiteralPath $recoveryRoot -Recurse -Force -ErrorAction Stop)
  Write-Output "R1_PARTIAL_ITEMS=$($items.Count)"
  foreach ($item in $items | Select-Object -First 120) {
    $full = [IO.Path]::GetFullPath($item.FullName)
    if (-not $full.StartsWith($rootFull,[StringComparison]::OrdinalIgnoreCase)) { throw "Unexpected recovery path: $full" }
    if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Refusing to delete reparse point: $full" }
    if ($item.PSIsContainer) { Write-Output "R1_DIR=$full" } else { Write-Output "R1_FILE=$full SIZE=$($item.Length)" }
  }
  $setupLog = Join-Path $r1LogRoot 'setup.log'
  if (Test-Path -LiteralPath $setupLog -PathType Leaf) {
    Write-Output 'R1_SETUP_LOG_TAIL_BEGIN'
    Get-Content -LiteralPath $setupLog -Tail 80
    Write-Output 'R1_SETUP_LOG_TAIL_END'
  }
  Remove-Item -LiteralPath $recoveryRoot -Recurse -Force
}
Write-Output "R1_ROOT_AFTER_CLEANUP=$([bool](Test-Path -LiteralPath $recoveryRoot))"
if (Test-Path -LiteralPath $recoveryRoot) { throw 'R1 owned partial root could not be removed.' }
if (@(Get-ProductRegistryKeys).Count -ne 0) { throw 'Product registration appeared during R1 cleanup.' }
Write-Output 'R1_PARTIAL_RECOVERY=PASS'
Write-Output 'R1_PARTIAL_RECOVERY_END'

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
if (@(Get-ProductRegistryKeys).Count -ne 0) { throw 'Product registration exists before r3 install.' }

$setupLogR3 = Join-Path $logRoot 'setup-r3.log'
$uninstallLogR3 = Join-Path $logRoot 'uninstall-r3.log'
Write-Output 'INSTALL_R3_BEGIN'
$installCode = Start-And-Wait -FilePath $installer -Arguments @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/NOICONS',"/DIR=$installRoot", "/LOG=$setupLogR3") -WorkingDirectory (Split-Path -Parent $installer)
Write-Output "INSTALL_R3_EXIT=$installCode"
if ($installCode -ne 0) { if (Test-Path $setupLogR3) { Get-Content $setupLogR3 -Tail 120 }; throw "Installer r3 returned $installCode" }

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
Write-Output 'INSTALL_R3_VALIDATED=PASS'

Write-Output 'UNINSTALL_R3_BEGIN'
$uninstallCode = Start-And-Wait -FilePath $uninstaller -Arguments @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART',"/LOG=$uninstallLogR3") -WorkingDirectory $installRoot
Write-Output "UNINSTALL_R3_EXIT=$uninstallCode"
if ($uninstallCode -ne 0) { if (Test-Path $uninstallLogR3) { Get-Content $uninstallLogR3 -Tail 120 }; throw "Uninstaller r3 returned $uninstallCode" }
Start-Sleep -Milliseconds 1000
$postUninstallEntries = @(Get-ProductRegistryKeys)
Write-Output "POST_UNINSTALL_PRODUCT_ENTRIES=$($postUninstallEntries.Count)"
Write-Output "APP_REMAINS=$([bool](Test-Path -LiteralPath $appInstalled)) HELPER_REMAINS=$([bool](Test-Path -LiteralPath $helperInstalled))"
if ($postUninstallEntries.Count -ne 0 -or (Test-Path -LiteralPath $appInstalled) -or (Test-Path -LiteralPath $helperInstalled)) { throw 'Uninstall r3 did not fully remove product registration/files.' }
Write-Output 'UNINSTALL_R3_VALIDATED=PASS'
Write-Output 'STAGE3_INSTALLER_LIFECYCLE=PASS'
