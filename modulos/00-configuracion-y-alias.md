# 00 · Configuración y alias

> **Objetivo:** dejar Git configurado como lo tiene un dev senior: niveles de config, alias útiles y ajustes que ahorran tiempo en el resto del curso.

```bash
bash scripts/lab.sh 00
cd laboratorio/m00-config
```

---

## 1. Niveles de configuración

| Nivel | Flag | Archivo | Alcance |
|---|---|---|---|
| Sistema | `--system` | `<git>/etc/gitconfig` | Todos los usuarios |
| Global | `--global` | `~/.gitconfig` | Tu usuario |
| Local | `--local` (default) | `.git/config` | Solo este repo |
| Worktree | `--worktree` | `.git/config.worktree` | Solo un worktree |

El nivel más específico gana.

```bash
git config --list --show-origin          # todo + de qué archivo viene
git config --show-scope user.email       # ¿qué nivel define este valor?
git config --global --edit               # abre ~/.gitconfig en el editor
git config --unset --local user.name     # borra una clave
```

## 2. Ajustes recomendados

```bash
git config --global init.defaultBranch main
git config --global pull.rebase true          # pull = fetch + rebase (historial lineal)
git config --global fetch.prune true          # limpia ramas remotas borradas
git config --global rebase.autoStash true     # stash automático antes de rebase
git config --global rebase.autoSquash true    # respeta fixup!/squash! (módulo 02)
git config --global rerere.enabled true       # recuerda resoluciones de conflictos (módulo 03)
git config --global diff.colorMoved zebra     # colorea líneas movidas en el diff
git config --global merge.conflictStyle diff3 # muestra también el ancestro común en conflictos
git config --global core.editor "code --wait" # o "notepad", "vim"...
```

## 3. Alias

```bash
git config --global alias.st "status -sb"
git config --global alias.lg "log --graph --oneline --decorate --all"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.unstage "restore --staged"
git config --global alias.amend "commit --amend --no-edit"
# Alias que ejecuta un comando de shell (empieza con !)
git config --global alias.ramas '!git for-each-ref --sort=-committerdate refs/heads --format="%(committerdate:relative)%09%(refname:short)"'
```

Formatos de `log` que se usan mucho:

```bash
git log --pretty=format:"%h %ad | %s%d [%an]" --date=short
#  %h hash corto  %an autor  %ad fecha  %s asunto  %d refs (ramas/tags)
```

## 4. Configuración condicional (`includeIf`)

Usar otro email según la carpeta (trabajo vs. personal):

```ini
# ~/.gitconfig
[includeIf "gitdir:~/trabajo/"]
    path = ~/.gitconfig-trabajo
```

---

## Ejercicios

- [x] Ejecuta `git config --list --show-origin` y encuentra de qué archivo vienen tu `user.name` y tu `core.autocrlf`.
- [x] En el laboratorio, pon un `user.name` **local** distinto al global y confírmalo con `git config --show-scope user.name`.
- [x] Crea los alias `st`, `lg` y `last` y úsalos en el laboratorio.
- [x] Crea un alias `hist` que muestre el log con formato `hash fecha | mensaje [autor]` y fecha corta.
- [x] Activa `rerere.enabled`, `rebase.autoSquash` y `fetch.prune` a nivel global (los usarás más adelante).
- [x] Crea un alias de shell (`!`) que liste las ramas locales ordenadas por fecha del último commit.
- [x] Configura `includeIf` para que los repos dentro de `laboratorio/` usen el email `practica@curso.local` y compruébalo.

### 🏆 Reto
- [x] Crea el alias `git deshacer` que deshaga el último commit dejando los cambios en staging, y el alias `git limpiar-ramas` que borre las ramas locales ya fusionadas en `main` (sin borrar `main`).

<details>
<summary>💡 Pista del reto</summary>

`reset --soft HEAD~1` y `branch --merged main | grep -v ... | xargs git branch -d`.
</details>

## Repaso

1. ¿Qué nivel gana si `user.email` está en global y en local? R= local
2. ¿Qué hace `merge.conflictStyle diff3` y por qué ayuda? R= no lo se
3. ¿Por qué un alias que empieza con `!` se comporta distinto? R= se ejecuta un comando de shell

<details>
<summary>Respuestas</summary>

1. El local (el más específico).
2. En los conflictos muestra, además de "lo mío" y "lo suyo", la versión del ancestro común (`|||||||`). Así se ve qué cambió cada lado.
3. Se ejecuta como comando de shell, no como subcomando de git, y eso permite usar tuberías y otros programas.
</details>
