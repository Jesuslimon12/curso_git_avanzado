#!/usr/bin/env bash
# Genera los escenarios de práctica de cada módulo dentro de laboratorio/.
#
# Uso:
#   bash scripts/lab.sh            -> lista los laboratorios disponibles
#   bash scripts/lab.sh 03         -> (re)crea laboratorio/m03-ramas
#   bash scripts/lab.sh todos      -> (re)crea todos
#
# Cada laboratorio es desechable: volver a ejecutarlo lo borra y lo crea de cero.
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="$RAIZ/laboratorio"

# Identidad y fechas fijas para que el historial sea igual en cada ejecución
export GIT_AUTHOR_NAME="Alumno" GIT_AUTHOR_EMAIL="alumno@curso.local"
export GIT_COMMITTER_NAME="Alumno" GIT_COMMITTER_EMAIL="alumno@curso.local"
FECHA_BASE=1735725600 # 2025-01-01 10:00 UTC
TICK=0

# ---------------------------------------------------------------- helpers ---

configurar_repo() {
  git config user.name "${1:-Alumno}"
  git config user.email "$(echo "${1:-alumno}" | tr 'A-Z' 'a-z')@curso.local"
  git config commit.gpgsign false
  git config tag.gpgsign false
  git config core.autocrlf false
}

# nuevo_repo <ruta relativa a laboratorio/>: borra, crea y entra al repo
nuevo_repo() {
  local dir="$LAB/$1"
  rm -rf "$dir"
  mkdir -p "$dir"
  cd "$dir"
  git init -q -b main
  configurar_repo
}

siguiente_fecha() {
  TICK=$((TICK + 1))
  echo "@$((FECHA_BASE + TICK * 5400)) +0000"
}

# c "mensaje": agrega todo y hace commit con una fecha que avanza
c() {
  local fecha
  fecha="$(siguiente_fecha)"
  git add -A
  GIT_AUTHOR_DATE="$fecha" GIT_COMMITTER_DATE="$fecha" git commit -q -m "$1"
}

# como "Autor" "mensaje": igual que c() pero con otro autor
como() {
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$(echo "$1" | tr 'A-Z' 'a-z')@equipo.dev" c "$2"
}

# fusiona <rama> "mensaje": merge --no-ff con fecha controlada
fusiona() {
  local fecha
  fecha="$(siguiente_fecha)"
  GIT_AUTHOR_DATE="$fecha" GIT_COMMITTER_DATE="$fecha" git merge -q --no-ff "$1" -m "$2"
}

# ------------------------------------------------------------ laboratorios ---

lab_00() {
  nuevo_repo m00-config
  echo "# Laboratorio de configuración" > README.md;       c "docs: agrega README"
  echo "console.log('hola');" > app.js;                     c "feat: agrega app"
  echo "node_modules/" > .gitignore;                        c "chore: agrega .gitignore"
  echo "console.log('adiós');" >> app.js;                   c "feat: despedida"
}

lab_01() {
  nuevo_repo m01-historial
  mkdir -p src
  echo "# Tienda online" > README.md
  como Ana "docs: README inicial"

  cat > utils.js <<'EOF'
export function formatearPrecio(n) {
  return `$${n.toFixed(2)}`;
}
EOF
  como Ana "feat: utilidades de formato"

  cat > src/carrito.js <<'EOF'
import { formatearPrecio } from '../utils.js';

export const carrito = [];

export function agregar(producto) {
  carrito.push(producto);
}
EOF
  como Luis "feat: carrito básico"

  cat >> src/carrito.js <<'EOF'

export function calcularDescuento(total) {
  return total > 100 ? total * 0.1 : 0;
}
EOF
  como Marta "feat: descuento por compra mayor a 100"

  cat >> src/carrito.js <<'EOF'

export function total() {
  return carrito.reduce((s, p) => s + p.precio, 0);
}
EOF
  como Luis "feat: total del carrito"

  git mv utils.js src/helpers.js
  sed -i "s#'../utils.js'#'./helpers.js'#" src/carrito.js
  como Ana "refactor: mueve utils a src/helpers.js"

  git switch -q -c feature/busqueda
  cat > src/busqueda.js <<'EOF'
export function buscar(productos, texto) {
  return productos.filter(p => p.nombre.includes(texto));
}
EOF
  como Marta "feat: búsqueda de productos"
  echo "// casos: 'cami' -> camisa, camiseta" >> src/busqueda.js
  como Marta "test: casos de búsqueda"

  git switch -q main
  echo "- Carrito de compras" >> README.md
  como Ana "docs: documenta carrito"
  fusiona feature/busqueda "Merge branch 'feature/busqueda'"
  git tag -a v1.0.0 -m "Primera versión"

  cat > src/carrito.js <<'EOF'
import { formatearPrecio } from './helpers.js';

export const carrito = [];

export function agregar(producto) {
  carrito.push(producto);
}

export function total() {
  return carrito.reduce((s, p) => s + p.precio, 0);
}
EOF
  como Luis "refactor: limpia código sin uso"

  cat >> src/helpers.js <<'EOF'

export function formatearFecha(d) {
  return d.toISOString().slice(0, 10);
}
EOF
  como Marta "feat: formatear fechas"

  sed -i 's#return `$${n.toFixed(2)}`;#return new Intl.NumberFormat("es-MX", { style: "currency", currency: "MXN" }).format(n);#' src/helpers.js
  como Ana "fix: precio con separador de miles"

  printf '# Changelog\n\n## 1.1.0\n- Formato de fechas\n- Precios con separador de miles\n' > CHANGELOG.md
  como Luis "docs: changelog v1.1"
}

