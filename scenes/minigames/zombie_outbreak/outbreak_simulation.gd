class_name OutbreakSimulation
extends RefCounted
## Combate, oleadas y colisiones en coordenadas logicas de 320x180.

signal points_earned(points: int)
signal sound_requested(cue: StringName)
signal defeated

const ARENA: Rect2 = Rect2(10, 31, 300, 126)
const MAGAZINE_SIZE: int = 12
const MAX_ENEMIES: int = 44
const MAX_BULLETS: int = 48
const MAX_PARTICLES: int = 100
const DASH_COOLDOWN: float = 1.8
const COVER: Array[Rect2] = [
	Rect2(60, 61, 14, 17),
	Rect2(104, 119, 22, 12),
	Rect2(217, 63, 20, 12),
	Rect2(263, 116, 14, 17),
]

var player: Vector2 = Vector2(160, 99)
var tuning: OutbreakTuning = OutbreakTuning.new()
var aim: Vector2 = Vector2(1, 0)
var health: int = 100
var ammo: int = MAGAZINE_SIZE
var kills: int = 0
var elapsed: float = 0.0
var reload_left: float = 0.0
var fire_left: float = 0.0
var dash_left: float = 0.0
var dash_cooldown: float = 0.0
var hurt_left: float = 0.0
var muzzle_left: float = 0.0
var shake_left: float = 0.0
var active: bool = false
var wave: int = 1
var enemies: Array[OutbreakEnemy] = []
var bullets: Array[OutbreakBullet] = []
var particles: Array[OutbreakParticle] = []
var pickups: Array[OutbreakPickup] = []

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _spawn_left: float = 1.8
var _dash_direction: Vector2 = Vector2.RIGHT
var _combo_left: float = 0.0
var _combo: int = 0


func reset(random_seed: int = 0) -> void:
	if random_seed == 0:
		_rng.randomize()
	else:
		_rng.seed = random_seed
	player = Vector2(160, 99)
	aim = Vector2.RIGHT
	health = 100
	ammo = MAGAZINE_SIZE
	kills = 0
	elapsed = 0.0
	reload_left = 0.0
	fire_left = 0.0
	dash_left = 0.0
	dash_cooldown = 0.0
	hurt_left = 0.0
	muzzle_left = 0.0
	shake_left = 0.0
	wave = 1
	_spawn_left = 1.8
	_combo = 0
	_combo_left = 0.0
	enemies.clear()
	bullets.clear()
	particles.clear()
	pickups.clear()
	active = true


## Un tick fisico; no usa reloj global, input global ni cambios de escena.
func step(
	delta: float, movement: Vector2, target: Vector2, shooting: bool, reloading: bool, dashing: bool
) -> void:
	if not active:
		return
	_tick_cooldowns(delta)
	elapsed += delta
	wave = mini(3, 1 + int(elapsed / 20.0))
	var direction: Vector2 = player.direction_to(target)
	if not direction.is_zero_approx():
		aim = direction
	_move_player(delta, movement, dashing)
	if reloading:
		reload_weapon()
	if shooting:
		fire()
	_spawn_left -= delta
	if _spawn_left <= 0.0:
		_spawn_wave()
	_update_enemies(delta)
	if not active:
		return
	_update_bullets(delta)
	_update_effects(delta)


func fire() -> bool:
	if not active or fire_left > 0.0 or reload_left > 0.0 or dash_left > 0.0:
		return false
	if ammo <= 0:
		reload_weapon()
		return false
	if bullets.size() >= MAX_BULLETS:
		return false
	ammo -= 1
	fire_left = tuning.fire_interval
	muzzle_left = 0.06
	var bullet := OutbreakBullet.new()
	bullet.position = player + aim * 8.0
	bullet.previous = bullet.position
	bullet.velocity = aim * 260.0
	bullets.append(bullet)
	sound_requested.emit(&"shot")
	return true


