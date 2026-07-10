-- Hyprland 0.55 Native Lua Framework
-- Entry Point: hyprland.lua (Sovereign Ecosystem)
-- Domain-Driven Architecture

if not hl then return end

-- Dinamik ve Güvenli Yol Tespiti
local user_home = os.getenv("HOME")
    or os.getenv("XDG_CONFIG_HOME")
               or ("/home/" .. (os.getenv("USER") or "unknown"))

local lua_dir = user_home .. "/.config/hypr/lua/"

local function load_module(path)
    local full_path = lua_dir .. path .. ".lua"
    local f = io.open(full_path, "r")
    if f then
        f:close()
        local ok, err = pcall(dofile, full_path)
        if not ok then
            io.stderr:write("[hyprland.lua] ERROR loading '" .. path .. "': " .. err .. "\n")
        end
    else
        io.stderr:write("[hyprland.lua] Module not found: " .. full_path .. "\n")
    end
end

-- ==============================================
-- 1. KÜTÜPHANELER (Libraries)
-- ==============================================
load_module("lib/utils")

-- ==============================================
-- 2. ARAYÜZ (UI - Global Renk ve Temalar)
-- ==============================================
load_module("ui/colors")
load_module("ui/theme")

-- ==============================================
-- 3. ÇEKİRDEK (Core - Donanım ve Servisler)
-- ==============================================
load_module("core/hardware")
load_module("core/autostart")

-- ==============================================
-- 4. PENCERE YÖNETİCİSİ (WM - Kural ve Kısayollar)
-- ==============================================
load_module("wm/rules")
load_module("wm/events")
load_module("wm/binds")

io.stderr:write("[hyprland.lua] Sovereign Ecosystem initialized — " .. user_home .. "\n")
