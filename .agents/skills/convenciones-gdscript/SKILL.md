---
name: convenciones-gdscript
description: Guía de estilo y checklist de revisión para GDScript en Spooky World (Godot 4.7). Úsala siempre que escribas, modifiques o revises un archivo .gd.
---

# Convenciones GDScript de Spooky World

Base: la guía oficial de estilo de Godot 4 más las reglas del proyecto.
El formato lo fija `gdformat`; las reglas, `gdlint` (configurado en `gdlintrc`, líneas de máximo 100).

## Orden dentro de un script

```gdscript
class_name Ghost              # solo si otros scripts lo usan como tipo
extends Area2D
## Una línea de qué es esto. Dueño si es un minijuego.

signal whacked(ghost: Ghost)

const FADE_SEC: float = 0.1

@export var lifetime: float = 1.2

var is_friendly: bool = false
var _done: bool = false

@onready var _visual: ColorRect = %Visual


func _ready() -> void:            # callbacks de Godot primero
	...


func hide_away() -> void:         # métodos públicos
	...


func _on_input_event(...) -> void:  # privados y handlers al final
	...
```

Dos líneas en blanco entre funciones. Indentación con tabs.

## Nombres

| Qué | Estilo | Ejemplo |
| --- | --- | --- |
| Archivos `.gd`, `.tscn`, carpetas | snake_case | `ghost_whack.gd` |
| `class_name`, nodos en escenas | PascalCase | `Ghost`, `SpawnTimer` |
| Variables, funciones, señales | snake_case | `fall_speed`, `add_score()`, `score_changed` |
| Constantes y enums | MAYÚSCULAS | `MAX_SPEED` |
| Privados | prefijo `_` | `_spawn_timer`, `_clear()` |
| Handlers de señales | `_on_<emisor>_<señal>` | `_on_basket_area_entered` |
| Señales | verbo en pasado | `finished`, `whacked` |

## Tipado (obligatorio)

- Todas las variables, parámetros y retornos llevan tipo: `var speed: float = 200.0`, `func hit(damage: int) -> void:`.
- `:=` solo cuando el tipo es obvio a la vista: `var ghost := GHOST_SCENE.instantiate() as Ghost`.
- Arrays y diccionarios tipados: `Array[Marker2D]`, `Dictionary[StringName, int]`.
- Casteos con `as` y luego comprobar `null`.
- En `for`, tipa la variable: `for child: Node in get_children():`.
- El proyecto avisa (warning) de declaraciones sin tipo y accesos inseguros: no los ignores.

## Arquitectura

- **Call down, signal up**: el padre llama métodos de sus hijos; los hijos emiten señales y no conocen a su padre.
- Nodos por `%NombreUnico` (marcar "Access as Unique Name") o `@export var x: Node`. Nunca `get_node("../..")` ni rutas largas.
- Grupos (`add_to_group`) para afectar a muchos nodos a la vez.
- Nada de globales nuevos. Los únicos autoloads son `GameManager`, `SceneLoader` y `AudioManager`.
- Los minijuegos no usan autoloads de navegación; ver el contrato en `AGENTS.md`.
- Valores ajustables como `@export`, agrupados con `@export_group("Dificultad")` y `@export_group("Puntaje")`.
- Colores desde `Palette`, no `Color(...)` sueltos en código.

## Física, input y tiempo

- Movimiento en `_physics_process(delta)`, multiplicado por `delta`.
- Input solo por acciones: `Input.get_axis("move_left", "move_right")`, `Input.get_vector(...)`, `event.is_action_pressed("action")`.
- Timers con nodo `Timer` o `get_tree().create_timer()`; nunca contar frames.
- `queue_free()` para borrar; nunca `free()` de un nodo en la escena durante física.
- `preload()` en una constante para escenas que se instancian seguido.

## Comentarios

- `##` (doc comment) arriba de la clase y de cada método o variable pública no obvia.
- `#` para explicar el *por qué*, no el *qué*.
- Comentarios en español; identificadores en inglés.

## Checklist de revisión

- [ ] Todo tipado; sin warnings nuevos en el editor.
- [ ] Sin rutas de nodo largas; sin `get_parent()` para llegar a hermanos.
- [ ] Input por acciones; física con `delta`.
- [ ] Si es minijuego: `if not is_running: return` en los callbacks por frame, y `_on_start()` deja todo reiniciado.
- [ ] Sin cambios de escena fuera de `SceneLoader`.
- [ ] `gdlint` y `gdformat --check` pasan.