func reload_weapon() -> void:
	if active and ammo < MAGAZINE_SIZE and reload_left <= 0.0:
		reload_left = tuning.reload_seconds
		sound_requested.emit(&"reload")


## Util tambien para pruebas deterministas y futuras variantes de oleada.
func spawn_enemy(at: Vector2, kind: int = 0) -> OutbreakEnemy:
	if enemies.size() >= MAX_ENEMIES:
		return null
	var enemy := OutbreakEnemy.new(at, clampi(kind, 0, 2))
	enemy.phase = _rng.randf_range(0.0, TAU)
	enemies.append(enemy)
	return enemy


func damage_player(amount: int) -> void:
	if not active or hurt_left > 0.0 or dash_left > 0.0:
		return
	health = maxi(0, health - amount)
	hurt_left = 0.85
	shake_left = 0.16
	sound_requested.emit(&"hurt")
	burst(player, Palette.PUMPKIN, 10)
	if health == 0:
		active = false
		defeated.emit()


func burst(at: Vector2, color: Color, count: int) -> void:
	for i: int in mini(count, MAX_PARTICLES - particles.size()):
		var particle := OutbreakParticle.new()
		particle.position = at
		particle.velocity = Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(8, 38)
		particle.life = _rng.randf_range(0.15, 0.4)
		particle.color = color
		particles.append(particle)


