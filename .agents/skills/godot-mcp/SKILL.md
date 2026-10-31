---
name: godot-mcp
description: Cómo trabajar con el editor de Godot a través del MCP de Godot (@coding-solo/godot-mcp) en este proyecto, con pedidos pequeños, ejecutar, leer errores y corregir. Úsala cuando vayas a crear escenas o nodos, ejecutar el juego o depurar con el MCP.
---

# Trabajar con el MCP de Godot

El equipo usa el servidor **`@coding-solo/godot-mcp`** con **Godot 4.7.2** (`Godot_console.exe`).
Para Codex se configura en `.codex/config.toml`, que está en `.gitignore` porque tiene rutas de cada máquina:

```toml
[mcp_servers.godot]
command = 'C:\Program Files\nodejs\node.exe'
args = ['<ruta>\godot-mcp\node_modules\@coding-solo\godot-mcp\build\index.js']
cwd = '<ruta>\spooky-world'
startup_timeout_sec = 30

[mcp_servers.godot.env]
GODOT_PATH = '<ruta>\Godot\4.7.2\Godot_console.exe'
```

El MCP acelera lo repetitivo. Las decisiones de diseño y la "sensación" del juego las ajusta el equipo.

## Herramientas habituales del servidor

Confirma la lista real al empezar; puede cambiar según la versión del servidor.

| Herramienta | Para qué |
| --- | --- |
| `get_godot_version`, `get_project_info` | Comprobar que el MCP ve el proyecto y la versión correcta |
| `launch_editor` | Abrir el editor con este proyecto |
| `run_project` | Ejecutar el juego (o una escena concreta, si el servidor lo permite) |
| `get_debug_output` | Leer la salida y los errores de la ejecución |
| `stop_project` | Detener la ejecución |
| `create_scene`, `add_node`, `save_scene` | Crear escenas y nodos |
| `load_sprite` | Asignar una textura a un `Sprite2D` |
| `get_uid`, `update_project_uids` | Revisar o regenerar los UID de recursos |

El MCP **no** reemplaza leer y editar archivos: los scripts `.gd` se escriben como archivos normales siguiendo `convenciones-gdscript`.

## Al empezar la sesión (una vez)

1. `get_godot_version` debe responder **4.7.2**. Si no, revisa `GODOT_PATH`.
2. `get_project_info` sobre este repo.
3. `run_project` y luego `get_debug_output`: debe aparecer `[GameManager] Minijuegos encontrados: N`. Termina con `stop_project`.
4. Si algo falla, avisa al equipo. No pierdas más de 10 minutos arreglándolo: se puede seguir a mano en el editor.

## Ciclo de trabajo

1. **Entender**: lee `AGENTS.md` y la skill que aplique (`nuevo-minijuego`, `editar-escenas-tscn`...).
2. **Pedido pequeño**: un cambio verificable por vez (un nodo, una mecánica, un arreglo).
3. **Hacer**: edita archivos o usa las herramientas del MCP, respetando las convenciones.
4. **Ejecutar**: `run_project`.
5. **Leer la salida**: `get_debug_output`. Corrige errores y warnings antes de seguir. Después, `stop_project`.
6. **Reportar**: qué cambió, en qué archivos y qué falta.

Prueba de humo sin abrir ventana, desde la raíz del repo:

```powershell
& "$env:GODOT_PATH" --headless --path . -s res://tools/smoke_test.gd
```

## Reglas

- Trabaja solo dentro de la carpeta del minijuego que se te pidió, salvo que te pidan explícitamente otra cosa.
- No modifiques `project.godot`, `autoload/` ni `shared/` sin confirmación del dueño (Dev 1).
- Antes de cambios grandes, sugiere hacer commit.
- Si `create_scene` o `save_scene` generan una escena, revisa que respete `editar-escenas-tscn` (nombres, `%Unique`, rutas `res://`).
- No borres archivos; si algo sobra, pregunta.
- Si una herramienta del MCP falla dos veces seguidas, cambia de estrategia (edita el archivo a mano y recarga en el editor) en lugar de reintentar.
- No versionar `.codex/config.toml`.

## Pedidos que funcionan bien

- "Crea `scenes/minigames/bat_dodge/` desde la plantilla siguiendo la skill nuevo-minijuego, con un jugador `CharacterBody2D` que se mueve con `move_left`/`move_right` y murciélagos que cruzan la pantalla. Placeholders con `Palette`."
- "Ejecuta el proyecto, entra a Ghost Whack y dime qué errores salen en la salida de depuración."
- "Los fantasmas aparecen muy rápido al final: sube `spawn_interval_end` a 0.5 y prueba."
- "Reemplaza el `ColorRect` de la canasta por `assets/art/pumpkin_catch/pumpkin_catch_basket.png` siguiendo la skill integrar-assets."

## Depuración rápida

| Síntoma | Causa probable |
| --- | --- |
| `Invalid get index ... on base 'null instance'` con `%Algo` | Al nodo le falta "Access as Unique Name" o el nombre no coincide |
| El minijuego no aparece en el hub | `minigame_info.tres` con `enabled = false`, `id` distinto a la carpeta o `scene_path` mal |
| Los clics en `Area2D` no hacen nada | Falta `get_viewport().physics_object_picking = true`, o un `Control` encima con `mouse_filter` en Stop |
| No detecta colisiones | Capas o máscaras mal (1 player, 2 collectibles, 3 enemies, 4 world) |
| La partida no termina | `duration_sec = 0` y nunca se llama `end_game()` |
| "Otra vez" arranca en estado raro | `_on_start()` no reinicia todo |
| `Identifier "X" not declared` con un `class_name` | Abre el proyecto en el editor una vez para regenerar la caché de clases |
