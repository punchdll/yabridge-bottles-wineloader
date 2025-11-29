#!/bin/bash

RUNNER=""

YQ=$(command -v yq)
if [ -z "$YQ" ]; then
  echo "Error: yq is not installed." >&2
  exit 1
fi

# If bottle.yml exists in the prefix, use the "runner" specified there
if [[ -e "${WINEPREFIX}/bottle.yml" ]]; then
    # Parse runner from bottle.yml
    RUNNER=$(yq -r ".Runner" "${WINEPREFIX}/bottle.yml")
fi

# Bottles uses "sys-*" (e.g. "sys-wine-9.0") internally to refer to system wine
# Also fall back to system wine if runner is empty.
if [[ -n "$RUNNER" && "$RUNNER" != sys-* ]]; then
    # Bottles root directory is two directories up
    BOTTLES_ROOT="$(dirname "$(dirname "$WINEPREFIX")")"
    exec "$BOTTLES_ROOT/runners/$RUNNER/bin/wine" "$@"
fi

# Uncomment below, to assign a custom wine version to this wineprefix
#WINEPREFIX == "/path/to/your/wineprefix"

SYSTEM_WINE=$(command -v wine)

if [ ! -z "$SYSTEM_WINE" ]; then
  exec "$SYSTEM_WINE" "$@"
fi

echo "Error: wine is not installed." >&2
exit 1