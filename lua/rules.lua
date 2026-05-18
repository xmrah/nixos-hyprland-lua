-- Sovereign Window Rules
-- Tüm kurallar windowrulev2 formatında (v1 deprecated, 0.46+)

-- ═══════════════════════════════════════════
-- 1. FLOAT KURALLARI
-- ═══════════════════════════════════════════
hl.config({
    windowrulev2 = {
        -- Sistem araçları
        "float, class:^(pavucontrol)$",
        "float, class:^(blueman-manager)$",
        "float, class:^(nm-connection-editor)$",
        "float, class:^(.blueman-manager-wrapped)$",
        "float, class:^(org.kde.polkit-kde-authentication-agent-1)$",

        -- Dosya diyalogları
        "float, title:^(Open File)$",
        "float, title:^(Save File)$",
        "float, title:^(Confirm to replace files)$",
        "float, title:^(File Operation Progress)$",

        -- Medya ve araçlar
        "float, class:^(mpv)$",
        "float, class:^(imv)$",
        "float, class:^(org.gnome.Calculator)$",

-- ═══════════════════════════════════════════
-- 2. WORKSPACE ATAMALARI
-- ═══════════════════════════════════════════

        -- Tarayıcılar → Workspace 1
        "workspace 1, class:^(chromium)$",
        "workspace 1, class:^(zen)$",

        -- Terminal → Workspace 2
        "workspace 2, class:^(kitty)$",

        -- Dosya Yöneticisi → Workspace 3
        "workspace 3, class:^(org.kde.dolphin)$",

        -- Kod Editörü → Workspace 4
        "workspace 4, class:^(code)$",
        "workspace 4, class:^(Code)$",

        -- İletişim → Workspace 8
        "workspace 8, class:^(discord)$",
        "workspace 8, class:^(vesktop)$",

        -- Müzik → Workspace 9
        "workspace 9, class:^(Spotify)$",
        "workspace 9, title:^(Spotify)$",

-- ═══════════════════════════════════════════
-- 3. OPASİTE (Glassmorphism derinliği)
-- ═══════════════════════════════════════════

        "opacity 0.92 0.88, class:^(kitty)$",
        "opacity 0.95 0.90, class:^(code)$",
        "opacity 0.95 0.90, class:^(Code)$",
    },
})

-- ═══════════════════════════════════════════
-- 4. LAYER RULES (Bar/Panel Glassmorphism)
-- ═══════════════════════════════════════════
hl.config({
    layerrule = {
        "blur, waybar",
        "blurpopups, waybar",
        "ignorezero, waybar",

        "blur, swaync-control-center",
        "blur, swaync-notification-window",
        "ignorezero, swaync-control-center",
        "ignorezero, swaync-notification-window",
        "blur, wofi",
        "ignorezero, wofi",
    },
})
