`seminar2-generator` — учебная программа для второго семинара.

Она умеет:
- создавать файлы в указанной директории;
- писать события в `stdout`;
- писать служебные сообщения и ошибки в `stderr`;
- работать ограниченное время или непрерывно.

Внутреннее устройство генератора изучать не нужно.

---

## Быстрый старт

Показать справку:

```bash
seminar2-generator --help
```

Сгенерировать 20 событий:

```bash
seminar2-generator
```

По умолчанию файлы создаются в:

```text
./incoming
```

---

## Формат событий

В `stdout` генератор пишет строки вида:

```text
timestamp|level|source|file|status
```

Например:

```text
2026-09-01T18:42:10+00:00|INFO|sensor-b|event-00001.txt|accepted
2026-09-01T18:42:11+00:00|ERROR|sensor-a|event-00010.txt|failed
```

Диагностические сообщения идут отдельно в `stderr`.

---

## Основные параметры

|Параметр|Что делает|
|---|---|
|`--output-dir DIR`|Куда создавать файлы|
|`--count N`|Сколько событий создать|
|`--delay SEC`|Пауза между событиями|
|`--continuous`|Работать до `Ctrl+C`|
|`--no-files`|Не создавать отдельные файлы|
|`--help`|Показать справку|

---

## Сценарий 1. Создать несколько файлов

Находясь в `~/seminar2/control-center`:

```bash
seminar2-generator \
    --output-dir incoming \
    --count 20
```

В `incoming` появятся файлы:

```text
event-00001.txt
event-00002.txt
...
```

---

## Сценарий 2. Разделить `stdout` и `stderr`

```bash
seminar2-generator \
    --output-dir incoming \
    --count 100 \
    1> logs/events.log \
    2> logs/generator.err
```

После этого:

```text
logs/events.log
```

содержит события, а:

```text
logs/generator.err
```

содержит диагностику.

Напоминание:

```text
stdout = 1
stderr = 2
```

---

## Сценарий 3. Создать большой журнал

Для задач с `head`, `tail`, `less`, `grep`:

```bash
seminar2-generator \
    --count 5000 \
    --no-files \
    1> logs/events.log \
    2> logs/generator.err
```

`--no-files` нужен, чтобы генератор не создавал 5000 отдельных файлов.

---

## Сценарий 4. Запустить генератор постоянно

Для работы с `tmux`:

```bash
seminar2-generator \
    --continuous \
    --delay 1 \
    --output-dir incoming \
    1>> logs/events.log \
    2>> logs/generator.err
```

Остановить:

```text
Ctrl+C
```

Здесь используется `>>`, поэтому новые данные добавляются в существующие журналы.

---

## Если что-то пошло не так

Посмотрите текущую директорию:

```bash
pwd
```

Проверьте, существуют ли нужные каталоги:

```bash
ls
```

И снова посмотрите параметры генератора:

```bash
seminar2-generator --help
```