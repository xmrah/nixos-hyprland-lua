# ❄️ Hyprland Pure Lua Framework v0.55.0+

> **"Pure Speed, Zero Bloat, Total Control."**

Bu depo, Hyprland'in en yeni nesil **Native Lua API**'sini (v0.55+) temel alan, NixOS için optimize edilmiş, modüler ve yüksek performanslı bir masaüstü motorudur. Geleneksel DSL yapılarını terk ederek, tamamen programlanabilir ve canlı olarak düzenlenebilir bir deneyim sunar.

---

## 🚀 Öne Çıkan Özellikler

- **Native Lua Engine:** Legacy `hyprlang` bağımlılığı olmadan, saf Lua performansı.
- **UWSM Integration:** Sistemd ile tam uyumlu, stabil ve hızlı oturum yönetimi.
- **Live-Editing Altyapısı:** Nix Store engellerine takılmadan, anlık konfigürasyon yenileme.
- **AMD & 180Hz Optimizasyonu:** AMD RX 7700 XT ve 180Hz monitörler için özel olarak ince ayarlanmış gecikme (latency) kontrolü.
- **Modüler Mimari:** Hardware, Binds, Theme ve Rules katmanlarının tam izolasyonu.

## 🛠️ Modül Yapısı

```bash
lua/
├── autostart.lua   # Başlangıç servisleri (Waybar, SWWW, vb.)
├── binds.lua       # Gelişmiş keybinds & mouse sürükleme
├── hardware.lua    # Monitör, input ve GPU ayarları
├── rules.lua       # Pencere ve workspace kuralları
├── theme.lua       # Renkler, animasyonlar ve estetik
└── hyprland.lua    # Ana giriş (Entry Point)
```

## ⌨️ Yönetim Komutları (Justfile)

Bu projeyi yönetmek için kök dizinde `just` komutlarını kullanabilirsiniz:

- `just sync "mesaj"`: Tüm değişiklikleri commit'ler ve Codeberg'e gönderir.
- `just reload`: Hyprland konfigürasyonunu anında yeniler.
- `just check`: Sözdizimi hatalarını denetler.
- `just logs`: Canlı Hyprland loglarını izler.

## ⚖️ Lisans

Bu proje **GPL-3.0** lisansı ile korunmaktadır. "xmrah mode on" felsefesiyle özgürce geliştirilebilir.

---
*Developed with ❤️ by Antigravity AI for xmrah.*
