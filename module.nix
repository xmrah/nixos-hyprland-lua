{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wayland.windowManager.hyprland.luaConfig;
in {
  options.wayland.windowManager.hyprland.luaConfig = {
    enable = mkEnableOption "Pure Lua Hyprland Configuration Framework";
  };

  config = mkIf cfg.enable {
    # Home Manager'ın dosya yönetimini devre dışı bıraktık.
    # Kullanıcı /home/xmrah/Projects/nixos-hyprland-lua/lua dizinini 
    # manuel olarak ~/.config/hypr yoluna symlinklemelidir.
    # Bu sayede Nix Store çakışmaları ve Login Loop'lar engellenir.
  };
}
