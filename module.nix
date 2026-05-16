{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wayland.windowManager.hyprland.luaConfig;
in {
  options.wayland.windowManager.hyprland.luaConfig = {
    enable = mkEnableOption "Pure Lua Hyprland Configuration Framework";
  };

  config = mkIf cfg.enable {
    xdg.configFile."hypr" = {
      source = ./lua;
      recursive = true;
    };

    wayland.windowManager.hyprland.package = pkgs.hyprland;
  };
}
