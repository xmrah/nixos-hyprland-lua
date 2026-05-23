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
    # HM rebuild gerekmeden lua ve quickshell dosyaları anında etkinleşir.
    xdg.configFile."hypr/lua".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/lua";

    xdg.configFile."hypr/hyprland.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/lua/hyprland.lua";

    xdg.configFile."hypr/hyprlock.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/configs/hyprlock.conf";

    xdg.configFile."hypr/hypridle.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/configs/hypridle.conf";

    # Quickshell — live-edit (QML değişiklikleri yeniden başlatmada aktif)
    xdg.configFile."quickshell".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/quickshell";

    xdg.configFile."wofi/style.css".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/configs/wofi/style.css";

    xdg.configFile."wofi/config".source =
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/configs/wofi/config";

    # ── Klavye düzeni — hardware.lua bu env var'ları okur ─────────────────
    # home.sessionVariables shell profile'a yazar, UWSM okumaz.
    # environment.d → systemd user session'a doğrudan inject edilir → güvenli.
    xdg.configFile."environment.d/hyprland-kbd.conf".text =
      "HYPR_KB_LAYOUT=${cfg.keyboard.layout}\n"
      + lib.optionalString (cfg.keyboard.variant != "")
        "HYPR_KB_VARIANT=${cfg.keyboard.variant}\n";

    # ── Sovereign Shell — quickshell ──────────────────────────────────────
    systemd.user.services.quickshell = {
      Unit = {
        Description          = "Quickshell — Sovereign Desktop Shell";
        PartOf               = [ "graphical-session.target" ];
        After                = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type       = "simple";
        ExecStart  = "${pkgs.quickshell}/bin/quickshell";
        Restart    = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # ── Ses OSD — swayosd ─────────────────────────────────────────────────
    services.swayosd.enable = true;

    # ── Clipboard geçmişi daemon — cliphist ───────────────────────────────
    # binds.lua SUPER+C: cliphist list | wofi --dmenu | cliphist decode | wl-copy
    systemd.user.services.cliphist = {
      Unit = {
        Description          = "Clipboard history daemon (cliphist)";
        PartOf               = [ "graphical-session.target" ];
        After                = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type       = "simple";
        ExecStart  = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart    = "on-failure";
        RestartSec = "3s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # ── Bildirim daemon — swaync (quickshell bildirimler hazır olana kadar) ─
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
      # Sovereign Shell
      quickshell

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

      # Clipboard geçmişi (binds.lua: SUPER+C)
      cliphist
    ];
  };
}
