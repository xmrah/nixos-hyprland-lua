-- Sovereign Theme: Glassmorphism + Material You
-- AMD RX 7700 XT / 180Hz Optimized

-- ═══════════════════════════════════════════
-- 1. RENK PALETİ ve GENEL YAPI
-- ═══════════════════════════════════════════
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 12,
        border_size = 2,
        layout = "dwindle",
        resize_on_border = true,
        extend_border_grab_area = 15,
        col = {
            -- Material You: Cyan → Purple gradient
            active_border = { colors = {"rgba(7dcfffee)", "rgba(c27afaee)"}, angle = 45 },
            inactive_border = "rgba(45475a88)",
        },
    },
    dwindle = {
        preserve_split = true,
        smart_split = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        vrr = 1,                       -- FreeSync / Adaptive Sync
        animate_manual_resizes = true,
        animate_mouse_windowdragging = true,
    },
})

-- ═══════════════════════════════════════════
-- 2. GLASSMORPHISM DEKORASYON
-- ═══════════════════════════════════════════
hl.config({
    decoration = {
        rounding = 14,
        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            new_optimizations = true,
            xray = false,
            noise = 0.02,
            contrast = 0.9,
            brightness = 0.8,
            vibrancy = 0.2,
            vibrancy_darkness = 0.5,
        },
        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgba(1a1a2eaa)",
            color_inactive = "rgba(1a1a2e55)",
        },
    },
})

-- ═══════════════════════════════════════════
-- 3. BEZİER EĞRİLERİ ve ANİMASYONLAR
-- ═══════════════════════════════════════════
hl.config({
    animations = {
        enabled = true,

        -- Bezier eğrileri
        bezier = {
            "smooth,   0.25, 0.1,  0.25, 1",
            "overshot,  0.05, 0.9,  0.1,  1.05",
            "easeOut,   0.16, 1,    0.3,  1",
            "easeInOut, 0.45, 0,    0.55, 1",
            "spring,    0.1,  0.8,  0.2,  1.1",
        },

        -- Animasyon tanımları
        animation = {
            "windows,     1, 5, smooth",
            "windowsIn,   1, 5, overshot",
            "windowsOut,  1, 4, easeOut",
            "fade,        1, 4, smooth",
            "fadeIn,      1, 3, easeOut",
            "fadeOut,     1, 3, easeInOut",
            "workspaces,  1, 4, overshot",
            "border,      1, 8, smooth",
            "borderangle, 1, 30, smooth, loop",  -- Dönen gradient border
        },
    },
})