lab_02() {
  nuevo_repo m02-reescritura
  echo "# App de autenticación" > README.md;                c "docs: README"
  echo "<html><body></body></html>" > index.html;           c "feat: página base"

  git switch -q -c feature/login
  cat > login.html <<'EOF'
<form>
  <label>Usuaro</label>
  <input name="usuario">
  <label>Contraseña</label>
  <input name="password" type="password">
</form>
EOF
  c "agrega formulario de login"
  echo "<!-- TODO: botón de enviar -->" >> login.html;      c "wip"
  sed -i 's/Usuaro/Usuario/' login.html;                    c "arreglo typo"
  cat > validacion.js <<'EOF'
export function passwordValido(p) {
  return p.length >= 8;
}
EOF
  c "agrega validacion de password"
  echo "DB_PASSWORD=super-secreta-123" > credenciales.env;  c "agrega credenciales.env"
  cat >> validacion.js <<'EOF'

export function usuarioValido(u) {
  return /^[a-z0-9_]{3,}$/.test(u);
}
EOF
  c "wip 2 ahora si"
  echo "form { display: grid; gap: 8px; }" > login.css;     c "agrega estilos dle login"

  git switch -q main
  echo "0.2.0" > VERSION;                                   c "chore: versión 0.2.0"
  echo "DEBUG=true" > config.txt;                           c "feat: activa modo debug en producción"
  git switch -q feature/login
}

lab_03() {
  nuevo_repo m03-ramas
  printf 'app=tienda\ncolor=blanco\n' > config.txt
  echo "idioma=es" > i18n.txt
  c "chore: configuración inicial"
  echo "Bienvenido" > index.txt;                            c "feat: página de inicio"

  # Ramas que chocarán con main
  git switch -q -c feature/colores
  sed -i 's/color=blanco/color=azul/' config.txt;           c "feat: tema azul"
  git switch -q main
  git switch -q -c feature/idioma
  echo "idioma=en" > i18n.txt;                              c "feat: interfaz en inglés"
  git switch -q main

  # Hotfix del que solo queremos UN commit
  git switch -q -c hotfix/varios
  echo "debug=true" > debug.log;                            c "chore: logs de depuración"
  echo "escapar_html=true" > seguridad.txt;                 c "fix: sanitiza entrada de usuario"
  echo "experimento" > experimental.txt;                    c "chore: prueba experimental"
  git switch -q main

  # Cadena de ramas para rebase --onto
  git switch -q -c feature/base
  echo "base 1" > base.txt;                                 c "feat(base): paso 1"
  echo "base 2" >> base.txt;                                c "feat(base): paso 2"
  git switch -q -c feature/extension
  echo "ext 1" > extension.txt;                             c "feat(ext): paso 1"
  echo "ext 2" >> extension.txt;                            c "feat(ext): paso 2"
  git switch -q main

  # Rama con commits pequeños para merge --squash
  git switch -q -c feature/estilos
  echo "body { margin: 0; }" > estilos.css;                 c "estilos: reset"
  echo "h1 { font-size: 2rem; }" >> estilos.css;            c "estilos: títulos"
  echo "a { color: teal; }" >> estilos.css;                 c "estilos: enlaces"
  git switch -q main

  # main avanza y provoca los conflictos
  sed -i 's/color=blanco/color=rojo/' config.txt;           c "feat: tema rojo corporativo"
  echo "idioma=es-MX" > i18n.txt;                           c "feat: español de México"
}

