-- Sovereign Framework: Utils Library (Hyprland 0.56+)
-- Global Utils objesi (Her yerden erişilebilir)

Utils = {}

-- Asenkron bash komutu (Hyprland UI thread'ini asla bloklamaz)
function Utils.async_cmd(cmd)
    os.execute(cmd .. " > /dev/null 2>&1 &")
end

-- Native Hyprland bildirimi (v0.56+ — fork yok, anında gösterir)
-- Kısa durum mesajları için ideal (Auto-Tab, Focus Korundu vb.)
function Utils.notify(title, message, timeout)
    timeout = timeout or 2000
    local text = title .. ": " .. message
    hl.notification.create({ text = text, timeout = timeout })
end

-- Zengin bildirim (swaync üzerinden — aksiyon butonları, geçmiş vb. için)
function Utils.notify_send(title, message, timeout)
    timeout = timeout or 2000
    Utils.async_cmd(string.format("notify-send '%s' '%s' -t %d", title, message, timeout))
end

-- Quickshell IPC çağrısı (Örn: Utils.qs_ipc("bar", "hide"))
function Utils.qs_ipc(module, action)
    Utils.async_cmd(string.format("quickshell ipc call default %s %s", module, action))
end

print("[lib/utils.lua] Utils kütüphanesi yüklendi (v0.56+ native API).")

