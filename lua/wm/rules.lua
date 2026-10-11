-- Sovereign Window & Layer Rules
-- Unified Rules Table — Hyprland 0.56+
-- Not: Tek bir hl.config bloğunda toplanarak anahtarların birbirini ezmesi (overwrite) engellenmiştir.

hl.config({
    windowrulev2 = {
        -- ═══════════════════════════════════════════
        -- 1. FLOAT KURALLARI
        -- ═══════════════════════════════════════════
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

        -- ═══════════════════════════════════════════

        -- ═══════════════════════════════════════════
        -- 3. OPASİTE (Glassmorphism derinliği)
        -- ═══════════════════════════════════════════
        "opacity 0.92 0.88, class:^(kitty)$",
        "opacity 0.95 0.90, class:^(code)$",
        "opacity 0.95 0.90, class:^(Code)$",
        "opacity 0.95 0.90, class:^(codium)$",
        "opacity 0.95 0.90, class:^(vscodium)$",
        "opacity 0.95 0.90, class:^(antigravity-ide)$",

        -- ═══════════════════════════════════════════
        -- 4. DAVRANIŞ VE ETKİNLİK KURALLARI
        -- ═══════════════════════════════════════════
        -- Tam ekranda hypridle'ın ekranı kapatmasını önle (Film/Oyun)
        "idleinhibit fullscreen, fullscreen:1",

        -- Chromium ve Electron uygulamalarının pencere açılışında sahte maximize isteklerini bastır
        "suppressevent maximize, class:.*",

        -- XWayland Drag & Drop düzeltmesi (Hayalet pencere odak kaybını önler)
        "nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0",
    },

    -- ═══════════════════════════════════════════
    -- 5. LAYER RULES (Bar/Panel Glassmorphism)
    -- ═══════════════════════════════════════════
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

        -- Sovereign Overview (Quickshell) — SUPER+Tab genel bakış
        "animation fade, sovereign-overview",
        "blur, sovereign-overview",
        "ignorezero, sovereign-overview",
    },
})
