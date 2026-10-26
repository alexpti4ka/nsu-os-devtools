#!/usr/bin/env bash
# Проверка лабораторной работы 1 «Сборка и запуск многоконтейнерного приложения на C».
# Запускать из каталога c-lab-multiservice/:  ./check.sh
# Скрипт проверяет неизменность исходников, сборку проекта и результаты,
# а затем собирает именной архив lab1-launcher-<Фамилия>-<хеш>.tar.gz.

set -u
cd "$(dirname \"$0\")" || exit 1

pass=0
fail=0

ok()  { printf '  [OK] %s\n' "$1"; pass=$((pass + 1)); }
bad() { printf '  [--] %s\n' "$1"; fail=$((fail + 1)); }

check_file() {
    if [ -s "$1" ]; then
        ok "$2"
    else
        bad "$2: файл $1 отсутствует или пуст"
    fi
}

# ---------- Персональные данные студента ----------
echo "Лабораторная работа 1 «Сборка и запуск приложения на C»: проверка артефакта"
echo

STUDENT_SURNAME="${STUDENT_SURNAME:-}"
STUDENT_NAME="${STUDENT_NAME:-}"
if [ -z "$STUDENT_SURNAME" ] || [ -z "$STUDENT_NAME" ]; then
    echo "Для персонализированного задания введите свои данные:"
    read -rp "Фамилия: " STUDENT_SURNAME
    read -rp "Имя: " STUDENT_NAME
fi

STUDENT_KEY="${STUDENT_SURNAME} ${STUDENT_NAME}"
HASH=$(printf '%s' "$STUDENT_KEY" | sha256sum | cut -c1-8)
ARCHIVE="lab1-launcher-${STUDENT_SURNAME}-${HASH}.tar.gz"

echo "Студент: $STUDENT_SURNAME $STUDENT_NAME  (хеш $HASH)"
echo

# ---------- [1] Неизменность исходных файлов ----------
declare -A EXPECTED=(
    ["Makefile"]="f1fec61f4818504a152b1f491bca5ec91392f61aed0aa0a21ec5ae301764794d"
    ["lib/http.c"]="a01d2968e959eba75e527ab11b2d2d438672d64f9fa14a50748f4b27b70bcf08"
    ["lib/net.c"]="62ac604f2b9136b4655586e38f908c9777abac56046d8c0bd2d8137facd04ac0"
    ["lib/utils.c"]="9e1d6bf233558702c8cd583a812a4bf1bd09f81eee67753a160076d4a6d58032"
    ["include/http.h"]="a8c957dad4d72c7d04f409f3bb77f101d8899c0cbe753ed50c530bfc75f427a8"
    ["include/net.h"]="0015384a3b12250e3faaf5da63cc90a4a9825abd1a86fe4db1e107be0e1ba124"
    ["include/utils.h"]="8dd50c6790bc7ebfd44a7636ed6e3ac52df3f2ba47301bcec144ab2f4cabd60a"
    ["apps/backend/handler.c"]="882ac1f21f32dcd0f18de7a2c4a00d8ebcc10ac637501df6c8a4d01f192a62bb"
    ["apps/backend/main.c"]="3966b575a61af1c22a4c073528542da0d3e68d4f6a7e674d9bcd9ed9846aa211"
    ["apps/balancer/main.c"]="64d51ab5467beecab792e881b35d967215693b8661a90dca0d806614f312e6c6"
    ["apps/balancer/router.c"]="6d0df298edd3c4bf0bfd453af95953ce12fab9bae198c8dff3d2186b895cdc8b"
    ["apps/loadgen/main.c"]="27345e87a05c5bae76c33799ffdaddd4e0be5285d4585f0fdcfe7146abbc117d"
    ["apps/loadgen/stats.c"]="0d27ebdca577b553d0e709c11ef817e05834e5835a420defbafd87237d6c36ba"
    ["apps/backend/handler.h"]="62b128b28b88f35ef768a69fa8974fdd8bc21978e30861a90dca0d806614f312e6c6"
    ["apps/balancer/router.h"]="5598667192949942a3380b990061f85599218ce590fdd2fa5197a53890ebc53c"
    ["apps/loadgen/stats.h"]="89ed9008d922da6d27b74560de1eaa9b8dd6beef102b222ce76cebba74c6d741"
)

