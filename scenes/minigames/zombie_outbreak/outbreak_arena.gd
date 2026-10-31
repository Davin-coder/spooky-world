class_name OutbreakArena
extends Node2D
## Renderer pixel original: escenario, actores, efectos y HUD a 320x180.

const RESUME_RECT: Rect2 = Rect2(86, 89, 148, 18)
const EXIT_RECT: Rect2 = Rect2(86, 113, 148, 18)

var simulation: OutbreakSimulation
var time_left: float = 60.0
var score_value: int = 0
var paused: bool = false
var ended: bool = false
var cursor: Vector2 = Vector2(220, 100)
var _clock: float = 0.0


func _process(delta: float) -> void:
	_clock += delta
	queue_redraw()


func _draw() -> void:
	if simulation == null:
		return
	_draw_ground()
	_draw_props()
	_draw_actors()
	_draw_hud()
	if simulation.elapsed < 3.5 and not ended:
		_draw_briefing()
	elif fmod(simulation.elapsed, 20.0) < 1.7 and not ended:
		_panel(Rect2(113, 35, 94, 16), Palette.PIXEL_INK, Palette.PUMPKIN)
		_center("OLEADA %02d" % simulation.wave, 40, Palette.PUMPKIN)
	if paused:
		_draw_pause()
	elif ended:
		_panel(Rect2(61, 69, 198, 42), Palette.PIXEL_INK, Palette.PUMPKIN)
		_center("AMANECIO" if simulation.health > 0 else "FIN DE GUARDIA", 78, Palette.BONE, 2)
		_center("PUNTOS %05d" % score_value, 100, Palette.PIXEL_TEAL)


func _draw_ground() -> void:
	draw_rect(Rect2(0, 0, 320, 180), Palette.PIXEL_INK)
	draw_rect(OutbreakSimulation.ARENA, Palette.PIXEL_GROUND)
	for y: int in range(32, 157, 16):
		for x: int in range(10, 310, 16):
			if (x * 7 + y * 3) % 5 < 2:
				draw_rect(Rect2(x + 1, y + 1, 14, 14), Palette.PIXEL_TILE)
			if (x + y) % 7 == 0:
				draw_rect(Rect2(x + 3, y + 5, 3, 1), Palette.PIXEL_STONE)
	# Sendero central y bordes de piedra, todo alineado a la cuadricula.
	for x: int in range(20, 309, 16):
		draw_rect(Rect2(x, 90, 12, 10), Palette.PIXEL_TILE)
	for x: int in range(8, 313, 8):
		draw_rect(Rect2(x, 27, 6, 3), Palette.PIXEL_STONE)
		draw_rect(Rect2(x, 158, 6, 3), Palette.PIXEL_STONE)
	for y: int in range(29, 158, 8):
		draw_rect(Rect2(7, y, 2, 5), Palette.PIXEL_STONE)
		draw_rect(Rect2(311, y, 2, 5), Palette.PIXEL_STONE)
	# Rayas de peligro en las cuatro entradas.
	for x: int in range(145, 176, 5):
		draw_rect(Rect2(x, 27, 3, 2), Palette.PUMPKIN)
		draw_rect(Rect2(x, 159, 3, 2), Palette.PUMPKIN)


func _draw_props() -> void:
	for cover: Rect2 in OutbreakSimulation.COVER:
		draw_rect(
			Rect2(cover.position + Vector2(-2, 12), cover.size + Vector2(4, -8)), Palette.PIXEL_INK
		)
		_draw_sprite(&"grave", cover.get_center() + Vector2(0, -3))
	for at: Vector2 in [Vector2(27, 44), Vector2(293, 143), Vector2(32, 142)]:
		_draw_sprite(&"pumpkin", at)
	for at: Vector2 in [Vector2(50, 51), Vector2(247, 51), Vector2(250, 139)]:
		_draw_sprite(&"candle", at)
		if int(_clock * 5) % 3 == 0:
			draw_rect(Rect2(at + Vector2(0, -5), Vector2.ONE), Palette.PUMPKIN)
	for pickup: OutbreakPickup in simulation.pickups:
		if pickup.life > 2 or int(_clock * 8) % 2 == 0:
			_draw_sprite(&"medkit", pickup.position)


func _draw_actors() -> void:
	for enemy: OutbreakEnemy in simulation.enemies:
		var id: StringName = [&"walker", &"runner", &"brute"][enemy.kind]
		var bob: float = floor(sin(simulation.elapsed * 9 + enemy.phase))
		var tint: Color = Palette.BONE if enemy.flash > 0 else Color.WHITE
		_draw_sprite(id, enemy.position + Vector2(0, bob), tint)
	for bullet: OutbreakBullet in simulation.bullets:
		draw_line(bullet.previous.round(), bullet.position.round(), Palette.BONE, 1, false)
		draw_rect(Rect2(bullet.position.round(), Vector2(2, 1)), Palette.PUMPKIN)
	for particle: OutbreakParticle in simulation.particles:
		draw_rect(Rect2(particle.position.round(), Vector2.ONE), particle.color)
	var body_tint: Color = Color.WHITE
	if simulation.hurt_left > 0 and int(_clock * 14) % 2 == 0:
		body_tint = Palette.PUMPKIN
	_draw_sprite(&"player", simulation.player, body_tint)
	var hand: Vector2 = simulation.player.round() + simulation.aim * 4
	var muzzle: Vector2 = hand + simulation.aim * 6
	draw_line(hand.round(), muzzle.round(), Palette.PIXEL_INK, 4, false)
	draw_line(hand.round(), muzzle.round(), Palette.PIXEL_LIGHT, 2, false)
	if simulation.muzzle_left > 0:
		draw_rect(Rect2(muzzle.round() - Vector2(2, 2), Vector2(5, 5)), Palette.PUMPKIN)
		draw_rect(Rect2(muzzle.round() - Vector2(1, 1), Vector2(3, 3)), Palette.BONE)
	if not paused and not ended:
		_draw_crosshair()