func _tick_cooldowns(delta: float) -> void:
	fire_left = maxf(0.0, fire_left - delta)
	dash_left = maxf(0.0, dash_left - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	hurt_left = maxf(0.0, hurt_left - delta)
	muzzle_left = maxf(0.0, muzzle_left - delta)
	shake_left = maxf(0.0, shake_left - delta)
	_combo_left = maxf(0.0, _combo_left - delta)
	if _combo_left == 0.0:
		_combo = 0
	if reload_left > 0.0:
		reload_left = maxf(0.0, reload_left - delta)
		if reload_left == 0.0:
			ammo = MAGAZINE_SIZE
			sound_requested.emit(&"loaded")


func _move_player(delta: float, movement: Vector2, dashing: bool) -> void:
	var direction: Vector2 = movement.limit_length()
	if dashing and dash_cooldown <= 0.0:
		_dash_direction = direction if not direction.is_zero_approx() else aim
		dash_left = 0.16
		dash_cooldown = DASH_COOLDOWN
		sound_requested.emit(&"dash")
	if dash_left > 0.0:
		direction = _dash_direction
		burst(player, Palette.PIXEL_TEAL, 1)
	var speed: float = 210.0 if dash_left > 0.0 else tuning.move_speed
	player = _move_circle(player, direction * speed * delta, 4.0)


func _spawn_wave() -> void:
	_spawn_left = lerpf(
		tuning.spawn_interval_start, tuning.spawn_interval_end, clampf(elapsed / 60.0, 0.0, 1.0)
	)
	if enemies.size() >= MAX_ENEMIES:
		return
	var side: int = _rng.randi_range(0, 3)
	var at: Vector2 = Vector2(_rng.randf_range(15, 305), 34 if side == 0 else 153)
	if side >= 2:
		at = Vector2(13 if side == 2 else 307, _rng.randf_range(36, 152))
	# Sin apariciones sorpresivas encima del jugador.
	if at.distance_to(player) < 54.0:
		at = Vector2(320, 187) - at
	var kind: int = 0
	if wave >= 2 and _rng.randf() < 0.3:
		kind = 1
	if wave == 3 and _rng.randf() < 0.18:
		kind = 2
	spawn_enemy(at, kind)


func _update_enemies(delta: float) -> void:
	for enemy: OutbreakEnemy in enemies:
		enemy.flash = maxf(0.0, enemy.flash - delta)
		var direction: Vector2 = enemy.position.direction_to(player)
		for cover: Rect2 in COVER:
			if cover.grow(enemy.radius + 2).has_point(enemy.position + direction * 9):
				var tangent: Vector2 = direction.orthogonal()
				if (player - cover.get_center()).dot(tangent) < 0:
					tangent = -tangent
				direction = (direction * 0.2 + tangent).normalized()
		enemy.position = _move_circle(enemy.position, direction * enemy.speed * delta, enemy.radius)
		if enemy.position.distance_to(player) < enemy.radius + 4.0:
			damage_player(30 if enemy.kind == 2 else 20)


func _update_bullets(delta: float) -> void:
	for index: int in range(bullets.size() - 1, -1, -1):
		var bullet: OutbreakBullet = bullets[index]
		bullet.previous = bullet.position
		bullet.position += bullet.velocity * delta
		bullet.life -= delta
		if bullet.life <= 0.0 or not ARENA.has_point(bullet.position) or _hits_cover(bullet):
			bullets.remove_at(index)
			continue
		if _hit_enemy(bullet):
			bullets.remove_at(index)


func _hit_enemy(bullet: OutbreakBullet) -> bool:
	for index: int in enemies.size():
		var enemy: OutbreakEnemy = enemies[index]
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(
			enemy.position, bullet.previous, bullet.position
		)
		if closest.distance_squared_to(enemy.position) > pow(enemy.radius + 1.0, 2):
			continue
		enemy.health -= 1
		enemy.flash = 0.1
		enemy.position = _move_circle(enemy.position, aim * 3.0, enemy.radius)
		burst(enemy.position, Palette.SLIME, 5)
		sound_requested.emit(&"hit")
		if enemy.health <= 0:
			_kill_enemy(index)
		return true
	return false


func _kill_enemy(index: int) -> void:
	var enemy: OutbreakEnemy = enemies[index]
	kills += 1
	_combo += 1
	_combo_left = 2.0
	var multiplier: int = mini(3, 1 + _combo / 5)
	points_earned.emit([10, 15, 40][enemy.kind] * multiplier)
	burst(enemy.position, Palette.SLIME, 8)
	if kills % 7 == 0:
		var pickup := OutbreakPickup.new()
		pickup.position = enemy.position
		pickups.append(pickup)
	enemies.remove_at(index)


func _update_effects(delta: float) -> void:
	for index: int in range(particles.size() - 1, -1, -1):
		var particle: OutbreakParticle = particles[index]
		particle.position += particle.velocity * delta
		particle.life -= delta
		if particle.life <= 0:
			particles.remove_at(index)
	for index: int in range(pickups.size() - 1, -1, -1):
		var pickup: OutbreakPickup = pickups[index]
		pickup.life -= delta
		if pickup.position.distance_to(player) < 9.0:
			health = mini(100, health + 25)
			pickups.remove_at(index)
			sound_requested.emit(&"heal")
		elif pickup.life <= 0:
			pickups.remove_at(index)


func _move_circle(at: Vector2, movement: Vector2, radius: float) -> Vector2:
	var result: Vector2 = at
	var limits: Rect2 = ARENA.grow(-radius)
	result.x = clampf(at.x + movement.x, limits.position.x, limits.end.x)
	for cover: Rect2 in COVER:
		if cover.grow(radius).has_point(result):
			result.x = at.x
	result.y = clampf(at.y + movement.y, limits.position.y, limits.end.y)
	for cover: Rect2 in COVER:
		if cover.grow(radius).has_point(result):
			result.y = at.y
	return result


func _hits_cover(bullet: OutbreakBullet) -> bool:
	for cover: Rect2 in COVER:
		if _segment_hits_rect(bullet.previous, bullet.position, cover):
			burst(bullet.position, Palette.PIXEL_LIGHT, 2)
			return true
	return false


func _segment_hits_rect(from: Vector2, to: Vector2, rect: Rect2) -> bool:
	if rect.has_point(from) or rect.has_point(to):
		return true
	var corners: Array[Vector2] = [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	]
	for i: int in 4:
		if (
			Geometry2D.segment_intersects_segment(from, to, corners[i], corners[(i + 1) % 4])
			!= null
		):
			return true
	return false
