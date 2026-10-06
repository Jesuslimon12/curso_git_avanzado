# 04 · Stash avanzado y worktrees

> **Objetivo:** cambiar de contexto sin perder trabajo: guardar cambios de forma selectiva con `stash` y tener varias ramas abiertas a la vez con `worktree`.

```bash
bash scripts/lab.sh 04
cd laboratorio/m04-stash-worktree
git status
```

Tienes trabajo a medias en los tres estados posibles: `index.html` en **staging**, `estilos.css` **modificado** sin agregar y `notas.txt` **sin seguimiento**.

---

## 1. Stash

```bash
git stash push -m "mensaje"        # guarda cambios en archivos con seguimiento (staged + unstaged)
git stash push -u                  # incluye archivos sin seguimiento (untracked)
git stash push -a                  # incluye también los ignorados
git stash push --staged            # solo lo que está en staging (Git ≥ 2.35)
git stash push --keep-index        # guarda todo pero deja lo que está en staging
git stash push -p                  # elige por partes (hunks) qué guardar
git stash push -- estilos.css      # solo ciertos archivos

git stash list
git stash show -p stash@{1}        # diff de un stash
git stash apply stash@{1}          # lo aplica y lo conserva
git stash pop                      # lo aplica y lo borra (si no hay conflicto)
git stash pop --index              # restaura también lo que estaba en staging
git stash drop stash@{0}
git stash branch nueva-rama stash@{0}   # crea una rama desde donde se hizo el stash y lo aplica
git stash clear                         # ⚠ borra todos (recuperables con fsck, módulo 05)
```

## 2. Worktrees

Varios directorios de trabajo que comparten el **mismo** `.git`. No hace falta stash ni clonar de nuevo.

```bash
git worktree add ../m04-bugfix bugfix/menu        # abre una rama existente en otra carpeta
git worktree add -b hotfix/urgente ../m04-hotfix  # crea una rama nueva y la abre
git worktree add --detach ../m04-revision HEAD~2  # carpeta en un commit concreto (detached)
git worktree list
git worktree remove ../m04-hotfix
git worktree prune                                # limpia registros de carpetas borradas a mano
git worktree lock / unlock
```

> Una rama solo puede estar abierta en **un** worktree a la vez.

---

## Ejercicios

- [ ] Guarda **solo** `estilos.css` en un stash con mensaje y comprueba que `index.html` sigue en staging.
- [ ] Guarda el resto **incluyendo** `notas.txt` (`-u`). Revisa `git stash list` y el contenido de cada stash con `show -p`.
- [ ] Recupera el stash de `index.html` con `pop --index` y verifica que vuelve **a staging**, no solo al working dir.
- [ ] Haz varios cambios en un archivo y usa `stash push -p` para guardar solo algunos hunks.
- [ ] Usa `--keep-index`: deja en staging lo que quieres commitear, guarda el resto, "corre los tests" y restaura.
- [ ] Convierte un stash en rama con `git stash branch`.
- [ ] Sin tocar tus cambios en `main`, abre `bugfix/menu` en un worktree, haz un commit ahí y vuelve.
- [ ] Crea un worktree con una rama nueva `hotfix/urgente`, commitea y luego elimínalo con `worktree remove`.
- [ ] Intenta abrir `main` en un segundo worktree y lee el error.
- [ ] Borra a mano la carpeta de un worktree y límpialo con `worktree prune`.

### 🏆 Reto
- [ ] Tienes 3 stashes. Aplica **el del medio** en una rama nueva, resuelve un conflicto provocado a propósito y confirma que el stash no se borró por el conflicto.

## Repaso

1. ¿Qué diferencia hay entre `apply` y `pop`?
2. ¿Qué ventaja tiene un worktree frente a clonar el repo otra vez?
3. ¿Qué pasa con los stashes si haces `git stash clear` por error?

<details>
<summary>Respuestas</summary>

1. `apply` conserva el stash y `pop` lo borra si se aplicó sin conflictos.
2. Comparten objetos, refs y config: ocupa menos espacio, las ramas se ven al instante y no hay que hacer push/fetch entre copias.
3. Los commits del stash quedan inalcanzables pero existen hasta el `gc`. Se recuperan con `git fsck --unreachable | grep commit` (módulo 05).
</details>
