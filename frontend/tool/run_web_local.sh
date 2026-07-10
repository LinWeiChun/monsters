#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

FLUTTER_BIN="${FLUTTER_BIN:-/Users/linweijun/fultter/flutter/bin/flutter}"
WEB_HOSTNAME="${WEB_HOSTNAME:-localhost}"
WEB_PORT="${WEB_PORT:-5050}"
API_BASE_URL="${API_BASE_URL:-http://localhost:8080/api}"

if [[ -z "${GOOGLE_CLIENT_ID:-}" ]]; then
  echo "GOOGLE_CLIENT_ID is required for Web Google Sign-In." >&2
  echo "Example:" >&2
  echo "  GOOGLE_CLIENT_ID=your-web-client-id.apps.googleusercontent.com $0" >&2
  exit 1
fi

cd "$FRONTEND_DIR"

exec "$FLUTTER_BIN" run \
  -d chrome \
  --web-hostname "$WEB_HOSTNAME" \
  --web-port "$WEB_PORT" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
  "$@"
