#!/usr/bin/env bash
# Проверка домашнего задания «Конвейеры: дело кофейни «Байт»».
# Запускать из каталога задания:  ./check.sh
# Скрипт проверяет результаты в results/ и, если всё в порядке,
# собирает архив konvejery-results.tar.gz для отправки преподавателю.

set -u
cd "$(dirname "$0")" || exit 1

pass=0
fail=0

ok()  { printf '  [OK] %s\n' "$1"; pass=$((pass + 1)); }
bad() { printf '  [--] %s\n' "$1"; fail=$((fail + 1)); }

file_lines() { wc -l < "$1" | tr -d ' '; }

check_file() {
    if [ -s "$1" ]; then
        ok "$2"
    else
        bad "$2: файл $1 отсутствует или пуст"
    fi
}

echo "Домашнее задание «Конвейеры»: проверка артефакта"
echo

echo "[1] Состав каталога results/"
for f in lines.txt orders-21-25.txt wifi-reviews.txt top-drinks.txt \
         staff-new.txt shopping.txt hours.txt report.txt answers.txt session.txt; do
    check_file "results/$f" "results/$f"
done

echo
echo "[2] Исходные файлы не изменялись"
if [ -f orders.log ]; then
    n=$(file_lines orders.log)
    [ "$n" = "72" ] && ok "orders.log: 72 строки" || bad "orders.log: ожидалось 72 строки, получено $n (файл изменён?)"
else
    bad "orders.log: файл отсутствует"
fi
if [ -f reviews.txt ]; then
    n=$(file_lines reviews.txt)
    [ "$n" = "16" ] && ok "reviews.txt: 16 строк" || bad "reviews.txt: ожидалось 16 строк, получено $n"
fi
if [ -f staff.txt ]; then
    n=$(file_lines staff.txt)
    [ "$n" = "7" ] && ok "staff.txt: 7 строк" || bad "staff.txt: ожидалось 7 строк, получено $n"
fi

echo
echo "[3] Ключевые ответы"

if [ -s results/orders-21-25.txt ]; then
    n=$(file_lines results/orders-21-25.txt)
    [ "$n" = "5" ] && ok "orders-21-25.txt: 5 строк" || bad "orders-21-25.txt: ожидалось 5 строк, получено $n"
    grep -q '^2026-10-08|20:28:41|misha|latte|M|280|cash$' results/orders-21-25.txt \
        && ok "orders-21-25.txt: первая строка — заказ 21" \
        || bad "orders-21-25.txt: не найден заказ 21 (2026-10-08|20:28:41|misha|latte|M|280|cash)"
fi

if [ -s results/wifi-reviews.txt ]; then
    n=$(grep -icE 'wi-?fi' results/wifi-reviews.txt || true)
    [ "$n" = "5" ] && ok "wifi-reviews.txt: 5 отзывов про Wi-Fi" || bad "wifi-reviews.txt: ожидалось 5 отзывов про Wi-Fi, получено $n"
fi

if [ -s results/top-drinks.txt ]; then
    n=$(file_lines results/top-drinks.txt)
    [ "$n" = "3" ] && ok "top-drinks.txt: 3 строки" || bad "top-drinks.txt: ожидалось 3 строки, получено $n"
    first=$(head -n 1 results/top-drinks.txt)
    [ "$first" = "latte: 23" ] && ok "top-drinks.txt: первая строка 'latte: 23'" \
        || bad "top-drinks.txt: первая строка должна быть 'latte: 23', получено '$first'"
fi

if [ -s results/staff-new.txt ]; then
    n=$(file_lines results/staff-new.txt)
    [ "$n" = "7" ] && ok "staff-new.txt: 7 строк" || bad "staff-new.txt: ожидалось 7 строк, получено $n"
    n=$(grep -c 'trainee' results/staff-new.txt)
    [ "$n" = "1" ] && ok "staff-new.txt: 'trainee' встречается один раз" || bad "staff-new.txt: 'trainee' должен встречаться один раз, получено $n"
    n=$(grep -c 'kostya:trainee:' results/staff-new.txt)
    [ "$n" = "1" ] && ok "staff-new.txt: у kostya роль trainee" || bad "staff-new.txt: у kostya должна быть роль trainee"
fi

if [ -s results/shopping.txt ]; then
    n=$(file_lines results/shopping.txt)
    [ "$n" = "5" ] && ok "shopping.txt: 5 строк" || bad "shopping.txt: ожидалось 5 строк, получено $n"
    grep -q '^cinnamon$' results/shopping.txt && grep -q '^oat_milk$' results/shopping.txt \
        && ok "shopping.txt: есть cinnamon и oat_milk" || bad "shopping.txt: среди позиций нет cinnamon и oat_milk"
fi

if [ -s results/hours.txt ]; then
    n=$(file_lines results/hours.txt)
    [ "$n" = "12" ] && ok "hours.txt: 12 строк" || bad "hours.txt: ожидалось 12 строк, получено $n"
    sum=$(awk '{ s += $NF } END { print s + 0 }' results/hours.txt)
    [ "$sum" = "72" ] && ok "hours.txt: сумма заказов равна 72" || bad "hours.txt: сумма чисел равна $sum, ожидалось 72"
fi

if [ -s results/report.txt ]; then
    n=$(file_lines results/report.txt)
    [ "$n" = "13" ] && ok "report.txt: 13 строк" || bad "report.txt: ожидалось 13 строк, получено $n"
    grep -q '^Топ-3 напитка:$' results/report.txt && ok "report.txt: есть строка 'Топ-3 напитка:'" || bad "report.txt: нет строки 'Топ-3 напитка:'"
    grep -q '^Бесплатные заказы:$' results/report.txt && ok "report.txt: есть строка 'Бесплатные заказы:'" || bad "report.txt: нет строки 'Бесплатные заказы:'"
    grep -q '^Подозреваемый: kostya$' results/report.txt && ok "report.txt: подозреваемый — kostya" || bad "report.txt: последняя строка должна быть 'Подозреваемый: kostya'"
    n=$(grep -cE '^[0-9]{4}-[0-9]{2}-[0-9]{2}\|' results/report.txt)
    [ "$n" = "6" ] && ok "report.txt: 6 бесплатных заказов целиком" || bad "report.txt: ожидалось 6 строк заказов, получено $n"
fi

if [ -s results/answers.txt ]; then
    n=$(grep -cve '^[[:space:]]*$' results/answers.txt)
    [ "$n" -ge 8 ] && ok "answers.txt: записано $n непустых строк" || bad "answers.txt: записано всего $n непустых строк, ответов должно быть больше"
fi

echo
if [ "$fail" -eq 0 ]; then
    tar -czf konvejery-results.tar.gz results/
    echo "Все проверки пройдены ($pass из $pass)."
    echo
    echo "Архив готов: $(pwd)/konvejery-results.tar.gz"
    echo "Отправьте этот файл своему семинаристу удобным способом (канал связи уточните на занятии)."
    echo "В теме письма укажите: ДЗ Конвейеры — ФИО"
    exit 0
else
    echo "Проверок не пройдено: $fail. Исправьте замечания и запустите ./check.sh ещё раз."
    exit 1
fi