for file in "${!EXPECTED[@]}"; do
    if [ -f "$file" ]; then
        actual=$(sha256sum "$file" | cut -d' ' -f1)
        if [ "$actual" = "${EXPECTED[$file]}" ]; then
            ok "$file не изменён"
        else
            bad "$file: изменён (ожидался ${EXPECTED[$file]}, получен $actual)"
        fi
    else
        bad "$file: отсутствует"
    fi
done

echo

# ---------- [2] Локальная сборка ----------
echo "[2] Локальная сборка корневым Makefile"

if [ -f Makefile ]; then
    if make clean >/dev/null 2>&1; then
        ok "make clean выполнен"
    else
        bad "make clean не выполнен"
    fi

    if make >/dev/null 2>&1; then
        ok "make выполнен успешно"
    else
        bad "make завершился с ошибкой"
    fi

    for target in build/lib/libcommon.a apps/backend/backend apps/balancer/balancer apps/loadgen/loadgen; do
        check_file "$target" "$target собран"
    done
else
    bad "Makefile отсутствует"
fi

echo
# ---------- [3] Переменные CC / CFLAGS ----------
echo "[3] Переменные CC и CFLAGS из окружения"

if CC=clang CFLAGS="-Wall -Wextra" make clean >/dev/null 2>&1 && CC=clang CFLAGS="-Wall -Wextra" make >/dev/null 2>&1; then
    ok "сборка с переопределёнными CC/CFLAGS прошла успешно"
else
    bad "сборка с переопределёнными CC/CFLAGS не прошла"
fi

make clean >/dev/null 2>&1
make >/dev/null 2>&1

echo

# ---------- [4] compose.yaml ----------
echo "[4] Конфигурация Docker Compose"

if [ -f compose.yaml ]; then
    ok "compose.yaml существует"
    for svc in backend-1 backend-2 balancer loadgen; do
        if grep -qE "^[[:space:]]*${svc}:" compose.yaml; then
            ok "сервис $svc описан в compose.yaml"
        else
            bad "сервис $svc не найден в compose.yaml"
        fi
    done
else
    bad "compose.yaml отсутствует"
fi

for df in apps/backend/Dockerfile apps/balancer/Dockerfile apps/loadgen/Dockerfile; do
    check_file "$df" "$df существует"
done

echo

# ---------- [5] Результаты нагрузки ----------
echo "[5] Результаты нагрузки (results/result.csv)"

if [ -s results/result.csv ]; then
    lines=$(wc -l < results/result.csv | tr -d ' ')
    ok "results/result.csv содержит $lines строк(и)"
    if head -1 results/result.csv | grep -q 'request_id,backend,latency_ms,status'; then
        ok "results/result.csv: верный заголовок"
    else
        bad "results/result.csv: неверный заголовок (ожидается request_id,backend,latency_ms,status)"
    fi
else
    bad "results/result.csv отсутствует или пуст"
fi

echo
# ---------- [6] Персонализированные ответы ----------
echo "[6] Персонализированные ответы (lab1-results/answers.txt)"

if [ -s lab1-results/answers.txt ]; then
    n=$(grep -cve '^[[:space:]]*$' lab1-results/answers.txt)
    [ "$n" -ge 4 ] && ok "answers.txt: записано $n непустых строк(и)" \
        || bad "answers.txt: всего $n непустых строк, нужно не меньше 4"
else
    bad "answers.txt: файл отсутствует или пуст (создайте lab1-results/answers.txt с ответами на вопросы из раздела 7 README)"
fi

if [ -s lab1-results/answers.txt ]; then
    if grep -qiE 'REQUEST_COUNT|1000|100|запросов' lab1-results/answers.txt; then
        ok "answers.txt: указано количество запросов (персональный параметр)"
    else
        bad "answers.txt: не указано количество запросов из вашего варианта"
    fi
fi

# ---------- Итог ----------
echo
if [ "$fail" -eq 0 ]; then
    tar -czf "$ARCHIVE" lab1-results/
    echo "Все проверки пройдены ($pass из $pass)."
    echo
    echo "Архив готов: $(pwd)/$ARCHIVE"
    echo "Отправьте этот файл своему семинаристу удобным способом (канал связи уточните на занятии)."
    echo "В теме письма укажите: lab1-launcher — $STUDENT_SURNAME $STUDENT_NAME"
    exit 0
else
    echo "Проверок не пройдено: $fail. Исправьте замечания и запустите ./check.sh ещё раз."
    exit 1
fi
echo "[1] Исходные файлы не изменены студентами"