func _draw_hud() -> void:
	draw_rect(Rect2(0, 0, 320, 25), Palette.PIXEL_INK)
	draw_rect(Rect2(0, 24, 320, 1), Palette.PIXEL_TEAL)
	OutbreakArt.draw_text(self, "ULTIMA GUARDIA", Vector2(10, 4), Palette.PUMPKIN)
	OutbreakArt.draw_text(self, "PUNTOS %05d" % score_value, Vector2(10, 14), Palette.BONE)
	OutbreakArt.draw_text(
		self, "OLEADA %02d" % simulation.wave, Vector2(142, 4), Palette.PIXEL_TEAL
	)
	OutbreakArt.draw_text(
		self, "BAJAS %02d" % simulation.kills, Vector2(142, 14), Palette.PIXEL_LIGHT
	)
	var timer_color: Color = Palette.PUMPKIN if time_left <= 10 else Palette.BONE
	OutbreakArt.draw_text(self, "%02d S" % ceili(time_left), Vector2(263, 5), timer_color, 2)
	draw_rect(Rect2(0, 163, 320, 17), Palette.PIXEL_INK)
	OutbreakArt.draw_text(self, "+", Vector2(10, 168), Palette.BLOOD)
	draw_rect(Rect2(18, 168, 51, 6), Palette.PIXEL_TILE)
	draw_rect(Rect2(19, 169, simulation.health * 0.49, 4), Palette.SLIME)
	OutbreakArt.draw_text(self, "%02d/12" % simulation.ammo, Vector2(81, 168), Palette.BONE)
	if simulation.reload_left > 0:
		OutbreakArt.draw_text(self, "RECARGANDO", Vector2(126, 168), Palette.PUMPKIN)
	else:
		for i: int in simulation.ammo:
			draw_rect(Rect2(127 + i * 3, 169, 2, 5), Palette.PUMPKIN)
	var dash_label: String = "ESP LISTO" if simulation.dash_cooldown == 0 else "ESP ..."
	OutbreakArt.draw_text(self, dash_label, Vector2(176, 168), Palette.PIXEL_TEAL)
	OutbreakArt.draw_text(self, "ESC PAUSA", Vector2(257, 168), Palette.PIXEL_LIGHT)


func _draw_briefing() -> void:
	_panel(Rect2(51, 35, 218, 36), Palette.PIXEL_INK, Palette.PUMPKIN)
	_center("SOBREVIVE HASTA EL AMANECER", 40, Palette.BONE)
	_center("WASD MOVER / RATON APUNTAR", 51, Palette.PIXEL_TEAL)
	_center("CLIC DISPARAR / R RECARGAR", 61, Palette.PIXEL_LIGHT)


func _draw_pause() -> void:
	draw_rect(Rect2(0, 25, 320, 138), Color(Palette.PIXEL_INK, 0.85))
	_panel(Rect2(58, 45, 204, 99), Palette.PIXEL_INK, Palette.PIXEL_TEAL)
	_center("GUARDIA EN PAUSA", 57, Palette.PUMPKIN, 1)
	_center("EL RELOJ ESTA DETENIDO", 72, Palette.PIXEL_LIGHT)
	_panel(RESUME_RECT, Palette.PIXEL_TILE, Palette.PIXEL_TEAL)
	_center("REANUDAR [ESC]", 95, Palette.BONE)
	_panel(EXIT_RECT, Palette.PIXEL_GROUND, Palette.PIXEL_STONE)
	_center("ABANDONAR", 119, Palette.BONE)


func _draw_crosshair() -> void:
	var at: Vector2 = cursor.round()
	draw_line(at + Vector2(-5, 0), at + Vector2(-2, 0), Palette.PIXEL_TEAL)
	draw_line(at + Vector2(2, 0), at + Vector2(5, 0), Palette.PIXEL_TEAL)
	draw_line(at + Vector2(0, -5), at + Vector2(0, -2), Palette.PIXEL_TEAL)
	draw_line(at + Vector2(0, 2), at + Vector2(0, 5), Palette.PIXEL_TEAL)


func _draw_sprite(id: StringName, at: Vector2, tint: Color = Color.WHITE) -> void:
	var sprite: Texture2D = OutbreakArt.texture(id)
	var size: Vector2 = sprite.get_size()
	draw_rect(Rect2(at.round() + Vector2(-4, 5), Vector2(9, 3)), Palette.PIXEL_INK)
	draw_texture(sprite, (at - size * 0.5).round(), tint)


func _panel(rect: Rect2, fill: Color, border: Color) -> void:
	draw_rect(rect, fill)
	draw_rect(rect, border, false, 1)


func _center(value: String, y: float, color: Color, scale_factor: int = 1) -> void:
	var width: int = OutbreakArt.text_width(value, scale_factor)
	OutbreakArt.draw_text(self, value, Vector2((320 - width) / 2.0, y), color, scale_factor)
