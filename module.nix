{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wayland.windowManager.hyprland.luaConfig;
in {
  options.wayland.windowManager.hyprland.luaConfig = {
    enable = mkEnableOption "Pure Lua Hyprland Configuration Framework";
  };

  config = mkIf cfg.enable {
    # Nix Store'u bypass eden "Gerçek Live-Edit" sihri
    # Bu sayede Projects klasöründeki her değişiklik anında aktif olur.
    home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "/home/xmrah/Projects/nixos-hyprland-lua/lua";
  };
}
