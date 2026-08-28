Set-StrictMode -Version Latest
$ErrorActionPreference='Continue'
Write-Output 'STAGE3_DIAG_BEGIN'
$src='C:\Stage3-Work\source-current'
Set-Location -LiteralPath $src
Write-Output ("SOURCE_HEAD=" + (git rev-parse HEAD).Trim())
Write-Output ("SOURCE_STATUS_COUNT=" + @((git status --porcelain)).Count)
Write-Output 'PROCESSES_BEGIN'
Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match 'tunnel-client|node|dotnet|powershell' } | Sort-Object ProcessName,Id | ForEach-Object { Write-Output ("PROC="+$_.ProcessName+"|"+$_.Id+"|"+$_.StartTime.ToString('o')) }
Write-Output 'PROCESSES_END'
try { $r=Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:8080/readyz' -TimeoutSec 5; Write-Output ("TUNNEL_READYZ="+[int]$r.StatusCode) } catch { Write-Output ("TUNNEL_READYZ_ERROR="+$_.Exception.Message) }
$base='C:\Stage3-Work\corpus\784-stage3\baseline'
$service=Join-Path $base 'SERVICE'
$log=Join-Path $base 'service-console.log'
Write-Output ("SERVICE_DIR_EXISTS="+(Test-Path -LiteralPath $service))
if(Test-Path -LiteralPath $service){
  Write-Output ("SERVICE_RESULT_JSON_COUNT="+@(Get-ChildItem -LiteralPath $service -Recurse -File -Filter '*.result.json' -ErrorAction SilentlyContinue).Count)
  $rr=Join-Path $service 'stage3-run-result.json'; Write-Output ("SERVICE_RUN_RESULT_EXISTS="+(Test-Path -LiteralPath $rr)); if(Test-Path -LiteralPath $rr){ Get-Content -LiteralPath $rr -Raw | Write-Output }
}
Write-Output ("SERVICE_LOG_EXISTS="+(Test-Path -LiteralPath $log))
if(Test-Path -LiteralPath $log){ Write-Output 'SERVICE_LOG_TAIL_BEGIN'; Get-Content -LiteralPath $log -Tail 80; Write-Output 'SERVICE_LOG_TAIL_END' }
Write-Output 'STAGE3_DIAG_END'