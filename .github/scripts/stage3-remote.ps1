Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$artifactRoot = 'C:\Stage3-Work\artifacts'
$publish = Join-Path $artifactRoot 'publish-v0.4.0-stage3'
New-Item -ItemType Directory -Force -Path $artifactRoot | Out-Null
Push-Location $source
try {
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim()) BRANCH=$((git branch --show-current).Trim())"
  Write-Output 'PUBLISH_BEGIN'
  $publishScript = Join-Path $source 'scripts\publish-win-x64.ps1'
  & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $publishScript -OutputPath $publish
  $code = $LASTEXITCODE
  Write-Output "PUBLISH_SCRIPT_EXIT=$code"
  if ($code -ne 0) { throw "publish-win-x64 failed with exit code $code" }
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
  foreach ($asset in @('coreclr.dll','hostfxr.dll','hostpolicy.dll','e_sqlite3.dll','WebView2Loader.dll','pdfium.dll','libSkiaSharp.dll','x64\tesseract55.dll','x64\leptonica-1.85.0.dll')) {
    $hit = Get-ChildItem -LiteralPath $publish -Recurse -File -Force | Where-Object { $_.FullName.EndsWith($asset, [StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1
    Write-Output "ASSET=$asset PRESENT=$([bool]($null -ne $hit))"
  }
  Write-Output 'PUBLISH_VALIDATED=PASS'
  Write-Output 'PUBLISH_END'
}
finally { Pop-Location }
