{
  description = "Pure Lua & Nix Flake based Hyprland 0.56+ Framework";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    homeManagerModules.default = import ./module.nix;
    homeManagerModules.hyprland-lua = import ./module.nix;
  };
}
