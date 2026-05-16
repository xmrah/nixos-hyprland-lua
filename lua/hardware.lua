-- Hardware & Monitor (AMD RX 7700 XT / ASUS 180Hz)
-- Sovereign Edition

-- Environment Variables (Native 0.55 API)
-- Bunlar artık login sırasında çökme riskini önleyecek şekilde native atanır.
hl.env("WLR_NO_HARDWARE_CURSORS", "0")
hl.env("AMD_DEBUG", "radeonsi")
hl.env("AQ_DRM_DEVICES", "/dev/dri/renderD128") -- AMD RX 7700 XT force render node

-- Monitor Configuration
hl.monitor({
    output   = "desc:ASUSTek COMPUTER INC XG27ACS SBLMTF097654",
    mode     = "2560x1440@180",
    position = "auto",
    scale    = "1",
})

-- General Input Config
hl.config({
    input = {
        kb_layout = "tr",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
    },
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
    },
    cursor = {
        no_hardware_cursors = false,
    }
})
