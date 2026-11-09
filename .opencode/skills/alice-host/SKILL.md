---
name: Alice host
description: Explain and work on the `alice` NixOS laptop in /etc/nixos - how it is wired into flake.nix, how it evaluates and builds, its disk layout, hardware, Hyprland desktop, services, secrets and module discovery. Use for any question, review or change involving the alice machine.
---

# The `alice` host

`alice` is the daily-driver laptop and the primary machine in this repository.
The same flake also defines `eve` (server) and `bob` (Maastricht machine), but
this skill only describes `alice`.

Key facts:

- It runs **nixpkgs-unstable** with **home-manager-unstable**, not the stable
  channel. The `nixpkgs` input pinned to `nixos-26.05` is still used for the
  flake formatter and is exposed to Home Manager as `pkgs-stable`.
- The live system reports `26.11.2026110...` while `system.stateVersion` in
  `alice.nix` is `26.11` and Home Manager's `home.stateVersion` is `24.11`.
- The repo is `git@github.com:hbakardzhiev/dotfiles.git`, checked out at
  `/etc/nixos` on the machine. The hostname is set by the config, not by
  `nixos-generate-config`.
- It is an Intel + NVIDIA hybrid laptop with a LUKS-encrypted root, a separate
  LUKS data disk, Hyprland on Wayland, and a headless OpenCode server.

## Quick commands

Run these from `/etc/nixos`:

```bash
# Evaluate only (fast failure check, same as CI)
nix eval --raw .#nixosConfigurations.alice.config.system.build.toplevel.drvPath

# Build without switching
nix build .#nixosConfigurations.alice.config.system.build.toplevel

# Apply locally
sudo nixos-rebuild switch --flake .#alice
sudo nixos-rebuild boot --flake .#alice

# Roll back the running generation
sudo nixos-rebuild switch --rollback

# Whole-flake checks and formatting (CI parity)
nix flake check --no-update-lock-file
nix fmt .
```

The activation script runs `nvd diff /run/current-system "$systemConfig"` so a
switch prints a package/version diff.

## How `alice` is built

The build path is:

1. `flake.nix` sets `pc = "alice"` and creates
   `nixosConfigurations.alice` with `nixpkgs-unstable.lib.nixosSystem`.
2. Its `specialArgs` are `hostname = "alice"`, `sops-nix`, and
   `pkgs-unstable`. NixOS modules can therefore take `hostname`, `sops-nix`
   and `pkgs-unstable` as arguments.
3. The module list is:
   - `./alice.nix` - the host entry point.
   - `disko.nixosModules.disko`.
   - `home-manager-unstable.nixosModules.home-manager` plus an inline
     Home Manager block.
   - `sops-nix.nixosModules.sops`.
4. The inline Home Manager block sets `useGlobalPkgs`, `useUserPackages`,
   `sharedModules = [ sops-nix.homeManagerModules.sops ]`, and imports
   `./home.nix` as `home-manager.users.alice`. Its `extraSpecialArgs` are
   `hostname = "alice"`, `pkgs-unstable`, and `pkgs-stable = pkgs` (the stable
   26.05 package set). `backupFileExtension = "backup"`.

`alice.nix` is the real entry point even though it still carries the
`nixos-generate-config` header. It defines `hostname = "alice"` and
`username = "alice"` in a `let`, imports `./sops.nix`, and then imports every
Nix file under `modules/system/alice` and `modules/system/shared`.

### Automatic module discovery

`modules/functions/getNixFiles.nix` recursively returns every `*.nix` file
below a directory. Both `alice.nix` and `home.nix` use it:

- NixOS: `modules/system/<hostname>` + `modules/system/shared`.
- Home Manager: `modules/homeManager/<hostname>` + `modules/homeManager/shared`.

Consequences:

- Dropping a new `.nix` file into `modules/system/alice/` or
  `modules/system/shared/` imports it automatically; no import list to edit.
- Files ending in `.nix.bak` (or `.orig`) are **not** imported, because only
  `*.nix` matches. Several features are intentionally disabled that way.
- The directory name must match the hostname: `modules/system/alice` for this
  host. Renaming the flake attribute alone is not enough.

## Repository map for `alice`

