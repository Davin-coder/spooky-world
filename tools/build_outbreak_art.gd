extends SceneTree
## Genera los sprites originales iniciales. No ejecutar sobre una entrega final de arte.

const IDS: Array[StringName] = [
	&"player",
	&"walker",
	&"runner",
	&"brute",
	&"grave",
	&"pumpkin",
	&"candle",
	&"medkit",
]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OutbreakArt.ASSET_DIR)
	for id: StringName in IDS:
		var path: String = OutbreakArt.ASSET_DIR + String(id) + ".png"
		if FileAccess.file_exists(path):
			print("CONSERVADO ", path)
			continue
		var error: Error = OutbreakArt.make_image(id).save_png(path)
		if error != OK:
			quit(1)
			return
	_build_card()
	print("PIXEL ART OK")
	quit(0)


func _build_card() -> void:
	var path: String = OutbreakArt.ASSET_DIR + "card.png"
	if FileAccess.file_exists(path):
		return
	var image: Image = Image.create(320, 160, false, Image.FORMAT_RGBA8)
	image.fill(Palette.PIXEL_INK)
	image.fill_rect(Rect2i(8, 30, 304, 122), Palette.PIXEL_GROUND)
	for y: int in range(32, 149, 16):
		for x: int in range(10, 310, 16):
			if (x + y) % 3 == 0:
				image.fill_rect(Rect2i(x, y, 14, 14), Palette.PIXEL_TILE)
	for y: int in range(-13, 14):
		for x: int in range(-13, 14):
			if x * x + y * y < 169:
				image.set_pixel(270 + x, 20 + y, Palette.PUMPKIN)
	for at: Vector2i in [Vector2i(50, 45), Vector2i(225, 104), Vector2i(107, 111)]:
		_blit(image, &"grave", at)
	for at: Vector2i in [Vector2i(62, 88), Vector2i(255, 72), Vector2i(212, 51)]:
		_blit(image, &"walker", at)
	_blit(image, &"brute", Vector2i(235, 117))
	_blit(image, &"player", Vector2i(153, 82))
	_blit(image, &"pumpkin", Vector2i(23, 125))
	_blit(image, &"candle", Vector2i(288, 133))
	image.fill_rect(Rect2i(170, 86, 58, 1), Palette.BONE)
	image.save_png(path)


func _blit(image: Image, id: StringName, at: Vector2i) -> void:
	var sprite: Image = OutbreakArt.make_image(id)
	image.blend_rect(sprite, Rect2i(Vector2i.ZERO, sprite.get_size()), at)
