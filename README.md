# 🧠 Curso de Git Avanzado

Curso **100 % práctico** de comandos avanzados de Git. No construimos ninguna app: cada módulo genera un repo de laboratorio con un escenario preparado (historial con bugs, ramas en conflicto, commits "perdidos", remotos simulados…) para practicar los comandos en situaciones reales.

## Requisitos

- Git ≥ 2.38 (`git --version`)
- **Git Bash** (viene con Git for Windows). Todos los comandos del curso están pensados para Bash.
  > ⚠️ Abre la terminal **Git Bash** (o elige el perfil "Git Bash" en la terminal de VS Code). Si escribes `bash` dentro de PowerShell, en este equipo se abre el bash de **WSL**, que usa otra instalación de Git y rutas `/mnt/c/...`.
- Un editor configurado en Git (`git config --global core.editor "code --wait"`)

## Cómo se usa

```bash
# 1. Lee el módulo
modulos/01-historial.md

# 2. Genera su laboratorio (se puede regenerar las veces que quieras)
bash scripts/lab.sh 01
cd laboratorio/m01-historial

# 3. Practica los comandos y resuelve los ejercicios

# 4. Marca cada ejercicio terminado en el .md del módulo:  - [ ]  ->  - [x]

# 5. Actualiza tu progreso (desde la raíz del curso)
bash scripts/progreso.sh
```

Anota fechas, dudas y aprendizajes en la **bitácora** de [`PROGRESO.md`](PROGRESO.md).

> 💥 **Rompe cosas sin miedo.** `laboratorio/` está en `.gitignore`; si arruinas un escenario, `bash scripts/lab.sh <n>` lo deja como nuevo.

## Temario

| # | Módulo | Comandos clave |
|---|---|---|
| 00 | [Configuración y alias](modulos/00-configuracion-y-alias.md) | `config --show-origin`, alias, `includeIf` |
| 01 | [Inspección del historial](modulos/01-historial.md) | `log -S/-G/-L/--follow`, `blame -C`, `shortlog`, `describe` |
| 02 | [Reescribir historia](modulos/02-reescribir-historia.md) | `rebase -i`, `--fixup`/`--autosquash`, `reset`, `revert` |
| 03 | [Ramas: merge, rebase y cherry-pick](modulos/03-ramas-merge-rebase.md) | `rebase --onto`, `cherry-pick -x`, `merge --squash`, `rerere` |
| 04 | [Stash avanzado y worktrees](modulos/04-stash-y-worktree.md) | `stash -p/-u/--keep-index`, `stash branch`, `worktree` |
| 05 | [Reflog, recuperación y bisect](modulos/05-recuperacion-y-bisect.md) | `reflog`, `fsck --unreachable`, `bisect run` |
| 06 | [Selección fina y parches](modulos/06-parches-y-seleccion-fina.md) | `add -p`, `restore -p`, `format-patch`, `am`, `range-diff` |
| 07 | [Remotos avanzados](modulos/07-remotos-avanzados.md) | `fetch --prune`, `pull --rebase`, `--force-with-lease` |
| 08 | [Tags, submódulos y sparse-checkout](modulos/08-tags-submodulos-sparse.md) | `tag -a`, `submodule`, `subtree`, `sparse-checkout` |
| 09 | [Hooks y automatización](modulos/09-hooks.md) | `pre-commit`, `commit-msg`, `pre-push`, `core.hooksPath` |
| 10 | [Internals de Git](modulos/10-internals.md) | `cat-file`, `hash-object`, `write-tree`, `commit-tree` |
| 11 | [Proyecto final](modulos/11-proyecto-final.md) | Todo lo anterior |

Orden recomendado: 00 → 11. Los módulos 04, 08, 09 y 10 se pueden hacer en cualquier orden.

## Estructura

```
curso_git_avanzado/
├── README.md          # este archivo
├── PROGRESO.md        # tabla de avance + bitácora personal
├── modulos/           # teoría, ejercicios y repaso de cada módulo
├── scripts/
│   ├── lab.sh         # genera los escenarios de práctica
│   └── progreso.sh    # recalcula el avance a partir de las casillas marcadas
└── laboratorio/       # repos de práctica (ignorado por git, desechable)
```
