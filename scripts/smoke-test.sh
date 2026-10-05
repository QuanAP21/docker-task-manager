#!/bin/sh
set -eu

COMPOSE_FILE="${1:-docker-compose.prod.yml}"
BASE_URL="http://localhost:3000"
PASSED=0
TOTAL=0
CREATED_ID=""

pass() {
  PASSED=$((PASSED + 1))
  echo "[PASS] $1"
}

fail() {
  echo "[FAIL] $1"
  echo "       $2"
  exit 1
}

check() {
  TOTAL=$((TOTAL + 1))
  NAME="$1"
  shift
  if "$@"; then
    pass "$NAME"
  else
    fail "$NAME" "Command failed: $*"
  fi
}

json_id() {
  python -c 'import sys,json; print(json.load(sys.stdin)["id"])'
}

json_done() {
  python -c 'import sys,json; print(str(json.load(sys.stdin)["is_done"]).lower())'
}

echo "========================================"
echo " TASK MANAGER - DEPLOYMENT SMOKE TEST"
echo "========================================"
echo "Compose file: $COMPOSE_FILE"
echo ""

check "Docker Compose services are visible" docker compose -f "$COMPOSE_FILE" ps

STATUS=$(docker inspect --format='{{.State.Health.Status}}' task_db_prod 2>/dev/null || true)
[ "$STATUS" = "healthy" ] || fail "PostgreSQL service is healthy" "task_db_prod status is $STATUS"
pass "PostgreSQL service is healthy"
TOTAL=$((TOTAL + 1))

check "Backend internal healthcheck passes" docker compose -f "$COMPOSE_FILE" exec -T backend python healthcheck.py
check "Frontend is reachable" curl --fail --silent "$BASE_URL/" >/dev/null
check "Backend health via frontend reverse proxy" curl --fail --silent "$BASE_URL/health/" >/dev/null
check "GET /api/tasks/ via frontend reverse proxy" curl --fail --silent "$BASE_URL/api/tasks/" >/dev/null

CREATED=$(curl --fail --silent -X POST "$BASE_URL/api/tasks/" \
  -H "Content-Type: application/json" \
  -d '{"title":"Smoke test task","description":"Created by smoke-test.sh","is_done":false}')
CREATED_ID=$(printf '%s' "$CREATED" | json_id)
[ -n "$CREATED_ID" ] || fail "POST /api/tasks/ creates task" "No id returned"
pass "POST /api/tasks/ creates task"
TOTAL=$((TOTAL + 1))

check "GET created task" curl --fail --silent "$BASE_URL/api/tasks/$CREATED_ID/" >/dev/null

UPDATED=$(curl --fail --silent -X PUT "$BASE_URL/api/tasks/$CREATED_ID/" \
  -H "Content-Type: application/json" \
  -d '{"title":"Smoke test task","description":"Updated by smoke test","is_done":true}')
DONE=$(printf '%s' "$UPDATED" | json_done)
[ "$DONE" = "true" ] || fail "PUT /api/tasks/{id}/ updates task" "Task was not updated"
pass "PUT /api/tasks/{id}/ updates task"
TOTAL=$((TOTAL + 1))

check "DELETE /api/tasks/{id}/ deletes task" curl --fail --silent -X DELETE "$BASE_URL/api/tasks/$CREATED_ID/" >/dev/null
check "Docker DNS resolves db service from backend" docker compose -f "$COMPOSE_FILE" exec -T backend getent hosts db
check "Backend can reach db:5432" docker compose -f "$COMPOSE_FILE" exec -T backend nc -zv db 5432

echo ""
echo "========================================"
echo " $PASSED / $TOTAL TESTS PASSED"
echo " SYSTEM STATUS: HEALTHY"
echo "========================================"
