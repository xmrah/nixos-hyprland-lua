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

        -- Portal ve Paylaşım Arayüzleri
        "float, class:^(xdg-desktop-portal-gtk)$",
        "float, class:^(hyprland-share-picker)$",

        -- Dosya diyalogları
        "float, title:^(Open File)$",
        "float, title:^(Save File)$",
        "float, title:^(Confirm to replace files)$",
        "float, title:^(File Operation Progress)$",

        -- Picture-in-Picture (Chromium / Firefox / Zen)
        "float, title:^(Picture-in-Picture)$",
        "float, title:^(Picture in picture)$",
        "pin, title:^(Picture-in-Picture)$",
        "pin, title:^(Picture in picture)$",
        "keepaspectratio, title:^(Picture-in-Picture)$",
        "keepaspectratio, title:^(Picture in picture)$",

        -- Medya ve araçlar
        "float, class:^(mpv)$",
        "float, class:^(imv)$",
        "float, class:^(org.gnome.Calculator)$",

        -- Steam Popups & Diyalogları (Ana pencere hariç float)
        "float, class:^(steam)$",
        "tile, class:^(steam)$, title:^(Steam)$",
    },
})

-- ═══════════════════════════════════════════
-- 2. WORKSPACE ATAMALARI
-- ═══════════════════════════════════════════
hl.config({
    windowrulev2 = {
        -- Terminal → Workspace 2
        "workspace 2, class:^(kitty)$",

        -- Dosya Yöneticisi → Workspace 3
        "workspace 3, class:^(org.kde.dolphin)$",

        -- Kod Editörü → Workspace 4
        "workspace 4, class:^(code)$",
        "workspace 4, class:^(Code)$",
        "workspace 4, class:^(codium)$",
        "workspace 4, class:^(vscodium)$",
        "workspace 4, class:^(antigravity-ide)$",

        -- İletişim → Workspace 8
        "workspace 8, class:^(discord)$",
        "workspace 8, class:^(vesktop)$",

        -- Müzik → Workspace 9
        "workspace 9, class:^(Spotify)$",
        "workspace 9, title:^(Spotify)$",
    },
})

-- ═══════════════════════════════════════════
-- 3. OPASİTE (Glassmorphism derinliği)
-- ═══════════════════════════════════════════
hl.config({
    windowrulev2 = {
        "opacity 0.92 0.88, class:^(kitty)$",
        "opacity 0.95 0.90, class:^(code)$",
        "opacity 0.95 0.90, class:^(Code)$",
        "opacity 0.95 0.90, class:^(codium)$",
        "opacity 0.95 0.90, class:^(vscodium)$",
        "opacity 0.95 0.90, class:^(antigravity-ide)$",
    },
})

-- ═══════════════════════════════════════════
-- 4. DAVRANIŞ VE ETKİNLİK KURALLARI
-- ═══════════════════════════════════════════
hl.config({
    windowrulev2 = {
        -- Tam ekranda hypridle'ın ekranı kapatmasını önle (Film/Oyun)
        "idleinhibit fullscreen, fullscreen:1",

        -- Chromium ve Electron uygulamalarının pencere açılışında sahte maximize isteklerini bastır
        "suppressevent maximize, class:.*",
    },
})

-- ═══════════════════════════════════════════
-- 5. LAYER RULES (Bar/Panel Glassmorphism)
-- ═══════════════════════════════════════════
hl.config({
    layerrule = {
        -- Sovereign Bar (Quickshell) — üstten kayar, glassmorphism blur
        "animation slide, sovereign-bar",
        "blur, sovereign-bar",
        "ignorezero, sovereign-bar",

        -- Sovereign Dashboard (Quickshell) — sağdan slide
        "animation slide, sovereign-dashboard",
        "blur, sovereign-dashboard",
        "ignorezero, sovereign-dashboard",

        -- Sovereign Launcher (Quickshell) — ortadan açılır
        "animation popin 80%, sovereign-launcher",
        "blur, sovereign-launcher",
        "ignorezero, sovereign-launcher",

        -- Sovereign Notifications (Quickshell) — sağdan fade
        "animation fade, sovereign-notifications",
        "blur, sovereign-notifications",
        "ignorezero, sovereign-notifications",
    },
})
