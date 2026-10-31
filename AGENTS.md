# Spooky World — contexto para agentes de IA

Este archivo lo leen Codex, Claude y cualquier agente que trabaje en el repo.
`CLAUDE.md` lo importa. **Léelo completo antes de cambiar algo.**

## Qué es

Spooky World es una colección de minijuegos de Halloween hecha en una
**hackatón de 6 horas** por **2 devs y 2 diseñadores**.
Flujo del juego: Menú → Hub (elige minijuego) → Minijuego (con HUD y cuenta
regresiva) → Resultados → Hub.

- Motor: **Godot 4.7**, **GDScript** con tipado estático, renderer *GL Compatibility*.
- Resolución base 1280×720, stretch `canvas_items`, aspect `keep`.
- El editor se controla con el **MCP `@coding-solo/godot-mcp`** desde Codex o Claude (ver skill `godot-mcp`).
- Plan completo y cronograma: [`docs/PLAN.md`](docs/PLAN.md).

## Prioridad absoluta: que siempre sea jugable

1. `main` siempre abre y se juega de principio a fin.
2. Una mecánica jugable con cuadros de color vale más que arte sin lógica.
3. A las **4 h 30** se congelan las features: después, solo bugs, pulido y export.
4. Si algo no es jugable a tiempo, se pone `enabled = false` en su `minigame_info.tres`; no se borra.

## Mapa del repo

```
autoload/            Singletons. ÚNICOS globales permitidos.
  game_manager.gd    Sesión, puntajes, descubrimiento de minijuegos, navegación.
  scene_loader.gd    Cambio de escena con fundido. Único que llama change_scene_*.
  audio_manager.gd   Música y efectos (buses Music y SFX).
shared/              Código y escenas reutilizables.
  minigame.gd        class_name Minigame: CONTRATO de todos los minijuegos.
  minigame_info.gd   class_name MinigameInfo: ficha (.tres) de cada minijuego.
  palette.gd         class_name Palette: colores oficiales. No uses colores sueltos.
  hud/               HUD común (puntaje, tiempo, cuenta regresiva).
scenes/
  main_menu/ hub/ results/      Pantallas del flujo.
  minigame_host/                Instancia el minijuego, le pone HUD, reporta puntaje.
  minigames/<id>/               UNA carpeta por minijuego, autocontenida.
    <id>.tscn / <id>.gd         Escena raíz (extiende Minigame) y su script.
    minigame_info.tres          Ficha. GameManager la descubre sola.
  minigames/_template/          Plantilla para copiar (carpetas con "_" se ignoran).
assets/
  art/<id>/ art/ui/  audio/music/ audio/sfx/  fonts/
tools/smoke_test.gd  Prueba de humo headless.
docs/                Plan, arquitectura y especificación de assets.
.agents/skills/      Procedimientos paso a paso (sirven para cualquier agente).
```

## Minijuegos actuales

| id | Nombre | Dueño | Estado |
| --- | --- | --- | --- |
| `pumpkin_catch` | Pumpkin Catch | Dev 2 | MVP prioritario |
| `ghost_whack` | Ghost Whack | Dev 1 | MVP |
| `haunted_maze` | Haunted Maze | Dev 2 | **Opcional**: lo primero que se corta |
| `zombie_outbreak` | Última guardia | Dev 1 | Arcade pixel art, jugable |

La ampliación pixel art fue solicitada por el usuario después del MVP. Ver
`docs/PIXEL_ART.md` y `docs/ZOMBIE_OUTBREAK.md`. La colección ilustrada conserva
su presentación. El juego pixel usa HUD propio (`use_shared_hud = false`),
`set_game_paused()` para el reloj, `exit_requested` para abandonar y una escena
opcional de resultados que extiende `MinigameResults`. No añade autoloads.
Sus acciones específicas son `zombie_fire`, `zombie_reload` y `zombie_dash`.

## El contrato de minijuego (no romperlo)

- La raíz de la escena **extiende `Minigame`** (`shared/minigame.gd`).
- Lógica de inicio en `_on_start()`, de cierre en `_on_end()`. No sobreescribas `start()` ni `end_game()`.
- Puntos con `add_score(n)` (negativo resta). Fin anticipado con `end_game()`.
- Lógica por frame en `_process` / `_physics_process`, **siempre** con `if not is_running: return` al inicio.
- Un minijuego **no** cambia de escena, **no** usa `GameManager`, **no** conoce el hub ni a otros minijuegos. Solo emite señales (las emite la base).
- Dificultad progresiva con `get_progress()` (0 → 1 según el tiempo **transcurrido**; sumar tiempo no la baja).
- Vidas (opcional): `max_lives = N` en la escena (0 = sin vidas). `lose_life()` resta una y, con la última,
  termina la partida (`out_of_lives`). `add_life()` suma una, sin pasar de `max_lives`. El HUD las dibuja solo.
