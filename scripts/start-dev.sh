#!/usr/bin/env bash
# Cross-platform-ish dev start script for Unix-like shells
# Starts API on $API_PORT (default 5010) and frontend.

set -euo pipefail
API_PORT=${1:-5010}
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
API_PROJECT="$REPO_ROOT/src/api/CdsApi.csproj"
FRONTEND_PROJECT="$REPO_ROOT/src/frontend/CdsFrontend.csproj"

check_port() {
  if command -v lsof >/dev/null 2>&1; then
    lsof -iTCP:"$API_PORT" -sTCP:LISTEN -t || true
  elif command -v ss >/dev/null 2>&1; then
    ss -ltnp | grep ":$API_PORT" || true
  else
    # best-effort: use netstat
    netstat -an 2>/dev/null | grep ":$API_PORT" || true
  fi
}

PID=$(check_port | awk '{print $1}' | head -n1 || true)
if [ -n "$PID" ]; then
  echo "Port $API_PORT appears in use (PID: $PID)."
  read -p "Kill process $PID and continue? (y/N) " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    kill -9 $PID || { echo "Failed to kill $PID"; exit 1; }
    sleep 1
  else
    echo "Aborting. Free port $API_PORT and retry.";
    exit 1
  fi
fi

echo "Starting API on http://localhost:$API_PORT"
# Start API in background, write logs
nohup dotnet run --project "$API_PROJECT" --urls "http://localhost:$API_PORT" > "$REPO_ROOT/logs/api.log" 2>&1 &
API_BG=$!
sleep 1

echo "Starting Frontend (Blazor WASM)"
nohup dotnet run --project "$FRONTEND_PROJECT" > "$REPO_ROOT/logs/frontend.log" 2>&1 &
FRONTEND_BG=$!

echo "Dev servers started:"
echo "  API PID: $API_BG (logs: logs/api.log)"
echo "  Frontend PID: $FRONTEND_BG (logs: logs/frontend.log)"

echo "To stop: kill $API_BG $FRONTEND_BG"
