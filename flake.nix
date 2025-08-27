{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/d63062affaf262d46d9fdcce40bb8c4ccb936d54";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    nix-bitcoin = {
      url = "github:fort-nix/nix-bitcoin/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      sops-nix,
      nix-bitcoin,
      nixpkgs-unstable,
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
            hostname = pc;
            inherit sops-nix;
          }; # Pass flake inputs to our config
          system = "x86_64-linux";
          modules = [
            ./${pc}.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];

              home-manager.users.alice = import ./home.nix;
              home-manager.extraSpecialArgs = {
                hostname = pc;
                nixpkgs-unstable = import nixpkgs-unstable { system = "x86_64-linux";} ;
              };
              home-manager.backupFileExtension = "hm-backup";
            }
            sops-nix.nixosModules.sops
          ];
        };
        ${server} = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            hostname = server;
          };
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
            hostname = maastricht;
            inherit sops-nix;
            inherit nix-bitcoin;
          }; # Pass flake inputs to our config
          modules = [
            ./${maastricht}.nix
            nix-bitcoin.nixosModules.default
            {
              imports = [
                (nix-bitcoin + /modules/presets/secure-node.nix)
              ];
            }
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