lab_04() {
  nuevo_repo m04-stash-worktree
  echo "<h1>Mi sitio</h1>" > index.html;                    c "feat: página inicial"
  echo "body { font-family: sans-serif; }" > estilos.css;   c "feat: estilos base"
  echo "console.log('listo');" > app.js;                    c "feat: script principal"
  git branch bugfix/menu
  git switch -q -c feature/carrusel
  echo "// carrusel de imágenes" > carrusel.js;             c "feat: carrusel"
  git switch -q main

  # Trabajo a medias: staged, unstaged y untracked
  echo "<nav>menú nuevo</nav>" >> index.html
  git add index.html
  echo "body { color: red; }" >> estilos.css
  echo "ideas sueltas para el sprint" > notas.txt
}

escribe_calculadora() {
  {
    echo '#!/usr/bin/env bash'
    echo '# Uso: bash calculadora.sh <operación> <a> <b>'
    echo 'op=$1; a=$2; b=$3'
    echo 'case $op in'
    printf '%s\n' "${OPERACIONES[@]}"
    echo '  *) echo "operación desconocida: $op" >&2; exit 1 ;;'
    echo 'esac'
  } > calculadora.sh
}

lab_05() {
  nuevo_repo m05-recuperacion
  OPERACIONES=('  suma) echo $((a + b)) ;;' '  resta) echo $((a - b)) ;;')
  escribe_calculadora
  cat > test.sh <<'EOF'
#!/usr/bin/env bash
# Sale con 0 si la suma funciona y con 1 si está rota.
[ "$(bash calculadora.sh suma 2 3)" = "5" ]
EOF
  echo "# Calculadora" > README.md
  c "feat: calculadora con suma y resta"

  agrega() { OPERACIONES+=("$1"); escribe_calculadora; c "$2"; }
  agrega '  multiplica) echo $((a * b)) ;;'                 "feat: multiplicación"
  echo "Uso: bash calculadora.sh suma 2 3" >> README.md;    c "docs: documenta uso"
  agrega '  divide) echo $((a / b)) ;;'                     "feat: división"
  agrega '  modulo) echo $((a % b)) ;;'                     "feat: módulo"
  echo "Ejemplo: bash calculadora.sh divide 10 2" >> README.md; c "docs: ejemplos"
  agrega '  potencia) echo $((a ** b)) ;;'                  "feat: potencia"
  printf 'root = true\n[*]\nindent_size = 2\n' > .editorconfig; c "chore: agrega .editorconfig"
  agrega '  maximo) echo $(( a > b ? a : b )) ;;'           "feat: máximo"
  agrega '  minimo) echo $(( a < b ? a : b )) ;;'           "feat: mínimo"
  printf '# Changelog\n- 0.9 operaciones básicas\n' > CHANGELOG.md; c "docs: changelog"
  agrega '  promedio) echo $(( (a + b) / 2 )) ;;'           "feat: promedio"
  # El bug: se esconde en un "refactor" que toca varias cosas
  OPERACIONES[0]='  suma) echo $((a + b + (a > 1))) ;;'
  echo "Todas las operaciones usan enteros." >> README.md
  escribe_calculadora;                                      c "refactor: normaliza formato"
  agrega '  abs) echo $(( a < 0 ? -a : a )) ;;'             "feat: valor absoluto"
  echo "- 0.95 abs" >> CHANGELOG.md;                        c "docs: actualiza changelog"
  agrega '  doble) echo $((a * 2)) ;;'                      "feat: doble"
  echo "MIT" > LICENSE;                                     c "chore: licencia MIT"
  agrega '  triple) echo $((a * 3)) ;;'                     "feat: triple"
  echo "Contribuciones bienvenidas." >> README.md;          c "docs: guía de contribución"
  echo "1.0.0" > VERSION;                                   c "chore: versión 1.0.0"

  # Cosas "perdidas" para rescatar
  git switch -q -c experimento
  echo "algoritmo secreto" > secreto.txt;                   c "experimento: algoritmo secreto"
  echo "versión optimizada" >> secreto.txt;                 c "experimento: optimización"
  git switch -q main
  git branch -q -D experimento

  echo "cambio importante" > importante.txt;                c "feat: cambio importante"
  git reset -q --hard HEAD~1

  echo "borrador de trabajo valioso" > borrador.txt
  git add borrador.txt
  git stash push -q -m "borrador valioso"
  git stash drop -q
}

