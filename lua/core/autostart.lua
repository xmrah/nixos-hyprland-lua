-- Sovereign Autostart Services (Hyprland 0.56+)
-- UWSM uyumlu — dbus/systemd çağrıları UWSM'ye bırakıldı.

-- Cursor tema (Wayland native)
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
    -- UWSM oturumunu hazır işaretle → graphical-session.target aktif olur
    -- Bu olmadan quickshell, swaync, cliphist gibi systemd user servisleri başlamaz
    hl.exec_cmd("uwsm finalize")


    -- Wallpaper Engine + ilk görüntü
    -- nixpkgs 26.05: swww → awww olarak yeniden adlandırıldı
    hl.exec_cmd("awww daemon")
    hl.exec_cmd("sh -c 'until awww query 2>/dev/null; do sleep 0.05; done && awww img ~/.config/hypr/wallpaper.jpg --transition-type fade --transition-duration 1 --transition-fps 90'")

    -- Ağ Yönetimi
    hl.exec_cmd("nm-applet --indicator")

    -- Boşta Kalma Yöneticisi (hyprlock ile entegre)
    hl.exec_cmd("hypridle")
end)
