#!/usr/bin/env bash
set -euo pipefail

cd /opt/traefik_master
mkdir -p dynamic

python3 - <<'PY'
from pathlib import Path

compose = Path("docker-compose.yml")
text = compose.read_text()
original = text

if "--providers.file.directory=/dynamic" not in text:
    text = text.replace(
        '      - "--providers.docker.exposedbydefault=false"\n',
        '      - "--providers.docker.exposedbydefault=false"\n'
        '      - "--providers.file.directory=/dynamic"\n'
        '      - "--providers.file.watch=true"\n',
    )
elif "--providers.file.watch=true" not in text:
    text = text.replace(
        '      - "--providers.file.directory=/dynamic"\n',
        '      - "--providers.file.directory=/dynamic"\n'
        '      - "--providers.file.watch=true"\n',
    )

if "./dynamic:/dynamic:ro" not in text:
    text = text.replace(
        "      - /var/run/docker.sock:/var/run/docker.sock:ro\n",
        "      - /var/run/docker.sock:/var/run/docker.sock:ro\n"
        "      - ./dynamic:/dynamic:ro\n",
    )

if text != original:
    compose.write_text(text)
    print("traefik docker-compose.yml updated")
else:
    print("traefik file provider already enabled")
PY

cat > dynamic/timo.yml <<'YAML'
http:
  routers:
    timo:
      rule: "Host(`timo.it-sefako.com`)"
      entryPoints:
        - websecure
      service: timo
      tls:
        certResolver: myresolver

  services:
    timo:
      loadBalancer:
        servers:
          - url: "http://172.18.0.1:3100"
YAML

docker compose up -d
echo "Timon Traefik config installed: https://timo.it-sefako.com"
