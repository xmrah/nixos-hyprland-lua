# nixos-hyprland-lua - Framework Yönetim & Kalite Kontrol Paneli
# Author: xmrah (Sovereign Edition)

# Varsayılan yardım menüsü
default:
    @just --list

# Tüm değişiklikleri doğrula ve uzak repolara senkronize et
sync message="framework update":
    just check
    just audit
    git add .
    git commit -m "feat: {{message}} - $(date +'%Y-%m-%d %H:%M')" || echo "Değişiklik yok."
    git push

# Hyprland ve Quickshell oturumunu anında yenile
reload:
    hyprctl reload
    systemctl --user restart quickshell
    @echo "✅ Hyprland ve Quickshell yenilendi."

# Lua Syntax ve Hyprland Yapılandırma Doğrulaması
check:
    @echo "🔍 [1/2] Lua sözdizimi doğrulanıyor..."
    @find lua -name "*.lua" -exec luac -p {} +
    @echo "🔍 [2/2] Hyprland sözdizimi doğrulanıyor..."
    @hyprctl configerrors
    @echo "✅ Sözdizimi testleri BAŞARILI."

# Gray-Hat Güvenlik, Fork Bomb, QML Bütünlük ve Sızıntı Denetimi
audit:
    @python3 scripts/audit.py

# Canlı Hyprland log akışı
logs:
    hyprctl rollinglog
