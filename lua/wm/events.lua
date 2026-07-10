-- Sovereign Framework: Smart Event Hooks
-- Hyprland 0.55+ Native Lua API (Ecosystem Edition)
-- Hızlı, Non-Blocking ve Uzaysal (Spatial) Bütünlüğe Saygılı

-- ═══════════════════════════════════════════
-- STATE (DURUM) YÖNETİMİ (RAM İçi, Sıfır Gecikme)
-- ═══════════════════════════════════════════
local ws_window_counts = {}

-- ═══════════════════════════════════════════
-- 1. AUTO-TAB (Geometrik Koruma)
-- ═══════════════════════════════════════════
hl.on("window.open", function(w)
    if not w then return end
    
    local class = string.lower(w.class or "")
    local distractors = { "discord", "telegram-desktop", "slack", "signal", "spotify" }
    for _, d in ipairs(distractors) do
        if class == d then return end 
    end

    local ws_id = -1
    if type(w.workspace) == "table" and w.workspace.id then
        ws_id = w.workspace.id
    elseif type(w.workspace) == "number" then
        ws_id = w.workspace
    end
    
    if ws_id ~= -1 then
        ws_window_counts[ws_id] = (ws_window_counts[ws_id] or 0) + 1
        
        if ws_window_counts[ws_id] >= 3 and not w.floating then
            Utils.async_cmd("hyprctl dispatch togglegroup")
            Utils.notify("Sovereign Auto-Tab", "Alan daraldığı için Geometrik Koruma (Sekme) aktif edildi.")
        end
    end
end)

hl.on("window.close", function(w)
    if not w then return end
    local ws_id = -1
    if type(w.workspace) == "table" and w.workspace.id then
        ws_id = w.workspace.id
    elseif type(w.workspace) == "number" then
        ws_id = w.workspace
    end
    
    if ws_id ~= -1 and ws_window_counts[ws_id] then
        ws_window_counts[ws_id] = math.max(0, ws_window_counts[ws_id] - 1)
    end
end)

-- ═══════════════════════════════════════════
-- 2. FOCUS STEALING PREVENTION (Dikkat Dağıtıcı Filtresi)
-- ═══════════════════════════════════════════
hl.on("window.open", function(w)
    if not w then return end
    
    local class = string.lower(w.class or "")
    local distractors = { "discord", "telegram-desktop", "slack", "signal", "spotify" }
    
    local is_distractor = false
    for _, d in ipairs(distractors) do
        if class == d then
            is_distractor = true
            break
        end
    end
    
    if is_distractor then
        local addr = w.address or ""
        if addr ~= "" then
            Utils.async_cmd("hyprctl dispatch movetoworkspacesilent 9,address:" .. addr)
            Utils.notify("Focus Korundu", (w.title or class) .. " sessizce (WS 9) başlatıldı.", 3000)
        end
    end
end)


-- ═══════════════════════════════════════════
-- 3. ZEN MODE (Focus Tracker)
-- ═══════════════════════════════════════════
hl.on("window.active", function(w)
    if not w then return end

    local is_zen_app = (w.class == "mpv" or w.class == "gamescope" or w.class == "steam_app")

    if is_zen_app or w.fullscreen then
        hl.config({
            decoration = { dim_inactive = true, dim_strength = 0.4 }
        })
        Utils.qs_ipc("bar", "hide")
    else
        hl.config({
            decoration = { dim_inactive = false, dim_strength = 0.0 }
        })
        Utils.qs_ipc("bar", "show")
    end
end)

print("[wm/events.lua] Zeki ve Non-Blocking Hooks yüklendi.")
