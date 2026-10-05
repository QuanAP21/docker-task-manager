#!/bin/sh
set -eu
COMPOSE_FILE="${1:-docker-compose.prod.yml}"
mkdir -p backups
OUT="backups/taskdb_$(date +%Y%m%d_%H%M%S).sql"
docker compose -f "$COMPOSE_FILE" exec -T db pg_dump -U taskuser taskdb > "$OUT"
echo "Backup saved to $OUT"
