#!/usr/bin/env python3
"""
Sovereign Framework — Otomatik Kalite ve Gray-Hat Güvenlik Denetleyicisi
"""
import glob
import os
import re
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
QML_DIR = os.path.join(BASE_DIR, "quickshell")
QMLDIR_FILE = os.path.join(QML_DIR, "qmldir")

def check_qmldir_registration():
    print("🔍 [QC 1/4] QML & qmldir bütünlüğü kontrol ediliyor...")
    with open(QMLDIR_FILE, "r", encoding="utf-8") as f:
        qmldir_text = f.read()

    qml_files = glob.glob(os.path.join(QML_DIR, "*.qml"))
    errors = []
    for f in qml_files:
        base = os.path.basename(f)
        if base != "shell.qml" and base not in qmldir_text:
            errors.append(f"❌ '{base}' dosyası quickshell/qmldir içinde kayıtlı değil!")

    if errors:
        for err in errors:
            print(err)
        return False
    print("  ✅ Tüm aktif QML bileşenleri qmldir içinde tanımlı.")
    return True

def check_dead_qml_code():
    print("🔍 [QC 2/4] Quickshell ölü kod (Dead-Code) analizi yapılıyor...")
    qml_files = glob.glob(os.path.join(QML_DIR, "*.qml"))
    all_content = {}
    for f in qml_files:
        with open(f, "r", encoding="utf-8") as fl:
            all_content[os.path.basename(f)] = fl.read()

    singletons = {
        "Appearance", "Colors", "AudioService", "BrightnessService",
        "SysInfoService", "GlobalStates", "NotificationService", "shell"
    }

    errors = []
    for f in sorted(qml_files):
        name = os.path.basename(f)[:-4]
        if name in singletons:
            continue
        pattern = re.compile(rf'(^|\s){name}\s*\{{')
        used = False
        for fname, content in all_content.items():
            if fname == f"{name}.qml":
                continue
            if pattern.search(content) or f"{name}." in content:
                used = True
                break
        if not used:
            errors.append(f"❌ Ölü/Kullanılmayan QML dosyası tespit edildi: {name}.qml")

    if errors:
        for err in errors:
            print(err)
        return False
    print("  ✅ Sıfır ölü kod: Tüm QML dosyaları ekosistemde aktif kullanılıyor.")
    return True

def check_shell_injection():
    print("🛡️ [QC 3/4] Güvenlik & Shell Injection denetimi...")
    dangerous_patterns = [
        re.compile(r'sh",\s*"-c",\s*"echo.*cliphist'),
        re.compile(r'command:\s*\["sh",\s*"-c",\s*".*\+.*replace\(.*cliphist')
    ]
    errors = []
    for f in glob.glob(os.path.join(QML_DIR, "*.qml")):
        with open(f, "r", encoding="utf-8") as fl:
            text = fl.read()
        for pat in dangerous_patterns:
            if pat.search(text):
                errors.append(f"❌ Güvensiz kabuk boru hattı (shell injection riski): {os.path.basename(f)}")

    if errors:
        for err in errors:
            print(err)
        return False
    print("  ✅ Shell injection açığı bulunamadı: Pano ve süreçler güvenli stdin kullanıyor.")
    return True

def check_secret_leaks():
    print("🛡️ [QC 4/4] Sır ve kişisel veri sızıntı taraması...")
    leak_pattern = re.compile(r'password\s*=|api[_-]?key\s*=|private_key|xmrah7@gmail\.com', re.IGNORECASE)
    errors = []
    for root, dirs, files in os.walk(BASE_DIR):
        if any(ignored in root for ignored in [".git", ".agent"]):
            continue
        for file in files:
            if file in ["Justfile", "audit.py"]:
                continue
            path = os.path.join(root, file)
            try:
                with open(path, "r", encoding="utf-8", errors="ignore") as fl:
                    for i, line in enumerate(fl, 1):
                        if leak_pattern.search(line):
                            errors.append(f"❌ Sızıntı tespiti ({file}:{i}): {line.strip()[:60]}")
            except Exception:
                pass

    if errors:
        for err in errors:
            print(err)
        return False
    print("  ✅ Sır/Veri sızıntısı yok: Çalışma dizini tertemiz.")
    return True

if __name__ == "__main__":
    results = [
        check_qmldir_registration(),
        check_dead_qml_code(),
        check_shell_injection(),
        check_secret_leaks()
    ]
    if not all(results):
        print("\n❌ DENETİM BAŞARISIZ: Lütfen yukarıdaki hataları düzeltin!")
        sys.exit(1)
    print("\n🎉 TEBRİKLER: Tüm Kalite ve Gray-Hat Denetimleri %100 Başarılı!")
    sys.exit(0)
