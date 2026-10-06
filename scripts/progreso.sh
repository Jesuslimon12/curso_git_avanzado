#!/usr/bin/env bash
# Cuenta las casillas marcadas (- [x]) de cada módulo en modulos/*.md
# y reescribe la tabla de avance dentro de PROGRESO.md.
#
# Uso: bash scripts/progreso.sh
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROGRESO="$RAIZ/PROGRESO.md"
TABLA="$(mktemp)"
trap 'rm -f "$TABLA"' EXIT

# barra <porcentaje> -> ██████░░░░
barra() {
  local llenos=$(( $1 / 10 )) i s=""
  for (( i = 0; i < 10; i++ )); do
    if (( i < llenos )); then s+="█"; else s+="░"; fi
  done
  printf '%s' "$s"
}

total_hechos=0
total=0
{
  echo "| Módulo | Ejercicios | Avance | Estado |"
  echo "|---|:---:|---|:---:|"
  for f in "$RAIZ"/modulos/*.md; do
    titulo=$(grep -m1 '^# ' "$f" | sed 's/^# //')
    hechos=$(grep -ciE '^[[:space:]]*- \[x\]' "$f" || true)
    pendientes=$(grep -cE '^[[:space:]]*- \[ \]' "$f" || true)
    n=$(( hechos + pendientes ))
    p=$(( n > 0 ? hechos * 100 / n : 0 ))
    if   (( hechos == 0 )); then estado="⬜ Pendiente"
    elif (( hechos == n )); then estado="✅ Completado"
    else                         estado="🟡 En curso"
    fi
    echo "| [$titulo](modulos/$(basename "$f")) | $hechos/$n | \`$(barra "$p")\` $p% | $estado |"
    total_hechos=$(( total_hechos + hechos ))
    total=$(( total + n ))
  done
  pt=$(( total > 0 ? total_hechos * 100 / total : 0 ))
  echo
  echo "**Avance total:** \`$(barra "$pt")\` **$pt%** ($total_hechos de $total ejercicios)"
  echo
  echo "_Última actualización: $(date '+%Y-%m-%d %H:%M')_"
} > "$TABLA"

# Sustituye lo que haya entre los marcadores de PROGRESO.md
awk -v tabla="$TABLA" '
  /<!-- PROGRESO:INICIO -->/ { print; while ((getline l < tabla) > 0) print l; saltar = 1; next }
  /<!-- PROGRESO:FIN -->/    { saltar = 0 }
  !saltar                    { print }
' "$PROGRESO" > "$PROGRESO.tmp"
mv "$PROGRESO.tmp" "$PROGRESO"

cat "$TABLA"
