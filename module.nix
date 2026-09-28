{ config, lib, pkgs, inputs, ... }:

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

    # Legacy symlink'ler kaldırıldı: wofi, swaync, wlogout
    # Tüm UI artık Quickshell üzerinden yönetiliyor.

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
    # cliphist daemon arka planda clipboard geçmişini toplar.
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

    # swaync servisi kaldırıldı — bildirimler Quickshell üzerinden yönetilecek.

    # ── Paketler ───────────────────────────────────────────────────────────
    # Lua dosyalarının (binds.lua, autostart.lua) doğrudan çağırdığı araçlar.
    # Kullanıcının home.packages'ına dokunmasına gerek kalmaz.
    home.packages = with pkgs; [
      # ── Sovereign Shell ──────────────────────────────────────────────────
      quickshell

      # ── Geliştirici ─────────────────────────────────────────────────────
      lua-language-server
      lua

      # ── Terminal (binds.lua: SUPER+Return) ──────────────────────────────
      kitty

      # ── Wallpaper (autostart.lua: awww) ─────────────────────────────────
      awww

      # ── Ekran kilidi + boşta kalma ──────────────────────────────────────
      hyprlock
      hypridle

      # ── Ekran görüntüsü (binds.lua: SUPER+SHIFT/ALT/CTRL+S) ────────────
      grim
      slurp
      swappy
      wl-clipboard

      # ── Parlaklık — DDC/CI (binds.lua + Brightness.qml) ────────────────
      ddcutil

      # ── Bildirim (libnotify CLI) ────────────────────────────────────────
      libnotify

      # ── Ağ yönetimi (autostart.lua: nm-applet) ─────────────────────────
      networkmanagerapplet

      # ── Clipboard geçmişi (cliphist daemon) ─────────────────────────────
      cliphist

      # ── Medya kontrolü (binds.lua: XF86AudioPlay/Next/Prev/Stop) ────────
      playerctl

      # ── Ses yönetimi (Volume.qml: tıkla → pavucontrol) ─────────────────
      pavucontrol
    ];
  };
}
