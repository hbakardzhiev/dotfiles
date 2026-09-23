{
  config,
  lib,
  pkgs,
  sopsFile ? ../../../../secrets/lnd/secrets.yaml,
  ...
}:
let
  dataDir = "/var/lib/lnd";
  network = "mainnet";
  networkDir = "${dataDir}/chain/bitcoin/${network}";
  user = "lnd";
  group = "lnd";

  passwordFile = config.sops.secrets."wallet-password".path;
  lndinit = "${pkgs.lndinit}/bin/lndinit";

  rpcAddress = "127.0.0.1";
  rpcPort = 10009;
  restAddress = "127.0.0.1";
  restPort = 8080;
  p2pAddress = "127.0.0.1";
  p2pPort = 9735;

  neutrinoPeers = [
    "btcd-mainnet.lightning.computer:8333"
    "btcd0.lightning.engineering:8333"
    "bb1.breez.technology:8333"
    "bb2.breez.technology:8333"
    "node.eldamar.icu:8333"
    "neutrino.noderunner.wtf:8333"
  ];

  lndConf = pkgs.writeText "lnd.conf" ''
    datadir=${dataDir}
    tlscertpath=${dataDir}/tls.cert
    tlskeypath=${dataDir}/tls.key

    listen=${p2pAddress}:${toString p2pPort}
    rpclisten=${rpcAddress}:${toString rpcPort}
    restlisten=${restAddress}:${toString restPort}

    bitcoin.active=1
    bitcoin.${network}=1
    bitcoin.node=neutrino

    wallet-unlock-password-file=${passwordFile}
    db.bolt.auto-compact=true
    routing.strictgraphpruning=true

    [neutrino]
    ${lib.concatMapStrings (peer: "neutrino.addpeer=${peer}\n") neutrinoPeers}

    [fee]
    fee.url=https://nodes.lightning.computer/fees/v1/btc-fee-estimates.json
  '';

  lncli = pkgs.writeShellScriptBin "lncli" ''
    exec /run/wrappers/bin/sudo -n -u ${user} ${pkgs.lnd}/bin/lncli \
      --rpcserver=${rpcAddress}:${toString rpcPort} \
      --tlscertpath='${dataDir}/tls.cert' \
      --macaroonpath='${networkDir}/admin.macaroon' \
      "$@"
  '';

  # lndconnect QR for Zeus: host:8080 + macaroon query param (not in hostname)
  lnd-qr = pkgs.writeShellScriptBin "lnd-qr" ''
    set -euo pipefail
    macaroon=$(/run/wrappers/bin/sudo -n -u ${user} ${pkgs.coreutils}/bin/base64 -w0 '${networkDir}/admin.macaroon' \
      | tr '+/' '-_' | tr -d '=')
    uri="lndconnect://lnd.tail6dbb0b.ts.net:8080?macaroon=$macaroon"
    echo "$uri"
    ${pkgs.qrencode}/bin/qrencode -t ANSIUTF8 "$uri"
  '';

  nodeinfo = pkgs.writeShellScriptBin "nodeinfo" ''
    set -euo pipefail

    echo "=== LND (neutrino) ==="
    if ! systemctl is-active --quiet lnd; then
      echo "lnd.service: inactive"
      exit 0
    fi
    echo "lnd.service: active"

    info="$(lncli getinfo 2>/dev/null || true)"
    if [[ -z "$info" ]]; then
      echo "lncli getinfo: unavailable (still starting?)"
      exit 0
    fi

    get() { jq -r ".''${1} // \"n/a\"" <<<"$info"; }

    echo "version:          $(get version)"
    echo "identity:         $(get identity_pubkey)"
    echo "alias:            $(get alias)"
    echo "network:          $(jq -r '.chains[0].network // "n/a"' <<<"$info")"
    echo "backend:          neutrino"
    echo "block_height:     $(get block_height)"
    echo "synced_to_chain:  $(get synced_to_chain)"
    echo "synced_to_graph:  $(get synced_to_graph)"
    echo "peers:            $(get num_peers)"
    echo "channels:         active=$(get num_active_channels) pending=$(get num_pending_channels) inactive=$(get num_inactive_channels)"

    bal="$(lncli walletbalance 2>/dev/null || true)"
    if [[ -n "$bal" ]]; then
      echo "onchain_total:    $(jq -r '.total_balance // "n/a"' <<<"$bal") sat"
      echo "onchain_confirmed:$(jq -r '.confirmed_balance // "n/a"' <<<"$bal") sat"
    fi

    chan="$(lncli channelbalance 2>/dev/null || true)"
    if [[ -n "$chan" ]]; then
      echo "channel_local:    $(jq -r '.local_balance // "n/a"' <<<"$chan") sat"
      echo "channel_remote:   $(jq -r '.remote_balance // "n/a"' <<<"$chan") sat"
    fi

    echo
    echo "=== Storage ==="
    sudo -n -u ${user} ${pkgs.coreutils}/bin/du -sh "${dataDir}" 2>/dev/null \
      | awk '{print "dataDir:  "$1"  "$2}' || echo "dataDir:  (unreadable)"
    if sudo -n -u ${user} ${pkgs.coreutils}/bin/test -d '${networkDir}' 2>/dev/null; then
      sudo -n -u ${user} ${pkgs.coreutils}/bin/du -sh '${networkDir}' 2>/dev/null \
        | awk '{print "network:  "$1"  "$2}'
    fi
    for f in neutrino.db block_headers.bin reg_filter_headers.bin; do
      p='${dataDir}/data/chain/bitcoin/${network}/'"$f"
      if sudo -n -u ${user} ${pkgs.coreutils}/bin/test -f "$p" 2>/dev/null; then
        size=$(sudo -n -u ${user} ${pkgs.coreutils}/bin/du -h "$p" 2>/dev/null | cut -f1)
        printf '%-24s %s\n' "$f:" "$size"
      fi
    done

    echo
    echo "=== Neutrino peers (configured) ==="
    ${lib.concatMapStrings (peer: "echo \"  - ${peer}\"\n") neutrinoPeers}
    peers="$(lncli listpeers 2>/dev/null | jq -r '.peers[]?.address // empty' || true)"
    if [[ -n "$peers" ]]; then
      echo
      echo "=== Connected peers ==="
      while IFS= read -r addr; do
        echo "  - $addr"
      done <<<"$peers"
    fi
  '';