lab_06() {
  nuevo_repo m06-parches
  cat > servicio.py <<'EOF'
def dividir(a, b):
    return a / b


def normalizar(texto):
    return texto.strip().lower()


def validar(datos):
    return all(k in datos for k in ("id", "nombre"))


def procesar(datos):
    if not validar(datos):
        return None
    datos["nombre"] = normalizar(datos["nombre"])
    return datos


def guardar(datos, ruta):
    with open(ruta, "w") as f:
        f.write(str(datos))


def cargar(ruta):
    with open(ruta) as f:
        return f.read()
EOF
  c "feat: servicio de datos"
  mkdir -p docs
  echo "# Guía" > docs/guia.md;                             c "docs: guía inicial"

  git switch -q -c contribucion
  printf '\n## Instalación\npip install servicio\n' >> docs/guia.md; como Marta "docs: instalación"
  printf '\n## Uso\nprocesar({"id": 1, "nombre": "Ana"})\n' >> docs/guia.md; como Marta "docs: uso"
  printf '\n## Licencia\nMIT\n' >> docs/guia.md;            como Marta "docs: licencia"
  git switch -q main

  # Tres cambios independientes sin commitear en el mismo archivo
  cat > servicio.py <<'EOF'
def dividir(a, b):
    if b == 0:
        raise ValueError("b no puede ser 0")
    return a / b


def normalizar(texto):
    return texto.strip().lower()


def validar(datos):
    return all(k in datos for k in ("id", "nombre"))


def procesar(datos):
    print("DEBUG datos:", datos)
    if not validar(datos):
        return None
    datos["nombre"] = normalizar(datos["nombre"])
    return datos


def guardar(datos, ruta):
    with open(ruta, "w") as f:
        f.write(str(datos))


def cargar(ruta):
    with open(ruta) as f:
        return f.read()


def exportar_csv(filas, ruta):
    with open(ruta, "w") as f:
        for fila in filas:
            f.write(",".join(map(str, fila)) + "\n")
EOF
}

lab_07() {
  local base="$LAB/m07-remotos"
  rm -rf "$base"
  mkdir -p "$base"
  cd "$base"
  git init -q --bare -b main origen.git

  git clone -q origen.git alice 2>/dev/null
  cd alice; configurar_repo Alice
  echo "# Proyecto compartido" > README.md;                 como Alice "docs: README"
  echo "v1" > app.txt;                                      como Alice "feat: app v1"
  git push -q -u origin main 2>/dev/null

  cd "$base"
  git clone -q origen.git bob
  cd bob; configurar_repo Bob
  git switch -q -c feature/vieja
  echo "idea descartada" > vieja.txt;                       como Bob "feat: idea que se descartará"
  git push -q -u origin feature/vieja 2>/dev/null

  cd "$base/alice"; git fetch -q          # Alice ve origin/feature/vieja

  cd "$base/bob"
  git push -q origin --delete feature/vieja 2>/dev/null
  git switch -q main
  echo "v2 (Bob)" >> app.txt;                               como Bob "feat: mejora de Bob"
  git push -q 2>/dev/null

  cd "$base/alice"                        # Alice trabaja sin saber del push de Bob
  echo "Autora: Alice" > AUTORES.md;                        como Alice "docs: autores"
}

lab_08() {
  rm -rf "$LAB/m08-tags-submodulos"
  nuevo_repo m08-tags-submodulos/libreria
  echo 'saludar() { echo "Hola $1"; }' > lib.sh;            c "feat: función saludar"
  echo 'despedir() { echo "Adiós $1"; }' >> lib.sh;         c "feat: función despedir"
  sed -i 's/Adiós/Adiós,/' lib.sh;                          c "fix: puntuación"

  nuevo_repo m08-tags-submodulos/app
  mkdir -p frontend backend docs infra
  echo "# App monorepo" > README.md;                        c "docs: README"
  echo "<div id=app></div>" > frontend/index.html;          c "feat(frontend): esqueleto"
  echo "GET /usuarios" > backend/rutas.txt;                 c "feat(backend): ruta usuarios"
  echo "# Arquitectura" > docs/arquitectura.md;             c "docs: arquitectura"
  echo "servidor: 2 cpu" > infra/servidor.yml;              c "feat(infra): servidor"
  echo "POST /usuarios" >> backend/rutas.txt;               c "feat(backend): crear usuario"
  echo "<nav></nav>" >> frontend/index.html;                c "feat(frontend): navegación"
  echo "réplicas: 3" >> infra/servidor.yml;                 c "feat(infra): réplicas"
  echo "DELETE /usuarios" >> backend/rutas.txt;             c "feat(backend): borrar usuario"
}

lab_09() {
  nuevo_repo m09-hooks
  echo "# Laboratorio de hooks" > README.md;                c "docs: README"
  echo "export const suma = (a, b) => a + b;" > app.js;     c "feat: suma"
}

