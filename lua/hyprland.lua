-- Hyprland 0.55 Native Lua Framework
-- Author: xmrah (Codeberg Public Edition)

if not hl then
    print("FATAL: 'hl' namespace not found. Hyprland 0.55+ required.")
    return
end

-- Modüler Yükleme Fonksiyonu
local function load_module(name)
    local path = os.getenv("HOME") .. "/.config/hypr/" .. name .. ".lua"
    local success, err = pcall(dofile, path)
    if not success then
        print("Error loading " .. name .. ": " .. err)
    end
end

-- Yükleme Sırası
load_module("hardware")
load_module("theme")
load_module("rules")
load_module("binds")

print("Hyprland Pure Lua Framework initialized.")
