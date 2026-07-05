# Armada LSFG-VK local build: install on another device

This is the current local Armada OS/Fedora ARM64 build based on the Rocknix LSFG-VK plugin.

Current default behavior:

- `~/lsfg %command%` uses Rocknix-style implicit Vulkan layer discovery plus the validated low-latency Armada overrides.
- Global default LSFG config is `multiplier=2`, `fps_limit=60`, `flow_scale=0.8`, `performance_mode=1`.
- Existing per-game LSFG profiles are cleared during install so all games use the global default.
- `~/lsfg-force %command%` is also installed as an optional forced-layer fallback for games that need explicit `VK_INSTANCE_LAYERS` injection.

## Requirements on target device

- Armada OS / Fedora ARM64
- Steam/FEX working
- Lossless Scaling installed from Steam, or at least:

```bash
~/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll
```

## Install from dev machine

```bash
unzip armada-lsfg-vk-local-current.zip
cd armada-lsfg-vk
./install-to-device.sh armada@DEVICE_IP
```

Example:

```bash
./install-to-device.sh armada@192.168.18.49
```

## Manual install on target

```bash
scp -r armada-lsfg-vk armada@DEVICE_IP:/tmp/armada-lsfg-vk
ssh armada@DEVICE_IP
cd /tmp/armada-lsfg-vk
chmod +x install-armada.sh
sudo ./install-armada.sh
```

## Steam launch options

Default Rocknix-style mode:

```bash
~/lsfg %command%
```

Optional forced-layer fallback:

```bash
~/lsfg-force %command%
```

## Verify environment after launching a game

```bash
PID="$(pgrep -n -f 'Deadzone|FF7|P3R|Persona|Shipping|Win64')"
echo "PID=$PID"
tr '\0' '\n' < /proc/$PID/environ | grep -E 'VK_|LSFG|GAMESCOPE|DXVK|VKD3D|FEX|SteamAppId|ENABLE|DISABLE' | sort
```

Expected defaults include:

```text
DXVK_FRAME_RATE=60
ENABLE_GAMESCOPE_WSI=1
LSFGVK_FLOW_SCALE=0.8
LSFGVK_MULTIPLIER=2
LSFGVK_PERFORMANCE_MODE=1
LSFG_ENABLE=1
VK_IMPLICIT_LAYER_PATH=/usr/lib/pressure-vessel/overrides/share/vulkan/implicit_layer.d
```

## Verify install files

```bash
systemctl status lsfg-vk-overlay.service --no-pager
find /usr/lib -iname '*LS_frame*' -o -iname '*lsfg*'
find ~/.local/share/Steam/steamapps/common/'Lossless Scaling' -iname 'Lossless.dll'
cat ~/.config/fex-emu/Config.json
```


## Low-latency defaults

The default `~/lsfg` wrapper now applies the same low-latency settings that were validated on Armada after comparison with Rocknix:

```bash
export ENABLE_GAMESCOPE_WSI=1
export GAMESCOPE_DISABLE_ASYNC_FLIPS=0
export STEAM_GAMESCOPE_COLOR_MANAGED=0
export GAMESCOPE_NV12_COLORSPACE=
```

So the only Steam launch option needed per game is:

```bash
~/lsfg %command%
```
