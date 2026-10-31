extends Minigame
## PLANTILLA de minijuego. No editar aquí: copiar la carpeta _template a
## scenes/minigames/<id>/ y seguir la skill .agents/skills/nuevo-minijuego.
##
## Checklist rápido:
## 1. Renombrar archivos: <id>.gd, <id>.tscn y ajustar minigame_info.tres.
## 2. Lógica de inicio en _on_start(), de cierre en _on_end().
## 3. Sumar puntos con add_score(). Terminar antes de tiempo con end_game().
## 4. Probar solo con F6 (arranca sin host) y luego desde el hub.
## 5. Vidas (opcional): poner max_lives = 3 (o las que quieras) en el Inspector
##    de la raíz y llamar lose_life() al recibir daño; con la última termina
##    solo y el HUD las dibuja. Tiempo extra: add_time(segundos).

@export_group("Dificultad")
@export var spawn_interval_start: float = 1.0
@export var spawn_interval_end: float = 0.5

@export_group("Puntaje")
@export var points_per_hit: int = 10

@onready var _spawn_timer: Timer = %SpawnTimer


func _ready() -> void:
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _on_start() -> void:
	_spawn_timer.start(spawn_interval_start)


func _on_end() -> void:
	_spawn_timer.stop()


func _physics_process(_delta: float) -> void:
	if not is_running:
		return
	# Movimiento / input por frame aquí. Usar acciones del Input Map:
	# move_left, move_right, move_up, move_down, action, back.


func _on_spawn_timer_timeout() -> void:
	# Crear enemigos/objetos aquí. Subir dificultad con get_progress() (0 → 1).
	_spawn_timer.wait_time = lerpf(spawn_interval_start, spawn_interval_end, get_progress())
