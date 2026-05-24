-- Hyprland Plugin Yükleyici
-- hl.config() plugin yüklemeyi desteklemiyor — hyprctl ile runtime'da yüklenir.
-- Symlink: module.nix → ~/.local/share/hypr-plugins/hyprexpo.so

local home   = os.getenv("HOME") or ""
local hyprexpo = home .. "/.local/share/hypr-plugins/hyprexpo.so"

local f = io.open(hyprexpo, "r")
if not f then
    io.stderr:write("[plugins.lua] hyprexpo bulunamadı: " .. hyprexpo .. "\n")
    io.stderr:write("[plugins.lua] 'just lua-deploy ...' ile nixos-config'i güncelle\n")
    return
end
f:close()

-- ── hyprexpo — workspace genel bakış ──────────────────────────────────────
-- Plugin yükle → yükleme tamamlanınca keyword'lerle yapılandır
hl.on("hyprland.start", function()
    hl.exec_cmd(
        "sh -c 'hyprctl plugin load " .. hyprexpo ..
        " && hyprctl keyword plugin:hyprexpo:columns 3" ..
        " && hyprctl keyword plugin:hyprexpo:gap_size 5" ..
        " && hyprctl keyword plugin:hyprexpo:bg_col 0xff1e1e2e" ..
        " && hyprctl keyword plugin:hyprexpo:workspace_method \"center current\"" ..
        " && hyprctl keyword plugin:hyprexpo:enable_gesture false'"
    )
end)