- Tiempo extra: `add_time(segundos)` sube el reloj y el HUD muestra "+N s". Sin efecto si `duration_sec = 0`.
- No declares en tu minijuego miembros con nombres de la base (`max_lives`, `lives`, `score`…): es error de parseo.
- Valores de ajuste como `@export` (agrupados con `@export_group`) para que diseño los cambie en el Inspector.
- Se prueba solo con **F6**: la base detecta que corre sin host y arranca sola.

Para crear uno: skill [`nuevo-minijuego`](.agents/skills/nuevo-minijuego/SKILL.md).

## Reglas de código (resumen; detalle en la skill `convenciones-gdscript`)

- **Tipado estático en todo**: variables, parámetros y retornos (`var speed: float = 200.0`, `func hit(damage: int) -> void`).
- Nombres: `snake_case` en archivos, variables y funciones; `PascalCase` en `class_name` y nodos; `CONSTANTES` en mayúsculas; privados con `_`.
- Orden del script: `class_name`, `extends`, `##` doc, señales, constantes, `@export`, variables, `@onready`, callbacks de Godot, métodos públicos, privados.
- "Call down, signal up": el padre llama métodos de sus hijos; los hijos emiten señales.
- Referencias a nodos con `%NombreUnico` o `@export`. **Nunca** rutas como `get_node("../../X")`.
- Input solo por acciones: `move_left`, `move_right`, `move_up`, `move_down`, `action`, `back`. Nunca teclas fijas.
- Movimiento y física en `_physics_process`, siempre multiplicado por `delta`.
- Escenas que se instancian muchas veces: `const X: PackedScene = preload(...)`.
- Borrar nodos con `queue_free()`, nunca `free()` en medio de la física.
- Colores desde `Palette`. Capas de física: 1 player, 2 collectibles, 3 enemies, 4 world.
- Textos visibles en español; código, archivos y nodos en inglés.
- Sin dependencias ni addons nuevos sin acordarlo con el equipo.

## Reglas de equipo y archivos

- **Cada carpeta tiene dueño.** Dev 1: `autoload/`, `shared/`, `scenes/{main_menu,hub,results,minigame_host}`, `project.godot`, `ghost_whack`. Dev 2: `pumpkin_catch`, `haunted_maze`.
- **No edites escenas (`.tscn`) de otro dueño.** Si lo necesitas, pídeselo.
- `project.godot` (Input Map, autoloads, capas) solo lo toca Dev 1.
- Agregar un minijuego **no** requiere tocar archivos compartidos: basta su carpeta y su `minigame_info.tres`.
- Assets: `snake_case`, en inglés, con prefijo del minijuego (`pumpkin_catch_basket.png`). Ver [`docs/ASSETS.md`](docs/ASSETS.md).
- Git: ramas `feat/<id>`, commits pequeños `<área>: <qué>`, merge a `main` al menos 1 vez por hora. Ver [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Cómo verificar un cambio

1. `gdlint $(git ls-files '*.gd')` y `gdformat --check $(git ls-files '*.gd')` (instalar con `pip install "gdtoolkit==4.*"`).
2. Abrir en el editor, revisar el panel **Debugger → Errors**: cero errores en rojo.
3. Probar el minijuego solo con **F6** y luego el flujo completo con **F5**.
4. Prueba de humo: `godot --headless --path . -s res://tools/smoke_test.gd` → debe imprimir `SMOKE TEST OK`.

## Qué NO hacer

- No crear nuevos autoloads ni variables globales.
- No llamar `get_tree().change_scene_*` fuera de `SceneLoader`.
- No reestructurar carpetas ni renombrar archivos de otros.
- No editar `.godot/` (es caché, está ignorado) ni archivos `.import` a mano.
- No mezclar a mano conflictos en `.tscn`: se conserva la versión del dueño.
- No agregar guardado a disco, multijugador, localización ni opciones avanzadas (fuera de alcance).

## Skills disponibles (`.agents/skills/`)

| Skill | Cuándo usarla |
| --- | --- |
| `nuevo-minijuego` | Crear un minijuego desde la plantilla |
| `convenciones-gdscript` | Escribir o revisar cualquier `.gd` |
| `editar-escenas-tscn` | Crear o modificar `.tscn` / `.tres` (a mano o por MCP) |
| `integrar-assets` | Reemplazar placeholders por arte o audio de diseño |
| `godot-mcp` | Trabajar con el editor a través del MCP de Godot |
| `entrega-export` | Exportar y preparar la entrega final |
| `pixel-art-godot` | Crear o integrar contenido en la colección pixel art |
| `zombie-outbreak` | Combate, balance, audio y pruebas de Última guardia |
