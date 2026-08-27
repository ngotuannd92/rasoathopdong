Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = 'C:\Stage3-Work\source-current'
$logRoot = 'C:\Stage3-Work\logs\stage3-pdf-ocr'
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
Push-Location $source
try {
  function Run-Test([string]$name,[string]$config,[string]$filter) {
    $log = Join-Path $logRoot ($name + '-' + $config.ToLowerInvariant() + '.log')
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    dotnet test .\tests\RasoatHopDong.Tests\RasoatHopDong.Tests.csproj -c $config --no-build --no-restore --nologo --filter $filter --logger 'console;verbosity=minimal' *> $log
    $code = $LASTEXITCODE
    $ErrorActionPreference = $old
    Write-Output "GATE=$name CONFIG=$config EXIT=$code"
    Get-Content $log | Where-Object { $_ -match 'Passed!|Failed!|Total tests:|Skipped:' } | Select-Object -Last 8
    if ($code -ne 0) { Get-Content $log -Tail 120; throw "$name $config failed." }
  }
  Write-Output "SOURCE_HEAD=$((git rev-parse HEAD).Trim())"
  $ocr = 'FullyQualifiedName~PdfDocumentReaderTests.Read_ShouldRecognizeRealVietnameseScanOnWindows|FullyQualifiedName~Stage2CandidateRuntimeGateTests.WorkingSetCandidates_ReviewGolden_ShouldCoverDocxPdfTextAndOcrWithProductionPipeline'
  $pdf = 'FullyQualifiedName~PdfDocumentReaderTests.Read_ShouldExtractTextFromSimpleTextPdfWithoutCallingOcr|FullyQualifiedName~ReviewServiceTests.ReviewContract_ShouldRunFromPdfToReviewResult|FullyQualifiedName~Stage8CompareServiceIntegrationTests.ProductionCompare_ShouldCompareTwoRealPdfFilesWithSharedBaseCriteria'
  Run-Test 'ocr-real-runtime' 'Debug' $ocr
  Run-Test 'ocr-real-runtime' 'Release' $ocr
  Run-Test 'pdf-production-runtime' 'Debug' $pdf
  Run-Test 'pdf-production-runtime' 'Release' $pdf
  Write-Output 'STAGE3_PDF_OCR_RUNTIME=PASS'
}
finally { Pop-Location }
