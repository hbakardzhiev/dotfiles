# Hristo Bakardzhiev's Dotfiles

Welcome to my dotfiles repository! This collection is tailored for users who want to streamline their Linux environment setup, particularly focusing on NixOS, Home Manager, and utilizing flakes for configuration management.

## Status

![Flake Check badge](https://github.com/hbakardzhiev/dotfiles/actions/workflows/flakeCheck.yml/badge.svg)
![Lint badge](https://github.com/hbakardzhiev/dotfiles/actions/workflows/lint.yml/badge.svg)
![Security badge](https://github.com/hbakardzhiev/dotfiles/actions/workflows/security.yml/badge.svg)
![Build badge](https://github.com/hbakardzhiev/dotfiles/actions/workflows/build.yml/badge.svg)
![Config Checks badge](https://github.com/hbakardzhiev/dotfiles/actions/workflows/checks.yml/badge.svg)
![Docs & Hygiene badge](https://github.com/hbakardzhiev/dotfiles/actions/workflows/docs.yml/badge.svg)
![Update of flake badge](https://github.com/hbakardzhiev/dotfiles/actions/workflows/bump.yml/badge.svg)

## Overview

This repository leverages:

- **NixOS**: For system configuration and package management.
- **Home Manager**: To manage user-specific configurations.
- **Flakes**: An experimental feature in Nix for reproducible builds.
- **Sops**: For secrets management, ensuring your sensitive information stays secure.
- **LUKS**: This enabled encryption of the NVMe disk.

## Features

- **Modular Configuration**: Utilizing flakes to create a reproducible and modular setup, making it easier to manage and scale your configurations across different machines.
- **Secrets Management**: Integrated with Sops to encrypt and decrypt secrets seamlessly during your NixOS and Home Manager deployments.
- **Customizable**: Although specific customizations aren't detailed in the provided excerpts, the nature of dotfiles means everything is set up for personal customization.

## Getting Started

To start using these dotfiles:

1. **Clone this repository**:

   ```bash
   git clone https://github.com/hbakardzhiev/dotfiles.git
   cd dotfiles
   ```

2. **Setup with NixOS**:
   - Ensure you have Nix installed.
   - Use the flakes feature to build your system configuration:

     ```bash
     nix build .#nixosConfigurations.yourMachineName.config.system.build.toplevel
     ```

   Replace `yourMachineName` with the appropriate configuration name.

3. **Home Manager Setup**:
   - If you're using Home Manager standalone or within NixOS:

     ```bash
     home-manager switch --flake .#yourUsername@yourMachineName
     ```

   Again, customize `yourUsername` and `yourMachineName`.

4. **Secrets with Sops**:
   - Install Sops-Nix or ensure you have Sops installed.
   - Edit secrets as needed, encrypted with:

     ```bash
     sops your_secret_file.yaml
     ```

## CI

Seven workflows gate every push and PR. Only **Build** compiles anything —
everything else is text-level and finishes within minutes.

- **Flake Check** (`flakeCheck.yml`):
  - `nix flake check --no-update-lock-file`: evaluates the flake and fails if
    `flake.nix` and `flake.lock` disagree.
  - Matrix eval of each host toplevel (`alice`, `eve`, `bob`) without building
    — catches option/module eval errors early.
  - Per host: failed `assertions` fail the job; `warnings` surface as
    annotations (`STRICT_WARNINGS: "1"` in the workflow promotes them to
    errors once the tree is warning-free).
  - Effective SSH posture: an enabled sshd with password auth,
    keyboard-interactive auth or `PermitRootLogin = yes` fails the job.
- **Lint** (`lint.yml`):
  - `nixfmt --check` on all `.nix` files.
  - `deadnix --fail` for unused bindings.
  - [statix](https://github.com/nerdypepper/statix) with `statix.toml` (style nits W03/W10/W20 disabled).
  - Repo hygiene: merge-conflict markers, `flake.lock` present/valid JSON.
- **Security** (`security.yml`):
  - [gitleaks](https://github.com/gitleaks/gitleaks) full-history secret scan (config in `.gitleaks.toml`).
  - Asserts every `secrets/**/secrets.yaml` stays sops-encrypted and that no age private key is committed.
  - [actionlint](https://github.com/rhysd/actionlint) on workflow files.
  - [zizmor](https://docs.zizmor.sh/) security audit of the workflows themselves (config in `.github/zizmor.yml`).
  - Weekly scheduled rescan + manual dispatch.
- **Build** (`build.yml`): `nix build` of every host's toplevel, so build-only
  failures (bad hashes, broken build scripts) are caught before merge. Runs on
  **every commit** — each PR and each push to `main` — plus a weekly full
  build and manual dispatch.
- **Config Checks** (`checks.yml`) — repository-specific rules, implemented in
  `.github/scripts/`:
  - `sops_cross_check.py`: every literal `sops.secrets`/`sops.placeholder`
    reference resolves to a key in `secrets/**`, `.sops.yaml` creation rules
    cover every secrets file, and sops file paths exist. Unreferenced keys are
    warned about unless allowlisted in `.github/sops-unused-allowlist.txt`.
  - `policy_scan.py`: fails on plaintext `password = "..."` assignments in Nix
    code, sshd password auth in config, impure `builtins.getEnv`/
    `builtins.currentSystem`, unpinned container images, and any workflow
    `uses:` not pinned to a full 40-character commit SHA. Warnings (non-fatal)
    cover insecure plain-http URLs, `wheelNeedsPassword = false` and
    `permittedInsecurePackages`. Escape hatch: `# policy-ok: <rule-id>` on the
    offending line.
  - `lock_sync.py`: inputs and `follows` declared in `flake.nix` must match
    `flake.lock` (no Nix needed — pure text/JSON comparison).
  - `nix fmt` must leave the tree clean, proving the flake's declared
    formatter works.
- **Docs & Hygiene** (`docs.yml`):
  - [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) on all Markdown.
  - README ↔ workflow inventory: every workflow needs a status badge and a
    mention in this section, and every badge must point at a real workflow.
  - Text hygiene: trailing whitespace, missing EOF newlines, UTF-8 BOMs
    (Nix files are exempt from trailing whitespace — spaces inside `''…''`
    strings are content).
- **Bump** (`bump.yml`): daily `nix flake update` bot commit. The updated lock
  is verified first (`nix flake check` + eval of all three hosts), so a
  breaking lock bump fails the workflow instead of landing on `main`.
- **Dependabot**: weekly PRs for GitHub Actions version bumps, 7-day release
  cooldown.

All third-party actions are pinned to full commit SHA references (enforced by
`policy_scan.py`); Dependabot keeps the pins and their `# vX` comments fresh.

GitHub secret scanning and push protection are also enabled on the repo.

## Customization

- **Edit the flake.nix**: Here you can add or modify inputs and outputs to suit additional needs or different system configurations.
- **Configuration Files**: Dive into the `configuration.nix` or `home.nix` files to tweak your system and home settings respectively.

## Notes

- **Wayland Support**: Given the trend towards Wayland, like with Sway (a tiling Wayland compositor), ensure your applications are compatible or look into XWayland for legacy support if you switch from traditional X11 setups.
- **Security**: Remember, dotfiles often contain personal configurations. This repo uses Sops for secrets, but always review what you make public.

## Contribution

Feel free to fork this repository, make it your own, or contribute back with pull requests for improvements or bug fixes.
