-- Sovereign Keybindings: Pure Lua 0.55+
-- Author: xmrah

local mainMod = "SUPER"

-- ═══════════════════════════════════════════
-- 1. UYGULAMALAR
-- ═══════════════════════════════════════════
hl.bind(mainMod .. "+Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. "+Q",      hl.dsp.window.close())
hl.bind(mainMod .. "+M",      hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. "+E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. "+R",      hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mainMod .. "+C",      hl.dsp.exec_cmd("chromium"))

-- ═══════════════════════════════════════════
-- 2. PENCERE YÖNETİMİ
-- ═══════════════════════════════════════════
hl.bind(mainMod .. "+V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. "+F",      hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. "+P",      hl.dsp.window.pseudo())
hl.bind(mainMod .. "+J",      hl.dsp.layout("togglesplit"))

-- Pencere Boyutlandırma (SUPER+CTRL+Yön)
hl.bind(mainMod .. "+CTRL+left",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive -40 0"),  { repeating = true })
hl.bind(mainMod .. "+CTRL+right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 40 0"),   { repeating = true })
hl.bind(mainMod .. "+CTRL+up",    hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -40"),  { repeating = true })
hl.bind(mainMod .. "+CTRL+down",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 40"),   { repeating = true })

-- Pencere Taşıma (SUPER+SHIFT+Yön)
hl.bind(mainMod .. "+SHIFT+left",  hl.dsp.exec_cmd("hyprctl dispatch movewindow l"))
hl.bind(mainMod .. "+SHIFT+right", hl.dsp.exec_cmd("hyprctl dispatch movewindow r"))
hl.bind(mainMod .. "+SHIFT+up",    hl.dsp.exec_cmd("hyprctl dispatch movewindow u"))
hl.bind(mainMod .. "+SHIFT+down",  hl.dsp.exec_cmd("hyprctl dispatch movewindow d"))

-- ═══════════════════════════════════════════
-- 3. FOCUS
-- ═══════════════════════════════════════════
hl.bind(mainMod .. "+left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. "+right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. "+up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. "+down",  hl.dsp.focus({ direction = "d" }))

-- ═══════════════════════════════════════════
-- 4. WORKSPACES
-- ═══════════════════════════════════════════
for i = 1, 9 do
    hl.bind(mainMod .. "+" .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. "+SHIFT+" .. i, hl.dsp.window.move({ workspace = i }))
end

-- Workspace Scroll (Mouse wheel ile geçiş)
hl.bind(mainMod .. "+mouse_up",   hl.dsp.exec_cmd("hyprctl dispatch workspace e-1"))
hl.bind(mainMod .. "+mouse_down", hl.dsp.exec_cmd("hyprctl dispatch workspace e+1"))

-- Özel Workspace (Scratchpad)
hl.bind(mainMod .. "+S",       hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkspace magic"))
hl.bind(mainMod .. "+SHIFT+S", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace special:magic"))

-- ═══════════════════════════════════════════
-- 5. FARE
-- ═══════════════════════════════════════════
hl.bind(mainMod .. "+mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. "+mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ═══════════════════════════════════════════
-- 6. SİSTEM KONTROL
-- ═══════════════════════════════════════════

-- Bildirim Merkezi (SwayNC)
hl.bind(mainMod .. "+N", hl.dsp.exec_cmd("swaync-client -t -sw"))

-- Ekran Kilidi
hl.bind(mainMod .. "+L", hl.dsp.exec_cmd("hyprlock"))

-- ═══════════════════════════════════════════
-- 7. MULTİMEDYA
-- ═══════════════════════════════════════════
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),    { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                         { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                         { repeating = true, locked = true })

-- ═══════════════════════════════════════════
-- 8. EKRAN GÖRÜNTÜSÜ
-- ═══════════════════════════════════════════
-- Print: Alan seç → panoya kopyala
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
-- SUPER+Print: Tüm ekran → dosyaya kaydet
hl.bind(mainMod .. "+Print", hl.dsp.exec_cmd("grim ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"))
-- SUPER+SHIFT+Print: Alan seç → düzenle (swappy)
hl.bind(mainMod .. "+SHIFT+Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))

