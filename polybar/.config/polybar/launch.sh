#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

outputs=$(xrandr | grep " connected" | cut -d" " -f1)

primary_output=$(xrandr | grep " connected primary" | cut -d " " -f1) || eDP1

# Launch main bar on all displays
for output in $outputs; do
  export MONITOR=$output
  export TRAY_POSITION=none

  # Display tray on primary output
  if [[ $output == $primary_output ]]; then
    TRAY_POSITION=right
  fi

  # Launch with custom config path & live reloading
  polybar -r -c ~/.config/polybar/config.ini main &
  disown
done
