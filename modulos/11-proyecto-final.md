# 11 · Proyecto final: "Rescate del repo"

> **Objetivo:** usar todo el curso en un escenario realista y sin guía paso a paso. Aquí solo hay misiones. Los comandos ya los conoces.

```bash
bash scripts/lab.sh 11
cd laboratorio/m11-proyecto-final
```

**Situación:** llegas a un proyecto de inventario y encuentras:

- `bash pruebas.sh` **falla**: el cálculo de IVA está mal en `main`, pero en `v1.0.0` estaba bien.
- `feature/reportes` (de Marta) tiene commits `wip`, `fix typo`… y **choca** con `main` en el `README.md`.
- Luis dice que ayer hizo un hotfix `fix: evita stock negativo` en una rama… que ya no existe.
- Hay que publicar la versión **v2.0.0** hoy.

> Regla: no borres el laboratorio. Si algo sale mal, **recupéralo** (ese también es el examen).

---

## Misiones

- [ ] **1. Diagnóstico.** Describe el estado del repo en la bitácora: ramas, tags, cuántos commits hay desde `v1.0.0` y quién hizo cada uno (usa `log`, `shortlog` y `describe`).
- [ ] **2. Caza del bug.** Encuentra con `bisect run` el commit que rompió el IVA. Anota su hash y su autor.
- [ ] **3. Corrección segura.** Arregla el bug **sin reescribir `main`** y sin perder la operación `mitad` que se agregó en ese mismo commit (pista: `revert -n` + ajuste manual, o `restore -p`).
- [ ] **4. Rescate.** Recupera la rama `hotfix/stock-negativo` desde el reflog e intégrala en `main` con `cherry-pick -x`.
- [ ] **5. Limpieza.** Deja `feature/reportes` en 3 commits limpios con Conventional Commits (`rebase -i`).
- [ ] **6. Actualización.** Rebasa `feature/reportes` sobre `main` resolviendo el conflicto del README (activa antes `rerere`).
- [ ] **7. Integración.** Fusiona `feature/reportes` en `main` con `--no-ff`.
- [ ] **8. Hotfix en paralelo.** Sin hacer stash ni commit de nada en `main`, crea un `worktree` para la rama `hotfix/v1.0.1` basada en `v1.0.0`, arregla ahí el README y etiqueta `v1.0.1`.
- [ ] **9. Release.** Crea el tag anotado `v2.0.0` y genera `CHANGELOG.md` con los commits desde `v1.0.0` agrupados por tipo (`feat`, `fix`, `docs`…).
- [ ] **10. Calidad.** Agrega un hook `pre-commit` versionado en `.githooks/` que ejecute `pruebas.sh` y bloquee el commit si falla.
- [ ] **11. Publicación.** Crea un bare `../m11-remoto.git`, agrégalo como `origin`, sube `main`, las ramas y los tags.
- [ ] **12. Verificación.** Clona el remoto en otra carpeta y comprueba que `pruebas.sh` pasa, que el historial está limpio y que `git describe` devuelve `v2.0.0`.

### 🏆 Reto extra
- [ ] Repite el proyecto desde cero (`bash scripts/lab.sh 11`) en **menos de 30 minutos** y anota tu tiempo en la bitácora.

## Criterios de "completado"

- `pruebas.sh` pasa en `main`.
- `git log --oneline --graph` de `main` se entiende sin explicaciones.
- No se perdió ningún trabajo (hotfix, `mitad`, reportes).
- Tags `v1.0.0`, `v1.0.1` y `v2.0.0` presentes y anotados.
