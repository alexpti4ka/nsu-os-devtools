#!/usr/bin/env bash
# Проверка домашнего задания «Компиляция: от исходника до линковки».
# Запускать из каталога задания:  ./check.sh
# Скрипт проверяет результаты в gcc-results/ и, если всё в порядке,
# собирает архив gcc-results.tar.gz для отправки преподавателю.

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

echo "Домашнее задание «Компиляция»: проверка артефакта"
echo

echo "[1] Состав каталога gcc-results/"
for f in warn-gcc.txt warn-clang.txt warn-werror.txt \
         pipeline.i pipeline.s pipeline.o pipeline pipeline-run.txt \
         main.i main2-noguard.i main2-guard.i \
         obj/main.o obj/mathx.o obj/strx.o calc calc-run.txt timestamps.txt \
         link-error-a.txt link-error-b.txt answers.txt session.txt; do
    check_file "gcc-results/$f" "gcc-results/$f"
done

echo
echo "[2] Исходники задания не изменены"
grep -q '#ifndef SHAPE_H' include/shape.h && ok "include/shape.h в исходном состоянии" \
    || bad "include/shape.h: потерян include guard — верните файл (git checkout -- .)"
if grep -q '#ifndef' include/common.h; then
    bad "include/common.h: остался include guard — верните файл в исходное состояние"
else
    ok "include/common.h в исходном состоянии (без guard)"
fi
grep -q 'int add(int a, int b) { return a + b; }' calc/include/mathx.h \
    && bad "calc/include/mathx.h: в заголовке осталось определение функции — верните файл" \
    || ok "calc/include/mathx.h в исходном состоянии (только объявление)"
grep -q 'count_char' calc/include/strx.h && ok "calc/include/strx.h в исходном состоянии" \
    || bad "calc/include/strx.h: функция переименована — верните файл"
grep -q 'int add(int a, int b) { return a + b; }' calc/src/mathx.c && ok "calc/src/mathx.c в исходном состоянии" \
    || bad "calc/src/mathx.c: определение add отсутствует — верните файл"


echo
echo "[3] Ключевые результаты"

if [ -s gcc-results/warn-gcc.txt ]; then
    n=$(grep -c 'warning' gcc-results/warn-gcc.txt)
    [ "$n" -ge 3 ] && ok "warn-gcc.txt: предупреждений gcc — $n (не меньше 3)" \
        || bad "warn-gcc.txt: предупреждений gcc только $n, ожидалось не меньше 3"
fi
if [ -s gcc-results/warn-clang.txt ]; then
    n=$(grep -c 'warning' gcc-results/warn-clang.txt)
    [ "$n" -ge 3 ] && ok "warn-clang.txt: предупреждений clang — $n (не меньше 3)" \
        || bad "warn-clang.txt: предупреждений clang только $n, ожидалось не меньше 3"
fi
if [ -s gcc-results/warn-werror.txt ]; then
    grep -q 'error' gcc-results/warn-werror.txt && ok "warn-werror.txt: сборка с -Werror не прошла" \
        || bad "warn-werror.txt: не найдено сообщение об ошибке"
fi

if [ -s gcc-results/pipeline-run.txt ]; then
    grep -q '55' gcc-results/pipeline-run.txt && ok "pipeline-run.txt: программа печатает 55" \
        || bad "pipeline-run.txt: ожидался вывод 55"
fi
if [ -s gcc-results/pipeline.i ]; then
    grep -qF '((i) * (i))' gcc-results/pipeline.i && ok "pipeline.i: макрос SQUARE раскрыт" \
        || bad "pipeline.i: не найдено раскрытие ((i) * (i))"
    grep -q 'SQUARE' gcc-results/pipeline.i && bad "pipeline.i: слово SQUARE ещё встречается" \
        || ok "pipeline.i: макроса SQUARE не осталось"
fi
if [ -s gcc-results/pipeline.s ]; then
    grep -q 'sum_squares' gcc-results/pipeline.s && ok "pipeline.s: найдена функция sum_squares" \
        || bad "pipeline.s: не найдена функция sum_squares"
fi

if [ -s gcc-results/main.i ]; then
    grep -qF '((p.x + 1) * (p.x + 1))' gcc-results/main.i && ok "main.i: AREA_SQUARE раскрыт со скобками" \
        || bad "main.i: не найдено раскрытие ((p.x + 1) * (p.x + 1))"
    grep -q 'PI_APPROX' gcc-results/main.i && bad "main.i: макрос PI_APPROX не раскрылся" \
        || ok "main.i: PI_APPROX подставлен"
fi

if [ -s gcc-results/main2-noguard.i ]; then
    n=$(grep -c 'struct Pair {' gcc-results/main2-noguard.i)
    [ "$n" = "2" ] && ok "main2-noguard.i: struct Pair встречается дважды" \
        || bad "main2-noguard.i: 'struct Pair {' встречается $n раз(а), ожидалось 2"
fi
if [ -s gcc-results/main2-guard.i ]; then
    n=$(grep -c 'struct Pair {' gcc-results/main2-guard.i)
    [ "$n" = "1" ] && ok "main2-guard.i: struct Pair встречается один раз" \
        || bad "main2-guard.i: 'struct Pair {' встречается $n раз(а), ожидалось 1"
fi

if [ -s gcc-results/calc-run.txt ]; then
    grep -q '^5$' gcc-results/calc-run.txt && grep -q '^20$' gcc-results/calc-run.txt && grep -q '^3$' gcc-results/calc-run.txt \
        && ok "calc-run.txt: вывод 5, 20, 3" \
        || bad "calc-run.txt: ожидался вывод 5, 20, 3"
fi
if [ -s gcc-results/timestamps.txt ]; then
    n=$(file_lines gcc-results/timestamps.txt)
    [ "$n" -ge 3 ] && ok "timestamps.txt: записаны времена объектных файлов" \
        || bad "timestamps.txt: в файле всего $n строк, ожидалось не меньше 3"
fi

if [ -s gcc-results/link-error-a.txt ]; then
    grep -q 'undefined reference' gcc-results/link-error-a.txt && ok "link-error-a.txt: undefined reference" \
        || bad "link-error-a.txt: не найдено 'undefined reference'"
fi
if [ -s gcc-results/link-error-b.txt ]; then
    grep -q 'multiple definition' gcc-results/link-error-b.txt && ok "link-error-b.txt: multiple definition" \
        || bad "link-error-b.txt: не найдено 'multiple definition'"
fi

if [ -s gcc-results/answers.txt ]; then
    n=$(grep -cve '^[[:space:]]*$' gcc-results/answers.txt)
    [ "$n" -ge 8 ] && ok "answers.txt: записано $n непустых строк" \
        || bad "answers.txt: записано всего $n непустых строк, ответов должно быть больше"
fi

echo
if [ "$fail" -eq 0 ]; then
    tar -czf gcc-results.tar.gz gcc-results/
    echo "Все проверки пройдены ($pass из $pass)."
    echo
    echo "Архив готов: $(pwd)/gcc-results.tar.gz"
    echo "Отправьте этот файл своему семинаристу удобным способом (канал связи уточните на занятии)."
    echo "В теме письма укажите: ДЗ Компиляция — ФИО"
    exit 0
else
    echo "Проверок не пройдено: $fail. Исправьте замечания и запустите ./check.sh ещё раз."
    exit 1
fi
