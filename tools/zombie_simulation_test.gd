extends SceneTree
## Pruebas deterministas del combate: municion, impactos, dano, pausa y limites.

var _errors: PackedStringArray = []
var _points: int = 0
var _deaths: int = 0


func _initialize() -> void:
	_test_weapon()
	_test_cover()
	_test_health()
	_test_dash()
	_test_bounded_session()
	if _errors.is_empty():
		print("ZOMBIE SIMULATION TEST OK")
	else:
		for message: String in _errors:
			printerr("FAIL: ", message)
	quit(0 if _errors.is_empty() else 1)


func _test_weapon() -> void:
	var model := OutbreakSimulation.new()
	model.reset(123)
	model.points_earned.connect(_on_points)
	model.spawn_enemy(Vector2(185, 99))
	_check(model.fire(), "Primer disparo aceptado")
	_check(not model.fire(), "La cadencia impide disparar dos veces en el mismo instante")
	_check(model.ammo == 11, "Un disparo consume una bala")
	for i: int in 20:
		model.step(1.0 / 60, Vector2.ZERO, Vector2(220, 99), false, false, false)
	_check(model.kills == 1 and _points == 10, "Impacto elimina al caminante y emite puntos")
	model.reload_weapon()
	_check(model.ammo == 11 and model.reload_left > 0, "La recarga no es instantanea")
	for i: int in 75:
		model.step(1.0 / 60, Vector2.ZERO, Vector2(220, 99), false, false, false)
	_check(model.ammo == 12 and model.reload_left == 0, "Recarga completa tras su duracion")
	model.ammo = 0
	_check(not model.fire() and model.reload_left > 0, "Cargador vacio inicia recarga automatica")


func _test_cover() -> void:
	var model := OutbreakSimulation.new()
	model.reset(456)
	model.player = Vector2(40, 69)
	model.aim = Vector2.RIGHT
	var enemy: OutbreakEnemy = model.spawn_enemy(Vector2(90, 69), 2)
	enemy.speed = 0
	model.fire()
	for i: int in 20:
		model.step(1.0 / 60, Vector2.ZERO, Vector2(100, 69), false, false, false)
	_check(enemy.health == 4, "Las lapidas bloquean las balas")
	for i: int in 120:
		model.step(1.0 / 60, Vector2.RIGHT, Vector2(100, 69), false, false, false)
	_check(model.player.x < 60, "El jugador no atraviesa una lapida")


func _test_health() -> void:
	var model := OutbreakSimulation.new()
	model.reset(789)
	model.defeated.connect(_on_death)
	model.damage_player(20)
	model.damage_player(20)
	_check(model.health == 80, "Invulnerabilidad evita dano repetido inmediato")
	var pickup := OutbreakPickup.new()
	pickup.position = model.player
	model.pickups.append(pickup)
	model.step(1.0 / 60, Vector2.ZERO, Vector2(220, 99), false, false, false)
	_check(model.health == 100 and model.pickups.is_empty(), "Botiquin cura y se consume")
	model.hurt_left = 0
	model.damage_player(200)
	model.damage_player(200)
	_check(model.health == 0 and _deaths == 1, "Derrota se emite una sola vez")
	var before: Vector2 = model.player
	model.step(0.5, Vector2.RIGHT, Vector2(220, 99), true, false, false)
	_check(model.player == before and model.bullets.is_empty(), "Derrotado no avanza ni dispara")
	model.reset(123)
	_check(
		model.health == 100 and model.ammo == 12 and model.kills == 0, "Reintento reinicia estado"
	)


func _test_bounded_session() -> void:
	var model := OutbreakSimulation.new()
	model.reset(2026)
	for i: int in 3600:
		model.health = 100
		var direction: Vector2 = Vector2.from_angle(float(i) * 0.005)
		var target: Vector2 = model.player + direction * 90
		if not model.enemies.is_empty():
			target = model.enemies[0].position
		model.step(1.0 / 60, direction, target, true, false, i % 120 == 0)
	_check(model.wave == 3, "Sesion alcanza tercera oleada")
	_check(model.enemies.size() <= model.MAX_ENEMIES, "Limite de enemigos")
	_check(model.bullets.size() <= model.MAX_BULLETS, "Limite de balas")
	_check(model.particles.size() <= model.MAX_PARTICLES, "Limite de particulas")
	_check(model.ARENA.has_point(model.player), "Jugador permanece dentro de arena")


func _test_dash() -> void:
	var model := OutbreakSimulation.new()
	model.reset(321)
	model.step(0.01, Vector2.RIGHT, Vector2(220, 99), false, false, true)
	_check(model.dash_left > 0 and model.dash_cooldown > 0, "Esquiva inicia con cooldown")
	model.damage_player(20)
	_check(model.health == 100, "Esquiva protege durante el impulso")
	for i: int in 15:
		model.step(1.0 / 60, Vector2.ZERO, Vector2(220, 99), false, false, false)
	model.step(0.01, Vector2.RIGHT, Vector2(220, 99), false, false, true)
	_check(model.dash_left == 0, "No permite otra esquiva antes del cooldown")


func _on_points(value: int) -> void:
	_points += value


func _on_death() -> void:
	_deaths += 1


func _check(condition: bool, message: String) -> void:
	if not condition:
		_errors.append(message)
