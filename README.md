# ❄️ Hyprland Pure Lua Framework (Sovereign Edition)

> **"Pure Speed, Zero Bloat, Total Control."**

NixOS için Hyprland'in **Native Lua API**'sini (v0.56+) ve **Quickshell (QML)** motorunu temel alan, modüler, estetik ve bağımsız masaüstü çerçevesi. Geleneksel DSL yapılarını terk ederek tamamen programlanabilir, test edilebilir ve canlı düzenlenebilir modern bir Wayland deneyimi sunar.


---

## 🌟 Öne Çıkan Özellikler

* **🚀 Native Lua Engine:** Legacy `hyprlang` statik DSL'i yerine Hyprland 0.56+ yerel C++/Lua çalıştırma ortamı.
* **💎 Sovereign Shell (Quickshell):** Waybar, Wofi ve harici bildirim daemon'ları yerine donanım hızlandırmalı tek parça QML masaüstü arayüzü (Bar, Dashboard, Launcher, Pano Geçmişi, Bildirimler, Overview).
* **⚡ Çift Modlu Mimari (Turnkey & Live-Edit):**
  * **Turnkey Mod (Tak-Çalıştır):** Repoyu klonlamaya gerek kalmadan, doğrudan Nix Store üzerinden tek satırla (`enable = true;`) kurulum.
  * **Geliştirici Modu (Live-Edit):** `repoPath` tanımlandığında `mkOutOfStoreSymlink` devreye girer; Home Manager rebuild gerekmeden Lua ve QML değişiklikleri anında (`just reload`) aktifleşir.
* **🖥️ Donanım ve Ortam Bağımsızlığı:**
  * **Çift Parlaklık Motoru:** Masaüstü harici monitörlerde **DDC/CI**, dizüstü ve sanal makinelerde (VM) **brightnessctl** otomatik algılama ve korumalı debounce.
  * **Dinamik Ağ ve Cihazlar:** Hardcoded arayüz adları yerine dinamik WiFi aygıt keşfi.
  * **Evrensel Ekran Desteği:** Her monitör ve VM için otomatik `preferred, auto, 1` fallback; ortam değişkenleriyle özelleştirilebilir profil desteği.
* **🛡️ Gray-Hat Güvenlik & Kalite Denetimi:** `just check` ve `just audit` ile otomatik sözdizimi, dead-code, qmldir bütünlüğü, shell injection ve veri sızıntı denetimi.

---

## 📦 Kurulum (NixOS & Home Manager)

### 1. Flake Input Ekle

`flake.nix` dosyanızın `inputs` bölümüne ekleyin:

