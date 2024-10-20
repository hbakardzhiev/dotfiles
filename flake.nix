{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/2a0beb52294a22f28a2eb0c2a1d41aba088d6dfd";
    home-manager.url = "github:nix-community/home-manager";
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
              home-manager.backupFileExtension = "rebuild";
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
              home-manager.backupFileExtension = "rebuild";
            }
            sops-nix.nixosModules.sops
          ];
        };
        ${maastricht} = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit sops-nix;
          }; # Pass flake inputs to our config
          modules = [
            ./${maastricht}.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];

              home-manager.users.alice = import ./home.nix;
              home-manager.extraSpecialArgs = {
                hostname = maastricht;
              };
              home-manager.backupFileExtension = "rebuild";
            }
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
