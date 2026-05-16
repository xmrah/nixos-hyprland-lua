-- Hyprland 0.55 Native Lua Framework
-- Entry Point: hyprland.lua
-- Hardened Version (Safe Boot)

if not hl then
    return
end

-- Fallback user path if HOME env is missing during login
local user_home = os.getenv("HOME") or "/home/xmrah"

-- Modüler Yükleme Fonksiyonu
local function load_module(name)
    local path = user_home .. "/.config/hypr/" .. name .. ".lua"
    -- Check if file exists before dofile to prevent crash
    local f = io.open(path, "r")
    if f then
        f:close()
        local success, err = pcall(dofile, path)
        if not success then
            print("Error loading " .. name .. ": " .. err)
        end
    else
        print("Module not found: " .. name .. " at " .. path)
    end
end

-- Yükleme Sırası
load_module("autostart")
load_module("hardware")
load_module("theme")
load_module("rules")
load_module("binds")
