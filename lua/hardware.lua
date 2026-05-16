-- Hardware: AMD Ryzen 5 7500F | GPU: PowerColor RX 7700 XT
-- Optimized for 2560x1440 @ 180Hz

hl.config({
    -- Monitor Konfigürasyonu
    monitor = {
        "DP-1, 2560x1440@180, 0x0, 1",
        "HDMI-A-1, 2560x1440@180, 0x0, 1",
    },

    -- Native AMDGPU Environment Variables
    env = {
        "LIBVA_DRIVER_NAME, radeonsi",
        "XDG_SESSION_TYPE, wayland",
        "GBM_BACKEND, drm-kms",
        "__GLX_VENDOR_LIBRARY_NAME, mesa",
        "WLR_NO_HARDWARE_CURSORS, 1",
    },

    -- Girdi ve Hassasiyet
    input = {
        kb_layout = "tr",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
        force_no_accel = true,
        touchpad = {
            natural_scroll = false,
        },
    },

    -- Donanım İmleci
    cursor = {
        no_hardware_cursors = true,
        inactive_timeout = 3,
    }
})
