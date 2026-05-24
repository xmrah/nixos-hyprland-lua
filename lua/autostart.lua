-- Sovereign Autostart Services
-- UWSM uyumlu — dbus/systemd çağrıları UWSM'ye bırakıldı.

-- Cursor tema (Wayland native)
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
    -- Wallpaper Engine + ilk görüntü
    -- swww query ile daemon hazır olana kadar poll edilir, sabit sleep yok
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("sh -c 'until swww query 2>/dev/null; do sleep 0.05; done && swww img ~/.config/hypr/wallpaper.jpg --transition-type fade --transition-duration 1 --transition-fps 90'")

    -- Ağ Yönetimi
    hl.exec_cmd("nm-applet --indicator")

    -- Polkit (Yetki Yükseltme)
    hl.exec_cmd("/run/current-system/sw/libexec/polkit-kde-authentication-agent-1")

    -- Boşta Kalma Yöneticisi (hyprlock ile entegre)
    hl.exec_cmd("hypridle")
end)
