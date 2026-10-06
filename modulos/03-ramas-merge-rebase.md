# 03 · Ramas: merge, rebase y cherry-pick

> **Objetivo:** integrar trabajo con la estrategia correcta: merge o rebase, `--onto`, `cherry-pick`, merges con squash, conflictos y `rerere`.

```bash
bash scripts/lab.sh 03
cd laboratorio/m03-ramas
git log --oneline --graph --all
```

| Rama | Para practicar |
|---|---|
| `feature/colores` | Conflicto en `config.txt` con `main` |
| `feature/idioma` | Conflicto en `i18n.txt`, estrategias `-X ours/theirs` |
| `hotfix/varios` | Llevar **solo** `fix: sanitiza entrada de usuario` a `main` |
| `feature/base` → `feature/extension` | `rebase --onto` |
| `feature/estilos` | `merge --squash` |

---

## 1. Merge

```bash
git merge feature/x                  # fast-forward si se puede; si no, commit de merge
git merge --no-ff feature/x          # siempre crea commit de merge (guarda que existió la rama)
git merge --ff-only feature/x        # falla si no se puede hacer fast-forward
git merge --squash feature/x         # aplica todos los cambios como UN cambio en staging (sin merge)
git merge -X ours feature/x          # en los conflictos gana main (lo que no choca se fusiona)
git merge -X theirs feature/x        # en los conflictos gana la rama entrante
git merge -s ours feature/x          # ⚠ ignora TODO el contenido de la otra rama; solo la marca como fusionada
git merge --abort
```

## 2. Rebase

```bash
git switch feature/x && git rebase main     # vuelve a aplicar feature/x encima de main
git rebase --onto main feature/base feature/extension
#               ^destino ^desde (excluido) ^rama a mover
git pull --rebase
```

`rebase --onto A B C` significa: toma los commits de `C` que no están en `B` y aplícalos encima de `A`.

## 3. Cherry-pick

```bash
git cherry-pick <commit>
git cherry-pick -x <commit>       # agrega "(cherry picked from commit ...)" al mensaje
git cherry-pick -n <commit>       # aplica los cambios sin hacer commit
git cherry-pick A..B              # rango (sin incluir A)
git cherry-pick --continue | --abort | --skip
```

## 4. Conflictos

```bash
git status                        # archivos en conflicto ("both modified")
git diff                          # muestra los marcadores
git checkout --ours   archivo     # quédate con tu versión
git checkout --theirs archivo     # quédate con la versión entrante
git checkout -m archivo           # vuelve a poner los marcadores si te equivocaste
git log --merge -p                # commits de ambos lados que tocan los archivos en conflicto
git mergetool
```

> 🔁 **Ojo:** durante un **rebase**, `ours` = la rama **sobre la que** aplicas (main) y `theirs` = tus commits. Es al revés que en un merge.

## 5. `rerere` (reuse recorded resolution)

```bash
git config rerere.enabled true
# resuelves un conflicto una vez -> Git lo recuerda
# si vuelve a aparecer el mismo conflicto, lo resuelve solo
git rerere status
git rerere diff
```

---

## Ejercicios

- [ ] Haz merge de `feature/colores` en `main`, resuelve el conflicto quedándote con `color=azul` y termina el merge.
- [ ] Deshaz ese merge (`reset --hard ORIG_HEAD`) y vuelve a hacerlo, esta vez con `merge.conflictStyle diff3`. Anota la diferencia.
- [ ] Rebasa `feature/idioma` sobre `main` y resuelve el conflicto. Comprueba en la práctica qué significan `--ours`/`--theirs` durante un rebase.
- [ ] Sin tocar `hotfix/varios`, lleva a `main` **solo** el commit `fix: sanitiza entrada de usuario` usando `cherry-pick -x`.
- [ ] Mueve `feature/extension` para que parta de `main` **sin** los commits de `feature/base`, con `rebase --onto`.
- [ ] Integra `feature/estilos` como un único commit con `merge --squash`. ¿Git considera la rama como fusionada? (`git branch --merged`).
- [ ] Deshaz lo anterior y compara `merge --no-ff` con el fast-forward en el grafo.
- [ ] Haz un merge de `feature/idioma` usando `-X theirs` y verifica el resultado.
- [ ] Activa `rerere`, resuelve el conflicto de `feature/colores`, aborta o deshaz, repite el merge y comprueba que el conflicto se resuelve solo.

### 🏆 Reto
- [ ] Encuentra el ancestro común entre `main` y `feature/colores` (`git merge-base`), y usa `git merge-tree` (o `git diff main...feature/colores`) para **predecir** el conflicto antes de fusionar.

## Repaso

1. ¿Cuándo prefieres rebase y cuándo merge?
2. ¿Qué diferencia hay entre `-X ours` y `-s ours`?
3. ¿Por qué después de `merge --squash` la rama no aparece como fusionada?

<details>
<summary>Respuestas</summary>

1. Rebase para actualizar tu rama privada y tener una historia lineal. Merge (`--no-ff`) para integrar ramas compartidas o cuando quieres conservar el contexto de la rama.
2. `-X ours` fusiona normal y solo en los conflictos elige tu lado. `-s ours` descarta todos los cambios de la otra rama.
3. Porque el commit que crea tiene un solo padre. No hay ningún enlace a la rama, solo su contenido.
</details>
