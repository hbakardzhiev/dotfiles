{ ... }:
{
  # For GPU mining
  services.cgminer = {
    enable = true;
    pools = [
      {
        pass = "x";
        url = "stratum+tcp://mine.ocean.xyz:3334";
        user = "bc1qnslwaadh4n993uzg0hvsv8dn3029xhgfd4826c";
      }
    ];
    config = {
      auto-fan = true;
      auto-gpu = true;
      scan-time = 60;
    };
  };

  # systemd.user.services.miningBTC = {
  #   startAt = "10:00";
  #   wantedBy = [ "default.target" ];
  #   path = with pkgs; [
  #     cpuminer
  #   ];
  #   script = ''
  #     #!/bin/bash
  #     minerd -a sha256d -o stratum+tcp://mine.ocean.xyz:3334 -u bc1qnslwaadh4n993uzg0hvsv8dn3029xhgfd4826c -p x -t 3
  #   '';
  # };
  # For CPU mining but error in the current version
  # services.cpuminer-cryptonight = {
  #   enable = true;
  #   url = "stratum+tcp://mine.ocean.xyz:3334";
  #   threads = 2;
  #   user = "bc1qnslwaadh4n993uzg0hvsv8dn3029xhgfd4826c";
  # };
}
