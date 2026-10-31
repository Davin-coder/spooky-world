---
name: zombie-outbreak
description: Ampliar, equilibrar o depurar Última guardia, el shooter 2D de zombis de Spooky World. Incluye pistola, recarga, esquiva, oleadas, cobertura, audio y pruebas del combate.
---

# Trabajar en Última guardia

El juego vive en `scenes/minigames/zombie_outbreak/`. Lee `docs/ZOMBIE_OUTBREAK.md` antes de modificar la mecánica y usa el contrato visual de `docs/PIXEL_ART.md` para el arte.

## Elegir dónde cambiar

| Cambio | Archivo |
| --- | --- |
| Munición, daño, enemigos, colisiones y oleadas | `outbreak_simulation.gd` |
| Traducción de input, pausa del reloj, señales a Minigame | `zombie_outbreak.gd` |
| Escenario, HUD, impactos, mira y pausa visual | `outbreak_arena.gd` |
| Patrones de sprites y fuente bitmap | `outbreak_art.gd` |
| Sonidos PCM y bucle original | `outbreak_audio.gd` |
| Resultados y decisión de repetir/salir | `outbreak_results.gd` y `outbreak_results_canvas.gd` |

La simulación no debe depender de `SceneTree`, `Input`, `GameManager` ni audio real. Recibe delta y decisiones, mantiene entidades tipadas y emite puntos, sonidos y derrota. Usa semillas fijas al reproducir un bug; la partida normal aleatoriza su semilla.

Mantén estas propiedades al ampliar combate:

- Una bala se consume una vez; la cadencia y la recarga bloquean disparos. El cargador vacío permite recarga automática.
- Daño de contacto tiene invulnerabilidad breve. La esquiva tiene tiempo activo y cooldown independientes.
- Enemigos aparecen en bordes lejos del jugador. Mantén límites explícitos de enemigos, balas y partículas para Web.
- El fin y la pausa detienen simulación; la pausa también detiene el Timer de `Minigame`. No pausar los autoloads de navegación.
- Los puntos salen por señal a `add_score`; derrota llama `end_game`. Abandonar emite `exit_requested`. El minijuego no cambia de escena.
- Los enemigos, proyectiles y partículas son datos `RefCounted` acotados, no nodos de física. Si una mecánica futura necesita nodos, separa esa presentación sin duplicar el estado del combate.

## Validación proporcionada al cambio

- Combate: `godot --headless --path . -s res://tools/zombie_simulation_test.gd`.
- Integración: `godot --headless --path . res://tools/zombie_flow_test.tscn`.
- Revisión visual: ejecutar esa escena sin `--headless`, con `-- --capture`, para guardar una captura real en `docs/images/zombie_outbreak.png`.
- Si cambias contratos comunes, ejecutar también las pruebas de humo y flujo de los juegos ilustrados.
- Completar `gdlint` y `gdformat --check` sobre scripts nuevos o modificados.

Para añadir un arma o enemigo, define primero cadencia, daño, telegráfico visual y coste de procesamiento; implementa una variante jugable y comprueba la interacción con cobertura, recarga y pausa antes de añadir más contenido.
