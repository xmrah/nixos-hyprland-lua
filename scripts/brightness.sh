#!/usr/bin/env bash
# Monitor Brightness Control with Debounce for I2C safety
# Usage: ./brightness.sh <bus> <change>
# Example: ./brightness.sh 9 "+ 5"

BUS=$1
CHANGE=$2
CHANGE2=$3

if [ -z "$BUS" ] || [ -z "$CHANGE" ]; then
    echo "Usage: $0 <bus> <change>"
    exit 1
fi

PIDFILE="/tmp/brightness_adjust.pid"

if [ -f "$PIDFILE" ]; then
    kill $(cat "$PIDFILE") 2>/dev/null
fi

echo $$ > "$PIDFILE"
sleep 0.1 
ddcutil -b "$BUS" setvcp 10 $CHANGE $CHANGE2
rm -f "$PIDFILE"
