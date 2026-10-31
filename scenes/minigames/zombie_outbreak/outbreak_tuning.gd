class_name OutbreakTuning
extends Resource
## Parametros de balance editables desde el Inspector del juego.

@export_group("Movimiento")
@export_range(40.0, 110.0, 1.0) var move_speed: float = 66.0

@export_group("Pistola")
@export_range(0.08, 0.5, 0.01) var fire_interval: float = 0.17
@export_range(0.5, 2.5, 0.05) var reload_seconds: float = 1.15

@export_group("Oleadas")
@export_range(0.3, 2.0, 0.05) var spawn_interval_start: float = 1.05
@export_range(0.15, 1.0, 0.05) var spawn_interval_end: float = 0.32
