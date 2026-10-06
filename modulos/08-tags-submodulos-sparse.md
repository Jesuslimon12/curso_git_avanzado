# 08 · Tags, submódulos y sparse-checkout

> **Objetivo:** versionar releases con tags, depender de otro repo con submódulos o subtree y trabajar solo con una parte de un monorepo.

```bash
bash scripts/lab.sh 08
cd laboratorio/m08-tags-submodulos/app
```

- `app/`: monorepo con `frontend/`, `backend/`, `docs/` e `infra/`, 9 commits y **ningún tag**.
- `libreria/`: repo independiente con utilidades en shell.

---

## 1. Tags

```bash
git tag v0.1.0                          # ligero: solo un puntero
git tag -a v1.0.0 -m "Release 1.0.0"    # anotado: objeto con autor, fecha y mensaje (usa este)
git tag -a v0.5.0 <commit> -m "..."     # etiquetar un commit pasado
git tag -l "v1.*"                       # listar con patrón
git tag --sort=-v:refname               # ordenar por versión semántica
git show v1.0.0
git tag -d v0.1.0                       # borrar local
git push origin v1.0.0 / --tags         # subir
git push origin --delete v0.1.0         # borrar remoto
git describe --tags                     # v1.0.0-2-g1a2b3c: tag + commits desde el tag + hash
git describe --tags --abbrev=0          # solo el último tag
git log v1.0.0..v1.1.0 --oneline        # cambios entre releases
git tag -s v1.0.0 -m "..."              # firmado con GPG/SSH (opcional)
git tag --contains <commit>             # ¿en qué releases está este commit?
```

## 2. Submódulos

Un repo dentro de otro, fijado a un commit concreto.

```bash
git submodule add ../libreria libs/libreria
git submodule status
git submodule update --init --recursive     # tras clonar un repo que tiene submódulos
git clone --recurse-submodules <url>
git submodule update --remote               # mueve el submódulo al último commit de su rama
git submodule foreach 'git log -1 --oneline'
git submodule deinit libs/libreria && git rm libs/libreria   # quitarlo
```

> ⚠️ Desde Git 2.38.1 los submódulos con ruta local están bloqueados por seguridad. En este laboratorio, antepón `-c protocol.file.allow=always`:
> `git -c protocol.file.allow=always submodule add ../libreria libs/libreria`

## 3. Subtree (alternativa sin `.gitmodules`)

```bash
git subtree add --prefix=libs/libreria ../libreria main --squash
git subtree pull --prefix=libs/libreria ../libreria main --squash
```

## 4. Sparse-checkout (monorepos)

```bash
cd ..   # desde laboratorio/m08-tags-submodulos
git clone --no-checkout app app-frontend && cd app-frontend
git sparse-checkout init --cone
git sparse-checkout set frontend docs
git checkout main
git sparse-checkout list
git sparse-checkout add backend
git sparse-checkout disable
```

---

## Ejercicios

- [ ] Crea un tag **ligero** y uno **anotado** y compara lo que muestra `git show` en cada caso (y `git cat-file -t` de cada uno).
- [ ] Etiqueta como `v0.1.0` el commit `feat(backend): ruta usuarios` (sin checkout) y como `v0.2.0` el último.
- [ ] Usa `git describe --tags` en varios commits y explica el formato de la salida.
- [ ] Lista los commits entre `v0.1.0` y `v0.2.0` y genera un changelog agrupado por autor.
- [ ] ¿Qué releases contienen el commit `feat(infra): servidor`? (`tag --contains`).
- [ ] Agrega `libreria` como submódulo en `libs/libreria` y revisa `.gitmodules` y `git submodule status`.
- [ ] Haz un commit nuevo en `libreria` y actualiza el submódulo en `app` para que apunte a él. ¿Qué cambio aparece en `git diff` de `app`?
- [ ] Clona `app` a `app-clon` y observa que el submódulo llega vacío; arréglalo con `submodule update --init`.
- [ ] Haz un clon sparse que solo tenga `frontend/` y `docs/`. Añade `backend/` después.

### 🏆 Reto
- [ ] En una rama aparte, quita el submódulo y en su lugar integra `libreria` con `git subtree add --squash`. Anota en la bitácora ventajas y desventajas de cada enfoque.

## Repaso

1. ¿Por qué se recomiendan los tags anotados para releases?
2. ¿Qué guarda realmente el repo padre de un submódulo?
3. ¿Qué problema resuelve sparse-checkout?

<details>
<summary>Respuestas</summary>

1. Guardan autor, fecha y mensaje, se pueden firmar, y `git describe` los usa por defecto (los ligeros requieren `--tags`).
2. Una entrada especial (gitlink) con el **hash del commit** del submódulo, más la URL en `.gitmodules`.
3. En un monorepo grande, poder tener en el working dir solo las carpetas en las que trabajas.
</details>
