{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.wayland.windowManager.hyprland.luaConfig;

  # Eğer repoPath belirtilmişse geliştirici 'live-edit' modu (mkOutOfStoreSymlink),
  # Belirtilmemişse saf Nix Store modu (turnkey kurulum, depoyu klonlamaya gerek yok).
  resolveSource = relPath:
    if cfg.repoPath != null && cfg.repoPath != "" then
      config.lib.file.mkOutOfStoreSymlink "${cfg.repoPath}/${relPath}"
    else
      ./. + "/${relPath}";
in {
  options.wayland.windowManager.hyprland.luaConfig = {
    enable = mkEnableOption "Pure Lua Hyprland Configuration Framework";

    repoPath = mkOption {
      type        = types.nullOr types.str;
      default     = null;
      example     = "/home/username/Projects/nixos-hyprland-lua";
      description = ''
        nixos-hyprland-lua reposunun mutlak yerel yolu.
        Belirtilirse mkOutOfStoreSymlink ile 'live-edit' modu açılır
        (home-manager rebuild gerekmeden lua/qml değişiklikleri anında etkinleşir).
        Belirtilmezse (varsayılan) dosyalar doğrudan Nix Store'dan bağlanır (bağımsız turnkey mod).
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

    # ── Dosya Bağlantıları (Live-edit veya Nix Store) ─────────────────────
    xdg.configFile."hypr/lua".source = resolveSource "lua";
    xdg.configFile."hypr/hyprland.lua".source = resolveSource "lua/hyprland.lua";
    xdg.configFile."hypr/hyprlock.conf".source = resolveSource "configs/hyprlock.conf";
    xdg.configFile."hypr/hypridle.conf".source = resolveSource "configs/hypridle.conf";
    xdg.configFile."hypr/scripts".source = resolveSource "scripts";
    xdg.configFile."quickshell".source = resolveSource "quickshell";

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

    # ── Paketler ───────────────────────────────────────────────────────────
    # Lua dosyalarının (binds.lua, autostart.lua) ve Quickshell'in doğrudan çağırdığı araçlar.
    home.packages = with pkgs; [
      # ── Sovereign Shell & Yazı Tipleri ──────────────────────────────────
      quickshell
      (pkgs.nerd-fonts.jetbrains-mono or (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }))

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

      # ── Parlaklık (DDC/CI ve Laptop/VM fallback) ───────────────────────
      ddcutil
      brightnessctl

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
