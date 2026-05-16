# nixos-hyprland-lua - Framework Yönetim Paneli
# Author: xmrah

# Varsayılan yardım menüsü
default:
    @just --list

# Tüm değişiklikleri anlık olarak Codeberg'e gönder
# Kullanım: just sync "Mesajın buraya"
sync message="framework update":
    git add .
    git commit -m "feat(lua): {{message}} - $(date +'%Y-%m-%d %H:%M')" || echo "Değişiklik yok."
    git push

# Hyprland konfigürasyonunu anında yenile
reload:
    hyprctl reload

# Hata kontrolü yap
check:
    hyprctl configerrors

# Logları takip et
logs:
    hyprctl rollinglog
