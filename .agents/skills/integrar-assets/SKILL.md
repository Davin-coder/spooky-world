---
name: integrar-assets
description: Reemplaza los placeholders (ColorRect) por sprites, animaciones, fondos, fuentes o audio del equipo de diseño sin cambiar la lógica. Úsala cuando lleguen assets o pidan "poner el arte" o "poner sonidos".
---

# Integrar assets de diseño

La lógica ya funciona con placeholders. Integrar arte **no debe cambiar el comportamiento**: solo la parte visual o sonora.

## 1. Revisar lo que llegó

Contra la especificación de `docs/ASSETS.md`:

- Nombre en `snake_case`, en inglés, con prefijo: `pumpkin_catch_basket.png`.
- Carpeta correcta: `assets/art/<id>/`, `assets/art/ui/`, `assets/audio/music/`, `assets/audio/sfx/`, `assets/fonts/`.
- PNG con transparencia al tamaño final; música en OGG; efectos en WAV u OGG.

Si algo no cumple, renómbralo o muévelo **antes** de abrir Godot (después, muévelo solo desde el editor).
Solo **una persona** importa assets a la vez para evitar conflictos con `.import`.

## 2. Sprite estático (reemplaza un ColorRect)

1. En la escena, agrega `Sprite2D` hermano del `ColorRect` llamado `Visual`.
2. Asigna `texture` y céntralo (`centered = true`, posición `(0, 0)`).
3. Ajusta la `CollisionShape2D` al tamaño del sprite si cambió.
4. Borra el `ColorRect`. Si el script lo usaba (por ejemplo, para cambiar el color), cambia el tipo de `_visual` a `Sprite2D` y usa `texture` o `modulate` en lugar de `color`.

Ejemplo para `Pumpkin`, con dos texturas:

```gdscript
@export var pumpkin_texture: Texture2D
@export var bomb_texture: Texture2D

@onready var _visual: Sprite2D = %Visual


func _ready() -> void:
	_visual.texture = bomb_texture if is_bomb else pumpkin_texture
```

## 3. Animación desde spritesheet

1. Nodo `AnimatedSprite2D` → `sprite_frames` → New SpriteFrames.
2. En el panel SpriteFrames: "Add frames from sprite sheet", indica columnas y filas.
3. Nombres de animación en snake_case: `idle`, `walk`, `hit`. FPS según lo que indique diseño.
4. En código: `_sprite.play(&"idle")`.

## 4. Laberinto con TileMapLayer (Haunted Maze)

1. Crea un `TileSet` con el tileset de diseño (tile de 48 px, o el que se acuerde).
2. Agrega física al tile de muro (Physics Layer en la capa 4 "world").
3. Agrega un `TileMapLayer` y dibuja el laberinto siguiendo `LAYOUT`, o genera las celdas en `_build_maze()` con `set_cell()`.
4. Cuando el TileMapLayer funcione, elimina el código que crea `ColorRect` y colisiones a mano.

## 5. Fondos y UI

- Fondos de 1280×720: `Sprite2D` o `TextureRect` en lugar del `ColorRect` `Background`, con `centered = false` en `(0, 0)`.
- Botones: idealmente un `Theme` compartido en `assets/art/ui/spooky_theme.tres` asignado a la raíz de cada pantalla (lo crea Dev 1).
- Fuente: importa el `.ttf` en `assets/fonts/` y asígnala en el Theme (Default Font).

## 6. Audio

```gdscript
const SFX_POP: AudioStream = preload("res://assets/audio/sfx/pumpkin_catch_pop.wav")
AudioManager.play_sfx(SFX_POP, 0.1)  # 0.1 = variación de tono
```

- Música: `AudioManager.play_music(preload("res://assets/audio/music/hub_theme.ogg"))`. Activa Loop en el panel Import del `.ogg`.
- Los minijuegos pueden llamar a `AudioManager` (es la única excepción permitida de autoload).

## 7. Pixel art

Si el estilo final es pixel art: Project Settings → Rendering → Textures → Default Texture Filter = **Nearest** (lo cambia solo Dev 1, en `project.godot`).

## 8. Verificar

- F6 en la escena: se ve bien, las colisiones coinciden con el dibujo.
- La jugabilidad es la misma que con placeholders.
- Commit: `<id>: integra arte de <qué>`.
