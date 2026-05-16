# nixos-hyprland-lua - Framework Yönetim Paneli
# Author: xmrah (Sovereign Edition)

# Varsayılan yardım menüsü
default:
    @just --list

# Tüm değişiklikleri anlık olarak Codeberg'e gönder
sync message="framework update":
    just check
    git add .
    git commit -m "feat(lua): {{message}} - $(date +'%Y-%m-%d %H:%M')" || echo "Değişiklik yok."
    git push

# Hyprland konfigürasyonunu anında yenile
reload:
    hyprctl reload

# Lua Syntax ve Hyprland API doğrulaması
check:
    @echo "🔍 Checking Lua syntax..."
    @luac -p lua/*.lua || (echo "❌ Lua Syntax Error!"; exit 1)
    @echo "🔍 Checking Hyprland config..."
    @hyprctl configerrors
    @echo "✅ Everything looks good."

# Logları takip et
logs:
    hyprctl rollinglog
