# 10 · Internals de Git

> **Objetivo:** entender qué hay dentro de `.git`: objetos, refs y cómo un commit es solo un archivo que apunta a otros. Con esto, todo lo anterior deja de ser magia.

```bash
bash scripts/lab.sh 10
cd laboratorio/m10-internals
```

---

## 1. Los 4 tipos de objeto

| Tipo | Contiene |
|---|---|
| **blob** | Contenido de un archivo (sin nombre) |
| **tree** | Lista de entradas: modo, tipo, hash, nombre (un directorio) |
| **commit** | tree raíz + padre(s) + autor + committer + mensaje |
| **tag** (anotado) | Objeto + tipo + nombre + tagger + mensaje |

Cada objeto se identifica por el hash de su contenido (SHA-1 por defecto).

```bash
git cat-file -t HEAD            # tipo
git cat-file -p HEAD            # contenido "bonito"
git cat-file -p HEAD^{tree}
git cat-file -p HEAD:saludo.txt
git ls-tree -r HEAD             # árbol completo
git rev-parse HEAD:docs         # hash del tree de docs/
git count-objects -vH           # cuántos objetos y cuánto ocupan
```

## 2. Refs: nombres que apuntan a hashes

```bash
cat .git/HEAD                   # ref: refs/heads/main  (ref simbólica)
cat .git/refs/heads/main        # un hash
git show-ref
git symbolic-ref HEAD
git update-ref refs/heads/nueva HEAD~1     # crea una rama "a mano"
cat .git/packed-refs            # refs empaquetadas
```

## 3. Plumbing: crear un commit sin `git commit`

```bash
echo "contenido manual" | git hash-object -w --stdin   # crea un blob -> <hash-blob>
git update-index --add --cacheinfo 100644,<hash-blob>,manual.txt
git write-tree                                          # crea el tree del index -> <hash-tree>
echo "commit a mano" | git commit-tree <hash-tree> -p HEAD   # -> <hash-commit>
git update-ref refs/heads/main <hash-commit>
```

## 4. Almacenamiento y mantenimiento

```bash
find .git/objects -type f | head         # objetos sueltos (zlib)
git gc                                    # empaqueta objetos en .git/objects/pack
git verify-pack -v .git/objects/pack/*.idx | head
git fsck                                  # verifica la integridad
git maintenance run                       # tareas de mantenimiento modernas
```

---

## Ejercicios

- [ ] Recorre a mano la cadena `HEAD` → `refs/heads/main` → commit → tree → blob de `saludo.txt` usando solo `cat` y `git cat-file -p`.
- [ ] Calcula el hash de `"hola mundo\n"` con `git hash-object` y comprueba que coincide con el blob de `saludo.txt`. ¿Por qué coincide?
- [ ] Modifica `saludo.txt`, haz `git add` (sin commit) y encuentra el nuevo blob en `.git/objects`.
- [ ] Crea un commit **completo** usando solo plumbing (`hash-object`, `update-index`, `write-tree`, `commit-tree`, `update-ref`) y comprueba con `git log` que aparece.
- [ ] Crea una rama escribiendo el hash directamente en `.git/refs/heads/a-mano` y comprueba que `git branch` la muestra.
- [ ] Ejecuta `count-objects -v`, luego `git gc`, y compara el resultado. Revisa el pack con `verify-pack`.
- [ ] Crea un tag anotado y encuentra su objeto con `cat-file -p`.

### 🏆 Reto
- [ ] Explica en la bitácora, con tus palabras y con lo que viste en este módulo, qué hacen internamente `git branch`, `git commit`, `git reset --soft` y `git rebase` (en términos de objetos y refs).

## Repaso

1. ¿Por qué dos archivos con el mismo contenido ocupan un solo blob?
2. ¿Qué es realmente una rama?
3. ¿Por qué cambiar un commit antiguo cambia el hash de todos los que vienen después?

<details>
<summary>Respuestas</summary>

1. El hash depende solo del contenido. Mismo contenido, mismo hash, mismo objeto.
2. Un archivo con el hash de un commit (`refs/heads/<nombre>`).
3. Cada commit contiene el hash de su padre. Si cambia el padre, cambia el contenido del hijo, y con él su hash, y así hasta el final de la cadena.
</details>
