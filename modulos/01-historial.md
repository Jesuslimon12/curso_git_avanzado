# 01 · Inspección del historial

> **Objetivo:** encontrar cualquier cosa en el historial: quién cambió qué, cuándo, y en qué commit apareció o desapareció un código.

```bash
bash scripts/lab.sh 01
cd laboratorio/m01-historial
```

El laboratorio es una tienda con 3 autores (Ana, Luis, Marta), un archivo renombrado, una rama fusionada y un tag `v1.0.0`.

---

## 1. Cómo referirse a commits

| Sintaxis | Significado |
|---|---|
| `HEAD~3` | 3 commits atrás siguiendo el primer padre |
| `HEAD^2` | El **segundo padre** (solo en merges) |
| `main@{2}` | Dónde estaba `main` hace 2 movimientos (reflog) |
| `main@{yesterday}` | Dónde estaba `main` ayer |
| `v1.0.0^{commit}` | El commit al que apunta el tag |
| `:/texto` | El commit más reciente cuyo mensaje contiene "texto" |
| `A..B` | Commits en B que **no** están en A |
| `A...B` | Commits en A o en B pero no en ambos (diferencia simétrica) |

```bash
git rev-parse HEAD~2          # convierte una referencia en hash
git show HEAD^2 --stat        # (desde un merge) el commit de la rama fusionada
git show :/descuento          # busca por mensaje
```

## 2. `git log` avanzado

```bash
git log --oneline --graph --all --decorate
git log --author="Ana" --oneline
git log --since="2025-01-01" --until="2025-01-02"
git log --grep="feat" --oneline             # busca en los mensajes
git log -S "calcularDescuento" --oneline    # "pickaxe": commits donde cambia el nº de apariciones
git log -G "total\s*>" --oneline            # regex sobre las líneas cambiadas del diff
git log --follow -- src/helpers.js          # sigue el archivo aunque se haya renombrado
git log -L :formatearPrecio:src/helpers.js  # historia de UNA función
git log -L 1,5:src/carrito.js               # historia de un rango de líneas
git log --first-parent main                 # solo la "línea principal" (ignora el interior de los merges)
git log --merges / --no-merges
git log -p -2                               # parches de los últimos 2 commits
git log --stat / --name-status
```

## 3. Otras herramientas de inspección

```bash
git show v1.0.0                    # tag + commit
git show HEAD~1:src/carrito.js     # el archivo tal como estaba en ese commit
git blame src/carrito.js
git blame -L 5,10 src/carrito.js   # solo unas líneas
git blame -w -C -C src/helpers.js  # ignora espacios y detecta código movido/copiado
git shortlog -sn                   # commits por autor
git shortlog v1.0.0..HEAD          # changelog desde un tag
git describe --tags                # v1.0.0-3-gabc123: tag más cercano + distancia
git diff v1.0.0..HEAD --stat
git grep -n "export function" v1.0.0   # grep en otra versión sin hacer checkout
```

---

## Ejercicios

- [x] Muestra el grafo completo y señala el commit de merge y sus dos padres (`HEAD^1`/`HEAD^2` desde el merge).
- [x] Lista solo los commits de **Marta**, y después cuenta los commits por autor con `shortlog`.
- [x] Con `log -S`, averigua **en qué commit se agregó y en cuál se eliminó** `calcularDescuento`, y quién lo hizo.
- [x] Recupera el contenido de `calcularDescuento` **sin hacer checkout** (usa `git show <commit>:<ruta>`).
- [x] Muestra el historial completo de `src/helpers.js`, incluidos los commits de cuando se llamaba `utils.js`.
- [x] Muestra cómo evolucionó la función `formatearPrecio` con `log -L`.
- [x] Lista los commits que hay en `main` desde `v1.0.0` y genera un mini changelog con `shortlog`.
- [x] Usa `blame` para saber quién escribió la función `total()`.
- [x] Muestra `main` con `--first-parent` y explica qué commits desaparecen y por qué.
- [x] Busca con `git grep` todas las funciones exportadas en la versión `v1.0.0`.

### 🏆 Reto
- [ ] Con un solo comando, lista los archivos que tocó cada commit de Luis, mostrando si se agregaron (A), modificaron (M) o renombraron (R).

<details>
<summary>💡 Pista del reto</summary>

`git log --author=... --name-status --oneline`
</details>

## Repaso

1. ¿Qué diferencia hay entre `log -S` y `log -G`?
2. ¿Qué diferencia hay entre `main..feature` y `main...feature`?
3. ¿Por qué hace falta `--follow` para ver el historial de un archivo renombrado?

<details>
<summary>Respuestas</summary>

1. `-S` busca commits donde **cambia el número de apariciones** del texto (se agregó o se eliminó). `-G` busca commits cuyo diff tiene líneas que coinciden con la regex, aunque el número de apariciones no cambie.
2. `..` muestra lo que tiene `feature` y no tiene `main`. `...` muestra lo que tiene cada lado y el otro no.
3. Git no guarda renombres. Los deduce comparando el contenido, y `log -- ruta` solo mira esa ruta a menos que le pidas seguirla.
</details>
