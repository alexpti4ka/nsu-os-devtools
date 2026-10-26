#!/usr/bin/env bash
# Проверка семинара 6 «Файловые системы Linux».
# Запускать из каталога семинара:  ./check.sh
# Скрипт проверяет результаты в s6-results/ и, если всё в порядке,
# собирает именной архив s6-results-<Фамилия>-<хеш>.tar.gz для отправки преподавателю.

set -u
cd "$(dirname \"$0\")" || exit 1

RESULTS_DIR="s6-results"
ARCHIVE_PREFIX="s6-results"

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
echo "Семинар 6 «Файловые системы Linux»: проверка артефакта"
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
ARCHIVE="${ARCHIVE_PREFIX}-${STUDENT_SURNAME}-${HASH}.tar.gz"

# Персонализированный номер задачи, о которой нужно написать развёрнутый ответ.
# Берём байт из хэша и отображаем на диапазон задач 1..11.
HASH_BYTE=$(printf '%s' "$HASH" | cut -c1-2)
TASK_NUM=$(( 16#$HASH_BYTE % 11 + 1 ))

echo "Студент: $STUDENT_SURNAME $STUDENT_NAME  (хеш $HASH)"
echo "Персонализированный вопрос: задача №$TASK_NUM"
echo

# ---------- [1] Состав каталога s6-results/ ----------
echo "[1] Состав каталога $RESULTS_DIR/"
for f in task1-links.txt task2-mounts.txt task3-devices.txt \
         task4-loop.txt task5-tmpfs.txt task6-procfs.txt \
         task7-bind.txt task8-overlay.txt task9-docker.txt \
         task10-layer.txt task11-volume.txt answers.txt session.txt; do
    check_file "$RESULTS_DIR/$f" "$RESULTS_DIR/$f"
done

echo

# ---------- [2] Содержание ключевых файлов ----------
echo "[2] Содержание ключевых файлов"

if [ -s "$RESULTS_DIR/task1-links.txt" ]; then
    if grep -q 'hard.txt' "$RESULTS_DIR/task1-links.txt" \
       && grep -q 'symbolic.txt' "$RESULTS_DIR/task1-links.txt"; then
        ok "task1-links.txt: есть жёсткая и символьная ссылки"
    else
        bad "task1-links.txt: не найдены обе ссылки (hard.txt, symbolic.txt)"
    fi
fi

if [ -s "$RESULTS_DIR/task2-mounts.txt" ]; then
    if grep -qiE 'findmnt|mount|df|namei' "$RESULTS_DIR/task2-mounts.txt"; then
        ok "task2-mounts.txt: есть выводы команд монтирования"
    else
        bad "task2-mounts.txt: не найдены ожидаемые команды"
    fi
fi

if [ -s "$RESULTS_DIR/task4-loop.txt" ]; then
    if grep -qiE 'loop|losetup|lsblk|mkfs|ext4' "$RESULTS_DIR/task4-loop.txt"; then
        ok "task4-loop.txt: есть следы работы с loop device и ext4"
    else
        bad "task4-loop.txt: не найдены ожидаемые ключевые слова"
    fi
fi

if [ -s "$RESULTS_DIR/task11-volume.txt" ]; then
    if grep -qiE 'docker volume|named volume' "$RESULTS_DIR/task11-volume.txt"; then
        ok "task11-volume.txt: есть работа с named volume"
    else
        bad "task11-volume.txt: не найдены ожидаемые ключевые слова"
    fi
fi

# ---------- [3] Персонализированные ответы ----------
echo
echo "[3] Персонализированные ответы (защита от списывания)"

if [ -s "$RESULTS_DIR/answers.txt" ]; then
    n=$(grep -cve '^[[:space:]]*$' "$RESULTS_DIR/answers.txt")
    [ "$n" -ge 8 ] && ok "answers.txt: записано $n непустых строк" \
        || bad "answers.txt: всего $n непустых строк, нужно не меньше 8"

    # Персональный вопрос: студент должен описать свою задачу №$TASK_NUM
    if grep -qi "задача №$TASK_NUM\|задача $TASK_NUM\|task.*$TASK_NUM\|$TASK_NUM" "$RESULTS_DIR/answers.txt"; then
        ok "answers.txt: есть упоминание персонализированной задачи №$TASK_NUM"
    else
        bad "answers.txt: не найден развёрнутый ответ по персонализированной задаче №$TASK_NUM"
    fi
else
    bad "answers.txt: файл отсутствует или пуст"
fi

# ---------- Итог ----------
echo
if [ "$fail" -eq 0 ]; then
    tar -czf "$ARCHIVE" "$RESULTS_DIR/"
    echo "Все проверки пройдены ($pass из $pass)."
    echo
    echo "Архив готов: $(pwd)/$ARCHIVE"
    echo "Отправьте этот файл своему семинаристу удобным способом (канал связи уточните на занятии)."
    echo "В теме письма укажите: Семинар 6 Файловые системы — $STUDENT_SURNAME $STUDENT_NAME"
    exit 0
else
    echo "Проверок не пройдено: $fail. Исправьте замечания и запустите ./check.sh ещё раз."
    exit 1
fi