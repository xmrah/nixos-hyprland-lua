# ❄️ Hyprland Pure Lua Framework

> **"Pure Speed, Zero Bloat, Total Control."**

NixOS için Hyprland'in **Native Lua API**'sini (v0.55+) temel alan, modüler ve yüksek performanslı masaüstü çerçevesi. Geleneksel DSL yapılarını terk ederek tamamen programlanabilir ve canlı düzenlenebilir bir deneyim sunar.

---

## Öne Çıkan Özellikler

- **Native Lua Engine:** Legacy `hyprlang` bağımlılığı olmadan, saf Lua performansı
- **Home Manager Modülü:** `flake` input olarak eklenip tek satırla aktif edilir
- **Live-Editing:** Nix Store engellerine takılmadan, HM rebuild olmadan anlık konfigürasyon yenileme
- **UWSM Entegrasyonu:** systemd ile tam uyumlu, stabil oturum yönetimi
- **Quickshell:** QML tabanlı Sovereign Shell — systemd user servisi olarak çalışır
- **AMD & 180Hz Optimizasyonu:** AMD RX 7700 XT ve 180Hz monitörler için ince ayarlanmış gecikme kontrolü
- **Modüler Mimari:** Hardware, Binds, Theme ve Rules katmanlarının tam izolasyonu

---

## Kurulum

### 1. Flake Input Ekle

`flake.nix` dosyana input olarak ekle:

```nix
inputs = {
  nixos-hyprland-lua = {
    url = "github:xmrah/nixos-hyprland-lua";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### 2. Home Manager Modülünü İçe Aktar

`home.nix` veya ilgili HM modülüne ekle:

```nix
{ inputs, ... }:
{
  imports = [
    inputs.nixos-hyprland-lua.homeManagerModules.default
  ];
}
```

### 3. Modülü Yapılandır

```nix
wayland.windowManager.hyprland.luaConfig = {
  enable = true;

  # Repo'nun yerel klonu — live-edit bu path üzerinden çalışır
  repoPath = "/home/kullanici/Projects/nixos-hyprland-lua";

  keyboard = {
    layout  = "tr";   # xkb layout (varsayılan: "us")
    variant = "";     # xkb variant (opsiyonel, boş bırakılabilir)
  };
};
```

### 4. Home Manager'ı Yenile

```bash
home-manager switch --flake .#kullanici
```

> **Not:** `repoPath` altındaki Lua dosyalarında yaptığın değişiklikler `just reload` ile anında aktif olur — HM rebuild gerekmez.

---

## Modül Yapısı

```
nixos-hyprland-lua/
├── flake.nix            # Flake tanımı ve HM modülü export'u
├── module.nix           # Home Manager modülü (symlink + servis + paketler)
├── Justfile             # Yönetim komutları
├── lua/
│   ├── hyprland.lua     # Ana giriş noktası (entry point)
│   ├── colors.lua       # Renk paleti (global Colors tablosu)
│   ├── hardware.lua     # Monitör, input ve GPU ayarları
│   ├── autostart.lua    # Başlangıç servisleri
│   ├── theme.lua        # Glassmorphism, animasyonlar, estetik
│   ├── rules.lua        # Pencere ve workspace kuralları
│   └── binds.lua        # Keybinding'ler ve mouse sürükleme
├── configs/
│   ├── hyprlock.conf    # Ekran kilidi konfigürasyonu
│   └── wofi/            # Launcher tema ve ayarları
└── quickshell/          # QML tabanlı Sovereign Shell bileşenleri
```

---

## Yönetim Komutları (Justfile)

```bash
just sync "mesaj"   # Değişiklikleri commit'ler ve Codeberg'e gönderir
just reload         # Hyprland konfigürasyonunu anında yeniler
just check          # Lua sözdizimi + Hyprland config doğrulaması
just logs           # Canlı Hyprland loglarını izler
```

---

## Gereksinimler

- NixOS + Home Manager (flake tabanlı)
- Hyprland v0.55.0+
- UWSM (systemd oturum yönetimi için)

---

## Geliştirme Yöntemi

Bu framework **agentic workflow** ile geliştirilmektedir:

| Rol | Araç |
|-----|------|
| Orkestratör | xmrah |
| Ajan Ekibi | Claude Code (Anthropic) + Antigravity |

Orkestratör mimari kararları ve yönü belirler; ajan ekibi araştırma, kodlama ve dokümantasyonu üstlenir.

---

## Lisans

**GPL-3.0** — "xmrah mode on" felsefesiyle özgürce geliştirilebilir.
