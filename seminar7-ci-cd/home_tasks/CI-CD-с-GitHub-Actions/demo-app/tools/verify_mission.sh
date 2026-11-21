#!/usr/bin/env bash
set -euo pipefail

mission_file=${1:?Usage: verify_mission.sh data/mission.env}

value() {
    sed -n "s/^$1=//p" "$mission_file" | head -n 1
}

oxygen=$(value OXYGEN)
temperature=$(value REACTOR_TEMP)

[[ "$oxygen" =~ ^[0-9]+$ ]] || { echo "OXYGEN must be an integer" >&2; exit 1; }
[[ "$temperature" =~ ^-?[0-9]+$ ]] || { echo "REACTOR_TEMP must be an integer" >&2; exit 1; }

if (( oxygen < 19 || oxygen > 25 )); then
    echo "Unsafe mission: OXYGEN=$oxygen, expected 19..25" >&2
    exit 1
fi

if (( temperature < -20 || temperature > 60 )); then
    echo "Unsafe mission: REACTOR_TEMP=$temperature, expected -20..60" >&2
    exit 1
fi

echo "Mission data accepted: oxygen=$oxygen, reactor=$temperature"
