# Plan de audio — Spooky World

## Objetivo

Sonido de Halloween juguetón, corto y legible. Debe confirmar acciones, advertir peligro y acompañar sin cansar durante partidas de 30–60 s. El juego tiene `AudioManager` y buses `Music`/`SFX`; hay que producir archivos e invocar esas funciones desde los eventos existentes, sin añadir otro autoload.

La plataforma principal es **Web en PC**. El primer clic en “Jugar” debe permitir arrancar el audio; verificarlo en navegador real. Para el MVP, evitar depender de reverb u otros efectos del bus: la [reproducción Web de Godot](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_web.html#audio-playback) puede no procesarlos en el modo de muestras predeterminado.

## Dirección sonora

- **Música:** caja de música, pizzicato o percusión de madera, bajo suave y pads oscuros. Misterio cálido, sin sobresaltos fuertes.
- **Ritmo:** tempo medio; melodías simples que soporten repetición. La música no debe tapar las señales de acierto/error.
- **Efectos:** transitorios cortos, con sonidos distintos para premio, penalización, tiempo y navegación.
- **Sin voz obligatoria:** toda instrucción y resultado permanece visible en texto.

## Inventario de entrega

| Prioridad | Archivo propuesto | Evento | Duración orientativa | Responsable |
| --- | --- | --- | --- | --- |
| P0 | `assets/audio/music/menu_hub_loop.ogg` | Menú y hub | Bucle de 45–90 s | Diseñador 2 / audio |
| P0 | `assets/audio/music/minigame_loop.ogg` | Cualquier minijuego | Bucle de 45–90 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/ui_focus.wav` | Cambio de botón con ratón/teclado | 0.05–0.20 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/ui_confirm.wav` | Jugar, repetir o volver | 0.10–0.35 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/countdown_tick.wav` | Cuenta 3, 2, 1 | 0.10–0.25 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/pumpkin_catch_collect.wav` | Calabaza atrapada | 0.10–0.35 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/pumpkin_catch_bomb.wav` | Bomba atrapada | 0.20–0.50 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/ghost_whack_hit.wav` | Fantasma correcto | 0.10–0.40 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/ghost_whack_friend.wav` | Fantasma amigo golpeado | 0.20–0.50 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/haunted_maze_candy.wav` | Dulce recogido | 0.10–0.30 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/haunted_maze_exit.wav` | Llegada a la salida | 0.30–0.80 s | Diseñador 2 / audio |
| P0 | `assets/audio/sfx/time_up.wav` | Termina el reloj | 0.40–1.00 s | Diseñador 2 / audio |
| P1 | `assets/audio/sfx/new_record.wav` | Nuevo récord | 0.50–1.50 s | Diseñador 2 / audio |
| P1 | `assets/audio/music/haunted_maze_ambience.ogg` | Ambiente opcional del laberinto | Bucle de 30–60 s | Diseñador 2 / audio |

P0 son **2 bucles y 10 efectos**. Si el tiempo aprieta, empezar por `ui_confirm`, un acierto, un error, `time_up` y un solo bucle compartido; los demás se completan después. No bloquear la jugabilidad mientras llegan los archivos.

## Mezcla e implementación

1. Importar música en el bus `Music` y efectos en `SFX` mediante `AudioManager.play_music()` y `AudioManager.play_sfx()`; no crear reproductores dispersos para cada pantalla.
2. Mantener los efectos más claros que la música. Tomar el nivel actual de `Music` (-6 dB en `default_bus_layout.tres`) como punto de partida y ajustar **escuchando en navegador**. Evitar clipping en `Master`.
3. Efectos que se repiten rápido (calabazas, fantasmas): usar pequeñas variaciones de tono ya soportadas por `AudioManager.play_sfx(stream, pitch_variation)` y evitar que el mismo sonido se dispare muchas veces en un solo frame.
4. Al pasar de menú a partida, cambiar de pista con un fundido corto; no superponer dos bucles a volumen completo. Al volver al hub, recuperar la música de menú.
5. Añadir controles separados Música y SFX (0–100 %) y un botón Silenciar en menú/pausa. Para esta versión basta con recordar el ajuste durante la sesión.
6. Cada efecto esencial necesita feedback visual equivalente; el juego debe seguir siendo comprensible sin audio.

**Especificación de archivos:** OGG estéreo para música; WAV u OGG para efectos breves; 44.1 o 48 kHz; sin silencio accidental al inicio; bucles que empalmen sin clic; picos sin saturación. Entregar también un registro simple de autoría/licencia y versión para cada archivo. El nombre debe coincidir exactamente con esta tabla o actualizarse en código y documentación de forma coordinada.

## Prueba de aceptación

- En Web PC, el audio comienza después de la interacción del usuario y no genera errores de reproducción.
- Música y efectos funcionan por separado; Silenciar apaga ambos y se puede revertir.
- Cinco minutos de juego continuo sin que un bucle haga clic o un efecto repetido resulte molesto.
- Premio, error y fin de tiempo se distinguen con los ojos cerrados; con sonido apagado también se distinguen visualmente.
- No hay clips por encima de `Master` ni cambios bruscos de volumen entre pantallas.
