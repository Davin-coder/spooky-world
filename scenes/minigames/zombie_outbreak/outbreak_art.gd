class_name OutbreakArt
extends RefCounted
## Sprites y fuente bitmap originales. Los PNG entregados por arte tienen prioridad.

const ASSET_DIR: String = "res://assets/art/zombie_outbreak/"
const SPRITES: Dictionary[StringName, Array] = {
	&"player":
	[
		"....hhhh....",
		"...hhhhhh...",
		"...hsssssh..",
		"...sososss..",
		"....ssss....",
		".....ss.....",
		"...cccccc...",
		"..sccccccs..",
		"..sccccccs..",
		"...cccccc...",
		"....cccc....",
		"....oooo....",
		"...oo..oo...",
		"...oo..oo...",
		"..ooo..ooo..",
		"............",
	],
	&"walker":
	[
		"....gggg....",
		"...gggggg...",
		"...gogogg...",
		"...gggggg...",
		"....googg...",
		".....gg.....",
		"..gccccccg..",
		".ggccccccgg.",
		"..gccccccg..",
		"...ccoccc...",
		"....cccc....",
		"....oooo....",
		"...oo..oo...",
		"...oo..oo...",
		"..ooo..ooo..",
		"............",
	],
	&"brute":
	[
		".....gggggg.....",
		"....gggggggg....",
		"....goggoggg....",
		"....gggggggg....",
		".....goooggg....",
		".....gggggg.....",
		"..ggccccccccgg..",
		".gggccccccccggg.",
		".gggccccccccggg.",
		"..ggccccccccgg..",
		"...cccccccccc...",
		"....cccccccc....",
		".....oooooo.....",
		"....ooo..ooo....",
		"....ooo..ooo....",
		"...oooo..oooo...",
	],
	&"grave":
	[
		"....llll....",
		"..llttttll..",
		".lttttttttl.",
		"lttttttttttl",
		"lttttttttttl",
		"lttttotttttl",
		"ltttooottttl",
		"lttttotttttl",
		"lttttotttttl",
		"lttttttttttl",
		"lttttttttttl",
		"lttttttttttl",
		"lttttttttttl",
		"lttttttttttl",
		"oooooooooooo",
		"............",
	],
	&"pumpkin":
	[
		"....gg....",
		".....g....",
		"..aaaaaa..",
		".aaaaaaaa.",
		"aaaaooaaaa",
		"aaaoaaoaaa",
		"aaaaaaaaaa",
		".aaoooaaa.",
		"..aaaaaa..",
		"..........",
	],
	&"candle":
	[
		"..y...",
		".yay..",
		"..y...",
		".bbbb.",
		".bblb.",
		".bblb.",
		".bblb.",
		".oooo.",
	],
	&"medkit":
	[
		".llllll.",
		"lbbbbbbl",
		"lbbrrbbl",
		"lbrrrrbl",
		"lbrrrrbl",
		"lbbrrbbl",
		"lbbbbbbl",
		".llllll.",
	],
}
const GLYPHS: Dictionary[String, String] = {
	"A": "01110/10001/10001/11111/10001/10001/10001",
	"B": "11110/10001/10001/11110/10001/10001/11110",
	"C": "01111/10000/10000/10000/10000/10000/01111",
	"D": "11110/10001/10001/10001/10001/10001/11110",
	"E": "11111/10000/10000/11110/10000/10000/11111",
	"F": "11111/10000/10000/11110/10000/10000/10000",
	"G": "01111/10000/10000/10111/10001/10001/01111",
	"H": "10001/10001/10001/11111/10001/10001/10001",
	"I": "111/010/010/010/010/010/111",
	"J": "00111/00010/00010/00010/00010/10010/01100",
	"K": "10001/10010/10100/11000/10100/10010/10001",
	"L": "10000/10000/10000/10000/10000/10000/11111",
	"M": "10001/11011/10101/10101/10001/10001/10001",
	"N": "10001/11001/10101/10011/10001/10001/10001",
	"O": "01110/10001/10001/10001/10001/10001/01110",
	"P": "11110/10001/10001/11110/10000/10000/10000",
	"Q": "01110/10001/10001/10001/10101/10010/01101",
	"R": "11110/10001/10001/11110/10100/10010/10001",
	"S": "01111/10000/10000/01110/00001/00001/11110",
	"T": "11111/00100/00100/00100/00100/00100/00100",
	"U": "10001/10001/10001/10001/10001/10001/01110",
	"V": "10001/10001/10001/10001/10001/01010/00100",
	"W": "10001/10001/10001/10101/10101/11011/10001",
	"X": "10001/10001/01010/00100/01010/10001/10001",
	"Y": "10001/10001/01010/00100/00100/00100/00100",
	"Z": "11111/00001/00010/00100/01000/10000/11111",
	"0": "01110/10001/10011/10101/11001/10001/01110",
	"1": "010/110/010/010/010/010/111",
	"2": "01110/10001/00001/00010/00100/01000/11111",
	"3": "11110/00001/00001/01110/00001/00001/11110",
	"4": "10010/10010/10010/11111/00010/00010/00010",
	"5": "11111/10000/10000/11110/00001/00001/11110",
	"6": "01110/10000/10000/11110/10001/10001/01110",
	"7": "11111/00001/00010/00100/01000/01000/01000",
	"8": "01110/10001/10001/01110/10001/10001/01110",
	"9": "01110/10001/10001/01111/00001/00001/01110",
	":": "0/1/0/0/1/0/0",
	"/": "00001/00001/00010/00100/01000/10000/10000",
	"-": "000/000/000/111/000/000/000",
	"+": "000/010/010/111/010/010/000",
	".": "0/0/0/0/0/0/1",
	"!": "1/1/1/1/1/0/1",
	"?": "111/001/001/010/010/000/010",
	"[": "11/10/10/10/10/10/11",
	"]": "11/01/01/01/01/01/11",
}

