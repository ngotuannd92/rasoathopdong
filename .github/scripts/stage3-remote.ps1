Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
Push-Location $source
try {
  Write-Output 'OCR_TESTS_BEGIN'
  dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c Debug --no-build --no-restore --nologo --list-tests 2>&1 |
    Select-String -Pattern 'OCR|Ocr|Pdf|PDF|DocumentReader' | ForEach-Object { $_.Line.Trim() }
  Write-Output 'OCR_TESTS_END'
  Write-Output 'OCR_FILES_BEGIN'
  Get-ChildItem .\tests,.\docs\criteria-rebuild-phase2 -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'ocr|scan|pdf' } | Select-Object FullName,Length | Format-Table -AutoSize
  Write-Output 'OCR_FILES_END'
  Write-Output 'OCR_GOLDEN_ENTRIES_BEGIN'
  $manifest = Get-Content .\docs\criteria-rebuild-phase2\phase2-golden-manifest.json -Raw | ConvertFrom-Json
  $manifest.documents | Where-Object { $_.path -match '\.pdf$' -or $_.documentId -match 'ocr|scan|pdf' } | ConvertTo-Json -Depth 8
  Write-Output 'OCR_GOLDEN_ENTRIES_END'
}
finally { Pop-Location }
