extends Node
## Autoload "GameManager": estado de la sesión y navegación entre pantallas.
##
## - Descubre los minijuegos solo (busca scenes/minigames/*/minigame_info.tres).
## - Guarda puntajes de la sesión (en memoria, sin guardado a disco).
## - Es el ÚNICO lugar que decide a qué pantalla se va.
##
## Los minijuegos NO usan este autoload: solo emiten señales al host.

signal minigame_finished(info: MinigameInfo, final_score: int)

const MAIN_MENU_SCENE: String = "res://scenes/main_menu/main_menu.tscn"
const HUB_SCENE: String = "res://scenes/hub/hub.tscn"
const HOST_SCENE: String = "res://scenes/minigame_host/minigame_host.tscn"
const RESULTS_SCENE: String = "res://scenes/results/results.tscn"
const MINIGAMES_DIR: String = "res://scenes/minigames"
const INFO_FILE: String = "minigame_info.tres"

## Minijuegos habilitados, ordenados por MinigameInfo.order.
var minigames: Array[MinigameInfo] = []
## Minijuego que se está jugando (o el último jugado).
var current: MinigameInfo
## Puntaje de la última partida.
var last_score: int = 0
## true si la última partida superó el récord anterior.
var last_was_record: bool = false
## Mejor puntaje por id de minijuego en esta sesión.
var best_scores: Dictionary[StringName, int] = {}


func _ready() -> void:
	minigames = _discover_minigames()
	print("[GameManager] Minijuegos encontrados: %d" % minigames.size())


## Suma de los mejores puntajes de cada minijuego.
func get_session_total() -> int:
	var total: int = 0
	for best: int in best_scores.values():
		total += best
	return total


func get_best(id: StringName) -> int:
	return best_scores.get(id, 0)


# --- Navegación ----------------------------------------------------------------


func go_to_main_menu() -> void:
	SceneLoader.change_scene(MAIN_MENU_SCENE)


func go_to_hub() -> void:
	SceneLoader.change_scene(HUB_SCENE)


func play(info: MinigameInfo) -> void:
	current = info
	SceneLoader.change_scene(HOST_SCENE)


func replay_current() -> void:
	if current:
		play(current)
	else:
		go_to_hub()


## Lo llama MinigameHost cuando el minijuego emite finished.
func report_result(final_score: int) -> void:
	last_score = final_score
	last_was_record = false
	if current:
		last_was_record = final_score > 0 and final_score > get_best(current.id)
		best_scores[current.id] = maxi(get_best(current.id), final_score)
		minigame_finished.emit(current, final_score)
	SceneLoader.change_scene(RESULTS_SCENE)


# --- Descubrimiento ------------------------------------------------------------


func _discover_minigames() -> Array[MinigameInfo]:
	var found: Array[MinigameInfo] = []
	for dir_name: String in DirAccess.get_directories_at(MINIGAMES_DIR):
		# Carpetas que empiezan con "_" (como _template) se ignoran.
		if dir_name.begins_with("_"):
			continue
		var path: String = MINIGAMES_DIR.path_join(dir_name).path_join(INFO_FILE)
		if not ResourceLoader.exists(path):
			push_warning("[GameManager] %s no tiene %s" % [dir_name, INFO_FILE])
			continue
		var info: MinigameInfo = load(path) as MinigameInfo
		if info == null:
			push_error("[GameManager] %s no es un MinigameInfo" % path)
			continue
		if info.enabled:
			found.append(info)
	found.sort_custom(func(a: MinigameInfo, b: MinigameInfo) -> bool: return a.order < b.order)
	return found
