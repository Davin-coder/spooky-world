class_name MinigameResults
extends Control
## Presentacion de resultados opcional, con navegacion delegada a la pantalla padre.

signal retry_requested
signal hub_requested


func bind(_score_value: int, _best: int, _completed: bool) -> void:
	pass
