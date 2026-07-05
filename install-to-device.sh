#!/usr/bin/env bash
# Deploy this package from your dev machine to an Armada/Fedora device.
# Usage: ./install-to-device.sh armada@192.168.18.49
set -euo pipefail
TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "Usage: $0 armada@DEVICE_IP"
  exit 1
fi
REMOTE_DIR="/tmp/armada-lsfg-vk"
echo "[deploy] Copying package to $TARGET:$REMOTE_DIR"
ssh "$TARGET" "rm -rf '$REMOTE_DIR' && mkdir -p '$REMOTE_DIR'"
scp -r . "$TARGET:$REMOTE_DIR/"
echo "[deploy] Running installer on $TARGET"
ssh -t "$TARGET" "cd '$REMOTE_DIR' && chmod +x install-armada.sh && sudo ./install-armada.sh"
echo "[deploy] Done. Set Steam launch option per game to: ~/lsfg %command%"
