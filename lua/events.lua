-- Sovereign Framework: Smart Event Hooks
-- Hyprland 0.55+ Native Lua API (Paranoid Edition)
-- Hızlı, Non-Blocking ve Uzaysal (Spatial) Bütünlüğe Saygılı

-- ═══════════════════════════════════════════
-- STATE (DURUM) YÖNETİMİ (RAM İçi, Sıfır Gecikme)
-- ═══════════════════════════════════════════
local ws_window_counts = {}

-- ═══════════════════════════════════════════
-- 1. ZEN MODE (Focus Tracker - Optimize Edildi)
-- ═══════════════════════════════════════════
hl.on("window.active", function(w)
    if not w then return end

    local is_zen_app = (w.class == "mpv" or w.class == "gamescope" or w.class == "steam_app")

    if is_zen_app or w.fullscreen then
        hl.config({
            decoration = { dim_inactive = true, dim_strength = 0.4 }
        })
        os.execute("quickshell ipc call default bar hide > /dev/null 2>&1 &")
    else
        hl.config({
            decoration = { dim_inactive = false, dim_strength = 0.0 }
        })
        os.execute("quickshell ipc call default bar show > /dev/null 2>&1 &")
    end
end)

print("[events.lua] Paranoid Edition (Zeki ve Non-Blocking) Hooks yüklendi.")
