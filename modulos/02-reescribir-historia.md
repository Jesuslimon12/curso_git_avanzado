# 02 · Reescribir historia

> **Objetivo:** dejar una rama limpia antes de abrir un PR: juntar commits, reescribir mensajes, eliminar commits, y deshacer con `reset` y `revert` sabiendo cuál usar.

```bash
bash scripts/lab.sh 02
cd laboratorio/m02-reescritura
```

Estás en `feature/login`, que tiene 7 commits desordenados (`wip`, `arreglo typo`, un `.env` con una contraseña, un mensaje con una errata…). `main` avanzó 2 commits y uno de ellos (`activa modo debug en producción`) hay que revertirlo.

> ⚠️ **Regla de oro:** solo reescribe commits que **no** se hayan compartido. Si ya están en el remoto, tendrás que hacer `push --force-with-lease` (módulo 07) y avisar al equipo.

---

## 1. `commit --amend`

```bash
git commit --amend -m "nuevo mensaje"   # cambia el mensaje del último commit
git add olvidado.txt
git commit --amend --no-edit            # agrega archivos al último commit
git commit --amend --reset-author --no-edit
```

## 2. `reset`: mover la rama

| Modo | HEAD/rama | Staging | Working dir | Uso típico |
|---|---|---|---|---|
| `--soft` | ✅ se mueve | se conserva | se conserva | Volver a hacer los últimos N commits como uno |
| `--mixed` (default) | ✅ | se vacía | se conserva | Deshacer commits y volver a elegir qué agregar |
| `--hard` | ✅ | se vacía | **se descarta** | Tirar todo (recuperable con reflog, módulo 05) |

```bash
git reset --soft HEAD~3    # los 3 últimos commits quedan en staging -> un solo commit nuevo
git reset HEAD~1           # deshace el commit, los cambios quedan sin agregar
git reset --hard ORIG_HEAD # vuelve a donde estabas antes del último reset/merge/rebase
```

## 3. `revert`: deshacer sin reescribir

Crea un commit **nuevo** que invierte otro. Es la forma segura de deshacer en ramas compartidas.

```bash
git revert <commit>
git revert --no-edit HEAD~2..HEAD      # revierte un rango (un commit por cada uno)
git revert -n <a> <b> && git commit    # varios reverts en un solo commit
git revert -m 1 <merge>                # revertir un merge: -m indica qué padre es la "línea principal"
```

## 4. `rebase -i`: el editor de historia

```bash
git rebase -i main        # edita los commits de esta rama que no están en main
git rebase -i HEAD~5      # edita los últimos 5
```

En el editor, cada línea es un commit (**el más antiguo arriba**):

| Comando | Qué hace |
|---|---|
| `pick` | Deja el commit como está |
| `reword` (`r`) | Deja el commit y cambia el mensaje |
| `edit` (`e`) | Se detiene en el commit para modificarlo (`commit --amend`, dividirlo…) |
| `squash` (`s`) | Lo junta con el anterior y combina los mensajes |
| `fixup` (`f`) | Lo junta con el anterior y **descarta** su mensaje |
| `drop` (`d`) | Elimina el commit |
| `exec` (`x`) | Ejecuta un comando (p. ej. tests) en ese punto |

Si cambias el orden de las líneas, cambias el orden de los commits.

```bash
git rebase --continue    # tras resolver un conflicto o terminar un "edit"
git rebase --skip        # descarta el commit actual
git rebase --abort       # vuelve al estado anterior al rebase
```

**Dividir un commit** en dos: márcalo como `edit`, y cuando se detenga:

```bash
git reset HEAD~1
git add archivo1 && git commit -m "parte 1"
git add archivo2 && git commit -m "parte 2"
git rebase --continue
```

## 5. `fixup!` + `--autosquash`

```bash
git commit --fixup=<commit>      # crea "fixup! <mensaje del commit>"
git rebase -i --autosquash main  # lo coloca solo bajo su commit con la acción fixup
```

---

## Ejercicios

- [ ] Cambia el mensaje del último commit (`agrega estilos dle login`) con `--amend`.
- [ ] Usa `rebase -i main` para: juntar `wip` y `arreglo typo` en `agrega formulario de login` (fixup), juntar `wip 2 ahora si` en `agrega validacion de password`, y **eliminar** `agrega credenciales.env`.
- [ ] Durante el mismo rebase (o en otro), reescribe los mensajes restantes al formato *Conventional Commits* (`feat(login): ...`).
- [ ] Comprueba que `credenciales.env` ya no está en ninguna rama (`git log --all --oneline -- credenciales.env`), pero que **sigue existiendo** en el reflog (`git log --reflog --oneline -- credenciales.env`). Anota en tu bitácora por qué, si la contraseña ya se hubiera subido a un remoto, reescribir la historia no basta y hay que rotarla.
- [ ] Haz un cambio en `validacion.js`, créale un `commit --fixup` que apunte al commit de validación y aplícalo con `rebase -i --autosquash`.
- [ ] Usa `edit` para **dividir** un commit en dos.
- [ ] En `main`, revierte `activa modo debug en producción` con `revert`.
- [ ] Practica los 3 modos de `reset` en una rama temporal y anota en tu bitácora qué pasó con staging y con el working dir en cada caso.
- [ ] Rompe algo a propósito con `reset --hard` y vuelve atrás con `ORIG_HEAD`.

### 🏆 Reto
- [ ] Usa `git rebase -i --exec "test -f login.html" main` para ejecutar una verificación después de cada commit reescrito. Luego haz que falle a propósito y observa cómo se detiene el rebase.

## Repaso

1. ¿Cuándo usar `revert` en lugar de `reset`?
2. ¿Qué diferencia hay entre `squash` y `fixup`?
3. Después de un rebase, ¿los commits tienen el mismo hash? ¿Por qué?

<details>
<summary>Respuestas</summary>

1. Cuando los commits ya son públicos o compartidos. `revert` agrega historia y no la reescribe.
2. `squash` combina los mensajes (te abre el editor). `fixup` se queda solo con el mensaje del commit anterior.
3. No. El hash depende del contenido, del padre, de la fecha, etc. Si cambia el padre o el contenido, es un commit distinto.
</details>
