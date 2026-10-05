param(
    [string]$ComposeFile = "docker-compose.prod.yml"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path "backups" | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = "backups/taskdb_$timestamp.sql"

docker compose -f $ComposeFile exec -T db pg_dump -U taskuser taskdb > $outFile
Write-Host "Backup saved to $outFile"
