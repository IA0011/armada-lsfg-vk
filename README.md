# LSFG Frame Generation for Armada OS

Decky Loader plugin for installing and configuring **LSFG-VK frame generation** on Armada OS / Fedora ARM64 handhelds.

This fork is adapted for devices such as the **AYN Odin 3** running Armada OS.

## Features

- Installs the ARM64 LSFG-VK runtime
- Adds launch wrappers: `~/lsfg` and `~/lsfg-force`
- Installs the Vulkan implicit layer manifest
- Enables FEX Vulkan thunks
- Provides Decky UI controls for default and per-game LSFG settings

## Requirements

- Armada OS / Fedora ARM64
- Decky Loader
- Steam
- Lossless Scaling installed through Steam
- Internet connection for first-time install

## Installation

Install the plugin through Decky Loader, open **LSFG Frame Generation (Armada)**, then press:

```text
Install LSFG-VK
```

After installation, use this Steam launch option:

```text
~/lsfg %command%
```

If a game does not load the LSFG Vulkan layer, try the forced-layer wrapper:

```text
~/lsfg-force %command%
```

## Configuration

Default config:

```text
/var/home/armada/.config/lsfg-vk/default.json
```

Per-game configs:

```text
/var/home/armada/.config/lsfg-vk/games/<APPID>.json
```

Example:

```json
{
  "multiplier": 2,
  "fps_limit": 60,
  "flow_scale": 0.8,
  "performance_mode": 1
}
```

## Installed Files

The installer creates:

```text
/var/home/armada/.config/lsfg-vk/bin/lsfg
/var/home/armada/.config/lsfg-vk/bin/lsfg-force
/var/home/armada/.config/lsfg-vk/default.json
/var/home/armada/.local/lib/lsfg-vk/liblsfg-vk-arm64.so
/var/home/armada/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation_arm64.json
/var/home/armada/lsfg
/var/home/armada/lsfg-force
```

## Manual Install or Repair

The Decky UI runs the installer automatically, but it can also be run over SSH:

```bash
sudo bash /var/home/armada/homebrew/plugins/armada-lsfg-vk/install-armada.sh
sudo systemctl restart plugin_loader.service
```

## Troubleshooting

Check Decky logs:

```bash
sudo journalctl -u plugin_loader.service -n 180 --no-pager -l | grep -Ei "lsfg|install|status|traceback|error|failed|arch|unsupported"
```

Check runtime files:

```bash
find /var/home/armada/.config/lsfg-vk -maxdepth 4 -type f -o -type l 2>/dev/null
find /var/home/armada/.local/lib/lsfg-vk -maxdepth 3 -type f -o -type l 2>/dev/null
ls -l /var/home/armada/lsfg /var/home/armada/lsfg-force 2>/dev/null
ls -l /var/home/armada/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation_arm64.json 2>/dev/null
```

Restart Decky:

```bash
sudo systemctl restart plugin_loader.service
```

## Clean Uninstall

```bash
sudo systemctl stop plugin_loader.service

sudo rm -rf /var/home/armada/homebrew/plugins/armada-lsfg-vk
sudo rm -rf /var/home/armada/.config/lsfg-vk
sudo rm -rf /var/home/armada/.local/lib/lsfg-vk

rm -f /var/home/armada/lsfg
rm -f /var/home/armada/lsfg-force
rm -f /var/home/armada/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation_arm64.json
rm -f /var/home/armada/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json

sudo systemctl disable --now lsfg-vk-overlay.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/lsfg-vk-overlay.service
sudo systemctl daemon-reload
```

## Building

```bash
npm install
npm run build
```

## Packaging

From the parent directory:

```bash
zip -r armada-lsfg-vk.zip armada-lsfg-vk \
  -x "armada-lsfg-vk/.git/*" \
  -x "armada-lsfg-vk/node_modules/*"
```

## Notes

- Some games work with `~/lsfg %command%`.
- Some games may require `~/lsfg-force %command%`.
- Compatibility depends on the game, Proton, WineVulkan, vkd3d, Gamescope, FEX, and Armada OS.
- Some games may load the layer but not generate frames.
- Forced-layer mode may crash some Wine/Proton titles.
- ARM64 LSFG-VK compatibility is still experimental.

## Credits

Forked from `seilent/rocknix-lsfg-vk`.

Adapted for Armada OS by `IA0011`.

AI tools were used to help debug, adapt, document, and package this Armada OS fork.

## License

GPL-2.0
