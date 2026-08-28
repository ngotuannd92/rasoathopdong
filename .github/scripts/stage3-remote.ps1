Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
Push-Location $source
try {
  $head = (git rev-parse HEAD).Trim()
  Write-Output "SOURCE_HEAD=$head"
  Write-Output 'RELEVANT_FILES_BEGIN'
  Get-ChildItem .\docs\criteria-rebuild-phase2,.\tests -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'golden|compare|corpus|ocr|scan|pdf|docx|semantic|runtime' } |
    Sort-Object FullName |
    ForEach-Object { "{0}|{1}" -f $_.FullName,$_.Length }
  Write-Output 'RELEVANT_FILES_END'

  Write-Output 'MANIFEST_CANDIDATES_BEGIN'
  Get-ChildItem .\docs\criteria-rebuild-phase2 -Recurse -File -Filter *.json -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'golden|compare|semantic|corpus' } |
    Sort-Object FullName |
    ForEach-Object {
      Write-Output "FILE=$($_.FullName) SIZE=$($_.Length)"
      if ($_.Length -le 200000) {
        Write-Output 'CONTENT_BEGIN'
        Get-Content -LiteralPath $_.FullName -Raw
        Write-Output 'CONTENT_END'
      }
    }
  Write-Output 'MANIFEST_CANDIDATES_END'

  Write-Output 'PRODUCTION_DOC_TEST_REFERENCES_BEGIN'
  Get-ChildItem .\tests\RasoatHopDong.Tests -File -Filter *.cs |
    Select-String -Pattern 'Golden|CompareCorpus|Read_ShouldRecognizeRealVietnameseScanOnWindows|ReviewContract_ShouldRunFromPdfToReviewResult|ProductionCompare_ShouldCompareTwoRealPdfFilesWithSharedBaseCriteria|WorkingSetCandidates_ReviewGolden_ShouldCoverDocxPdfTextAndOcrWithProductionPipeline' |
    ForEach-Object { "{0}:{1}:{2}" -f $_.Path,$_.LineNumber,$_.Line.Trim() }
  Write-Output 'PRODUCTION_DOC_TEST_REFERENCES_END'
}
finally { Pop-Location }
