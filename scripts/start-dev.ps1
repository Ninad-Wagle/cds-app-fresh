param(
    [int]$ApiPort = 5010
)

function Get-PidByPort {
    param([int]$Port)
    try {
        $c = Get-NetTCPConnection -LocalPort $Port -ErrorAction Stop
        return $c.OwningProcess
    } catch {
        return $null
    }
}

$pid = Get-PidByPort -Port $ApiPort
if ($pid) {
    Write-Host "Port $ApiPort is in use by PID $pid."
    $answer = Read-Host "Kill process $pid and continue? (y/N)"
    if ($answer -eq 'y') {
        try {
            Stop-Process -Id $pid -Force -ErrorAction Stop
            Write-Host "Killed PID $pid."
            Start-Sleep -Seconds 1
        } catch {
            Write-Error "Failed to kill PID $pid: $_"
            exit 1
        }
    } else {
        Write-Host "Aborting. Free port $ApiPort and retry."
        exit 1
    }
}

Write-Host "Starting API on http://localhost:$ApiPort"
Start-Process -FilePath "dotnet" -ArgumentList "run --project src/api/CdsApi.csproj --urls http://localhost:$ApiPort" -NoNewWindow

Write-Host "Starting Frontend (Blazor WASM)"
Start-Process -FilePath "dotnet" -ArgumentList "run --project src/frontend/CdsFrontend.csproj" -NoNewWindow

Write-Host "Dev servers started. Use your terminals to inspect processes or run 'Get-Process -Name dotnet' to view them."