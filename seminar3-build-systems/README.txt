Seminar 3 workbench
===================

This directory contains a fully written C project for the compilation and build-systems workshop.
Students are not expected to implement C algorithms during this seminar.

Main project: textstat
  src/      implementations
  include/  public headers
  tests/    small test executables
  bench/    optimization experiments
  variants/ interchangeable policy implementations
  stages/   small source used to inspect compilation stages
  data/     input text files


Памятка
==================
редактор (vim, nano, code) → редактирует текст
компилятор (gcc, clang) → преобразует программу превращает файл .c в объектный код .o (на языке процессора)
linker (ld внутри gcc) → собирает итоговый executable (несколько .o в один)
Make (менеджер сборки) → управляет графом действий и зависимостей (можно и без него, но сложнее)

На новой системе приложения могут не стоять по умолчанию.
Ставим так:
sudo apt install gcc make clang

---
Полезные команды семинара
===================
gcc -I include src/*.c -o textstat          собрать всё одним вызовом
gcc -c src/tokenizer.c -o tokenizer.o      только компиляция, без линковки
gcc -E stages/stages.c -I stages/include -o /tmp/stages.i    препроцессор
gcc -S stages/stages.c -I stages/include -o /tmp/stages.s    ассемблер
gcc -c stages/stages.c -o /tmp/stages.o                    объектный код
ld -o prog main.o tokenizer.o               линковка
objdump -d /tmp/stages.o | head             дизассемблер
nm /tmp/stages.o                            символы (T/t/U)
file textstat libtextstat.so                 что это за файл
ldd ./textstat                              какие .so нужны
ar rcs libtextstat.a *.o                    статическая библиотека
gcc -shared -fPIC -o libtextstat.so *.o     динамическая библиотека
gcc -static main.o libtextstat.a -o prog    статическая линковка
gcc -MMD -MP -MF build/tokenizer.d ...     зависимости от заголовков
LD_LIBRARY_PATH=lib/debug ./textstat-shared data/small.txt   найти .so без установки

make / make all / make test / make clean   цели Makefile
make -j3                                    параллельная сборка
make -n                                     показать команды, не выполняя
make CC=clang CFLAGS="-O0 -g3" debug       переопределить переменные
make debug CONFIG=release                   конфигурация одной переменной
touch src/tokenizer.c                       изменить время файла → пересборка
stat -c '%y %n' src/*.c                     сравнить время .c и .o

---
Возможные проблемы
===================
gcc: command not found          не установлен компилятор → apt install gcc
fatal error: textstat.h: No such file или directory
                             забыт -I include
undefined reference to '...'   не хватает .o или .a при линковке
multiple definition of '...'   символ объявлен в двух .c — нужен static либо
                             условная компиляция #ifndef TEXTSTAT_H
error while loading shared libraries: libtextstat.so
                             loader не нашёл .so → LD_LIBRARY_PATH=lib/... или
                             ldconfig / установка в /usr/local/lib
cannot find -ltextstat          библиотека не в путях поиска → -L./lib
/usr/bin/ld: cannot find -lm   не хватает libm-dev
incompatible with ... , recompile
                             .o собран другим компилятором → make clean
Permission denied ./textstat   забыт +x или каталог не исполняемый
No such file or directory (gcc)
                             путь с пробелами/кириллицей, кавычки в -I
Makefile: *** ... No rule to make target 'x.c'
                             опечатка в имени цели/файла или не тот каталог
make: *** No rule to make target 'Makefile'
                             вы не в корне проекта — cd seminar3-build-systems
'cc1: fatal error: ... terminated'   кончилась память или не хватает swap
apt: command not found          это не Debian/Ubuntu (нужен dnf / pacman)