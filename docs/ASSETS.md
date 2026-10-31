# Especificación de assets (para diseño)

Desarrollo ya trabaja con cuadros de colores. Los assets reemplazan esos cuadros sin cambiar el juego, así que lo importante es que lleguen **con el nombre, tamaño y formato correctos**.

## Base

- Resolución del juego: **1280×720**.
- Paleta oficial (`shared/palette.gd`):

| Nombre | Hex | Uso |
| --- | --- | --- |
| NIGHT | `#1a1025` | Fondo principal |
| DUSK | `#2e1a47` | Fondo secundario, paneles |
| PURPLE | `#6b2fa3` | Acentos, botones, muros |
| PUMPKIN | `#ff7518` | Color protagonista, títulos |
| SLIME | `#8fd14f` | Positivo: puntos, éxito |
| BLOOD | `#c1121f` | Negativo: peligro, bombas |
| BONE | `#f2ead3` | Texto, fantasmas |
| SHADOW | `#0b0710` | Muros, sombras |

## Formatos

| Tipo | Formato | Regla |
| --- | --- | --- |
| Sprites y UI | PNG con transparencia | Al tamaño final; no se escalan en Godot |
| Animaciones | Spritesheet PNG en una fila | Frames del mismo tamaño; indicar cuántos frames y FPS |
| Fondos | PNG 1280×720 | Capas separadas si hay parallax |
| Música | OGG | En loop, volumen normalizado |
| Efectos | WAV u OGG | Menos de 2 s |
| Fuentes | TTF u OTF | Con licencia libre |

## Nombres

`snake_case`, en inglés, con prefijo del minijuego o `ui_`:

```
assets/art/pumpkin_catch/pumpkin_catch_basket.png
assets/art/pumpkin_catch/pumpkin_catch_pumpkin.png
assets/art/pumpkin_catch/pumpkin_catch_bomb.png
assets/art/ghost_whack/ghost_whack_ghost_idle.png
assets/art/ui/ui_button_play.png
assets/audio/sfx/pumpkin_catch_collect.wav
assets/audio/music/hub_theme.ogg
```

## Lista de assets por minijuego (tamaños actuales de los placeholders)

| Minijuego | Asset | Tamaño aprox. |
| --- | --- | --- |
| Pumpkin Catch | Canasta | 140×32 |
| Pumpkin Catch | Calabaza | 44×44 |
| Pumpkin Catch | Bomba | 44×44 |
| Pumpkin Catch | Fondo + suelo | 1280×720 |
| Ghost Whack | Fantasma (golpear) | 90×100 |
| Ghost Whack | Fantasma amigo (no golpear) | 90×100 |
| Ghost Whack | Ventana | 140×160 |
| Ghost Whack | Fachada de la casa | 928×520 |
| Haunted Maze | Jugador | 28×28 |
| Haunted Maze | Tile de muro | 48×48 |
| Haunted Maze | Dulce | 20×20 |
| Haunted Maze | Salida | 40×40 |
| UI | Logo "Spooky World", botones, tarjetas del hub | Libre |
| UI | Fondo de menú 16:9, sin texto y con centro despejado | 1920×1080 o 1280×720 |
| Audio | Música del hub, 1 efecto por acción (atrapar, golpe, error, fin) | — |

El fondo actual `assets/art/ui/ui_menu_background.png` es temporal. La ilustración final se entrega con **el mismo nombre y ruta** para sustituirlo sin modificar la escena; ver [`UX_UI.md`](UX_UI.md).

## Entrega

- Carpeta compartida con la misma estructura de `assets/`.
- Avisar en el canal del equipo cuando haya algo nuevo.
- Importa a Godot **una sola persona**: el dueño del minijuego para su arte y Dev 1 para la UI y el audio.
