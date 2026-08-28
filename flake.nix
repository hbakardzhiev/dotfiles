{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/d63062affaf262d46d9fdcce40bb8c4ccb936d54";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    sovran = {
      url = "git+https://git.sovransystems.com/Sovran_Systems/Sovran_SystemsOS?ref=stable";
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
      sovran,
      nixpkgs-unstable,
      ...
    }:
    let
      pc = "alice";
      server = "eve";
      maastricht = "bob";
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      formatter.x86_64-linux = pkgs.nixfmt-tree;
      nixosConfigurations = {
        ${pc} = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostname = pc;
            inherit sops-nix;
            inherit pkgs-unstable;
          }; # Pass flake inputs to our config
          inherit system;
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
                inherit pkgs-unstable;
              };
              home-manager.backupFileExtension = "backup";
            }
            sops-nix.nixosModules.sops
          ];
        };
        ${server} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            hostname = server;
            inherit pkgs-unstable;
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
                inherit pkgs-unstable;
              };
              home-manager.backupFileExtension = "hm-backup";
            }
            sops-nix.nixosModules.sops
          ];
        };
        ${maastricht} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            hostname = maastricht;
            inherit sops-nix;
            inherit pkgs-unstable;
          }; # Pass flake inputs to our config
          modules = [
            ./${maastricht}.nix
            "${sovran}/modules/bitcoin"
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];

              home-manager.users.alice = import ./home.nix;
              home-manager.extraSpecialArgs = {
                hostname = maastricht;
                inherit pkgs-unstable;
              };
              home-manager.backupFileExtension = "hm-backup";
            }
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
