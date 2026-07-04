#!/bin/sh
# LSFG-VK runtime installer for stock ROCKNIX images
# Installs frame generation support without rebuilding the OS.
#
# Usage: curl -sSL https://raw.githubusercontent.com/seilent/rocknix-lsfg-vk/main/install.sh | bash
#
# What it does:
#   1. Downloads liblsfg-vk.so and layer JSON from the distribution repo
#   2. Deploys them into the FEX RootFS (where pressure-vessel discovers them)
#   3. Installs the lsfg launch wrapper and setup service

set -euo pipefail

LSFG_VK_VERSION="1.0.0"
LSFG_VK_ZIP="https://github.com/PancakeTAS/lsfg-vk/releases/download/v${LSFG_VK_VERSION}/lsfg-vk-${LSFG_VK_VERSION}-x86_64.zip"
REPO="https://raw.githubusercontent.com/seilent/distribution/next/packages/graphics/vulkan/lsfg-vk"
LSFG_DIR="/var/home/armada/.config/lsfg-vk"
BIN_DIR="${LSFG_DIR}/bin"
SRC_DIR="${LSFG_DIR}/lib"
GAMES_DIR="${LSFG_DIR}/games"
FEX_ROOTFS="/var/home/armada/.local/share/fex-emu/RootFS/ArchLinux"
TMP_DIR="/tmp/lsfg-vk-install"

log() { echo "[lsfg-vk] $*"; }

# Create directories
mkdir -p "${BIN_DIR}" "${SRC_DIR}" "${TMP_DIR}" "${GAMES_DIR}"

# Create default config if not present
if [ ! -f "${LSFG_DIR}/default.json" ]; then
    echo '{"multiplier": 2, "fps_limit": 30, "flow_scale": 0.3, "performance_mode": 1}' > "${LSFG_DIR}/default.json"
fi

# Download and extract .so from upstream release
log "Downloading lsfg-vk v${LSFG_VK_VERSION}..."
curl -sSL "${LSFG_VK_ZIP}" -o "${TMP_DIR}/lsfg-vk.zip"
unzip -qo "${TMP_DIR}/lsfg-vk.zip" "lib/liblsfg-vk.so" -d "${TMP_DIR}"
cp "${TMP_DIR}/lib/liblsfg-vk.so" "${SRC_DIR}/liblsfg-vk.so"
rm -rf "${TMP_DIR}"

# Download config/scripts from distribution repo
log "Downloading layer config and scripts..."
curl -sSL "${REPO}/files/VkLayer_LS_frame_generation.json" -o "${SRC_DIR}/VkLayer_LS_frame_generation.json"
curl -sSL "${REPO}/sources/lsfg" -o "${BIN_DIR}/lsfg"
chmod +x "${BIN_DIR}/lsfg"
cp "${BIN_DIR}/lsfg" ~/lsfg
chmod +x ~/lsfg

# Deploy into FEX RootFS
deploy_fex() {
    if [ ! -d "$FEX_ROOTFS" ]; then
        log "FEX RootFS not found at ${FEX_ROOTFS} — skipping (install Steam first)"
        return 0
    fi
    log "Deploying layer into FEX RootFS..."
    install -D -m 0644 "${SRC_DIR}/liblsfg-vk.so" "${FEX_ROOTFS}/usr/lib/liblsfg-vk.so"
    install -D -m 0644 "${SRC_DIR}/VkLayer_LS_frame_generation.json" \
        "${FEX_ROOTFS}/usr/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.x86_64.json"
}

# Create setup script (for re-running after FEX RootFS updates)
cat > "${BIN_DIR}/lsfg-vk-setup" << 'SETUP'
#!/bin/bash
set -u
LSFG_DIR="/var/home/armada/.config/lsfg-vk"
SRC_DIR="${LSFG_DIR}/lib"
FEX_ROOTFS="/var/home/armada/.local/share/fex-emu/RootFS/ArchLinux"

[ -d "$FEX_ROOTFS" ] && {
    install -D -m 0644 "${SRC_DIR}/liblsfg-vk.so" "${FEX_ROOTFS}/usr/lib/liblsfg-vk.so"
    install -D -m 0644 "${SRC_DIR}/VkLayer_LS_frame_generation.json" \
        "${FEX_ROOTFS}/usr/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.x86_64.json"
}
SETUP
chmod +x "${BIN_DIR}/lsfg-vk-setup"

# Create systemd service for auto-deploy on boot
mkdir -p /var/home/armada/.config/system.d
cat > /var/home/armada/.config/system.d/lsfg-vk-setup.service << EOF
[Unit]
Description=Deploy LSFG-VK layer into FEX RootFS
After=local-fs.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=${BIN_DIR}/lsfg-vk-setup

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /var/home/armada/.config/system.d/multi-user.target.wants
ln -sf /var/home/armada/.config/system.d/lsfg-vk-setup.service /var/home/armada/.config/system.d/multi-user.target.wants/lsfg-vk-setup.service

# Deploy now
deploy_fex

# Add bin dir to PATH via profile.d (sourced by /etc/profile, which Steam also sources)
mkdir -p /var/home/armada/.config/profile.d
cat > /var/home/armada/.config/profile.d/99-lsfg-vk.conf << 'EOF'
export PATH="/var/home/armada/.config/lsfg-vk/bin:$PATH"
EOF

log ""
log "Installation complete!"
log ""
log "Usage:"
log "  1. Set Steam launch options to: ~/lsfg %command%"
log "  2. Create config at ${LSFG_DIR}/default.json:"
log '     {"multiplier": 2, "fps_limit": 30, "flow_scale": 0.3, "performance_mode": 1}'
log ""
log "  Or per-game: ${LSFG_DIR}/games/<APPID>.json"
log ""
log "  Re-run after RootFS updates: ${BIN_DIR}/lsfg-vk-setup"
