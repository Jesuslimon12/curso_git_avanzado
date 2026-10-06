# 06 · Selección fina y parches

> **Objetivo:** commitear solo parte de un archivo, descartar cambios concretos, comparar versiones con precisión y mover cambios entre repos como archivos de parche.

```bash
bash scripts/lab.sh 06
cd laboratorio/m06-parches
git diff
```

`servicio.py` tiene **3 cambios sin commitear que no tienen nada que ver entre sí**:
1. Un bugfix en `dividir` (valida `b == 0`).
2. Un `print("DEBUG ...")` que **no** debe llegar al repo.
3. Una función nueva `exportar_csv`.

La rama `contribucion` tiene 3 commits de documentación para exportar como parches.

---

## 1. Staging interactivo

```bash
git add -p servicio.py
#  y = agregar este hunk     n = no agregar
#  s = dividir en hunks más pequeños    e = editar el hunk a mano
#  q = salir                 ? = ayuda
git diff --staged               # lo que va al commit
git diff                        # lo que queda fuera
git restore -p servicio.py      # descarta hunks del working dir (¡irreversible!)
git restore --staged -p         # saca hunks del staging
git commit -p                   # add -p + commit en un paso
```

## 2. Diff avanzado

```bash
git diff --word-diff            # diferencias palabra por palabra
git diff --color-moved          # distingue código movido de código nuevo
git diff --stat / --shortstat / --name-only
git diff -w                     # ignora espacios en blanco
git diff main...contribucion    # cambios de la rama desde que se separó de main
git diff HEAD~2 HEAD -- docs/   # limitar a una ruta
git range-diff main contribucion-v1 contribucion-v2   # compara dos versiones de una misma serie
```

## 3. Parches

```bash
# Formato email (conserva autor, fecha y mensaje): uno por commit
git format-patch main..contribucion -o ../parches
git format-patch -3 HEAD                # los 3 últimos

git am ../parches/*.patch               # los aplica como commits
git am --abort | --continue | --skip

# Parche simple (solo el diff, sin metadatos)
git diff > cambios.diff
git apply --check cambios.diff          # ¿se puede aplicar?
git apply --stat cambios.diff
git apply cambios.diff                  # aplica al working dir (no hace commit)
git apply -R cambios.diff               # revierte el parche
git apply --3way cambios.diff           # si hay conflicto, deja marcadores
```

---

## Ejercicios

- [ ] Con `git add -p`, commitea **solo** el bugfix de `dividir` (`fix: valida división por cero`).
- [ ] Commitea **solo** `exportar_csv` en otro commit.
- [ ] Descarta el `print("DEBUG ...")` con `git restore -p` y deja el working dir limpio.
- [ ] Usa `s` (split) o `e` (edit) en algún hunk para quedarte solo con parte de él.
- [ ] Compara dos commits con `--word-diff` y con `--stat`.
- [ ] Exporta los commits de `contribucion` con `format-patch` a la carpeta `../parches` y lee uno de los `.patch`.
- [ ] Crea la rama `integracion` desde `main` y aplica los parches con `git am`. Comprueba que se conservó el **autor** y la fecha original.
- [ ] Genera un diff simple del working dir, verifícalo con `apply --check`, aplícalo y revírtelo con `apply -R`.
- [ ] Crea `contribucion-v2` (copia de `contribucion` con un mensaje cambiado vía rebase -i) y compara ambas con `git range-diff`.

### 🏆 Reto
- [ ] Clona el laboratorio a otra carpeta (`git clone m06-parches m06-receptor`) y lleva un commit de un repo al otro **sin remotos**, solo con `format-patch` + `am`.

## Repaso

1. ¿Qué diferencia hay entre `format-patch`/`am` y `diff`/`apply`?
2. ¿Por qué `restore -p` es peligroso?
3. ¿Para qué sirve `range-diff`?

<details>
<summary>Respuestas</summary>

1. `format-patch`/`am` conservan los commits completos (autor, fecha, mensaje). `diff`/`apply` solo aplican cambios al working dir, sin crear commits.
2. Descarta cambios que nunca se guardaron en Git, así que no hay reflog que los recupere.
3. Para comparar dos versiones de una serie de commits (antes y después de un rebase, o la v1 y la v2 de un PR).
</details>
