#!/bin/bash

script_name="$0"  # name of script
arg=$1

# Theory:
#  "xrandr" adjusts brightness through software gamma correction. So xrandr modifies the display's gamma or color levels to make the screen appear brighter or darker. This does not affect the actual hardware backlight of the screen; instead, it changes how the pixels are rendered, which is why the values in /sys/class/backlight are untouched.
#  For changing hardware brightness for monitors, which are support it, we use "brightnessctl"

function help() {
  cat <<-EOF
Change brightness for all monitors

Examples:
    $script_name +10%
    $script_name -10%
EOF
}

case "$arg" in
  "-h"|"--help"|"help")
    help
    exit 0
    ;;
esac

echo "$arg" | grep -E '^[+-][0-9]+%$' &> /dev/null
if [[ "$?" != "0" ]]; then
    help
    exit 0
fi

value=${arg:1:-1}
operation=${arg::1}
echo "value: $value"
echo "operation: $operation"

echo
echo "Gamma correction for monitors which doesn't support hardware brightness changing"
for monitor in $(xrandr --listmonitors | awk '/^\s+[0-9]:/ {print $NF}'); do
    echo "monitor: $monitor"
    echo $monitor | grep --color=no eDP &> /dev/null
    if [[ "$?" == "0" ]]; then
        echo "  This monitor should support hardware brightness managment. So skip gamma correction for this monitor."
        continue
    fi
    current_brightness=$(xrandr --verbose | grep -A 5 "^$monitor" | grep "Brightness" | awk '{print $2}')
    new_brightness=$(echo "$current_brightness $operation $value / 100" | bc -l)
    echo "  new_brightness: $new_brightness"
    if (( $(echo "$new_brightness < 0" | bc -l) )); then new_brightness=0; fi
    if (( $(echo "$new_brightness > 1" | bc -l) )); then new_brightness=1; fi
    echo "  new_brightness final: $new_brightness"
    xrandr --output $monitor --brightness $new_brightness
done
echo
echo "Made hardware brightness changing"
if [[ "$?" == "0" ]]; then
    if [[ "$operation" == "+" ]]; then
        brightnessctl set ${operation}${value}%
    else
        brightnessctl set ${value}%${operation}
    fi
fi