lab_10() {
  nuevo_repo m10-internals
  echo "hola mundo" > saludo.txt;                           c "primer commit"
  mkdir -p docs
  echo "# Guía" > docs/guia.md;                             c "docs: guía"
}

escribe_inventario() {
  {
    echo '#!/usr/bin/env bash'
    echo '# Uso: bash inventario.sh <comando> <valor>'
    echo 'case $1 in'
    printf '%s\n' "${COMANDOS[@]}"
    echo '  *) echo "comando desconocido: $1" >&2; exit 1 ;;'
    echo 'esac'
  } > inventario.sh
}

lab_11() {
  nuevo_repo m11-proyecto-final
  COMANDOS=('  iva) echo $(( $2 * 116 / 100 )) ;;')
  escribe_inventario
  cat > pruebas.sh <<'EOF'
#!/usr/bin/env bash
# Sale con 0 si el cálculo de IVA es correcto.
[ "$(bash inventario.sh iva 100)" = "116" ]
EOF
  printf '# Inventario\n\n## Comandos\n- iva\n' > README.md
  como Ana "feat: cálculo de IVA"

  cmd() { COMANDOS+=("$1"); escribe_inventario; como "$2" "$3"; }
  cmd '  descuento) echo $(( $2 * 90 / 100 )) ;;'           Luis  "feat: descuento del 10%"
  echo "- descuento" >> README.md;                          como Luis "docs: comando descuento"
  git tag -a v1.0.0 -m "Versión 1.0.0"

  git switch -q -c feature/reportes
  echo "stock total: 0" > reportes.txt;                     como Marta "feat: reporte de stock"
  echo "wip" >> reportes.txt;                               como Marta "wip"
  sed -i 's/stock total/Stock total/' reportes.txt;         como Marta "fix typo"
  echo "ventas del mes: 0" >> reportes.txt;                 como Marta "feat: reporte de ventas"
  sed -i '/^wip$/d' reportes.txt;                           como Marta "wip otra vez"
  echo "- reportes" >> README.md;                           como Marta "docs: comando reportes"
  git switch -q main

  cmd '  doble) echo $(( $2 * 2 )) ;;'                      Ana   "feat: comando doble"
  # Bug escondido en un refactor
  COMANDOS[0]='  iva) echo $(( $2 * 106 / 100 )) ;;'
  COMANDOS+=('  mitad) echo $(( $2 / 2 )) ;;')
  escribe_inventario;                                       como Luis "refactor: reordena comandos y agrega mitad"
  echo "- doble" >> README.md;                              como Ana "docs: comando doble"
  echo "MIT" > LICENSE;                                     como Luis "chore: licencia"
  echo "- mitad" >> README.md;                              como Ana "docs: comando mitad"

  # Un hotfix que alguien borró por accidente
  git switch -q -c hotfix/stock-negativo
  echo "rechazar valores negativos" > validaciones.txt;     como Luis "fix: evita stock negativo"
  git switch -q main
  git branch -q -D hotfix/stock-negativo
}

# ------------------------------------------------------------------- main ---

declare -A NOMBRES=(
  [00]="m00-config            Configuración y alias"
  [01]="m01-historial         Inspección del historial"
  [02]="m02-reescritura       Reescribir historia"
  [03]="m03-ramas             Ramas, merge, rebase y cherry-pick"
  [04]="m04-stash-worktree    Stash avanzado y worktrees"
  [05]="m05-recuperacion      Reflog, recuperación y bisect"
  [06]="m06-parches           Selección fina y parches"
  [07]="m07-remotos           Remotos avanzados"
  [08]="m08-tags-submodulos   Tags, submódulos y sparse-checkout"
  [09]="m09-hooks             Hooks y automatización"
  [10]="m10-internals         Internals de Git"
  [11]="m11-proyecto-final    Proyecto final"
)

crear() {
  local n
  n=$(printf '%02d' "$((10#$1))")
  if [[ -z "${NOMBRES[$n]:-}" ]]; then
    echo "Módulo desconocido: $1" >&2
    exit 1
  fi
  ( "lab_$n" )
  echo "✔ laboratorio/${NOMBRES[$n]%% *} listo"
}

if [[ $# -eq 0 ]]; then
  echo "Uso: bash scripts/lab.sh <módulo|todos>"
  echo
  for n in $(printf '%s\n' "${!NOMBRES[@]}" | sort); do
    echo "  $n  ${NOMBRES[$n]}"
  done
  exit 0
fi

mkdir -p "$LAB"
if [[ "$1" == "todos" ]]; then
  for n in $(printf '%s\n' "${!NOMBRES[@]}" | sort); do crear "$n"; done
else
  crear "$1"
fi
