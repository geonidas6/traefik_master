#!/usr/bin/env bash
set -euo pipefail

rm -f /opt/traefik_master/dynamic/timo.yml
echo "Timon Traefik config removed. Traefik file provider will unload it automatically."
