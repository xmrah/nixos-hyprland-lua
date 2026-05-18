-- Sovereign Color Palette
-- Catppuccin Mocha base + Material You accent (Cyan/Purple)
-- Single source of truth — tüm modüller bu global'i kullanır.
-- Kullanım: Colors.cyan, Colors.base, vb.

Colors = {}

-- ═══════════════════════════════════════════
-- HYPRLAND (rgba format — border, shadow vb.)
-- ═══════════════════════════════════════════
Colors.active_border_a   = "rgba(7dcfffee)"   -- Cyan  (gradient başı)
Colors.active_border_b   = "rgba(c27afaee)"   -- Purple (gradient sonu)
Colors.inactive_border   = "rgba(45475a88)"
Colors.shadow            = "rgba(1a1a2eaa)"
Colors.shadow_inactive   = "rgba(1a1a2e55)"

-- ═══════════════════════════════════════════
-- CATPPUCCIN MOCHA (hex — opacity kuralları, layerrule vb.)
-- ═══════════════════════════════════════════
Colors.rosewater = "#f5e0dc"
Colors.flamingo  = "#f2cdcd"
Colors.pink      = "#f5c2e7"
Colors.mauve     = "#cba6f7"
Colors.red       = "#f38ba8"
Colors.maroon    = "#eba0ac"
Colors.peach     = "#fab387"
Colors.yellow    = "#f9e2af"
Colors.green     = "#a6e3a1"
Colors.teal      = "#94e2d5"
Colors.sky       = "#89dceb"
Colors.sapphire  = "#74c7ec"
Colors.blue      = "#89b4fa"
Colors.lavender  = "#b4befe"
Colors.text      = "#cdd6f4"
Colors.subtext1  = "#bac2de"
Colors.overlay2  = "#9399b2"
Colors.overlay1  = "#7f849c"
Colors.overlay0  = "#6c7086"
Colors.surface2  = "#585b70"
Colors.surface1  = "#45475a"
Colors.surface0  = "#313244"
Colors.base      = "#1e1e2e"
Colors.mantle    = "#181825"
Colors.crust     = "#11111b"
