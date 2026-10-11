#!/usr/bin/env bash
# Sovereign Framework — Dynamic Brightness Control with Debounce
# Destekler: 1) brightnessctl (Laptop / VM) 2) ddcutil (Harici Monitör DDC/CI)
# Kullanım: brightness.sh [bus] <+5|-5>

if [[ "$1" =~ ^[+-] ]]; then
    CHANGE="$1"
    BUS=""
else
    BUS="$1"
    CHANGE="$2"
    CHANGE2="$3"
    [ -n "$CHANGE2" ] && CHANGE="$CHANGE $CHANGE2"
fi

# 1. Öncelik: Laptop veya Dahili Ekran (brightnessctl anında çalışır)
if command -v brightnessctl >/dev/null 2>&1 && brightnessctl -m >/dev/null 2>&1; then
    if [[ "$CHANGE" =~ \+ ]]; then
        brightnessctl set +5% >/dev/null 2>&1
    else
        brightnessctl set 5%- >/dev/null 2>&1
    fi
    exit 0
fi

# 2. Öncelik: DDC/CI Harici Monitör (ddcutil)
if command -v ddcutil >/dev/null 2>&1; then
    PIDFILE="/tmp/brightness_adjust.pid"
    if [ -f "$PIDFILE" ]; then
        kill "$(cat "$PIDFILE")" 2>/dev/null
    fi
    echo $$ > "$PIDFILE"
    sleep 0.1
    if [ -n "$BUS" ]; then
        ddcutil -b "$BUS" setvcp 10 $CHANGE 2>/dev/null
    else
        ddcutil setvcp 10 $CHANGE 2>/dev/null
    fi
    rm -f "$PIDFILE"
fi
