param(
    [Parameter(Mandatory=$true)]
    [string]$File,
    [string]$ComposeFile = "docker-compose.prod.yml"
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path $File)) {
    throw "Backup file not found: $File"
}

cmd /c type "$File" | docker compose -f $ComposeFile exec -T db psql -U taskuser -d taskdb
Write-Host "Restore completed from $File"