```nix
inputs = {
  nixos-hyprland-lua = {
    url = "github:xmrah/nixos-hyprland-lua";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### 2. Home Manager Modülünü İçe Aktar

`home.nix` veya ilgili Home Manager yapılandırmanıza ekleyin:

```nix
{ inputs, ... }:
{
  imports = [
    inputs.nixos-hyprland-lua.homeManagerModules.default
  ];
}
```

### 3. Modülü Etkinleştir

#### Seçenek A: Turnkey Mod (Önerilen — Doğrudan Nix Store)
Repoyu yerel diskte klonlamadan, saf Nix ekosistemi üzerinden kullanmak için:

```nix
wayland.windowManager.hyprland.luaConfig = {
  enable = true;

  keyboard = {
    layout  = "tr";   # xkb layout (varsayılan: "us")
    variant = "";     # xkb variant (opsiyonel)
  };
};
```

#### Seçenek B: Geliştirici Modu (Live-Edit)
Eğer Lua ve QML kodlarını anlık olarak düzenleyip test etmek istiyorsanız yerel repo yolunu belirtin:

```nix
wayland.windowManager.hyprland.luaConfig = {
  enable   = true;
  repoPath = "/home/kullanici/Projects/nixos-hyprland-lua"; # Canlı sembolik bağlar

  keyboard = {
    layout  = "tr";
    variant = "";
  };
};
```

### 4. Yapılandırmayı Uygula

```bash
home-manager switch --flake .#kullanici
```

---

## ⌨️ Temel Kısayollar (Cheat Sheet)

| Kısayol | Eylem | Açıklama |
|---|---|---|
| `SUPER + Return` | Terminal | Kitty açar |
| `SUPER + Q` | Kapat | Aktif pencereyi kapatır |
| `SUPER + E` | Dosyalar | Dolphin dosya yöneticisi |
| `SUPER + R` | Uygulama Başlatıcı | Sovereign Launcher (Quickshell) |
| `SUPER + D` | Kontrol Merkezi | Sovereign Dashboard (Hızlı ayarlar) |
| `SUPER + C` | Pano Geçmişi | Cliphist Pano Menüsü |
| `SUPER + N` | Bildirimler | Bildirim Merkezi |
| `SUPER + Tab` | Genel Bakış | Overview (Açık pencereler) |
| `SUPER + V` | Float | Pencereyi serbest/döşeli moduna alır |
| `SUPER + F` | Tam Ekran | Pencereyi tam ekran yapar |
| `SUPER + G` | Oyun Modu | Animasyon ve efektleri kapatıp performansı maksimize eder |
| `SUPER + L` | Kilitle | Hyprlock ekran koruyucu |
| `SUPER + SHIFT + S` | Ekran Alıntısı | Seçili alanı panoya kopyalar |
| `SUPER + ALT + S` | Tam Ekran SS | `~/Pictures/Screenshots` dizinine kaydeder |
| `SUPER + CTRL + S` | Ekran Düzenleme | Swappy ile düzenleme arayüzünü açar |
| `SUPER + [1-9]` | Çalışma Alanı | 1-9 arası masaüstlerine geçer |

---

## 📁 Dizin Yapısı

```
nixos-hyprland-lua/
├── flake.nix            # Flake tanımı ve modül export'ları
├── module.nix           # Çift modlu Home Manager modülü (Store / Live-edit)
├── Justfile             # Kalite, test ve operasyonel otomasyon
├── lua/
│   ├── hyprland.lua     # Çerçeve ana giriş noktası
│   ├── lib/utils.lua    # Yardımcı fonksiyonlar (async_cmd, notify, ipc)
│   ├── ui/colors.lua    # Global Catppuccin / Material You renk token'ları
│   ├── ui/theme.lua     # Glassmorphism, animasyonlar ve dekorasyon
│   ├── core/hardware.lua# Dinamik GPU, monitör ve klavye yapılandırması
│   ├── core/autostart.lua# UWSM ve masaüstü başlangıç servisleri
│   ├── wm/rules.lua     # Pencere ve katman kuralları (Layer rules)
│   ├── wm/events.lua    # Olay dinleyicileri (event hooks)
│   └── wm/binds.lua     # Kısayol tuşları ve fare kontrolleri
├── configs/
│   ├── hyprlock.conf    # Ekran kilidi teması
│   └── hypridle.conf    # Güç yönetimi ve otomatik karartma
├── quickshell/          # Sovereign Shell QML bileşenleri
└── scripts/
    ├── audit.py         # Güvenlik ve kalite denetleyicisi
    └── brightness.sh    # Akıllı parlaklık kontrolü
```

---

## 🛠️ Yönetim Komutları (Justfile)

```bash
just check          # Lua sözdizimi ve Hyprland yapılandırma doğrulaması
just audit          # QML bütünlüğü, dead-code, shell injection ve gizli veri denetimi
just reload         # Hyprland ve Quickshell oturumunu anında canlı yeniler
just sync "mesaj"   # Testleri koşturur ve değişiklikleri depolara pushlar
just logs           # Canlı Hyprland log akışını izler
```

---

## 📜 Lisans

**GPL-3.0** — Açık kaynak, bağımsız ve toplulukla paylaşılabilir.