| Path | Purpose |
| --- | --- |
| `flake.nix` | Inputs, all three hosts, Home Manager wiring, `alice-iso` |
| `alice.nix` | Host entry point: modules, hostname, disks, services |
| `home.nix` | Home Manager entry point for user `alice` |
| `sops.nix` | Shared sops settings (also imported by Home Manager) |
| `modules/system/alice/` | Alice-only NixOS modules |
| `modules/system/shared/` | NixOS modules for all hosts |
| `modules/homeManager/alice/` | Alice-only Home Manager modules |
| `modules/homeManager/shared/` | Home Manager modules for all hosts |
| `modules/installer/alice-iso.nix` | On-demand `alice-iso` installer image |
| `modules/functions/getNixFiles.nix` | Recursive `.nix` file discovery |
| `modules/system/shared/options/` | Custom options: networking, opencode, android, docker, nextcloud, secrets, lidswitch |
| `secrets/` | sops-encrypted YAML and `.sops.yaml` recipients |
| `.github/workflows/` | CI: eval, build, lint, security, ISO, lock bump |

## Boot, disks and filesystems

Declarative disk layout lives in `modules/system/alice/disko.nix` and is
applied **only** by running disko from the installer:

```bash
disko --mode destroy,format,mount --flake github:hbakardzhiev/dotfiles#alice
```

It targets one disk by stable by-id path
(`/dev/disk/by-id/nvme-PUSKILL_SSD_512GB_00000000000410`):

- `ESP` (2 GB, EFI, vfat) mounted at `/boot` with `fmask=0077,dmask=0077`.
- `root` (remaining space) is a LUKS container named `cryptroot` with
  `allowDiscards = true`, containing ext4 mounted at `/`.

Nothing in disko runs at boot or activation. `hardware-configuration.nix`
deliberately does not declare the root/ESP filesystems; disko owns them.

The data disk is outside the disko layout. In `alice.nix`:

- `boot.initrd.luks.devices.data.device` is the data disk's by-UUID path
  (`e0f556fe-81c6-46f9-8243-f8b5f18e8b86`), so it keeps its existing LUKS
  container and is opened as `/dev/mapper/data`.
- `/drives/data` is ext4 from `/dev/mapper/data`.

The root LUKS container is unlocked interactively at boot. There is no disk
swap; `zramSwap.enable = true` comes from the Hyprland module.

Boot loader and kernel:

- systemd-boot with `efi.canTouchEfiVariables = true`.
- Kernel params: `mitigations=off` (shared) and
  `psmouse.synaptics_intertouch=0` (alice).
- `boot.tmp.cleanOnBoot = true`; NTFS support enabled.

## Hardware

`modules/system/alice/hardware-configuration.nix` describes an Intel laptop
with a discrete NVIDIA Quadro P1000:

- `services.xserver.videoDrivers = [ "nvidia" "intel" ]`.
- NVIDIA `legacy_580` branch, `modesetting.enable = true`,
  `powerManagement.enable = true`, `open = false`, `nvidiaSettings = true`.
- PRIME **offload** (not sync), with `enableOffloadCmd = true`,
  `intelBusId = "PCI:0:2:0"`, `nvidiaBusId = "PCI:1:0:0"`.
- Intel microcode, `powerManagement.cpuFreqGovernor = "powersave"`.
- `fwupd`, `thermald`, `irqbalance`, `power-profiles-daemon`, `upower`,
  `udisks2`, and `services.fstrim.enable`.

The shared configuration adds Intel VA-API userspace drivers
(`intel-media-driver`, `intel-vaapi-driver`, `intel-compute-runtime`, etc.) and
sets `LIBVA_DRIVER_NAME = "iHD"` in the user session.

## Networking and remote access

- Hostname is not hard-coded in `networking.hostName`; it comes from
  `tools.networking.hostname` in `alice.nix`, which sets
  `networking.hostName = "alice"`.
- NetworkManager is the network stack (`enableIwdWifi = false`), with
  `nameservers = [ "1.1.1.1" "9.9.9.9" ]` and the firewall enabled.
- OpenSSH is enabled with `PasswordAuthentication = false`,
  `KbdInteractiveAuthentication = false`, and Alice's authorized keys.
  `openFirewall` is false, so SSH is reached over the tailnet or LAN only if
  another rule allows it.
- Tailscale is enabled from the unstable package in
  `modules/system/shared/vpn/tailscale.nix` (`useRoutingFeatures` plus the
  alice override `"client"`), opens UDP 41641, and installs
  `tailscale-systray`. Alice's Hyprland autostart launches the systray.
