#!/usr/bin/env bash
# Проверка домашнего задания «Система сборки: Makefile для проекта calc».
# Запускать из каталога задания:  ./check.sh
# Скрипт проверяет результаты в make-results/ и, если всё в порядке,
# собирает архив s3-makefile.tar.gz для отправки преподавателю.

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

echo "Домашнее задание «Makefile»: проверка артефакта"
echo

echo "[1] Состав каталога make-results/"
for f in Makefile run.txt test-ok.txt test-fail.txt \
         timestamps-1.txt timestamps-edit.txt answers.txt session.txt; do
    check_file "make-results/$f" "make-results/$f"
done

echo
echo "[2] Исходный проект calc/ не изменён"
if grep -q 'mul(4, 5)' calc/src/main.c; then
    ok "calc/src/main.c в исходном состоянии"
else
    bad "calc/src/main.c: не найден вызов mul(4, 5) — верните файл (git checkout -- .)"
fi
if grep -q 'int add(int a, int b) { return a + b; }' calc/src/mathx.c; then
    ok "calc/src/mathx.c в исходном состоянии"
else
    bad "calc/src/mathx.c: определение add не найдено — верните файл"
fi
if grep -q '^add: 5$' calc/expected.txt && grep -q '^mul: 20$' calc/expected.txt; then
    ok "calc/expected.txt в исходном состоянии"
else
    bad "calc/expected.txt: содержимое изменено — верните файл"
fi

echo
echo "[3] Финальный Makefile"
if [ -s make-results/Makefile ]; then
    grep -q '^\.PHONY' make-results/Makefile && ok "Makefile: есть директива .PHONY" \
        || bad "Makefile: не найдена директива .PHONY"
    grep -q '^all:' make-results/Makefile && ok "Makefile: есть цель all" \
        || bad "Makefile: нет цели all"
    grep -q '^clean:' make-results/Makefile && ok "Makefile: есть цель clean" \
        || bad "Makefile: нет цели clean"
    grep -q '^run:' make-results/Makefile && ok "Makefile: есть цель run" \
        || bad "Makefile: нет цели run"
    grep -q '^test:' make-results/Makefile && ok "Makefile: есть цель test" \
        || bad "Makefile: нет цели test"
    grep -q 'mkdir -p build' make-results/Makefile && ok "Makefile: сборка создаёт каталог build сама" \
        || bad "Makefile: не найдена команда 'mkdir -p build'"
    grep -q 'diff - expected.txt' make-results/Makefile && ok "Makefile: test сравнивает вывод с expected.txt" \
        || bad "Makefile: в цели test нет сравнения 'diff - expected.txt'"
fi

echo
echo "[4] Выводы целей"
if [ -s make-results/run.txt ]; then
    grep -q 'add: 5' make-results/run.txt && grep -q 'mul: 20' make-results/run.txt \
        && ok "run.txt: цель run печатает add: 5 и mul: 20" \
        || bad "run.txt: в выводе нет строк 'add: 5' и 'mul: 20'"
fi
if [ -s make-results/test-ok.txt ]; then
    grep -q 'exit=0' make-results/test-ok.txt && ok "test-ok.txt: make test прошёл (exit=0)" \
        || bad "test-ok.txt: ожидался 'exit=0' — make test не прошёл"
fi
if [ -s make-results/test-fail.txt ]; then
    grep -qE 'exit=[1-9]' make-results/test-fail.txt \
        && ok "test-fail.txt: make test упал на намеренной ошибке" \
        || bad "test-fail.txt: make test не сообщил об ошибке (ожидался ненулевой exit)"
fi

echo
echo "[5] Файлы времён"
for f in timestamps-1.txt timestamps-edit.txt; do
    if [ -s "make-results/$f" ]; then
        n=$(grep -c 'build/' "make-results/$f")
        [ "$n" -ge 3 ] && ok "$f: записаны времена трёх объектных файлов" \
            || bad "$f: найдено только $n строк про build/, ожидалось 3"
    fi
done
if [ -s make-results/timestamps-1.txt ] && [ -s make-results/timestamps-edit.txt ]; then
    for obj in mathx.o report.o; do
        t1=$(grep "build/$obj" make-results/timestamps-1.txt)
        t2=$(grep "build/$obj" make-results/timestamps-edit.txt)
        if [ -n "$t1" ] && [ "$t1" = "$t2" ]; then
            ok "$obj не пересобирался после правки main.c"
        else
            bad "$obj: времена в файлах различаются — после правки main.c пересобралось лишнее"
        fi
    done
    m1=$(grep 'build/main.o' make-results/timestamps-1.txt)
    m2=$(grep 'build/main.o' make-results/timestamps-edit.txt)
    if [ -n "$m1" ] && [ "$m1" != "$m2" ]; then
        ok "main.o пересобрался после правки main.c"
    else
        bad "main.o: время не изменилось — правка main.c не пересобрала объектный файл"
    fi
fi

if [ -s make-results/answers.txt ]; then
    n=$(grep -cve '^[[:space:]]*$' make-results/answers.txt)
    [ "$n" -ge 6 ] && ok "answers.txt: записано $n непустых строк" \
        || bad "answers.txt: записано всего $n непустых строк, ответов должно быть больше"
fi

echo
if [ "$fail" -eq 0 ]; then
    tar -czf s3-makefile.tar.gz make-results/
    echo "Все проверки пройдены ($pass из $pass)."
    echo
    echo "Архив готов: $(pwd)/s3-makefile.tar.gz"
    echo "Отправьте этот файл своему семинаристу удобным способом (канал связи уточните на занятии)."
    echo "В теме письма укажите: s3-makefile — ФИО"
    exit 0
else
    echo "Проверок не пройдено: $fail. Исправьте замечания и запустите ./check.sh ещё раз."
    exit 1
fi

