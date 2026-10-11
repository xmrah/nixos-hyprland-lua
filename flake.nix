{
  description = "Pure Lua & Nix Flake based Hyprland 0.56+ Framework";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      homeManagerModules.default = import ./module.nix;
      homeManagerModules.hyprland-lua = import ./module.nix;

      # Kolaylık için NixOS modül alias'ı
      nixosModules.default = self.homeManagerModules.default;

      # Standart Nix kod biçimlendirici
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style or nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
