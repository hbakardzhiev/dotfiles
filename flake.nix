{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/2a0beb52294a22f28a2eb0c2a1d41aba088d6dfd";
    home-manager.url = "github:nix-community/home-manager";
    nix-bitcoin = {
      url = "github:fort-nix/nix-bitcoin/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nur,
      sops-nix,
      nix-bitcoin,
      ...
    }:
    let
      pc = "alice";
      server = "eve";
      maastricht = "bob";
    in
    {
      nixosConfigurations = {
        ${pc} = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit sops-nix;
          }; # Pass flake inputs to our config
          system = "x86_64-linux";
          modules = [
            ./${pc}.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ nur.overlay ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];

              home-manager.users.alice = import ./home.nix;
              home-manager.extraSpecialArgs = {
                hostname = pc;
              };
              home-manager.backupFileExtension = "hm-backup";
            }
            sops-nix.nixosModules.sops
          ];
        };
        ${server} = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./${server}.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];

              home-manager.users.alice = import ./home.nix;
              home-manager.extraSpecialArgs = {
                hostname = server;
              };
              home-manager.backupFileExtension = "hm-backup";
            }
            sops-nix.nixosModules.sops
          ];
        };
        ${maastricht} = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit sops-nix;
            inherit nix-bitcoin;
          }; # Pass flake inputs to our config
          modules = [
            ./${maastricht}.nix
            # nix-bitcoin.nixosModules.default
            # {
            #   # Automatically generate all secrets required by services.
            #   # The secrets are stored in /etc/nix-bitcoin-secrets
            #   nix-bitcoin.generateSecrets = true;

            #   # Enable some services.
            #   # See ../configuration.nix for all available features.
            #   services.bitcoind.enable = true;
            #   services.bitcoind.dataDir = "/run/media/et1";
            #   services.clightning.enable = true;

            #   # When using nix-bitcoin as part of a larger NixOS configuration, set the following to enable
            #   # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
            #   nix-bitcoin.operator = {
            #     enable = true;
            #     name = "alice";
            #   };
            # }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];

              home-manager.users.alice = import ./home.nix;
              home-manager.extraSpecialArgs = {
                hostname = maastricht;
              };
              home-manager.backupFileExtension = "hm-backup";
            }
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
