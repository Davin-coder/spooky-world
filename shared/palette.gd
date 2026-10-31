class_name Palette
extends RefCounted
## Paleta de Halloween compartida. Úsala en placeholders y UI para que los
## minijuegos se vean como un solo juego. Si diseño cambia la paleta,
## se actualiza SOLO aquí.

const NIGHT := Color("1a1025")  ## Fondo principal
const DUSK := Color("2e1a47")  ## Fondo secundario, paneles
const PURPLE := Color("6b2fa3")  ## Acentos, botones
const PUMPKIN := Color("ff7518")  ## Color protagonista, títulos
const SLIME := Color("8fd14f")  ## Positivo: puntos, éxito
const BLOOD := Color("c1121f")  ## Negativo: peligro, bombas
const BONE := Color("f2ead3")  ## Texto, fantasmas
const SHADOW := Color("0b0710")  ## Muros, sombras

# Arcade pixel: misma noche de Halloween, con acentos frios para el cementerio.
const PIXEL_INK := Color("10131c")
const PIXEL_GROUND := Color("252d35")
const PIXEL_TILE := Color("303b43")
const PIXEL_STONE := Color("607079")
const PIXEL_LIGHT := Color("9eafb0")
const PIXEL_TEAL := Color("52c6b6")
const PIXEL_SKIN := Color("dfac82")
const PIXEL_COAT := Color("477898")
const PIXEL_HAIR := Color("604434")
