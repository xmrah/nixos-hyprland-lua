-- Keybindings: Pure Lua 0.55+ (Hardened Version)
-- Author: xmrah

local mainMod = "SUPER"

-- [ Applications ]
hl.bind(mainMod .. "+Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. "+Q",      hl.dsp.window.close())
hl.bind(mainMod .. "+M",      hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. "+E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. "+R",      hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mainMod .. "+V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. "+F",      hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. "+P",      hl.dsp.window.pseudo())
hl.bind(mainMod .. "+J",      hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. "+C",      hl.dsp.exec_cmd("chromium"))

-- [ Focus ]
hl.bind(mainMod .. "+left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. "+right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. "+up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. "+down",  hl.dsp.focus({ direction = "d" }))

-- [ Workspaces ]
for i = 1, 9 do
    hl.bind(mainMod .. "+" .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. "+SHIFT+" .. i, hl.dsp.window.move({ workspace = i }))
end

-- [ Mouse Bindings ]
hl.bind(mainMod .. "+mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. "+mouse:273", hl.dsp.window.resize(), { mouse = true })

-- [ Multimedia ]
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),    { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                         { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                         { repeating = true, locked = true })

-- [ Screenshots ]
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
