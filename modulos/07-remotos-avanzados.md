# 07 · Remotos avanzados

> **Objetivo:** trabajar en equipo con seguridad: fetch vs. pull, ramas de seguimiento, varios remotos, `--force-with-lease` y limpieza de referencias.

```bash
bash scripts/lab.sh 07
cd laboratorio/m07-remotos
```

Se simula un equipo **sin GitHub**:

```
m07-remotos/
├── origen.git   # repo "servidor" (bare)
├── alice/       # clon de Alice: tiene 1 commit sin subir y NO sabe que Bob subió algo
└── bob/         # clon de Bob: ya subió un cambio a main y borró la rama remota feature/vieja
```

---

## 1. Inspeccionar remotos

```bash
git remote -v
git remote show origin              # ramas, tracking y estado detallado
git branch -vv                      # cada rama con su upstream y ahead/behind
git status -sb                      # ## main...origin/main [ahead 1, behind 1]
git ls-remote origin                # refs del servidor sin hacer fetch
```

## 2. Fetch, pull y seguimiento

```bash
git fetch                           # descarga y actualiza origin/*, NO toca tus ramas
git fetch --prune                   # además borra origin/* que ya no existen en el servidor
git fetch --all                     # todos los remotos
git log --oneline main..origin/main # lo que llegó y aún no integraste
git pull --rebase                   # fetch + rebase (sin commits de merge innecesarios)
git pull --ff-only                  # solo si es fast-forward; si no, falla
git branch -u origin/main           # asigna el upstream a la rama actual
git push -u origin feature/x        # push + asigna upstream
```

## 3. Push avanzado

```bash
git push origin HEAD                # sube la rama actual con el mismo nombre
git push origin local:remota        # sube la rama local con otro nombre en el remoto
git push origin --delete rama       # borra una rama remota
git push --force-with-lease         # force SOLO si el remoto está como la última vez que lo viste
git push --force-with-lease=main:<hash-esperado>
git push --tags / git push origin v1.0.0
git push --dry-run
```

> ❌ `--force` a secas pisa el trabajo de otros sin avisar.
> ✅ `--force-with-lease` se niega si alguien subió algo que no has descargado.

## 4. Varios remotos (flujo *fork*)

```bash
git remote add upstream <url>
git fetch upstream
git rebase upstream/main
git remote rename origin personal
git remote set-url origin <nueva-url>
git remote remove upstream
```

---

## Ejercicios

- [ ] En `alice`, ejecuta `git status -sb` y `git branch -vv`. Luego haz `git fetch` y compáralos otra vez. Explica `ahead`/`behind`.
- [ ] Mira qué subió Bob **sin integrarlo**: `git log -p main..origin/main`.
- [ ] En `alice`, `git branch -a` todavía muestra `origin/feature/vieja`. Límpiala con `fetch --prune` y compruébalo con `git remote show origin`.
- [ ] Integra el trabajo de Bob con `pull --rebase` (sin merge commit) y sube el commit de Alice.
- [ ] **Force-with-lease:** en `alice`, reescribe el último commit (amend) *después* de que Bob suba otro cambio. Intenta `push --force-with-lease`, lee el rechazo y resuélvelo bien.
- [ ] Repite lo anterior con `--force` en una rama de prueba y comprueba que el commit de Bob desaparece del servidor (así ves por qué no se usa).
- [ ] Desde `bob`, crea `feature/x` y súbela con otro nombre en el remoto (`feature/x:feature/revision`).
- [ ] Crea `upstream.git` (`git clone --bare origen.git upstream.git`), agrégalo como segundo remoto en `alice` y trae ramas de ambos.
- [ ] Usa `git ls-remote` para ver las refs del servidor sin hacer fetch.

### 🏆 Reto
- [ ] Configura en `alice` un alias `sync` que haga `fetch --prune` + `pull --rebase` + muestre `status -sb`, y úsalo para simular un día de trabajo en equipo (Bob sube 3 veces, Alice sincroniza).

## Repaso

1. ¿Qué diferencia hay entre `fetch` y `pull`?
2. ¿Por qué se prefiere `--force-with-lease` a `--force`?
3. ¿Qué es un repo *bare* y por qué el "servidor" lo es?

<details>
<summary>Respuestas</summary>

1. `fetch` solo descarga y actualiza las ramas remotas (`origin/*`). `pull` además integra (merge o rebase) en tu rama actual.
2. Porque comprueba que el remoto sigue donde tú lo viste. Si alguien subió algo en medio, se niega en vez de borrarlo.
3. Un repo sin working dir, solo con el contenido de `.git`. Hacer push a una rama que alguien tiene abierta en su working dir causaría inconsistencias.
</details>
