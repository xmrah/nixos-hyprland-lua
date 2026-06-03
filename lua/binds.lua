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
hl.bind(mainMod .. "+T",      hl.dsp.exec_cmd("chromium"))
hl.bind(mainMod .. "+C",      hl.dsp.exec_cmd("cliphist list | wofi --dmenu -p 'Clipboard' | cliphist decode | wl-copy"))

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
hl.bind(mainMod .. "+S",     hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkspace magic"))
hl.bind(mainMod .. "+Z",     hl.dsp.exec_cmd("hyprctl dispatch movetospecialworkspace magic"))

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
-- 7. MULTİMEDYA (SwayOSD Katmanı)
-- ═══════════════════════════════════════════
-- fnmode=2: F tuşları varsayılan F1-F12, Fn+F → XF86 keysym'leri tetikler

-- Ses
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })

-- Medya Kontrolü (playerctl)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"),       { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Parlaklık (DDC/CI — harici monitör, /sys/class/backlight yok)
-- NOT: repeating = true yok — ddcutil I2C flood edip kernel oops tetikler
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("ddcutil setvcp 10 + 5"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("ddcutil setvcp 10 - 5"), { locked = true })

-- ═══════════════════════════════════════════
-- 8. EKRAN GÖRÜNTÜSÜ
-- ═══════════════════════════════════════════
-- SUPER+SHIFT+S: Alan seç → panoya kopyala
hl.bind(mainMod .. "+SHIFT+S", hl.dsp.exec_cmd("sh -c 'grim -g \"$(slurp)\" - | wl-copy && notify-send \"Screenshot\" \"Panoya kopyalandı\" -t 2000'"))
-- SUPER+ALT+S: Tüm ekran → dosyaya kaydet
hl.bind(mainMod .. "+ALT+S", hl.dsp.exec_cmd("sh -c 'FILE=~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png; grim \"$FILE\" && notify-send \"Screenshot\" \"$FILE\" -t 2000'"))
-- SUPER+CTRL+S: Alan seç → düzenle (swappy)
hl.bind(mainMod .. "+CTRL+S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))

