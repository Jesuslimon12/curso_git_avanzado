# 09 · Hooks y automatización

> **Objetivo:** automatizar validaciones con hooks de Git, versionarlos para todo el equipo y saber cuándo saltarlos.

```bash
bash scripts/lab.sh 09
cd laboratorio/m09-hooks
ls .git/hooks        # ejemplos *.sample que trae Git
```

---

## 1. Qué es un hook

Un script ejecutable en `.git/hooks/<nombre>` que Git ejecuta en ciertos momentos. Si sale con un código **≠ 0**, la operación se cancela (en los hooks "pre").

| Hook | Cuándo | Uso típico |
|---|---|---|
| `pre-commit` | Antes de crear el commit | Linter, formato, bloquear `console.log` |
| `prepare-commit-msg` | Antes de abrir el editor | Insertar el ticket de la rama en el mensaje |
| `commit-msg` | Tras escribir el mensaje | Validar Conventional Commits |
| `post-commit` | Tras el commit | Notificaciones |
| `pre-rebase` | Antes de un rebase | Impedir rebase de ramas protegidas |
| `pre-push` | Antes de push | Tests, bloquear push directo a `main` |
| `post-checkout` / `post-merge` | Tras cambiar de rama / merge | Reinstalar dependencias |

## 2. Ejemplos

**pre-commit**: bloquea `console.log` en lo que está en staging:

```bash
#!/usr/bin/env bash
if git diff --cached -U0 -- '*.js' | grep -E '^\+.*console\.log' ; then
  echo "❌ Quita los console.log antes de commitear"
  exit 1
fi
```

**commit-msg**: valida Conventional Commits (`$1` = archivo con el mensaje):

```bash
#!/usr/bin/env bash
patron='^(feat|fix|docs|style|refactor|test|chore)(\([a-z0-9-]+\))?!?: .{3,}'
if ! grep -qE "$patron" "$1"; then
  echo "❌ Formato inválido. Ejemplo: feat(login): agrega botón"
  exit 1
fi
```

**pre-push**: impide push directo a main (stdin: `<ref local> <sha> <ref remota> <sha>`):

```bash
#!/usr/bin/env bash
while read -r _ _ ref_remota _; do
  if [[ "$ref_remota" == "refs/heads/main" ]]; then
    echo "❌ No se permite push directo a main"; exit 1
  fi
done
```

## 3. Hooks versionados para el equipo

`.git/hooks` **no** se versiona. Solución:

```bash
mkdir .githooks            # ponlos aquí y commitéalos
git config core.hooksPath .githooks
chmod +x .githooks/*       # en Windows/Git Bash: git update-index --chmod=+x .githooks/*
```

(En proyectos Node se suele usar *husky* o *lefthook*, que hacen justamente esto.)

## 4. Saltar hooks (con responsabilidad)

```bash
git commit --no-verify     # salta pre-commit y commit-msg
git push --no-verify       # salta pre-push
```

---

## Ejercicios

- [ ] Crea un `pre-commit` que bloquee `console.log`. Prueba un commit que lo tenga (falla) y otro sin él (pasa).
- [ ] Crea un `commit-msg` que exija Conventional Commits. Prueba mensajes válidos e inválidos.
- [ ] Crea un `prepare-commit-msg` que, si la rama se llama `feature/ABC-123-algo`, ponga `[ABC-123]` al principio del mensaje.
- [ ] Mueve tus hooks a `.githooks/`, configura `core.hooksPath` y commitéalos.
- [ ] Crea un `pre-push` que impida hacer push a `main` (crea un bare `../m09-remoto.git` para probarlo).
- [ ] Salta un hook con `--no-verify` y anota en la bitácora cuándo estaría justificado.

### 🏆 Reto
- [ ] Haz un `pre-commit` que ejecute un "test" (`node -e` o un script bash) **solo sobre los archivos en staging**, sin incluir cambios que no se hayan agregado. Pista: `git stash push --keep-index --include-untracked`, ejecutar el test y luego `git stash pop`.

## Repaso

1. ¿Por qué los hooks de `.git/hooks` no le llegan al equipo al clonar?
2. ¿Qué hooks pueden cancelar la operación?
3. ¿Los hooks del cliente sirven como seguridad real?

<details>
<summary>Respuestas</summary>

1. Porque `.git/` no se versiona. Se resuelve con `core.hooksPath` y una carpeta versionada.
2. Los "pre" (`pre-commit`, `commit-msg`, `pre-push`, `pre-rebase`…), saliendo con un código distinto de 0.
3. No, se saltan con `--no-verify`. Las reglas obligatorias van en el servidor o en CI (branch protection, checks del PR).
</details>
