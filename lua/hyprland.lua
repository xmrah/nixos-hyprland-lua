-- Hyprland 0.55 Native Lua Framework
-- Entry Point: hyprland.lua (Sovereign Edition)
-- Hardened and dynamic path resolution

if not hl then return end

-- Dinamik ve Güvenli Yol Tespiti
local user_home = os.getenv("HOME") 
               or os.getenv("XDG_CONFIG_HOME") 
               or ("/home/" .. (os.getenv("USER") or "xmrah"))

local function load_module(name)
    local path = user_home .. "/.config/hypr/" .. name .. ".lua"
    -- Check if file exists before dofile
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

-- Yükleme Sırası (Order is crucial)
load_module("autostart")
load_module("hardware")
load_module("theme")
load_module("rules")
load_module("binds")

print("Hyprland Sovereign Framework initialized at " .. user_home)
