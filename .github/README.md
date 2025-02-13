# Hristo Bakardzhiev's Dotfiles

Welcome to my dotfiles repository! This collection is tailored for users who want to streamline their Linux environment setup, particularly focusing on NixOS, Home Manager, and utilizing flakes for configuration management.

## Status
![Flake Check badge](https://github.com/hbakardzhiev/dotfiles/actions/workflows/flakeCheck.yml/badge.svg)
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

## Customization

- **Edit the flake.nix**: Here you can add or modify inputs and outputs to suit additional needs or different system configurations.
- **Configuration Files**: Dive into the `configuration.nix` or `home.nix` files to tweak system and home settings respectively.

## Notes

- **Wayland Support**: Given the trend towards Wayland, like with Sway (a tiling Wayland compositor), ensure your applications are compatible or look into XWayland for legacy support if you switch from traditional X11 setups.
- **Security**: Remember, dotfiles often contain personal configurations. This repo uses Sops for secrets, but always review what you make public.

## Contribution

Feel free to fork this repository, make it your own, or contribute back with pull requests for improvements or bug fixes.