static var _textures: Dictionary[StringName, Texture2D] = {}


static func texture(id: StringName) -> Texture2D:
	if _textures.has(id):
		return _textures[id]
	var path: String = ASSET_DIR + String(id) + ".png"
	var result: Texture2D
	if ResourceLoader.exists(path):
		result = load(path) as Texture2D
	else:
		result = ImageTexture.create_from_image(make_image(id))
	_textures[id] = result
	return result


static func make_image(id: StringName) -> Image:
	var base_id: StringName = &"walker" if id == &"runner" else id
	var rows: Array = SPRITES.get(base_id, SPRITES[&"player"])
	var colors: Dictionary[String, Color] = {
		"o": Palette.PIXEL_INK,
		"h": Palette.PIXEL_HAIR,
		"s": Palette.PIXEL_SKIN,
		"c": Palette.PIXEL_COAT,
		"g": Palette.SLIME,
		"t": Palette.PIXEL_STONE,
		"l": Palette.PIXEL_LIGHT,
		"a": Palette.PUMPKIN,
		"y": Palette.BONE,
		"b": Palette.BONE,
		"r": Palette.BLOOD,
	}
	if id == &"walker":
		colors["c"] = Palette.PURPLE
	elif id == &"runner":
		colors["c"] = Palette.BLOOD
	elif id == &"brute":
		colors["c"] = Palette.PUMPKIN
	var image: Image = Image.create(
		String(rows[0]).length(), rows.size(), false, Image.FORMAT_RGBA8
	)
	image.fill(Color.TRANSPARENT)
	for y: int in rows.size():
		var row: String = rows[y]
		for x: int in row.length():
			if colors.has(row[x]):
				image.set_pixel(x, y, colors[row[x]])
	return image


static func text_width(value: String, scale_factor: int = 1) -> int:
	var width: int = 0
	for character: String in value.to_upper():
		var rows: PackedStringArray = GLYPHS.get(character, GLYPHS["?"]).split("/")
		width += (3 if character == " " else rows[0].length() + 1) * scale_factor
	return width


static func draw_text(
	canvas: CanvasItem, value: String, at: Vector2, color: Color, scale_factor: int = 1
) -> void:
	var cursor: Vector2 = at.round()
	var normalized: String = value.to_upper()
	normalized = normalized.replace("Á", "A").replace("É", "E").replace("Í", "I")
	normalized = normalized.replace("Ó", "O").replace("Ú", "U").replace("Ñ", "N")
	for character: String in normalized:
		if character == " ":
			cursor.x += 3 * scale_factor
			continue
		var rows: PackedStringArray = GLYPHS.get(character, GLYPHS["?"]).split("/")
		for y: int in rows.size():
			for x: int in rows[y].length():
				if rows[y][x] == "1":
					var offset: Vector2 = Vector2(x, y) * scale_factor
					canvas.draw_rect(Rect2(cursor + offset, Vector2.ONE * scale_factor), color)
		cursor.x += (rows[0].length() + 1) * scale_factor
