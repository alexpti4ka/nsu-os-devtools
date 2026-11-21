#!/usr/bin/env bash
set -euo pipefail

mission_file=${1:?Usage: render_site.sh data/mission.env site/index.html}
output=${2:?Usage: render_site.sh data/mission.env site/index.html}

value() {
    sed -n "s/^$1=//p" "$mission_file" | head -n 1
}

escape_html() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

mission=$(value MISSION_NAME | escape_html)
callsign=$(value CALLSIGN | escape_html)
pr_number=$(value PR_NUMBER)
oxygen=$(value OXYGEN)
temperature=$(value REACTOR_TEMP)
commit=${GITHUB_SHA:-local}
run=${GITHUB_RUN_NUMBER:-local}
repository=${GITHUB_REPOSITORY:-}
run_id=${GITHUB_RUN_ID:-}
links=

if [[ -n "$repository" && "$run_id" =~ ^[1-9][0-9]*$ ]]; then
    repo_url="https://github.com/$repository"
    links="<p><a href=\"$repo_url/actions/runs/$run_id\">Запуск сборки и артефакт</a>"
    if [[ "$pr_number" =~ ^[1-9][0-9]*$ ]]; then
        links+=" · <a href=\"$repo_url/pull/$pr_number\">Pull request с инцидентом</a>"
    fi
    links+="</p>"
fi

mkdir -p "$(dirname "$output")"
cat > "$output" <<EOF
<!doctype html>
<html lang="ru"><head><meta charset="utf-8"><title>Mission Control</title>
<style>body{background:#07111f;color:#d8f3ff;font:18px system-ui;margin:3rem}main{max-width:46rem;border:1px solid #39e58c;padding:2rem;border-radius:1rem}strong{color:#39e58c}a{color:#8fe3ff}.tag{background:#122944;padding:.3rem .6rem;border-radius:1rem}code{overflow-wrap:anywhere}</style>
</head><body><main>
<p class="tag">MISSION CONTROL · VERIFIED RELEASE</p>
<h1>$mission</h1><p>Позывной Evil Corp: <strong>$callsign</strong></p>
<p>Кислород: <strong>$oxygen%</strong></p><p>Реактор: <strong>$temperature °C</strong></p>
<h2>СТАРТ РАЗРЕШЁН 🚀</h2><p>Коммит <code>$commit</code> · запуск $run</p>
$links
</main></body></html>
EOF
