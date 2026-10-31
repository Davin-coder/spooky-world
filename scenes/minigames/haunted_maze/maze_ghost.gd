class_name MazeGhost
extends Area2D
## Fantasma del laberinto. Sigue la ruta que le da la raíz, de centro a centro
## de celda, así nunca atraviesa muros. No conoce el laberinto ni al jugador:
## solo avisa con [signal caught_player] (su máscara es la capa del jugador).

signal caught_player
## Terminó la pausa de [method freeze_for] y vuelve a perseguir.
signal woke_up

## Píxeles por segundo. La raíz lo ajusta con la dificultad.
var speed: float = 120.0
## Si es false, se queda quieto y no atrapa (antes del inicio, al reaparecer).
var can_move: bool = false:
	set(value):
		can_move = value
		if can_move:
			# Si se activa encima del jugador, body_entered ya no se emitiría.
			_check_overlap.call_deferred()

var _path: Array[Vector2] = []

@onready var _wake_timer: Timer = %WakeTimer


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_wake_timer.timeout.connect(_on_wake_timer_timeout)


func _physics_process(delta: float) -> void:
	if not can_move:
		return
	var step: float = speed * delta
	while step > 0.0 and not _path.is_empty():
		var distance: float = position.distance_to(_path[0])
		if distance > step:
			position = position.move_toward(_path[0], step)
			return
		position = _path[0]
		step -= distance
		_path.remove_at(0)


## Punto al que va ahora (o donde está si no tiene ruta). La nueva ruta debe
## empezar aquí para no cortar esquinas a mitad de un tramo.
func get_next_waypoint() -> Vector2:
	return position if _path.is_empty() else _path[0]


## Reemplaza la ruta. [param points] empieza en [method get_next_waypoint].
func follow_path(points: Array[Vector2]) -> void:
	_path = points


## Lo deja quieto [param seconds] y luego vuelve a moverse solo.
func freeze_for(seconds: float) -> void:
	can_move = false
	_wake_timer.start(seconds)


## Lo detiene para siempre (fin de partida): no se despierta.
func stop() -> void:
	can_move = false
	_wake_timer.stop()


## Lo mueve al instante a [param point] y olvida la ruta.
func teleport_to(point: Vector2) -> void:
	position = point
	_path.clear()


func _on_body_entered(_body: Node2D) -> void:
	if can_move:
		caught_player.emit()


func _on_wake_timer_timeout() -> void:
	can_move = true
	woke_up.emit()


func _check_overlap() -> void:
	if can_move and has_overlapping_bodies():
		caught_player.emit()
