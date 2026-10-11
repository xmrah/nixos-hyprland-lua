# Git & Justfile Otomasyon Kuralı

## Temel Prensip
Bir repoda `Justfile` mevcutsa, Git işlemleri (add, commit, push) için kullanıcıya ASLA ham/manuel `git commit` veya `git push` komutları önerilmez. Projedeki önceden tanımlanmış `just` reçeteleri mutlak önceliklidir.

## nixos-hyprland-lua Standardı
- Değişiklikleri kaydetmek ve uzak repolara göndermek için daima `just sync "<mesaj>"` kullanılır.
- Bu komut otomatik olarak:
  1. `just check` (Lua sözdizimi ve Hyprland config kontrolü)
  2. `just audit` (QML bütünlüğü, shell injection ve secret denetimi)
  3. Git staging ve commit (`feat: <mesaj> - <tarih>`)
  4. Hem GitHub hem de Codeberg uzak depolarına (`origin` ve `codeberg`) eşzamanlı push işlemlerini tek seferde icra eder.
