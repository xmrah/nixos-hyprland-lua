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
        mkOutOfStoreSymlink bu yolu kullanır — live-edit çalışır
        (home-manager rebuild olmadan lua dosyaları anında etkinleşir).
      '';
    };

    keyboard = {
      layout = mkOption {
        type        = types.str;
        default     = "us";
        example     = "tr";
        description = "xkb klavye düzeni. hardware.lua'ya HYPR_KB_LAYOUT env var olarak geçer.";
      };
      variant = mkOption {
        type        = types.str;
        default     = "";
        example     = "f";
        description = "xkb variant (opsiyonel, boş bırakılabilir).";
      };
    };
  };

  config = mkIf cfg.enable {

    # ── Live-edit symlink'ler ──────────────────────────────────────────────
    # HM rebuild gerekmeden lua dosyaları anında etkinleşir.
    xdg.configFile."hypr/lua".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/lua";

    xdg.configFile."hypr/hyprland.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/lua/hyprland.lua";

    # ── Klavye düzeni — hardware.lua bu env var'ları okur ─────────────────
    home.sessionVariables = {
      HYPR_KB_LAYOUT  = cfg.keyboard.layout;
      HYPR_KB_VARIANT = cfg.keyboard.variant;
    };

    # ── Bildirim daemon — swaync ───────────────────────────────────────────
    systemd.user.services.swaync = {
      Unit = {
        Description          = "SwayNotificationCenter";
        PartOf               = [ "graphical-session.target" ];
        After                = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type       = "simple";
        ExecStart  = "${pkgs.swaynotificationcenter}/bin/swaync";
        ExecReload = "${pkgs.swaynotificationcenter}/bin/swaync-client --reload-config; ${pkgs.swaynotificationcenter}/bin/swaync-client --reload-css";
        Restart    = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # ── Paketler ───────────────────────────────────────────────────────────
    # Lua dosyalarının (binds.lua, autostart.lua) doğrudan çağırdığı araçlar.
    # Kullanıcının home.packages'ına dokunmasına gerek kalmaz.
    home.packages = with pkgs; [
      # Geliştirici araçları
      lua-language-server
      lua

      # Terminal (binds.lua: SUPER+Return)
      kitty

      # Launcher (binds.lua: SUPER+R)
      wofi

      # Oturum kapatma (waybar custom/power)
      wlogout

      # Wallpaper engine (autostart.lua)
      swww

      # Ekran kilidi + boşta kalma (binds.lua: SUPER+L / autostart.lua)
      hyprlock
      hypridle

      # Ekran görüntüsü (binds.lua: SUPER+SHIFT/ALT/CTRL+S)
      grim
      slurp
      swappy
      wl-clipboard

      # Parlaklık (binds.lua: XF86MonBrightness)
      brightnessctl

      # Bildirim
      swaynotificationcenter
      libnotify

      # Ağ yönetimi (autostart.lua: nm-applet)
      networkmanagerapplet
    ];
  };
}
