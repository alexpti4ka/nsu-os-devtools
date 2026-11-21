# Mission Control

Учебный проект для семинара по GitHub Actions. Панель показывает
телеметрию миссии и ваш позывной из Evil Corp. Следуйте заданию семинара,
чтобы дописать два шага в `.github/workflows/ci.yml` и опубликовать панель.

```bash
make test check-data site report
```

При инциденте исправляйте данные миссии. В `tools/verify_mission.sh`
описаны условия допуска к запуску.

Структура:

```text
data/mission.env       личная миссия и телеметрия
src/, tests/           маленькое C-приложение и unit-тесты
tools/                 проверка данных и генератор сайта
artifacts/             отчёт и бинарник для GitHub Actions
site/                  содержимое GitHub Pages
.github/workflows/     CI и deploy
```