in
{
  sops.secrets."wallet-password" = {
    owner = user;
    group = group;
    mode = "0400";
    sopsFile = sopsFile;
  };

  users.users.${user} = {
    isSystemUser = true;
    group = group;
    home = dataDir;
  };
  users.groups.${group} = { };

  users.users.alice.extraGroups = [ group ];
  security.sudo.extraRules = [
    {
      users = [ "alice" ];
      runAs = user;
      commands = [
        {
          command = "${pkgs.lnd}/bin/lncli";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.coreutils}/bin/du";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.coreutils}/bin/test";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.coreutils}/bin/base64";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = [
    (lib.hiPrio lncli) # else stock lncli from pkgs.lnd shadows it
    (lib.hiPrio nodeinfo)
    (lib.hiPrio lnd-qr)
    pkgs.jq
    pkgs.lnd
    pkgs.qrencode
  ];

  systemd.tmpfiles.rules = [
    "d '${dataDir}' 0750 ${user} ${group} - -"
  ];

  systemd.services.lnd = {
    description = "LND Lightning Network daemon (neutrino)";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    preStart = ''
      install -m600 ${lndConf} '${dataDir}/lnd.conf'
      mkdir -p '${networkDir}'

      if [[ ! -f '${networkDir}/wallet.db' ]]; then
        seed='${dataDir}/lnd-seed-mnemonic'

        if [[ ! -f "$seed" ]]; then
          echo "Create lnd seed (BACK UP ${dataDir}/lnd-seed-mnemonic NOW)"
          (umask u=r,go=; ${lndinit} gen-seed > "$seed")
        fi

        echo "Create lnd wallet"
        ${lndinit} -v init-wallet \
          --file.seed="$seed" \
          --file.wallet-password='${passwordFile}' \
          --init-file.output-wallet-dir='${networkDir}'
      fi
    '';

    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      ExecStart = "${pkgs.lnd}/bin/lnd --configfile='${dataDir}/lnd.conf'";
      Restart = "on-failure";
      RestartSec = "10s";
      TimeoutStopSec = "30s";
      UMask = "0077";
      NoNewPrivileges = true;
      ProtectHome = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ dataDir ];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };
}
