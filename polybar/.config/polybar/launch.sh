#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch main bar on all displays
# Use custom config config path & live reloading
for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar -r -c ~/.config/polybar/config.ini main &
done
