param(
    [string]$ComposeFile = "docker-compose.prod.yml"
)

$ErrorActionPreference = "Stop"
$baseUrl = "http://localhost:3000"
$passed = 0
$total = 0

function Pass($name) {
    $script:passed++
    Write-Host "[PASS] $name" -ForegroundColor Green
}

function Fail($name, $message) {
    Write-Host "[FAIL] $name" -ForegroundColor Red
    Write-Host "       $message" -ForegroundColor DarkRed
    exit 1
}

function Check($name, [scriptblock]$block) {
    $script:total++
    try {
        & $block
        Pass $name
    } catch {
        Fail $name $_.Exception.Message
    }
}

Write-Host "========================================"
Write-Host " TASK MANAGER - DEPLOYMENT SMOKE TEST"
Write-Host "========================================"
Write-Host "Compose file: $ComposeFile"
Write-Host ""

Check "Docker Compose services are visible" {
    docker compose -f $ComposeFile ps | Out-Null
}

Check "PostgreSQL service is healthy" {
    $status = docker inspect --format='{{.State.Health.Status}}' task_db_prod
    if ($status -ne "healthy") { throw "task_db_prod status is $status" }
}

Check "Backend internal healthcheck passes" {
    docker compose -f $ComposeFile exec -T backend python healthcheck.py | Out-Null
}

Check "Frontend is reachable" {
    $res = Invoke-WebRequest -Uri "$baseUrl/" -UseBasicParsing
    if ($res.StatusCode -ne 200) { throw "Expected 200, got $($res.StatusCode)" }
}

Check "Backend health via frontend reverse proxy" {
    $health = Invoke-RestMethod -Uri "$baseUrl/health/" -Method Get
    if ($health.status -ne "ok") { throw "Unexpected health status" }
}

Check "GET /api/tasks/ via frontend reverse proxy" {
    Invoke-RestMethod -Uri "$baseUrl/api/tasks/" -Method Get | Out-Null
}

$createdId = $null
Check "POST /api/tasks/ creates task" {
    $body = @{
        title = "Smoke test task"
        description = "Created by scripts/smoke-test.ps1"
        is_done = $false
    } | ConvertTo-Json
    $created = Invoke-RestMethod -Uri "$baseUrl/api/tasks/" -Method Post -ContentType "application/json" -Body $body
    if (-not $created.id) { throw "No task id returned" }
    $script:createdId = $created.id
}

Check "GET created task" {
    $task = Invoke-RestMethod -Uri "$baseUrl/api/tasks/$createdId/" -Method Get
    if ($task.title -ne "Smoke test task") { throw "Unexpected task title" }
}

Check "PUT /api/tasks/{id}/ updates task" {
    $body = @{
        title = "Smoke test task"
        description = "Updated by smoke test"
        is_done = $true
    } | ConvertTo-Json
    $task = Invoke-RestMethod -Uri "$baseUrl/api/tasks/$createdId/" -Method Put -ContentType "application/json" -Body $body
    if ($task.is_done -ne $true) { throw "Task was not updated" }
}

Check "DELETE /api/tasks/{id}/ deletes task" {
    Invoke-RestMethod -Uri "$baseUrl/api/tasks/$createdId/" -Method Delete | Out-Null
}

Check "Docker DNS resolves db service from backend" {
    $hosts = docker compose -f $ComposeFile exec -T backend getent hosts db
    if (-not ($hosts -match "db")) { throw "db host was not resolved" }
}

Check "Backend can reach db:5432" {
    docker compose -f $ComposeFile exec -T backend nc -zv db 5432 | Out-Null
}

Write-Host ""
Write-Host "========================================"
Write-Host " $passed / $total TESTS PASSED"
Write-Host " SYSTEM STATUS: HEALTHY"
Write-Host "========================================"
