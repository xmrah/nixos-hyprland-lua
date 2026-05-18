-- Sovereign Autostart Services
-- UWSM uyumlu — dbus/systemd çağrıları UWSM'ye bırakıldı.

-- Cursor tema (Wayland native)
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
    -- Wallpaper Engine
    hl.exec_cmd("swww-daemon")



    -- Ağ Yönetimi
    hl.exec_cmd("nm-applet --indicator")

    -- Polkit (Yetki Yükseltme)
    hl.exec_cmd("/run/current-system/sw/libexec/polkit-kde-authentication-agent-1")

    -- Boşta Kalma Yöneticisi (hyprlock ile entegre)
    hl.exec_cmd("hypridle")
end)
