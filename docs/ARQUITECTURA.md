# Arquitectura

## Principio

Cada minijuego es una escena **autocontenida** que cumple un contrato (`Minigame`).
El resto del juego solo sabe cargarla y recibir su puntaje. Así dos personas trabajan en paralelo sin tocar los mismos archivos.

## Flujo

```
MainMenu ──Jugar──▶ Hub ──elige──▶ MinigameHost ──finished(score)──▶ Results
   ▲                 ▲  ◀──Esc───────────┘                            │
   └──────Esc────────┴─────────────────"Volver al hub"────────────────┘
                                   "Otra vez" ──▶ MinigameHost
```

Toda la navegación pasa por `GameManager` → `SceneLoader.change_scene()`.

## Piezas

| Pieza | Archivo | Responsabilidad |
| --- | --- | --- |
| `GameManager` (autoload) | `autoload/game_manager.gd` | Descubre minijuegos, guarda puntajes de la sesión y navega |
| `SceneLoader` (autoload) | `autoload/scene_loader.gd` | Cambio de escena con fundido; único que llama `change_scene_to_file` |
| `AudioManager` (autoload) | `autoload/audio_manager.gd` | Música y pool de efectos en los buses `Music` y `SFX` |
| `Minigame` | `shared/minigame.gd` | Clase base: timer, puntaje, `start`/`end_game`, modo standalone (F6) |
| `MinigameInfo` | `shared/minigame_info.gd` | Ficha `.tres`: nombre, descripción, instrucciones, escena, orden, habilitado |
| `MinigameHud` | `shared/hud/` | Puntaje, tiempo, cuenta regresiva, mensajes |
| `MinigameHost` | `scenes/minigame_host/` | Instancia el minijuego, conecta el HUD, cuenta 3-2-1, reporta el resultado |
| `Palette` | `shared/palette.gd` | Colores oficiales |

## Descubrimiento de minijuegos

`GameManager` recorre `scenes/minigames/*/minigame_info.tres` al arrancar:

- Ignora carpetas que empiezan con `_` (por ejemplo `_template`).
- Solo incluye las fichas con `enabled = true`.
- Ordena por `order`.

Agregar un minijuego = crear su carpeta con su ficha. No se toca ningún archivo compartido.

## Ciclo de vida de una partida

1. `Hub` → `GameManager.play(info)` → cambia a `MinigameHost`.
2. `MinigameHost._ready()` instancia `info.scene_path`, verifica que sea `Minigame` y conecta el HUD.
3. Cuenta regresiva 3-2-1 → `minigame.start()` → `_on_start()` del minijuego.
4. El minijuego llama `add_score()`; el HUD escucha `score_changed`.
5. Se acaba el tiempo (o el minijuego llama `end_game()`) → `_on_end()` → `finished(score)`.
6. `MinigameHost` muestra "¡Tiempo!" o "¡Terminado!" y llama `GameManager.report_result(score)` → `Results`.

## Capas de física

| Capa | Nombre | Uso |
| --- | --- | --- |
| 1 | player | Jugador, canasta |
| 2 | collectibles | Calabazas, dulces |
| 3 | enemies | Fantasmas, enemigos |
| 4 | world | Muros, suelo |

## Input Map

| Acción | Teclas |
| --- | --- |
| `move_left` / `move_right` | A / D, ← / → |
| `move_up` / `move_down` | W / S, ↑ / ↓ |
| `action` | Espacio, clic izquierdo |
| `back` | Esc |

## Decisiones

- **GDScript + tipado estático**: iteración rápida y errores detectados en el editor.
- **GL Compatibility**: funciona en Web y en equipos modestos.
- **Placeholders con `ColorRect`**: desarrollo no espera a diseño.
- **Sin guardado a disco**: los récords viven solo durante la sesión.
