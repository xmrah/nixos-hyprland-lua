pragma Singleton
import Quickshell
import QtQuick

// Sovereign Appearance Tokens
// Animasyon süreleri, boyut değerleri — tüm QML bileşenlerinin tek kaynağı
// Bir değeri buradan değiştirmek tüm sisteme yansır
Singleton {
    // ── Animasyon Süreleri ─────────────────────────────────────────────
    readonly property QtObject anim: QtObject {
        // hover, border renk geçişleri
        readonly property QtObject fast: QtObject { readonly property int dur: 150 }
        // workspace dot genişlik / renk geçişleri
        readonly property QtObject ws:   QtObject { readonly property int dur: 180 }
        // CPU/RAM yük renk geçişleri (daha yavaş — ani değişimleri yumuşatır)
        readonly property QtObject cpu:  QtObject { readonly property int dur: 300 }
    }

    // ── Boyut Tokenları ────────────────────────────────────────────────
    readonly property QtObject size: QtObject {
        readonly property int barH:       36  // bar yüksekliği (piksel)
        readonly property int widgetH:    30  // bileşen yüksekliği
        readonly property int radius:     12  // köşe yarıçapı — Volume, Brightness, Power
        readonly property int radiusSm:   10  // küçük köşe yarıçapı — Clock, SysInfo, Workspaces
        readonly property int marginTop:   3  // bar üst boşluk
        readonly property int marginSide: 12  // bar sol/sağ boşluk
        readonly property int iconSize:   16  // ikon font boyutu
        readonly property int textSize:   13  // etiket font boyutu
    }
}
