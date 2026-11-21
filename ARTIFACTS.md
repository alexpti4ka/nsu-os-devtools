# Артефакты сдачи работ

Сводная таблица результатов, которые студенты отправляют семинаристу.

## Таблица артефактов

| Алиас | Семинар / работа | Файл задания | Формат сдачи | Что входит в результат |
|-------|------------------|--------------|------------|-------------------|
| `s2-coffee` | Семинар 2 — ДЗ «Конвейеры: дело кофейни „Байт“» | `seminar2-text-editors/home_tasks/Конвейеры/Задание.md` | `s2-coffee.tar.gz` | `results/`: lines.txt, orders-21-25.txt, wifi-reviews.txt, top-drinks.txt, staff-new.txt, shopping.txt, hours.txt, report.txt, answers.txt, session.txt |
| `s2-process` | Семинар 2 — Практика os-lab (процессы, systemd, порты, журналы) | `seminar2-text-editors/sem_2_prt_2/Задание.md` | `s2-process.tar.gz` | `os-lab-results/`: session.txt, config-backup.ini (+ star.txt при выполнении задания со звёздочкой) |
| `s3-makefile` | Семинар 3 — ДЗ «Система сборки: Makefile для проекта calc» | `seminar3-build-systems/home_tasks/Сборка-make/Задание.md` | `s3-makefile.tar.gz` | `make-results/`: Makefile, run.txt, test-ok.txt, test-fail.txt, timestamps-1.txt, timestamps-edit.txt, answers.txt, session.txt |
| `s3-compile` | Семинар 3 — ДЗ «Компиляция: от исходника до линковки» | `seminar3-build-systems/home_tasks/Компиляция-gcc/Задание.md` | `s3-compile.tar.gz` | `gcc-results/`: warn-*.txt, pipeline.i/s/o, pipeline-run.txt, main.i, main2-*.i, obj/*.o, calc, calc-run.txt, timestamps.txt, link-error-*.txt, answers.txt, session.txt |
| `s6-filesys` | Семинар 6 — «Файловые системы Linux» | `seminar6-filesystems/Семинар 6. Файловые системы Linux.md` | `s6-filesys-<Фамилия>-<хеш>.tar.gz` | `s6-results/`: task1-links.txt … task11-volume.txt, answers.txt, session.txt |
| `s7-cicd` | Семинар 7 — «Старт разрешён» | [Сдача семинара 7](seminar7-ci-cd/home_tasks/CI-CD-с-GitHub-Actions/Задание.md) | Одна ссылка на панель GitHub Pages | Позывной Evil Corp, ссылка на запуск с артефактом `mission-report` и ссылка на PR с красным и зелёным запусками |
| `lab1-launcher` | Лабораторная работа 1 — «Сборка и запуск многоконтейнерного приложения на C» | `lab1-multiservice/c-lab-multiservice/README.md` | `lab1-launcher-<Фамилия>-<хеш>.tar.gz` | `lab1-results/`: build/ (libcommon.a, backend, balancer, loadgen), results/ (result.csv), Dockerfile*, compose.yaml, check-output.txt, answers.txt |

## Как собирается архив

Для заданий, которые сдаются архивом:
1. Выполняет задание и сохраняет результаты в указанный каталог (`results/`, `os-lab-results/`, `make-results/`, `gcc-results/`, `s6-results/`, `lab1-results/`).
2. Запускает скрипт `./check.sh` из каталога задания.
3. Скрипт проверяет состав файлов и, если всё в порядке, собирает архив с именем из таблицы выше.
4. Студент отправляет архив семинаристу, указав в теме письма алиас и ФИО (например: `s2-coffee — ФИО`).

## Как идентифицировать присланную работу

По имени архива можно сразу понять, к какому заданию относится работа:

- `s2-coffee.tar.gz` → Семинар 2, «Конвейеры»
- `s2-process.tar.gz` → Семинар 2, os-lab
- `s3-makefile.tar.gz` → Семинар 3, Makefile
- `s3-compile.tar.gz` → Семинар 3, Компиляция
- `s6-filesys-<Фамилия>-<хеш>.tar.gz` → Семинар 6, Файловые системы
- `lab1-launcher-<Фамилия>-<хеш>.tar.gz` → Лабораторная работа 1, Мультисервисное приложение

Для `s7-cicd` отправьте ссылку с пометкой «Семинар 7». На панели
должен быть ваш позывной из Evil Corp.
