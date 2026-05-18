{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.wayland.windowManager.hyprland.luaConfig;
in {
  options.wayland.windowManager.hyprland.luaConfig = {
    enable = mkEnableOption "Pure Lua Hyprland Configuration Framework";

    repoPath = mkOption {
      type        = types.str;
      example     = "/home/username/Projects/nixos-hyprland-lua";
      description = ''
        nixos-hyprland-lua repo'sunun mutlak yolu.
        mkOutOfStoreSymlink bu yolu kullanır → live-edit çalışır
        (home-manager rebuild olmadan lua dosyaları anında etkinleşir).
      '';
    };

    keyboard = {
      layout = mkOption {
        type        = types.str;
        default     = "us";
        example     = "tr";
        description = "Klavye düzeni (xkb layout). hardware.lua'daki kb_layout'u override eder.";
      };

      variant = mkOption {
        type        = types.str;
        default     = "";
        example     = "f";
        description = "xkb variant (boş bırakılabilir).";
      };
    };
  };

  config = mkIf cfg.enable {
    # Live-edit symlink: HM rebuild gerekmeden lua dosyaları anında etkinleşir.
    xdg.configFile."hypr/lua".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/lua";

    xdg.configFile."hypr/hyprland.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/lua/hyprland.lua";

    # Klavye düzenini Nix tarafından hardware.lua'ya geçirmek için env var.
    # hardware.lua bunu okuyarak kb_layout'u override eder.
    home.sessionVariables = {
      HYPR_KB_LAYOUT  = cfg.keyboard.layout;
      HYPR_KB_VARIANT = cfg.keyboard.variant;
    };

    home.packages = with pkgs; [
      lua-language-server
      lua
    ];
  };
}
