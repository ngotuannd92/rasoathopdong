Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
Write-Output "MACHINE=$env:COMPUTERNAME"
Write-Output "NOW=$([DateTime]::UtcNow.ToString('o'))"
Write-Output 'TUNNEL_PROCESS_BEGIN'
Get-CimInstance Win32_Process -Filter "Name='tunnel-client.exe'" -ErrorAction SilentlyContinue | ForEach-Object {
  "PID={0} CMD={1}" -f $_.ProcessId,$_.CommandLine
}
Write-Output 'TUNNEL_PROCESS_END'
$profile = Join-Path $env:APPDATA 'tunnel-client\stage3-win11.yaml'
Write-Output "PROFILE_EXISTS=$(Test-Path -LiteralPath $profile)"
if (Test-Path -LiteralPath $profile) {
  Write-Output 'PROFILE_BEGIN'
  Get-Content -LiteralPath $profile
  Write-Output 'PROFILE_END'
}
Write-Output 'MCP_SERVER_FILE_BEGIN'
$server='C:\Stage3-Work\mcp-stage3\server\index.mjs'
Write-Output "SERVER_EXISTS=$(Test-Path -LiteralPath $server)"
if (Test-Path -LiteralPath $server) { Write-Output "SERVER_SHA256=$((Get-FileHash -LiteralPath $server -Algorithm SHA256).Hash.ToLowerInvariant())" }
Write-Output 'MCP_SERVER_FILE_END'
Write-Output 'NETWORK_BEGIN'
try { $r=Invoke-WebRequest -Uri 'https://api.openai.com/v1/models' -Method Head -UseBasicParsing -TimeoutSec 15; Write-Output "OPENAI_HTTP=$($r.StatusCode)" } catch { if ($_.Exception.Response) { Write-Output "OPENAI_HTTP=$([int]$_.Exception.Response.StatusCode)" } else { Write-Output "OPENAI_ERR=$($_.Exception.Message)" } }
Write-Output 'NETWORK_END'
Write-Output 'RUNNER_DONE'