class_name Minigame
extends Node2D
## Clase base de TODOS los minijuegos de Spooky World.
##
## Contrato:
## - El host (MinigameHost) instancia la escena, conecta [signal finished]
##   y llama [method start] cuando termina la cuenta regresiva.
## - El minijuego suma puntos con [method add_score] y termina con
##   [method end_game] (o solo, cuando se acaba [member duration_sec]).
## - Opcional: vidas con [member max_lives] > 0 y [method lose_life], y tiempo
##   extra con [method add_time]. El HUD común los muestra solo.
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
## Se emite cada vez que cambian las vidas (el HUD lo escucha).
signal lives_changed(lives: int)
## Se emite al sumar tiempo con [method add_time] (el HUD muestra "+N s").
signal time_added(seconds: float)

## Duración en segundos. 0 = sin límite (el minijuego decide cuándo terminar).
@export var duration_sec: float = 45.0
## Vidas al empezar. 0 = el minijuego no usa vidas (el HUD no las muestra).
## Con vidas, la partida termina sola al perder la última con [method lose_life].
@export var max_lives: int = 0

## Puntaje actual. Nunca baja de 0.
var score: int = 0:
	set(value):
		score = maxi(value, 0)
		score_changed.emit(score)

## true entre start() y end_game(). Úsalo para ignorar input antes/después.
var is_running: bool = false
## true si la última partida terminó porque se acabó el tiempo.
var timed_out: bool = false
## Vidas restantes. Se reinicia a [member max_lives] en [method start].
var lives: int = 0
## true si la última partida terminó porque se acabaron las vidas.
var out_of_lives: bool = false

var _timer: Timer
## Segundos sumados con add_time() en esta partida. Con esto get_progress()
## mide tiempo transcurrido sin depender de _process (que el hijo sobreescribe).
var _bonus_time_sec: float = 0.0


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
	lives = max_lives
	out_of_lives = false
	_bonus_time_sec = 0.0
	is_running = true
	lives_changed.emit(lives)
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


## Quita una vida. Al llegar a 0 marca [member out_of_lives] y termina la
## partida. Sin efecto si no está corriendo o si [member max_lives] es 0.
func lose_life() -> void:
	if not is_running or max_lives <= 0:
		return
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		out_of_lives = true
		end_game()


## Suma una vida, sin pasar de [member max_lives]. Para objetos de vida extra.
func add_life() -> void:
	if not is_running or max_lives <= 0 or lives >= max_lives:
		return
	lives += 1
	lives_changed.emit(lives)


## Suma segundos al reloj y emite [signal time_added]. Sin efecto si no está
## corriendo, si no hay límite de tiempo o si [param seconds] no es positivo.
## No baja la dificultad: [method get_progress] mide tiempo transcurrido.
func add_time(seconds: float) -> void:
	if not is_running or duration_sec <= 0.0 or seconds <= 0.0:
		return
	_bonus_time_sec += seconds
	_timer.start(_timer.time_left + seconds)
	time_added.emit(seconds)


## Segundos restantes; 0 si no hay límite de tiempo o no está corriendo.
func get_time_left() -> float:
	if not is_running or duration_sec <= 0.0:
		return 0.0
	return _timer.time_left


## Fracción de tiempo transcurrido respecto a [member duration_sec] (0 al
## inicio, 1 al final). Útil para subir la dificultad progresivamente.
## El tiempo sumado con [method add_time] alarga la partida, pero no hace
## retroceder el progreso: llega a 1 y se queda ahí hasta el final.
func get_progress() -> float:
	if duration_sec <= 0.0:
		return 0.0
	var elapsed: float = duration_sec + _bonus_time_sec - get_time_left()
	return clampf(elapsed / duration_sec, 0.0, 1.0)


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
