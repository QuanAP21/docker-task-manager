#!/bin/sh
set -eu
COMPOSE_FILE="${2:-docker-compose.prod.yml}"
FILE="${1:-}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Usage: scripts/restore-db.sh <backup.sql> [compose-file]"
  exit 1
fi
cat "$FILE" | docker compose -f "$COMPOSE_FILE" exec -T db psql -U taskuser -d taskdb
echo "Restore completed from $FILE"
