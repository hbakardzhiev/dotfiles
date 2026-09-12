{ pkgs, ... }:
let
  openclawStateDir = "/var/lib/openclaw";
  openclawImage = "ghcr.io/openclaw/openclaw:latest";
in
{
  # Podman as the OCI runtime (docker-compatible CLI, used by OpenClaw's sandbox tooling)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Containerized OpenClaw Gateway (pre-built image, no local source build).
  # Host networking: the gateway's default bind "loopback" then resolves to the
  # host loopback, so the Control UI is reachable at 127.0.0.1:18789 without
  # relying on DNAT/port-forwarding into the container (which conflicts with a
  # loopback bind and returns connection-refused).
  virtualisation.oci-containers = {
    backend = "podman";
    containers.openclaw = {
      image = openclawImage;
      networks = [ "host" ];
      autoStart = true;
      volumes = [
        "${openclawStateDir}:/home/node/.openclaw"
      ];
    };
  };

  # State dir writable by the container's `node` user (uid/gid 1000)
  systemd.tmpfiles.rules = [
    "d ${openclawStateDir} 0750 1000 1000 -"
  ];

  users.users.alice.extraGroups = [ "podman" ];

  # One-time interactive onboarding (prompts for provider API keys, generates
  # the Gateway token, writes config into the mounted state dir).
  # Must run through rootful podman (sudo) to match the gateway container's
  # uid mapping and storage; rootless podman cannot access the state dir.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "openclaw-onboard" ''
      if sudo ${pkgs.podman}/bin/podman exec openclaw true 2>/dev/null; then
        exec sudo ${pkgs.podman}/bin/podman exec -it openclaw \
          node dist/index.js onboard --mode local --no-install-daemon
      else
        exec sudo ${pkgs.podman}/bin/podman run --rm -it \
          -v ${openclawStateDir}:/home/node/.openclaw \
          --entrypoint node \
          ${openclawImage} \
          dist/index.js onboard --mode local --no-install-daemon
      fi
    '')
  ];
}