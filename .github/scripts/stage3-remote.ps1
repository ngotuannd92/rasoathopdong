Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
Write-Output "MACHINE=$env:COMPUTERNAME"
Write-Output "NOW=$([DateTime]::UtcNow.ToString('o'))"
Write-Output 'TUNNEL_DETAIL_BEGIN'
$procs = Get-CimInstance Win32_Process -Filter "Name='tunnel-client.exe'" -ErrorAction SilentlyContinue
foreach($p in $procs) {
  $owner='unknown'
  try { $o=Invoke-CimMethod -InputObject $p -MethodName GetOwner -ErrorAction Stop; $owner="$($o.Domain)\$($o.User)" } catch {}
  $gp=Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
  "PID={0} PARENT={1} SESSION={2} START={3} OWNER={4} EXE={5} CMD={6}" -f $p.ProcessId,$p.ParentProcessId,$p.SessionId,($(if($gp){$gp.StartTime.ToString('o')}else{'?'})),$owner,$p.ExecutablePath,$p.CommandLine
  Get-NetTCPConnection -OwningProcess $p.ProcessId -ErrorAction SilentlyContinue | ForEach-Object { "TCP PID={0} STATE={1} LOCAL={2}:{3} REMOTE={4}:{5}" -f $_.OwningProcess,$_.State,$_.LocalAddress,$_.LocalPort,$_.RemoteAddress,$_.RemotePort }
}
Write-Output 'TUNNEL_DETAIL_END'
Write-Output 'USER_PROFILES_BEGIN'
Get-ChildItem 'C:\Users' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
  $pf=Join-Path $_.FullName 'AppData\Roaming\tunnel-client\stage3-win11.yaml'
  if(Test-Path -LiteralPath $pf){ "PROFILE=$pf"; Get-Content -LiteralPath $pf }
}
Write-Output 'USER_PROFILES_END'
Write-Output 'DONE'