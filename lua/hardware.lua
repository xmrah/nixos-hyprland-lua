-- Hardware & Monitor (AMD RX 7700 XT / ASUS ROG Strix 180Hz)
-- Sovereign Edition — Hyprland 0.55+ Native Lua API

-- GPU Cihaz Yolu (KRİTİK)
-- card1 = KMS-capable cihaz (ekran yönetimi için zorunlu)
-- renderD128 = render node (sadece compute/render, KMS yapamaz → crash)
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")

-- Monitor Configuration (ASUS ROG Strix XG27ACS — 2560x1440@180Hz)
-- !! KİŞİSEL AYAR: desc satırını kendinize göre değiştirin.
-- !! Monitör tanımlayıcınızı bulmak için: hyprctl monitors
hl.monitor({
    output   = "desc:ASUSTek COMPUTER INC XG27ACS SBLMTF097654",
    mode     = "2560x1440@180",
    position = "auto",
    scale    = "1",
})

-- Input Configuration
-- kb_layout: module.nix keyboard.layout opsiyonundan HYPR_KB_LAYOUT env var olarak gelir.
-- Ayarlanmamışsa "us" kullanılır.
hl.config({
    input = {
        kb_layout  = os.getenv("HYPR_KB_LAYOUT")  or "us",
        kb_variant = os.getenv("HYPR_KB_VARIANT") or "",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
    },
    cursor = {
        no_hardware_cursors = true,  -- AMD RDNA3: cursor glitch ve login loop önlemi
    },
})
