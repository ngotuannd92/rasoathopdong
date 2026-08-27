Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$artifactRoot = 'C:\Stage3-Work\artifacts'
$publish = Join-Path $artifactRoot 'publish-v0.4.0-stage3'
New-Item -ItemType Directory -Force -Path $artifactRoot | Out-Null
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  Write-Output 'PREREQ_INVENTORY_BEGIN'
  $roots = @('C:\Stage3-Work', "$env:USERPROFILE\Downloads", "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents") | Where-Object { Test-Path $_ } | Select-Object -Unique
  foreach ($root in $roots) {
    Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -in @('rasoathopdong-v0.2.8-stage7-criteria-validation-implementation-r3.zip','MicrosoftEdgeWebView2RuntimeInstallerX64.exe','ISCC.exe') } |
      ForEach-Object {
        $hash = if ($_.Extension -in @('.zip','.exe')) { (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant() } else { '' }
        Write-Output "FOUND=$($_.FullName) SIZE=$($_.Length) SHA256=$hash"
      }
  }
  foreach ($candidate in @(
    'C:\Program Files (x86)\Inno Setup 6\ISCC.exe',
    'C:\Program Files\Inno Setup 6\ISCC.exe',
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe")) {
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
      $info = [Diagnostics.FileVersionInfo]::GetVersionInfo($candidate)
      Write-Output "ISCC_CANDIDATE=$candidate FILEVERSION=$($info.FileVersion) PRODUCTVERSION=$($info.ProductVersion)"
    }
  }
  Write-Output 'PREREQ_INVENTORY_END'
  Write-Output 'PUBLISH_BEGIN'
  & .\scripts\publish-win-x64.ps1 -OutputPath $publish
  if ($LASTEXITCODE -ne 0) { throw "publish-win-x64 failed with exit code $LASTEXITCODE" }
  $files = @(Get-ChildItem -LiteralPath $publish -Recurse -File -Force)
  $bytes = ($files | Measure-Object -Property Length -Sum).Sum
  $exe = Join-Path $publish 'RasoatHopDong.App.exe'
  $helper = Join-Path $publish 'RasoatHopDong.UpdateHelper.exe'
  $info = [Diagnostics.FileVersionInfo]::GetVersionInfo($exe)
  Write-Output "PUBLISH_PATH=$publish"
  Write-Output "PUBLISH_FILES=$($files.Count) PUBLISH_BYTES=$bytes"
  Write-Output "APP_FILEVERSION=$($info.FileVersion) APP_PRODUCTVERSION=$($info.ProductVersion)"
  Write-Output "APP_SHA256=$((Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash.ToLowerInvariant())"
  Write-Output "HELPER_SHA256=$((Get-FileHash -LiteralPath $helper -Algorithm SHA256).Hash.ToLowerInvariant())"
  Write-Output "OCR_VIE_BYTES=$((Get-Item (Join-Path $publish 'Ocr\tessdata\vie.traineddata')).Length)"
  Write-Output "OCR_ENG_BYTES=$((Get-Item (Join-Path $publish 'Ocr\tessdata\eng.traineddata')).Length)"
  Write-Output 'PUBLISH_VALIDATED=PASS'
  Write-Output 'PUBLISH_END'
}
finally { Pop-Location }
