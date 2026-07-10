-- Hyprland 0.55 Native Lua Framework
-- Entry Point: hyprland.lua (Sovereign Edition)
-- Hardened and dynamic path resolution

if not hl then return end

-- Dinamik ve Güvenli Yol Tespiti
local user_home = os.getenv("HOME")
    or os.getenv("XDG_CONFIG_HOME")
               or ("/home/" .. (os.getenv("USER") or "unknown"))

local lua_dir = user_home .. "/.config/hypr/lua/"

local function load_module(name)
    local path = lua_dir .. name .. ".lua"
    local f = io.open(path, "r")
    if f then
        f:close()
        local ok, err = pcall(dofile, path)
        if not ok then
            io.stderr:write("[hyprland.lua] ERROR loading '" .. name .. "': " .. err .. "\n")
        end
    else
        io.stderr:write("[hyprland.lua] Module not found: " .. path .. "\n")
    end
end

-- Yükleme Sırası (colors en önce — diğer modüller Colors global'ini kullanır)
load_module("colors")      -- Renk paleti (global Colors tablosu)
load_module("hardware")    -- Monitor, input, GPU
load_module("autostart")   -- UWSM uyumlu servisler
load_module("theme")       -- Glassmorphism, animasyonlar
load_module("rules")       -- Window/layer kuralları
load_module("events")      -- Smart Event Hooks (Zen Mode, vs.)
load_module("binds")       -- Keybinding'ler

io.stderr:write("[hyprland.lua] Sovereign Framework initialized — " .. user_home .. "\n")
