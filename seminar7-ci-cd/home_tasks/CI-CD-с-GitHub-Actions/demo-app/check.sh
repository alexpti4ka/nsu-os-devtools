#!/usr/bin/env bash
# Локальная предварительная проверка Mission Control.
set -euo pipefail

need() {
    if [ ! -e "$1" ]; then
        printf 'Нет обязательного файла: %s\n' "$1" >&2
        exit 1
    fi
}

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

for file in Makefile data/mission.env tools/verify_mission.sh \
            tools/render_site.sh .github/workflows/ci.yml; do
    need "$file"
done

grep -Eq '^MISSION_NAME=.*[^[:space:]]' data/mission.env ||
    fail 'Укажите название миссии (MISSION_NAME).'
grep -Eq '^CALLSIGN=.*[^[:space:]]' data/mission.env ||
    fail 'Укажите свой позывной из Evil Corp (CALLSIGN).'
grep -Eq '^PR_NUMBER=[1-9][0-9]*$' data/mission.env ||
    fail 'Укажите номер pull request (PR_NUMBER).'

workflow=.github/workflows/ci.yml
for target in test check-data; do
    grep -Eq "^[[:space:]]+run: make $target[[:space:]]*$" "$workflow" ||
        fail "Добавьте в ci.yml отдельный шаг с командой make $target."
done

make test check-data site report

printf 'Локальная проверка пройдена. Перед сдачей откройте опубликованную панель и проверьте обе ссылки на ней.\n'
