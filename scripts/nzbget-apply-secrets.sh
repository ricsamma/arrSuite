#!/bin/sh
set -eu

SECRET_FILE="${NZBGET_SECRET_FILE:-/run/secrets/nzbget.env}"
CONFIG_FILE="/config/nzbget.conf"

read_secret_value() {
  key="$1"
  if [ ! -f "$SECRET_FILE" ]; then
    return 1
  fi
  value=$(grep -E "^${key}=" "$SECRET_FILE" | head -n 1 | cut -d '=' -f2- || true)
  if [ -z "${value}" ]; then
    return 1
  fi
  printf '%s' "$value"
}

set_config_value() {
  key="$1"
  value="$2"
  escaped=$(printf '%s' "$value" | sed -e 's/[\\&]/\\\\&/g' -e 's/#/\\#/g')

  if grep -qE "^${key}=" "$CONFIG_FILE"; then
    sed -i "s#^${key}=.*#${key}=${escaped}#" "$CONFIG_FILE"
  else
    printf '\n%s=%s\n' "$key" "$value" >> "$CONFIG_FILE"
  fi
}

if [ -f "$CONFIG_FILE" ] && [ -f "$SECRET_FILE" ]; then
  username=$(read_secret_value "NZBGET_USERNAME" || true)
  password=$(read_secret_value "NZBGET_PASSWORD" || true)

  if [ -n "${username:-}" ]; then
    set_config_value "ControlUsername" "$username"
  fi

  if [ -n "${password:-}" ]; then
    set_config_value "ControlPassword" "$password"
  fi
fi

exec /init
