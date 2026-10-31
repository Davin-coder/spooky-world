class_name Minigame
extends Node2D
## Clase base de TODOS los minijuegos de Spooky World.
##
## Contrato:
## - El host (MinigameHost) instancia la escena, conecta [signal finished]
##   y llama [method start] cuando termina la cuenta regresiva.
## - El minijuego suma puntos con [method add_score] y termina con
##   [method end_game] (o solo, cuando se acaba [member duration_sec]).
## - Un minijuego NUNCA cambia de escena ni llama al hub, a otro minijuego
##   o a GameManager. Solo emite señales.
##
## Para implementar uno nuevo, sobreescribe los hooks [method _on_start],
## [method _on_end] y, si necesitas lógica por frame, [method _process] o
## [method _physics_process] consultando [member is_running].
## Ver la skill .agents/skills/nuevo-minijuego.

## Se emite una sola vez cuando el minijuego termina, con el puntaje final.
signal finished(final_score: int)
## Se emite cada vez que cambia el puntaje (el HUD lo escucha).
signal score_changed(new_score: int)

## Duración en segundos. 0 = sin límite (el minijuego decide cuándo terminar).
@export var duration_sec: float = 45.0

## Puntaje actual. Nunca baja de 0.
var score: int = 0:
	set(value):
		score = maxi(value, 0)
		score_changed.emit(score)

## true entre start() y end_game(). Úsalo para ignorar input antes/después.
var is_running: bool = false
## true si la última partida terminó porque se acabó el tiempo.
var timed_out: bool = false

var _timer: Timer


func _init() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_time_up)
	add_child(_timer, false, Node.INTERNAL_MODE_FRONT)


func _notification(what: int) -> void:
	# _notification se llama en toda la jerarquía de clases, así que esto
	# funciona aunque el minijuego hijo sobreescriba _ready() sin super().
	if what == NOTIFICATION_READY:
		_check_standalone_run.call_deferred()


## Arranca la partida. Lo llama el host (o el modo standalone con F6).
func start() -> void:
	score = 0
	timed_out = false
	is_running = true
	if duration_sec > 0.0:
		_timer.start(duration_sec)
	_on_start()


## Termina la partida y emite [signal finished]. Llamarlo dos veces es seguro.
func end_game() -> void:
	if not is_running:
		return
	is_running = false
	_timer.stop()
	_on_end()
	finished.emit(score)


## Suma (o resta, con valores negativos) puntos si la partida está activa.
func add_score(points: int) -> void:
	if is_running:
		score += points


## Segundos restantes; 0 si no hay límite de tiempo o no está corriendo.
func get_time_left() -> float:
	if not is_running or duration_sec <= 0.0:
		return 0.0
	return _timer.time_left


## Fracción de tiempo transcurrido (0 al inicio, 1 al final). Útil para
## subir la dificultad progresivamente.
func get_progress() -> float:
	if duration_sec <= 0.0:
		return 0.0
	return clampf(1.0 - get_time_left() / duration_sec, 0.0, 1.0)


# --- Hooks para sobreescribir ------------------------------------------------


## Se llama al iniciar. Reinicia estado, arranca spawners, etc.
func _on_start() -> void:
	pass


## Se llama al terminar, antes de emitir [signal finished]. Detén spawners.
func _on_end() -> void:
	pass


# --- Interno ------------------------------------------------------------------


func _on_time_up() -> void:
	timed_out = true
	end_game()


## Si la escena se ejecuta sola (F6 en el editor), arranca sin host para
## probar rápido. El puntaje final se imprime en la salida.
func _check_standalone_run() -> void:
	if get_tree().current_scene != self:
		return
	print("[%s] Modo standalone: iniciando sin host." % name)
	finished.connect(
		func(final_score: int) -> void: print("[%s] Terminado. Puntaje: %d" % [name, final_score])
	)
	start()
