-- Autostart Services
-- NOT: dbus-update-activation-environment ve systemctl import-environment
-- satırları UWSM tarafından otomatik yönetildiği için buradan kaldırıldı.
-- Çift çağrı hyprland-session.target'ı bozuyordu.

hl.on("hyprland.start", function()
    hl.exec_cmd("swww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("/run/current-system/sw/libexec/polkit-kde-authentication-agent-1")
end)
