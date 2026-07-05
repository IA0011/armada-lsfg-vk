# LSFG-VK Decky Plugin — Armada OS port

This is a Fedora/Armada-oriented adaptation of the ROCKNIX LSFG-VK Decky plugin.

Key path changes:

- Config: `$HOME/.config/lsfg-vk`
- Per-game profiles: `$HOME/.config/lsfg-vk/games/<APPID>.json`
- Local ARM64 layer: `$HOME/.local/lib/lsfg-vk/liblsfg-vk-arm64.so`
- Native Vulkan manifest: `$HOME/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation_arm64.json`
- Optional pressure-vessel override: overlay mounted over `/usr/lib` by `lsfg-vk-overlay.service`
- FEX config: `$HOME/.config/fex-emu/Config.json`

## Manual test install over SSH

```bash
scp install-armada.sh armada@192.168.18.49:/tmp/
ssh armada@192.168.18.49 'chmod +x /tmp/install-armada.sh && sudo /tmp/install-armada.sh'
ssh armada@192.168.18.49 'systemctl status lsfg-vk-overlay.service --no-pager'
```

Then set a Steam launch option to:

```bash
~/lsfg %command%
```

## Decky plugin install

Build on your CachyOS dev machine:

```bash
npm install
npm run build
```

Copy the plugin folder containing `plugin.json`, `main.py`, `defaults/`, `dist/`, and `install-armada.sh` into Decky’s plugin directory on Armada. Common locations are under the Decky user home, for example `~/homebrew/plugins/`; verify on the device with `find ~ -maxdepth 4 -type d -path '*homebrew/plugins'`.

## Notes

The overlay service is needed only for Steam pressure-vessel discovery. The native XDG Vulkan manifest is also installed for non-pressure-vessel ARM64 Vulkan discovery.


## Current local default build

This package now installs the Rocknix-style implicit wrapper as `~/lsfg` and an optional forced-layer wrapper as `~/lsfg-force`. The installer clears per-game LSFG JSON profiles and writes this global default:

```json
{
  "multiplier": 2,
  "fps_limit": 60,
  "flow_scale": 0.8,
  "performance_mode": 1
}
```


## Current validated Armada defaults

The installed `~/lsfg` wrapper uses Rocknix-style implicit Vulkan layer discovery and applies these low-latency Armada overrides globally for games launched through `~/lsfg`:

```bash
export ENABLE_GAMESCOPE_WSI=1
export GAMESCOPE_DISABLE_ASYNC_FLIPS=0
export STEAM_GAMESCOPE_COLOR_MANAGED=0
export GAMESCOPE_NV12_COLORSPACE=
export VK_IMPLICIT_LAYER_PATH=/usr/lib/pressure-vessel/overrides/share/vulkan/implicit_layer.d
```

Use this Steam launch option:

```bash
~/lsfg %command%
```
