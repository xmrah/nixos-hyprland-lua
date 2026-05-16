-- Keybindings: Pure Lua Dispatchers

local mainMod = "SUPER"

-- Temel Aksiyonlar
hl.bind(mainMod .. " + RETURN", hl.dsp.exec("kitty"))
hl.bind(mainMod .. " + Q", hl.dsp.killactive())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.togglefloating())
hl.bind(mainMod .. " + R", hl.dsp.exec("wofi --show drun"))

-- Pencere Odaklama
hl.bind(mainMod .. " + left", hl.dsp.movefocus("l"))
hl.bind(mainMod .. " + right", hl.dsp.movefocus("r"))
hl.bind(mainMod .. " + up", hl.dsp.movefocus("u"))
hl.bind(mainMod .. " + down", hl.dsp.movefocus("d"))

-- Workspace Yönetimi
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.workspace(tostring(i)))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.movetoworkspace(tostring(i)))
end

-- Mouse Binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.movewindow(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.resizewindow(), { mouse = true })