- The headless OpenCode server from `services.opencode` binds
  `127.0.0.1:4096` by default. It runs as user `alice` via a lingering user
  systemd service (`opencode serve --hostname ... --port ...`). Its basic-auth
  username is `opencode`; set `services.opencode.hostname = "0.0.0.0"` only
  when access over Tailscale is intended. Its machine config is written to
  `/etc/opencode/opencode.json` with MCP servers `nixos`,
  `language-server` (`nil`), `fetch`, `memory`, and `playwright`.

## Desktop and session

`modules/system/alice/wm/hyprland.nix`:

- `programs.hyprland.enable = true`, `withUWSM = false`,
  `xwayland.enable = false` (XWayland is intentionally off).
- SDDM with the Wayland greeter, default session `hyprland`, and autologin for
  `alice` (`services.displayManager.autoLogin`). `relogin` is false, so an
  explicit logout drops back to the greeter. Autologin is acceptable because
  the root and data disks are LUKS encrypted and `hyprlock` guards idle.
- `programs.dconf.enable`, GNOME keyring, polkit, and a PAM service for
  `hyprlock` (required to unlock).
- `services.logind.settings.Login.InhibitDelayMaxSec = 15` so the lock screen
  can appear before the five-second suspend inhibitor expires.
- zram swap, common fonts, and a long list of session tools (grim, slurp,
  wl-clipboard, brightnessctl, playerctl, networkmanager, blueman, etc.).

Home Manager owns the compositor configuration:

- `modules/homeManager/alice/hypr/hyprland.nix` writes Hyprland **Lua**
  config (`configType = "lua"`) because Hyprland 0.57 dropped hyprlang.
  Keybinds use `hl.dsp.*` dispatchers; `SUPER + D` opens fuzzel, `SUPER + L`
  locks, four-finger horizontal swipe changes workspace.
- Autostart: `hyprsunset`, `mako`, `thunderbird`, `nextcloud`,
  `tailscale-systray`, `udiskie --automount --no-tray`.
- `hypridle` locks after 5 minutes, turns DPMS off after 5.5 minutes, and
  suspends after 30 minutes. `hyprlock` uses its own PAM service.
- `waybar` is at the bottom with workspaces, window title, clock/calendar,
  disk-health, language, audio, network, Bluetooth, backlight, battery, tray.
- `fuzzel` is the launcher; `fuzzel-power` is the power menu.
- `tools.lidswitch.enable = false`, so the custom lid-switch overrides are
  off and logind's normal lid handling applies.

## Services and integrations on `alice`

Enabled in `alice.nix` and alice modules:

- `cloud.nextcloud.client.upload.enable = true` - `nextcloudcmd` user
  services at 10:00 upload `/drives/data/obsidian`,
  `/drives/data/configurationBackup`, and `/drives/data/Passwords` to the
  Nextcloud instance, using sops-provided credentials.
- `services.opencode` on port 4096.
- Bluetooth (`hardware.bluetooth`, `blueman`), printing (CUPS with `brlaser`
  drivers) plus Avahi, Wireshark, `pcscd` for smart cards/electronic
  signature, Tor client, and `trezord`.
- PipeWire with WirePlumber, `gvfs`, `udisks2`, `upower`, `fwupd`.
- `system.autoUpgrade` from `modules/system/shared/update/update.nix`:
  daily at 03:00, pulling
  `https://github.com/hbakardzhiev/dotfiles/archive/main.tar.gz#alice`,
  with `--no-write-lock-file`, a 45-minute randomized delay, reboot window
  04:00-06:00, and `allowReboot = true`. Pushing to `main` is what reaches
  the machine automatically.

User timers:

- `upload-github`: every 2 minutes after boot, commits and pushes
  `/drives/data/obsidian`.
- `sync-hypr-config`: 3 minutes after startup, copies `~/.config/hypr` to
  `/drives/data/configs/hypr` when that directory exists.

Disabled on purpose (mostly by `.bak` suffix or explicit flags):

- Docker (`custom.containers.docker.enable = false`).
- Android tooling (`tools.android.enable = false`, no Android Studio).
- Syncthing, mining, OpenClaw, Remix IDE, RStudio, .NET dev tools, Floorp,
  and some backup configs exist as `.nix.bak` files and are not evaluated.
- `pkgs.linuxKernel.packages.linux_zen` is commented out; the default kernel
  is used.

## Secrets

- sops-nix is enabled for both NixOS and Home Manager.
- `sops.nix` at the repo root sets
  `age.keyFile = "/home/alice/.config/sops/age/keys.txt"` (an unencrypted age
  key that must exist on the target), `defaultSopsFormat = "yaml"`, and
  `defaultSopsFile = ./secrets/allSecrets/secrets.yaml`.
