class_name MinigameInfo
extends Resource
## Ficha de un minijuego. Cada carpeta de scenes/minigames/<id>/ tiene un
## minigame_info.tres con este script; GameManager las encuentra solas,
## así que agregar un minijuego NO requiere tocar ningún archivo compartido.

## Identificador único en snake_case. Debe coincidir con el nombre de la carpeta.
@export var id: StringName = &""
## Nombre visible en el hub.
@export var display_name: String = ""
## Una línea que se muestra en el hub.
@export_multiline var description: String = ""
## Instrucciones cortas que aparecen durante la cuenta regresiva.
@export var instructions: String = ""
## Escena principal del minijuego (su raíz debe extender Minigame).
@export_file("*.tscn") var scene_path: String = ""
## Imagen para el botón del hub (opcional).
@export var icon: Texture2D
## Orden en el hub (menor primero).
@export var order: int = 0
## false = no aparece en el hub (para minijuegos a medias).
@export var enabled: bool = true
## Quién lo mantiene (para saber a quién preguntar).
@export var maintainer: String = ""
