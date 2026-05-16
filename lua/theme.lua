-- Native Hyprland Aesthetics (No third-party shell)

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        ["col.active_border"] = "rgba(33ccffee) rgba(00ff99ee) 45deg",
        ["col.inactive_border"] = "rgba(595959aa)",
        layout = "dwindle",
    },

    decoration = {
        rounding = 12,
        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            new_optimizations = true,
        },
        drop_shadow = true,
        shadow_range = 4,
        ["col.shadow"] = "rgba(1a1a1aee)",
    },

    animations = {
        enabled = true,
        bezier = {
            "fluid, 0.05, 0.9, 0.1, 1.05",
        },
        animation = {
            "windows, 1, 7, fluid",
            "windowsOut, 1, 7, default, popin 80%",
            "border, 1, 10, default",
            "fade, 1, 7, default",
            "workspaces, 1, 6, default",
        },
    },
})
