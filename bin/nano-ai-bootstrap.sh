#!/usr/bin/env bash
# Auto-bootstrap Nano-friendly AI settings on Jetson hosts.
set -o errexit
set -o nounset
set -o pipefail

is_jetson_host() {
  if [[ -f /proc/device-tree/model ]] && grep -qi "jetson" /proc/device-tree/model; then
    return 0
  fi

  if [[ -f /etc/nv_tegra_release ]]; then
    return 0
  fi

  return 1
}

upsert_env_var() {
  local key="$1"
  local value="$2"
  local file="$3"

  if grep -qE "^${key}=" "$file"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$file"
  else
    printf "%s=%s\n" "$key" "$value" >> "$file"
  fi
}

echo "[nano-bootstrap] Starting AI bootstrap check..."

if ! is_jetson_host; then
  echo "[nano-bootstrap] Not a Jetson host. Skipping Nano AI bootstrap."
  exit 0
fi

echo "[nano-bootstrap] Jetson host detected. Applying Nano AI defaults."

NANO_OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11434}"
NANO_OLLAMA_MODEL="${OLLAMA_MODEL:-llama3.2:1b}"
NANO_OLLAMA_NUM_CTX="${OLLAMA_NUM_CTX:-1024}"
NANO_OLLAMA_NUM_PREDICT="${OLLAMA_NUM_PREDICT:-384}"
NANO_OLLAMA_TEMPERATURE="${OLLAMA_TEMPERATURE:-0.3}"

export OLLAMA_URL="$NANO_OLLAMA_URL"
export OLLAMA_MODEL="$NANO_OLLAMA_MODEL"
export OLLAMA_NUM_CTX="$NANO_OLLAMA_NUM_CTX"
export OLLAMA_NUM_PREDICT="$NANO_OLLAMA_NUM_PREDICT"
export OLLAMA_TEMPERATURE="$NANO_OLLAMA_TEMPERATURE"

ENV_FILE="${GOVEND_ENV_FILE:-/etc/default/govend}"
ENV_DIR="$(dirname "$ENV_FILE")"

if [[ -e "$ENV_FILE" ]]; then
  if [[ -w "$ENV_FILE" ]]; then
    upsert_env_var "OLLAMA_URL" "$NANO_OLLAMA_URL" "$ENV_FILE"
    upsert_env_var "OLLAMA_MODEL" "$NANO_OLLAMA_MODEL" "$ENV_FILE"
    upsert_env_var "OLLAMA_NUM_CTX" "$NANO_OLLAMA_NUM_CTX" "$ENV_FILE"
    upsert_env_var "OLLAMA_NUM_PREDICT" "$NANO_OLLAMA_NUM_PREDICT" "$ENV_FILE"
    upsert_env_var "OLLAMA_TEMPERATURE" "$NANO_OLLAMA_TEMPERATURE" "$ENV_FILE"
    echo "[nano-bootstrap] Updated $ENV_FILE"
  else
    echo "[nano-bootstrap] $ENV_FILE exists but is not writable by current user."
  fi
else
  if [[ -d "$ENV_DIR" ]] && [[ -w "$ENV_DIR" ]]; then
    : > "$ENV_FILE"
    upsert_env_var "OLLAMA_URL" "$NANO_OLLAMA_URL" "$ENV_FILE"
    upsert_env_var "OLLAMA_MODEL" "$NANO_OLLAMA_MODEL" "$ENV_FILE"
    upsert_env_var "OLLAMA_NUM_CTX" "$NANO_OLLAMA_NUM_CTX" "$ENV_FILE"
    upsert_env_var "OLLAMA_NUM_PREDICT" "$NANO_OLLAMA_NUM_PREDICT" "$ENV_FILE"
    upsert_env_var "OLLAMA_TEMPERATURE" "$NANO_OLLAMA_TEMPERATURE" "$ENV_FILE"
    echo "[nano-bootstrap] Created $ENV_FILE"
  else
    echo "[nano-bootstrap] Cannot create $ENV_FILE (directory not writable)."
  fi
fi

if command -v ollama >/dev/null 2>&1; then
  if ! curl -fsS "$NANO_OLLAMA_URL/api/tags" >/dev/null 2>&1; then
    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files 2>/dev/null | grep -q '^ollama\.service'; then
      echo "[nano-bootstrap] Attempting to start ollama.service"
      systemctl start ollama.service || true
    fi
  fi

  echo "[nano-bootstrap] Ensuring model is available: $NANO_OLLAMA_MODEL"
  ollama pull "$NANO_OLLAMA_MODEL" || echo "[nano-bootstrap] Could not pull model automatically."
else
  echo "[nano-bootstrap] Ollama CLI not found. Install Ollama to enable local AI responses."
fi

if bundle exec rake ai:nano_check; then
  echo "[nano-bootstrap] Nano AI check passed."
else
  echo "[nano-bootstrap] Nano AI check failed. Continuing deploy without blocking."
fi
