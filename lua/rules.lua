-- Window Rules & Workspace Assignments

hl.config({
    windowrule = {
        "float, ^(pavucontrol)$",
        "float, ^(blueman-manager)$",
    },
    
    windowrulev2 = {
        "opacity 0.95 0.90, class:^(kitty)$",
        "workspace 2, class:^(firefox)$",
        "idleinhibit focus, class:^(mpv)$",
    },
})