- `modules/system/shared/sops.nix` declares many `sops.secrets` entries and
  assembles the `privateLaptop*` and `rsa*` fragments into
  `/home/alice/.ssh/id_ed25519` and `/home/alice/.ssh/id_rsa` via
  `sops.templates`, owned by `alice` with mode `0600`.
- Nextcloud credentials (`nextcloud/username`, `nextcloud/Password`) are
  declared by `modules/system/shared/options/secrets/nextcloud.nix`.
- Encrypted files live under `secrets/`; `.sops.yaml` defines the age
  recipient and creation rules. Never commit a decrypted file or the age
  private key.
- CI (`sops_cross_check.py`) fails if a `sops.secrets`/`sops.placeholder`
  reference has no matching key, if a secrets file is not covered by
  `.sops.yaml`, or if a referenced file is missing. Unused keys are warning
  unless allowlisted.

## Home Manager

`home.nix` imports `modules/homeManager/alice`, `modules/homeManager/shared`,
and `sops.nix`; creates user `alice` with home `/home/alice`;
enables `programs.home-manager`; adds `htop`, `p7zip`, `udiskie`, `tree`.

Alice-only Home Manager modules cover:

- Hyprland/Hyprlock/Hypridle/powermenu, Waybar and its `disk-health` helper,
  fuzzel, mako, session variables, XDG MIME defaults.
- Apps (LibreOffice, Xournal++, wl-mirror, etc.), Chromium (the browser module
  is named `browsers/default.nix`; `package = pkgs.chromium`), Electrum,
  Obsidian notes, OBS, pomodoro, Postman, TradingView, Zathura, drawing tools.
- Shared modules add Helix, Vim, git identity, Alacritty, and Bash aliases
  (including `gitnixos`, which commits and pushes `/etc/nixos`).

Home Manager's user is always `alice` in all three hosts, but the modules
selected depend on the `hostname` special argument.

## Installer image (`alice-iso`)

`modules/installer/alice-iso.nix` builds a minimal NixOS installer:

```bash
nix build .#nixosConfigurations.alice-iso.config.system.build.isoImage
```

- Image edition is forced to `alice`; live hostname is `alice-installer`.
- Includes flakes, `disko`, `git`, `curl`, `vim`, `tailscale`.
- Root SSH keys are baked in, sshd and Tailscale are enabled for headless
  installs.
- It ships **no** disk layout; the target is partitioned manually with disko.
- `/etc/alice-install.txt` documents the install flow:

  ```bash
  disko --mode destroy,format,mount --flake github:hbakardzhiev/dotfiles#alice
  nixos-install --flake github:hbakardzhiev/dotfiles#alice
  ```

- The age key must be restored to `/home/alice/.config/sops/age/keys.txt`
  before first boot, otherwise secrets cannot be activated.

CI builds the ISO only on manual `workflow_dispatch`, uploads it with
`SHA256SUMS`, and keeps it for 30 days.

## CI and repository conventions that affect alice

Every push/PR runs:

- `nix flake check --no-update-lock-file` and a matrix eval of `alice`,
  `eve`, `bob`; failed assertions fail, warnings are annotations.
- A full `nix build` of each host's toplevel (including `alice`), plus a
  weekly scheduled build.
- `nixfmt --check`, `deadnix --fail`, `statix` with `statix.toml`.
- sops wiring cross-check, lock-file agreement, formatter cleanliness.
- gitleaks, sops encryption/age-key checks, actionlint, zizmor.
- markdownlint on all Markdown (`MD013` is disabled) and text hygiene.
- `policy_scan.py`, which also scans Markdown and **warns on plain `http://`
  URLs** (localhost/127.0.0.1 are exempt), errors on plaintext password
  assignments in Nix, impure calls, unpinned images/actions.

Practical rules when editing:

- Keep `hostname` in `alice.nix` and the flake attribute `alice` consistent.
- Put host-only NixOS code in `modules/system/alice/`; cross-host code in
  `modules/system/shared/`; the equivalents for the user in
  `modules/homeManager/`.
- Name new files `*.nix`. A `.nix.bak` is silently ignored, which is the
  intended way to park disabled modules.
- Do not add the data disk to disko. Do not run disko against a live system:
  it destroys the named NVMe.
- Push to `main` for `system.autoUpgrade` to pick changes up; a local
  `nixos-rebuild` only changes the current machine.
- Use `pkgs-stable` (from `nixpkgs` 26.05) only when a package is missing or
  broken on unstable; alice is otherwise an unstable host.
