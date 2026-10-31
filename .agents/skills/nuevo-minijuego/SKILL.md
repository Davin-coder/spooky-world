---
name: nuevo-minijuego
description: Crea un minijuego nuevo de Spooky World a partir de la plantilla, con su escena, script, ficha minigame_info.tres y prueba. Úsala cuando pidan agregar, crear o arrancar un minijuego.
---

# Crear un minijuego nuevo

Un minijuego vive entero en `scenes/minigames/<id>/` y el hub lo descubre solo.
**No hay que tocar ningún archivo compartido.**

## 1. Definir antes de escribir código

Pide o propone estos datos (si faltan, usa valores razonables y dilo):

- `id` en `snake_case` (por ejemplo `bat_dodge`). Es el nombre de la carpeta.
- Nombre visible, una línea de descripción e instrucciones de una frase.
- Mecánica en una oración, controles (acciones del Input Map) y duración (30–60 s).
- Cómo se gana y se pierde puntaje.
- Dueño (Dev 1 o Dev 2).

Alcance: se debe poder construir en **unas 2 horas**. Si no cabe, recórtalo antes de empezar.

## 2. Copiar la plantilla

```
scenes/minigames/_template/  →  scenes/minigames/<id>/
  template_minigame.gd       →  <id>.gd
  template_minigame.tscn     →  <id>.tscn
  minigame_info.tres         →  minigame_info.tres
```

Después de copiar, actualiza las rutas dentro de los archivos:

- En `<id>.tscn`: la ruta `res://` del `ext_resource` del script y el `name` del nodo raíz (PascalCase, por ejemplo `BatDodge`).
- En `minigame_info.tres`: `id = &"<id>"`, `display_name`, `description`, `instructions`, `scene_path = "res://scenes/minigames/<id>/<id>.tscn"`, `order`, `maintainer` y `enabled = true`.
- Borra el comentario "PLANTILLA" del script y escribe un `##` con qué es el minijuego y su dueño.

Con el MCP de Godot puedes crear la escena desde el editor; el resultado debe quedar igual.

## 3. Implementar respetando el contrato

```gdscript
extends Minigame
## Bat Dodge: esquiva murciélagos. Dueño: Dev 1.

const BAT_SCENE: PackedScene = preload("res://scenes/minigames/bat_dodge/bat.tscn")

@export_group("Dificultad")
@export var spawn_interval_start: float = 1.0
@export var spawn_interval_end: float = 0.4

@onready var _spawn_timer: Timer = %SpawnTimer


func _ready() -> void:
	_spawn_timer.timeout.connect(_spawn_bat)


func _on_start() -> void:
	_spawn_timer.start(spawn_interval_start)


func _on_end() -> void:
	_spawn_timer.stop()


func _physics_process(delta: float) -> void:
	if not is_running:
		return
	# ...


func _spawn_bat() -> void:
	# ...
	_spawn_timer.wait_time = lerpf(spawn_interval_start, spawn_interval_end, get_progress())
```

Reglas:

- `_on_start()` deja todo en su estado inicial: debe poder jugarse dos veces seguidas ("Otra vez").
- `_on_end()` detiene timers y limpia objetos creados.
- Puntos con `add_score()`; fin anticipado (por ejemplo, el jugador muere) con `end_game()`.
- Nada de `GameManager`, `SceneLoader` ni cambios de escena dentro del minijuego.
- Objetos que se repiten (enemigos, items) van en su propia escena `.tscn` dentro de la misma carpeta, con su script y `class_name` en PascalCase.
- Placeholders con `ColorRect` y colores de `Palette` hasta que llegue el arte.
- Capas de física: 1 player, 2 collectibles, 3 enemies, 4 world.
- Si usas clics sobre `Area2D`, activa `get_viewport().physics_object_picking = true` en `_ready()`.

## 4. Probar

1. **F6** con la escena del minijuego abierta: arranca sola sin host y el puntaje sale en la consola.
2. **F5**: Menú → Hub → el minijuego aparece en el hub → Resultados → "Otra vez" funciona.
3. Panel Debugger → Errors: cero errores.
4. `gdlint` y `gdformat --check` sobre los `.gd` nuevos.
5. Opcional: `godot --headless --path . -s res://tools/smoke_test.gd`.

## 5. Entregar

- Commit en `feat/<id>`: `<id>: agrega minijuego jugable con placeholders`.
- Si no está jugable al congelar features (4 h 30), deja `enabled = false` y haz merge igual.
