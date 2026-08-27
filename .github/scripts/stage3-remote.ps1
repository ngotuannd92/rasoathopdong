Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$publish = 'C:\Stage3-Work\artifacts\publish-v0.4.0-stage3'
$prereqDir = 'C:\Stage3-Work\prerequisites'
$webview = Join-Path $prereqDir 'MicrosoftEdgeWebView2RuntimeInstallerX64.exe'
$installerOut = 'C:\Stage3-Work\artifacts\installer-v0.4.0-stage3-r1'
New-Item -ItemType Directory -Force -Path $prereqDir | Out-Null
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  if (-not (Test-Path -LiteralPath $publish -PathType Container)) { throw "Missing validated publish: $publish" }
  Write-Output 'WEBVIEW_DOWNLOAD_BEGIN'
  $tmp = Join-Path $prereqDir ('webview-' + [guid]::NewGuid().ToString('N') + '.tmp')
  try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -UseBasicParsing -Uri 'https://go.microsoft.com/fwlink/?linkid=2124701' -OutFile $tmp
    if ((Get-Item -LiteralPath $tmp).Length -le 0) { throw 'Downloaded WebView2 installer is empty.' }
    Move-Item -LiteralPath $tmp -Destination $webview -Force
  }
  finally { if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force } }
  $wvFile = Get-Item -LiteralPath $webview
  $wvSig = Get-AuthenticodeSignature -LiteralPath $webview
  $wvInfo = [Diagnostics.FileVersionInfo]::GetVersionInfo($webview)
  $wvSigner = if ($null -ne $wvSig.SignerCertificate) { $wvSig.SignerCertificate.GetNameInfo([Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $false) } else { '' }
  Write-Output "WEBVIEW_BYTES=$($wvFile.Length)"
  Write-Output "WEBVIEW_SHA256=$((Get-FileHash -LiteralPath $webview -Algorithm SHA256).Hash.ToLowerInvariant())"
  Write-Output "WEBVIEW_SIGNATURE=$($wvSig.Status) SIGNER=$wvSigner"
  Write-Output "WEBVIEW_FILEVERSION=$($wvInfo.FileVersion) PRODUCTVERSION=$($wvInfo.ProductVersion)"
  if ($wvSig.Status.ToString() -cne 'Valid' -or $wvSigner -cne 'Microsoft Corporation') { throw 'Downloaded WebView2 installer failed Microsoft signature validation.' }
  Write-Output 'WEBVIEW_DOWNLOAD_VALIDATED=PASS'
  Write-Output 'WEBVIEW_DOWNLOAD_END'

  if (Test-Path -LiteralPath $installerOut) { throw "Installer output path already exists; refusing to overwrite: $installerOut" }
  Write-Output 'INSTALLER_BUILD_BEGIN'
  $buildScript = Join-Path $source 'scripts\build-installer.ps1'
  & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $buildScript -PublishPath $publish -OutputDirectory $installerOut -WebView2RuntimeInstallerPath $webview
  $code = $LASTEXITCODE
  Write-Output "INSTALLER_SCRIPT_EXIT=$code"
  if ($code -ne 0) { throw "build-installer failed with exit code $code" }
  $items = @(Get-ChildItem -LiteralPath $installerOut -File -Force)
  if ($items.Count -ne 1) { throw "Expected exactly one installer output, found $($items.Count)." }
  $installer = $items[0]
  $info = [Diagnostics.FileVersionInfo]::GetVersionInfo($installer.FullName)
  $sig = Get-AuthenticodeSignature -LiteralPath $installer.FullName
  Write-Output "INSTALLER_PATH=$($installer.FullName)"
  Write-Output "INSTALLER_BYTES=$($installer.Length)"
  Write-Output "INSTALLER_SHA256=$((Get-FileHash -LiteralPath $installer.FullName -Algorithm SHA256).Hash.ToLowerInvariant())"
  Write-Output "INSTALLER_FILEVERSION=$($info.FileVersion) PRODUCTVERSION=$($info.ProductVersion)"
  Write-Output "INSTALLER_AUTHENTICODE=$($sig.Status)"
  Write-Output 'INSTALLER_VALIDATED=PASS'
  Write-Output 'INSTALLER_BUILD_END'
}
finally { Pop-Location }
