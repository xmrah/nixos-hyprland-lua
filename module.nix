{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wayland.windowManager.hyprland.luaConfig;
in {
  options.wayland.windowManager.hyprland.luaConfig = {
    enable = mkEnableOption "Pure Lua Hyprland Configuration Framework";

    repoPath = mkOption {
      type    = types.str;
      default = "/home/xmrah/Projects/nixos-hyprland-lua";
      description = ''
        nixos-hyprland-lua repo'sunun mutlak yolu.
        mkOutOfStoreSymlink bu yolu kullanır → live-edit çalışır.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Live-edit symlink'ler: HM rebuild gerekmeden lua dosyaları anında etkinleşir.
    xdg.configFile."hypr/lua".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/lua";

    xdg.configFile."hypr/hyprland.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/lua/hyprland.lua";

    home.packages = with pkgs; [
      lua-language-server
      lua
    ];
  };
}
