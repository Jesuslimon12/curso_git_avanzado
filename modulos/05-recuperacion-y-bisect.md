# 05 · Reflog, recuperación y bisect

> **Objetivo:** perder el miedo a romper cosas: recuperar commits, ramas y stashes "perdidos", y encontrar con `bisect` el commit que introdujo un bug.

```bash
bash scripts/lab.sh 05
cd laboratorio/m05-recuperacion
```

El escenario:
- `calculadora.sh` tiene **20 commits**. `bash calculadora.sh suma 2 3` debería dar `5`… pero en algún momento dejó de hacerlo. `test.sh` lo comprueba.
- Alguien borró la rama `experimento` con `-D`.
- Alguien hizo `reset --hard` y perdió el commit `feat: cambio importante`.
- Alguien hizo `stash drop` de un stash llamado `borrador valioso`.

---

## 1. Reflog

Registro **local** de a dónde apuntó HEAD (y cada rama). Por defecto se guarda unos 90 días.

```bash
git reflog                       # movimientos de HEAD
git reflog show main             # movimientos de una rama
git log -g --oneline             # el reflog en formato log
git reset --hard HEAD@{3}        # volver a un estado anterior
git branch rescate HEAD@{5}      # crear una rama en un punto del reflog
git show main@{1.hour.ago}
```

## 2. Objetos inalcanzables

Lo que no está en el reflog (p. ej. un stash borrado):

```bash
git fsck --unreachable --no-reflogs | grep commit
git fsck --lost-found                  # los copia a .git/lost-found/
git show <hash>                        # inspecciona el candidato
git log --oneline --all $(git fsck --unreachable --no-reflogs | awk '/commit/ {print $3}')
```

> 🗑️ Lo inalcanzable se borra con `git gc --prune=now`. **No lo ejecutes** mientras estés rescatando algo.

## 3. Restaurar archivos concretos

```bash
git restore --source=HEAD~5 -- calculadora.sh     # el archivo como estaba hace 5 commits
git restore --source=<commit> --staged --worktree -- ruta
git checkout <commit> -- ruta                     # forma clásica equivalente
```

## 4. Bisect: búsqueda binaria de bugs

```bash
git bisect start
git bisect bad                   # el commit actual tiene el bug
git bisect good <commit>         # este commit estaba bien
# Git hace checkout de un commit intermedio -> pruebas -> marcas:
git bisect good | bad | skip
git bisect log                   # historial de la sesión
git bisect reset                 # vuelve a donde empezaste

# Automático: el script devuelve 0 = good, 1-124 = bad, 125 = skip
git bisect start HEAD <commit-bueno>
git bisect run bash test.sh
```

Con 20 commits hacen falta como mucho ~5 pasos (log₂ 20).

---

## Ejercicios

- [ ] Ejecuta `bash test.sh; echo $?` para confirmar que el bug existe en `HEAD`.
- [ ] Encuentra el commit culpable con `bisect` **manual** (good/bad a mano). Anota cuántos pasos hicieron falta.
- [ ] Repite la búsqueda con `git bisect run bash test.sh`.
- [ ] Corrige el bug con `git revert` del commit culpable o restaurando la línea con `restore --source`. Verifica con `test.sh`.
- [ ] Recupera la rama `experimento` con el reflog.
- [ ] Recupera el commit `feat: cambio importante` que se perdió con `reset --hard`.
- [ ] Recupera el stash `borrador valioso` con `git fsck` y aplícalo.
- [ ] Muestra en qué commit estaba `main` hace 3 movimientos (`main@{3}`).
- [ ] Restaura `calculadora.sh` como estaba en el **primer** commit, sin mover HEAD, y luego déjalo como estaba.

### 🏆 Reto
- [ ] Modifica `test.sh` para que devuelva `125` (skip) en los commits donde no exista la operación `promedio` (usa `grep -q promedio calculadora.sh || exit 125`), y usa `bisect run` con él. Anota en la bitácora para qué sirve el 125 en proyectos reales (commits que no compilan).

## Repaso

1. ¿El reflog se sube al remoto?
2. ¿Por qué un stash borrado no aparece en `git reflog`?
3. ¿Qué significa el código de salida 125 en `bisect run`?

<details>
<summary>Respuestas</summary>

1. No, es solo local. Cada clon tiene el suyo.
2. `stash drop` borra la entrada del reflog de `refs/stash`, que era lo único que lo referenciaba. El commit sigue existiendo y lo encuentras con `fsck`.
3. "No se puede probar este commit, sáltalo" (`skip`).
</details>
