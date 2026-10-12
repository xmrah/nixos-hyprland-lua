-- Hardware & Monitor (AMD RX 7700 XT / ASUS ROG Strix 180Hz)
-- Sovereign Edition — Hyprland 0.56+ Native Lua API

-- GPU Cihaz Yolu (Dinamik)
-- card1 = harici GPU (varsa öncelikli kullanılır)
-- Yoksa sisteme bırakılır (VM, tek GPU veya iGPU uyumluluğu)
local card1 = io.open("/dev/dri/card1", "r")
if card1 then
    card1:close()
    hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")
end

-- Monitör Yapılandırması
-- Özel monitör ortam değişkeni veya override varsa uygula
local custom_desc = os.getenv("HYPR_MONITOR_DESC")
if custom_desc and custom_desc ~= "" then
    hl.monitor({
        output   = custom_desc,
        mode     = os.getenv("HYPR_MONITOR_MODE") or "preferred",
        position = os.getenv("HYPR_MONITOR_POS") or "auto",
        scale    = os.getenv("HYPR_MONITOR_SCALE") or "1",
    })
end

-- Genel Monitör Tanımı (Otomatik algılama: tüm ekranlar, harici monitörler ve VM için)
hl.monitor({
    output   = "",
    mode     = "2560x1440@180",
    position = "auto",
    scale    = "1",
})

-- Input Configuration
-- kb_layout: module.nix keyboard.layout opsiyonundan HYPR_KB_LAYOUT env var olarak gelir.
-- Ayarlanmamışsa "tr" kullanılır (reboot sonrası env var otomatik okunur).
hl.config({
    input = {
        kb_layout  = os.getenv("HYPR_KB_LAYOUT")  or "tr",
        kb_variant = os.getenv("HYPR_KB_VARIANT") or "",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
    },
    cursor = {
        no_hardware_cursors = true,  -- AMD RDNA3: cursor glitch ve login loop önlemi
    },
})
