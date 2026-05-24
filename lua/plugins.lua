-- Hyprland Plugin Yükleyici
-- .so symlink'leri home-manager tarafından ~/.local/share/hypr-plugins/'a yazılır.
-- module.nix: pkgs.hyprlandPlugins.hyprexpo → sabit path → rebuild sonrası güncellenir.

local home = os.getenv("HOME") or ""

-- ── hyprexpo — workspace genel bakış ──────────────────────────────────────
local hyprexpo = home .. "/.local/share/hypr-plugins/hyprexpo.so"
local f = io.open(hyprexpo, "r")
if f then
    f:close()
    hl.config({ plugin = hyprexpo })
    hl.config({
        plugin = {
            hyprexpo = {
                columns          = 3,
                gap_size         = 5,
                bg_col           = "rgb(1e1e2e)",
                workspace_method = "center current",
                enable_gesture   = false,
            }
        }
    })
else
    io.stderr:write("[plugins.lua] hyprexpo bulunamadı: " .. hyprexpo .. "\n")
    io.stderr:write("[plugins.lua] 'home-manager switch' çalıştır\n")
end
