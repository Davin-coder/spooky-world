class_name OutbreakResultsCanvas
extends Node2D
## Resultados del arcade con la misma cuadricula, fuente y paleta del combate.

const RETRY_RECT: Rect2 = Rect2(30, 130, 124, 23)
const HUB_RECT: Rect2 = Rect2(166, 130, 124, 23)

var score_value: int = 0
var best: int = 0
var completed: bool = false
var selection: int = 0


func _draw() -> void:
	draw_rect(Rect2(0, 0, 320, 180), Palette.PIXEL_INK)
	for y: int in range(8, 178, 16):
		for x: int in range(8, 318, 16):
			draw_rect(Rect2(x, y, 14, 14), Palette.PIXEL_GROUND)
	draw_rect(Rect2(20, 19, 280, 142), Palette.PIXEL_INK)
	draw_rect(Rect2(20, 19, 280, 142), Palette.PIXEL_TEAL, false, 1)
	_center("ARCADE / PIXEL ART", 7, Palette.PIXEL_LIGHT)
	_center("SOBREVIVISTE" if completed else "FIN DE GUARDIA", 32, Palette.PUMPKIN, 2)
	_center("LA NOCHE TERMINO" if completed else "OTRA NOCHE. OTRA OPORTUNIDAD.", 55, Palette.BONE)
	_center("%05d" % score_value, 72, Palette.PIXEL_TEAL, 3)
	_center("PUNTOS / RECORD %05d" % best, 103, Palette.PIXEL_LIGHT)
	_button(RETRY_RECT, "OTRA VEZ", selection == 0)
	_button(HUB_RECT, "VOLVER AL ARCADE", selection == 1)
	_center("FLECHAS + ENTER / RATON", 168, Palette.PIXEL_LIGHT)
	var sprite: Texture2D = OutbreakArt.texture(&"pumpkin")
	draw_texture(sprite, Vector2(26, 104))
	draw_texture(sprite, Vector2(282, 104))


func _button(rect: Rect2, label: String, focused: bool) -> void:
	draw_rect(rect, Palette.PIXEL_TILE if focused else Palette.PIXEL_GROUND)
	draw_rect(rect, Palette.PUMPKIN if focused else Palette.PIXEL_STONE, false, 1)
	var width: int = OutbreakArt.text_width(label)
	OutbreakArt.draw_text(
		self, label, rect.position + Vector2((rect.size.x - width) / 2, 8), Palette.BONE
	)


func _center(value: String, y: float, color: Color, scale_factor: int = 1) -> void:
	var width: int = OutbreakArt.text_width(value, scale_factor)
	OutbreakArt.draw_text(self, value, Vector2((320 - width) / 2.0, y), color, scale_factor)
