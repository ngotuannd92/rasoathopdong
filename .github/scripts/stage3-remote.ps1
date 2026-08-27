Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$installer = 'C:\Stage3-Work\artifacts\installer-v0.4.0-stage3-r1\rasoathopdong-setup-0.4.0.exe'
$publish = 'C:\Stage3-Work\artifacts\publish-v0.4.0-stage3'
$installRoot = 'C:\Stage3-Work\install-smoke\v0.4.0-r1'
$logRoot = 'C:\Stage3-Work\logs\installer-lifecycle-r1'
$uninstallDisplay = 'Rà soát hợp đồng'
$webViewClient = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'

if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) { throw "Missing installer: $installer" }
if (-not (Test-Path -LiteralPath $publish -PathType Container)) { throw "Missing publish: $publish" }
if (Test-Path -LiteralPath $installRoot) { throw "Disposable install root already exists: $installRoot" }
if (Test-Path -LiteralPath $logRoot) { throw "Disposable log root already exists: $logRoot" }
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

function Get-InstalledProductEntries {
  $roots = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )
  return @(
    foreach ($root in $roots) {
      Get-ItemProperty -Path $root -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq $uninstallDisplay }
    }
  )
}

$preExisting = @(Get-InstalledProductEntries)
Write-Output "PREEXISTING_PRODUCT_ENTRIES=$($preExisting.Count)"
if ($preExisting.Count -ne 0) {
  Write-Output 'INSTALLER_LIFECYCLE=NOT_RUN_PREEXISTING_PRODUCT'
  exit 0
}

$webViewPaths = @(
  "HKLM:\Software\WOW6432Node\Microsoft\EdgeUpdate\Clients\$webViewClient",
  "HKCU:\Software\Microsoft\EdgeUpdate\Clients\$webViewClient"
)
$webViewVersion = $null
foreach ($path in $webViewPaths) {
  $value = (Get-ItemProperty -LiteralPath $path -Name pv -ErrorAction SilentlyContinue).pv
  if (-not [string]::IsNullOrWhiteSpace([string]$value) -and [string]$value -ne '0.0.0.0') {
    $webViewVersion = [string]$value
    Write-Output "WEBVIEW_INSTALLED_PATH=$path VERSION=$webViewVersion"
    break
  }
}
if ([string]::IsNullOrWhiteSpace($webViewVersion)) {
  Write-Output 'INSTALLER_LIFECYCLE=NOT_RUN_WEBVIEW2_ABSENT'
  exit 0
}

$setupLog = Join-Path $logRoot 'setup.log'
$uninstallLog = Join-Path $logRoot 'uninstall.log'
Write-Output 'INSTALL_BEGIN'
& $installer '/VERYSILENT' '/SUPPRESSMSGBOXES' '/NORESTART' '/NOICONS' "/DIR=$installRoot" "/LOG=$setupLog"
$installCode = $LASTEXITCODE
Write-Output "INSTALL_EXIT=$installCode"
if ($installCode -ne 0) { if (Test-Path $setupLog) { Get-Content $setupLog -Tail 120 }; throw "Installer returned $installCode" }

$appInstalled = Join-Path $installRoot 'RasoatHopDong.App.exe'
$helperInstalled = Join-Path $installRoot 'RasoatHopDong.UpdateHelper.exe'
$uninstaller = Join-Path $installRoot 'unins000.exe'
foreach ($required in @($appInstalled,$helperInstalled,$uninstaller)) {
  if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Installed file missing: $required" }
}
$appInstalledHash = (Get-FileHash -LiteralPath $appInstalled -Algorithm SHA256).Hash.ToLowerInvariant()
$appPublishHash = (Get-FileHash -LiteralPath (Join-Path $publish 'RasoatHopDong.App.exe') -Algorithm SHA256).Hash.ToLowerInvariant()
$helperInstalledHash = (Get-FileHash -LiteralPath $helperInstalled -Algorithm SHA256).Hash.ToLowerInvariant()
$helperPublishHash = (Get-FileHash -LiteralPath (Join-Path $publish 'RasoatHopDong.UpdateHelper.exe') -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Output "APP_HASH_MATCH=$([bool]($appInstalledHash -ceq $appPublishHash)) SHA256=$appInstalledHash"
Write-Output "HELPER_HASH_MATCH=$([bool]($helperInstalledHash -ceq $helperPublishHash)) SHA256=$helperInstalledHash"
if ($appInstalledHash -cne $appPublishHash -or $helperInstalledHash -cne $helperPublishHash) { throw 'Installed executable hash does not match validated publish.' }
$postInstallEntries = @(Get-InstalledProductEntries)
Write-Output "POST_INSTALL_PRODUCT_ENTRIES=$($postInstallEntries.Count)"
if ($postInstallEntries.Count -ne 1) { throw "Expected one uninstall registration after install; found $($postInstallEntries.Count)." }
Write-Output 'INSTALL_VALIDATED=PASS'

Write-Output 'UNINSTALL_BEGIN'
& $uninstaller '/VERYSILENT' '/SUPPRESSMSGBOXES' '/NORESTART' "/LOG=$uninstallLog"
$uninstallCode = $LASTEXITCODE
Write-Output "UNINSTALL_EXIT=$uninstallCode"
if ($uninstallCode -ne 0) { if (Test-Path $uninstallLog) { Get-Content $uninstallLog -Tail 120 }; throw "Uninstaller returned $uninstallCode" }
Start-Sleep -Milliseconds 750
$postUninstallEntries = @(Get-InstalledProductEntries)
Write-Output "POST_UNINSTALL_PRODUCT_ENTRIES=$($postUninstallEntries.Count)"
Write-Output "APP_REMAINS=$([bool](Test-Path -LiteralPath $appInstalled))"
Write-Output "HELPER_REMAINS=$([bool](Test-Path -LiteralPath $helperInstalled))"
if ($postUninstallEntries.Count -ne 0 -or (Test-Path -LiteralPath $appInstalled) -or (Test-Path -LiteralPath $helperInstalled)) { throw 'Uninstall did not fully remove product registration/files.' }
Write-Output 'UNINSTALL_VALIDATED=PASS'
Write-Output 'STAGE3_INSTALLER_LIFECYCLE=PASS'
