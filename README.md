# OpenChamber Nix Flake

A Nix Flake for [OpenChamber](https://github.com/openchamber/openchamber), a web interface and CLI daemon for the OpenCode AI coding agent.

This flake provides:
* **`openchamber` package**: The OpenChamber web service and CLI wrapped with its runtime dependencies (`bun`, `git`, `openssh`, `cloudflared`, and `opencode`).
* **NixOS Module**: Declarative configuration and systemd service management.
* **Home Manager Module**: User-level configuration and user systemd service management.
* **Options Documentation**: Automatically generated options reference.

---

## Installation & Usage

### 1. NixOS Module

Add the flake to your inputs in `flake.nix`:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  openchamber-flake.url = "git+https://github.com/openchamber/openchamber-flake"; # Replace with your repo url
};
```

Then import the NixOS module into your system configuration:

```nix
{ inputs, config, pkgs, ... }: {
  imports = [
    inputs.openchamber-flake.nixosModules.openchamber
  ];

  services.openchamber = {
    enable = true;
    port = 3000;
    host = "127.0.0.1";
    
    # Securely supply the UI password
    uiPasswordFile = "/run/keys/openchamber-password";

    # Declarative settings (translates directly to settings.json)
    settings = {
      themeVariant = "dark";
      darkThemeId = "default";
      desktopLanAccessEnabled = false;
    };
  };
}
```

Detailed NixOS options are documented in [docs/NIXOS_OPTIONS.md](./docs/NIXOS_OPTIONS.md).

### 2. Home Manager Module

Import the Home Manager module in your user environment:

```nix
{ inputs, config, pkgs, ... }: {
  imports = [
    inputs.openchamber-flake.homeManagerModules.openchamber
  ];

  services.openchamber = {
    enable = true;
    port = 3001;
    
    # For Home Manager, dataDir defaults to ~/.config/openchamber
    settings = {
      themeVariant = "dark";
    };
  };
}
```

Detailed Home Manager options are documented in [docs/HOME_MANAGER_OPTIONS.md](./docs/HOME_MANAGER_OPTIONS.md).

---

## Option Documentation

To re-generate and update the Markdown documentation for the options, run:

```bash
nix run .#generate-docs
```

This will write the updated documentation directly to:
* [docs/NIXOS_OPTIONS.md](./docs/NIXOS_OPTIONS.md)
* [docs/HOME_MANAGER_OPTIONS.md](./docs/HOME_MANAGER_OPTIONS.md)

---

## Upgrades and Maintenance

The package configuration is compatible with `nix-update` for fully automated version and hash bumps.

To bump OpenChamber to the latest version, run:

```bash
nix-update openchamber --flake
```

This command will:
1. Retrieve the latest release tag from GitHub.
2. Update the `version` and the source `hash` in `pkgs/openchamber.nix`.
3. Clear the `npmDepsHash` dependency cache hash and trigger a build to determine the new hash.
4. Write the final verified hash back to the package definition.

---

## Running Integration Tests

To run the NixOS VM integration test locally (requires Linux):

```bash
nix build .#checks.x86_64-linux.openchamber-integration-test --no-link
```
