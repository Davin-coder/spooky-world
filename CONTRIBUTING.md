# Cómo trabajamos

Las escenas de Godot (`.tscn`) se mezclan mal en Git. La regla principal es: **cada carpeta tiene un dueño y nadie edita la escena de otro.**

## Dueños

| Área | Dueño |
| --- | --- |
| `project.godot`, `autoload/`, `shared/`, menú, hub, resultados, host | Dev 1 |
| `scenes/minigames/ghost_whack/` | Dev 1 |
| `scenes/minigames/pumpkin_catch/`, `scenes/minigames/haunted_maze/` | Dev 2 |
| `assets/art/<id>/` | Diseñador 1 entrega; importa el dueño del minijuego |
| `assets/art/ui/`, `assets/audio/`, `assets/fonts/` | Diseñador 2 entrega; importa Dev 1 |

Cambios en `project.godot` (Input Map, autoloads, capas, ajustes) se piden a Dev 1.

## Ramas y commits

- `main` siempre jugable.
- Una rama por trabajo: `feat/<id>`, `fix/<id>-<qué>`, `art/<id>`.
- Commits pequeños con formato `<área>: <qué>` en español:
  - `pumpkin_catch: agrega spawner de calabazas`
  - `hub: muestra el récord en cada tarjeta`
- Merge a `main` **al menos una vez por hora**. Antes: `git pull`, abrir el proyecto, F5 y confirmar que funciona.

## Conflictos

- En `.gd`: se resuelven normal.
- En `.tscn` o `.tres`: **no se mezclan a mano.** Se conserva la versión del dueño y el otro rehace su cambio en el editor.
- Si `main` se rompe: revertir al último commit jugable (`git revert`) y rehacer.

## Antes de hacer merge

- [ ] Abre sin errores en el Debugger.
- [ ] F5 recorre el flujo completo.
- [ ] `gdlint` y `gdformat --check` pasan.
- [ ] No se tocaron archivos de otro dueño.

## Sincronización

Cada hora, 5 minutos: qué funciona, qué está bloqueado y qué se corta.
