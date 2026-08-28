Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
Write-Output "MACHINE=$env:COMPUTERNAME"
Write-Output "NOW=$([DateTime]::UtcNow.ToString('o'))"
foreach($u in @('http://127.0.0.1:8080/healthz','http://127.0.0.1:8080/readyz','http://127.0.0.1:8080/api/status','http://127.0.0.1:8080/api/system')) {
  Write-Output "URL_BEGIN=$u"
  try {
    $r=Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 10
    Write-Output "STATUS=$($r.StatusCode)"
    Write-Output $r.Content
  } catch {
    if ($_.Exception.Response) {
      Write-Output "STATUS=$([int]$_.Exception.Response.StatusCode)"
      try { $sr=New-Object IO.StreamReader($_.Exception.Response.GetResponseStream()); Write-Output $sr.ReadToEnd(); $sr.Dispose() } catch {}
    } else { Write-Output "ERR=$($_.Exception.Message)" }
  }
  Write-Output "URL_END=$u"
}
Write-Output 'DONE'