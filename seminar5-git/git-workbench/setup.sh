#!/usr/bin/env bash
# setup.sh — разворачивает учебные репозитории для семинара по Git.
#
# Использование:  bash setup.sh
# Создаёт в текущем каталоге (или в каталоге, указанном первым аргументом):
#   01-basics/      — «грязный» каталог для настройки и базового цикла
#   02-branching/   — репозиторий с веткой feature и заминированным конфликтом
#   03-history/     — репозиторий с богатой историей, багом и несколькими авторами
#   remote.git/     — bare-репозиторий, играет роль «удалённого сервера»
#
# История коммитов задаётся фиксированными датами/авторами, поэтому
# результаты blame/bisect/log у всех студентов совпадают.
#
# Скрипт идемпотентен: при повторном запуске пересоздаёт все каталоги.

set -euo pipefail

ROOT="${1:-.}"
BASE_DATE="2025-01-06T10:00:00+00:00"

# Утилита: сделать коммит в репозитории dir с заданным автором и датой.
# Аргументы: dir author email date message
commit_as() {
    local dir="$1" name="$2" email="$3" date="$4" msg="$5"
    (
        cd "$dir"
        git add -A
        GIT_AUTHOR_NAME="$name" GIT_AUTHOR_EMAIL="$email" \
        GIT_COMMITTER_NAME="$name" GIT_COMMITTER_EMAIL="$email" \
        GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" \
        git -c user.name="$name" -c user.email="$email" \
            commit -q -m "$msg"
    )
}

mkdir -p "$ROOT"
# Приводим к абсолютному пути: ниже есть `cd "$ROOT"` из подкаталогов,
# а относительный путь после первого спуска уже указывает не туда.
ROOT="$(cd "$ROOT" && pwd)"
echo "== Развёртывание git-workbench в: $ROOT"
cd "$ROOT"
rm -rf 01-basics 02-branching 03-history remote.git

# ---------------------------------------------------------------------------
# 01-basics: обычный (ещё не git) каталог с парой файлов. Студент сам
# выполнит git init и пройдёт базовый цикл.
# ---------------------------------------------------------------------------
mkdir -p 01-basics
cat > 01-basics/hello.txt <<'EOF'
Привет, Git!
Это файл для первого коммита.
EOF
cat > 01-basics/notes.md <<'EOF'
# Зааметки

- выучить git status
- выучить git add
- выучить git commit
EOF

# ---------------------------------------------------------------------------
# 02-branching: репозиторий с ветками main и feature.
# Ветка feature не слита; слияние порождает конфликт в message.txt.
# ---------------------------------------------------------------------------
mkdir -p 02-branching
cd 02-branching
git init -q -b main
cat > message.txt <<'EOF'
Строка 1
Строка 2: общее
Строка 3
EOF
commit_as . "Студент" "student@nsu.ru" "2025-01-06T10:00:00+00:00" "добавить message.txt"

# Ветка feature меняет «Строку 2».
git branch feature
git switch -q feature
sed -i 's/Строка 2: общее/Строка 2: изменение в feature/' message.txt
commit_as . "Студент" "student@nsu.ru" "2025-01-08T10:00:00+00:00" "feature: изменить вторую строку"

# Возврат на main и другое изменение той же строки -> будущий конфликт.
git switch -q main
sed -i 's/Строка 2: общее/Строка 2: изменение в main/' message.txt
commit_as . "Студент" "student@nsu.ru" "2025-01-09T10:00:00+00:00" "main: изменить вторую строку"
git switch -q main
cd "$ROOT"

# ---------------------------------------------------------------------------
# 03-history: репозиторий с ~10 коммитами, несколькими авторами (для blame)
# и одним багом (для bisect). test.sh проходит до бага и падает после.
# ---------------------------------------------------------------------------
mkdir -p 03-history
cd 03-history
git init -q -b main

cat > compute.sh <<'EOF'
#!/usr/bin/env bash
# Вычисляет «ключевой» результат приложения.
echo $(( 6 * 7 ))
EOF
cat > test.sh <<'EOF'
#!/usr/bin/env bash
# Проверка: результат compute.sh должен быть 42.
if [ "$(bash compute.sh)" = "42" ]; then
    echo "OK"
    exit 0
else
    echo "FAIL"
    exit 1
fi
EOF
chmod +x compute.sh test.sh
d="2025-01-06T10:00:00+00:00"
git add .
commit_as . "Алиса" "alice@nsu.ru" "$d" "инициализация: compute.sh и test.sh"

# notes.txt редактируют разные «авторы» — для git blame.
cat > notes.txt <<'EOF'
строка от Алисы
EOF
commit_as . "Алиса" "alice@nsu.ru" "2025-01-07T10:00:00+00:00" "notes: первая строка"

cat >> notes.txt <<'EOF'
строка от Боба
EOF
commit_as . "Боб" "bob@nsu.ru" "2025-01-08T10:00:00+00:00" "notes: добавить строку Боба"

cat >> notes.txt <<'EOF'
строка от Каролины
EOF
commit_as . "Каролина" "carol@nsu.ru" "2025-01-09T10:00:00+00:00" "notes: добавить строку Каролины"

# Реальные изменения в compute.sh (чтобы каждый коммит не был пустым).
cat > compute.sh <<'EOF'
#!/usr/bin/env bash
# Ключевой результат приложения
echo $(( 6 * 7 ))
EOF
commit_as . "Алиса" "alice@nsu.ru" "2025-01-10T10:00:00+00:00" "compute: уточнить формулу"

# БАГ: 6 * 7 заменяют на 6 + 7 -> test.sh начинает падать.
sed -i 's/6 \* 7/6 + 7/' compute.sh
commit_as . "Боб" "bob@nsu.ru" "2025-01-11T10:00:00+00:00" "compute: упростить выражение"

cat >> notes.txt <<'EOF'
строка после бага
EOF
commit_as . "Каролина" "carol@nsu.ru" "2025-01-12T10:00:00+00:00" "notes: последняя строка"

cd "$ROOT"

# ---------------------------------------------------------------------------
# remote.git: bare-репозиторий. Служит «удалённым сервером» для
# push/pull/clone/fetch без реального GitHub.
# ---------------------------------------------------------------------------
git init -q --bare -b main remote.git

echo ""
echo "Готово. Создано:"
echo "  01-basics/   — для git init, status, add, commit (три области)"
echo "  02-branching/— ветки main/feature; merge даст конфликт"
echo "  03-history/  — 7 коммитов, 3 автора, баг для bisect"
echo "  remote.git/  — bare-«сервер» для remote/push/clone/pull/fetch"
