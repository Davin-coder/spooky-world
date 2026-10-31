# Plan de mejoras posterior al MVP

Estado de partida: el flujo **Menú → Hub → Minijuego → Resultados → Hub** funciona; hay tres minijuegos jugables con arte provisional, un HUD común, `AudioManager` y buses `Music`/`SFX`. Las carpetas de arte y audio aún no contienen las entregas finales. Este plan mejora la experiencia sin rehacer la arquitectura de minijuegos.

## Decisiones de producto

- **Plataforma principal:** Web en PC, con teclado y ratón. Windows queda como respaldo de exportación. Probar en navegador real, además del editor.
- **Dirección visual:** ilustración 2D de Halloween amable, con la paleta de `shared/palette.gd`. La diseñadora produce calabazas, velas y demás arte definitivo. El fondo ilustrado del menú es **temporal**; ver [UX/UI](UX_UI.md) y [especificación de assets](ASSETS.md).
- **Sesión objetivo:** entrar a un minijuego en dos decisiones (Jugar → elegir juego), entender sus controles antes de empezar y poder repetirlo desde Resultados.
- **Alcance:** primero claridad, feedback y rendimiento. No iniciar un cuarto minijuego antes de que los tres actuales estén bien pulidos.

## Orden de trabajo

Las estimaciones son **horas de trabajo de una persona**, no una fecha de entrega. P0 debe quedar listo antes de una demo pública; P1 mejora retención y acabado; P2 es opcional.

| ID | Prioridad | Entrega | Responsable | Estimación | Dependencia / comprobación |
| --- | --- | --- | --- | ---: | --- |
| P0-01 | P0 | Tema visual compartido de botones, paneles, foco y tipografía | Diseñadora UI + Dev 1 | 6–8 h | Usar un `Theme` común; menú, hub y resultados se ven coherentes |
| P0-02 | P0 | Fondo temporal del menú integrado y contrato de sustitución para arte final | Dev 1 + diseñadora | 1–2 h | El PNG se cambia por otro de la misma ruta sin modificar la escena |
| P0-03 | P0 | Tarjetas del hub con imagen, controles y récord visibles, no solo tooltip | Diseñadora UI + Dev 1 | 4–6 h | Se puede elegir con ratón y solo teclado; cada juego se entiende antes de entrar |
| P0-04 | P0 | Pausa con Esc: Reanudar / Reiniciar / Salir al hub, con confirmación al abandonar | Dev 1 | 4–6 h | Esc ya no descarta una partida por accidente; tiempo y spawns se detienen |
| P0-05 | P0 | Feedback claro de acierto, error, tiempo restante y resultado | Dev 1 + Dev 2 | 6–8 h | Cada evento tiene señal visual; ninguna información depende solo del sonido o color |
| P0-06 | P0 | Música y efectos esenciales conectados a `AudioManager` | Diseñador/a de sonido + Dev 1/2 | 6–10 h | Ver [plan de audio](AUDIO.md); silencio y volúmenes aceptables en Web |
| P0-07 | P0 | Ajuste de dificultad con 5 pruebas de personas externas al equipo | Dev 1 + Dev 2 | 4–6 h | Registrar bloqueos, abandonos y tiempos por minijuego |
| P0-08 | P0 | Export Web, prueba de carga, controles, sonido y rendimiento en navegadores de PC | Dev 1 | 3–5 h | Demo jugable sin errores rojos, sin enlaces a assets locales |
| P1-01 | P1 | Breve pantalla de instrucciones por minijuego antes de la cuenta regresiva | Diseñadora UI + Dev 1 | 3–4 h | Se entiende en 5 s y se puede omitir al repetir |
| P1-02 | P1 | Animaciones cortas y partículas de recompensa/penalización | Diseñadora de arte + Dev 1/2 | 5–8 h | No tapan el área jugable; opción de movimiento reducido |
| P1-03 | P1 | Control de volumen Música/SFX y botón Silenciar | Dev 1 | 3–5 h | Disponible desde menú o pausa; se respeta durante la sesión |
| P1-04 | P1 | Resultados con récord, comparación y siguiente acción destacada | Diseñadora UI + Dev 1 | 3–4 h | Repetir y volver al hub son inequívocos |
| P2-01 | P2 | Variaciones de música y ambientación por minijuego | Diseño de sonido | 5–8 h | Solo después de estabilizar el mix básico |
| P2-02 | P2 | Más niveles/variantes de los tres juegos existentes | Dev 1/2 | A estimar | Requiere datos de las pruebas y un nuevo objetivo de duración |

## Reparto por fases

1. **Fase A — claridad (P0-01 a P0-04):** acordar estilo de UI, implantar tema, tarjetas y pausa. Dev 1 toca solo flujo/UI compartidos; Dev 2 sigue con minijuegos. La diseñadora entrega componentes y estados.
2. **Fase B — sensación de juego (P0-05 a P0-07):** arte y audio se integran por carpeta dueña. Ajustar un juego cada vez, probarlo con F6 y después desde el hub.
3. **Fase C — salida Web (P0-08):** cerrar bugs, exportar, probar en dos navegadores de PC y hacer una demo de principio a fin. No añadir mecánicas nuevas en esta fase.
4. **Fase D — pulido (P1/P2):** abordar solo lo que las pruebas muestren como problema o lo que aumente claramente la calidad percibida.

## Recomendaciones por minijuego

| Juego | Primera mejora | Señal de éxito |
| --- | --- | --- |
| Pumpkin Catch | La bomba debe diferenciarse por **silueta e icono**, además de rojo; aviso breve antes de aumentar velocidad | Nadie confunde bomba y calabaza en una prueba sin audio |
| Ghost Whack | Fantasma amigo con expresión/silueta distinta; reacción al golpe correcto y al error | La regla “blanco sí, naranja no” se entiende sin leer el tooltip |
| Haunted Maze | Salida con pulso visual y contador de dulces; comprobar que el primer recorrido cabe en 60 s | 4 de 5 personas llegan a la salida tras una sola explicación |

## Criterios de salida de P0

- Cinco personas externas al equipo prueban el juego. Al menos cuatro llegan por sí mismas al primer minijuego y completan una partida.
- Una persona puede recorrer menú, hub, un minijuego y resultados **solo con teclado**; Ghost Whack informa que requiere ratón.
- Texto normal sobre fondos sólidos con contraste objetivo **≥ 4.5:1**; foco visible, indicación de acción además del color y estado usable sin audio. Referencia: [WCAG 2.2, contraste mínimo](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum).
- Sin errores de Godot al iniciar, completar, repetir o abandonar una partida. Pasan `tools/smoke_test.gd`, `tools/flow_test.tscn`, `gdlint` y `gdformat --check`.
- Se prueba la exportación Web a 1280×720 y en una ventana de 1024×576. No se recortan CTA, temporizador ni instrucciones.
- Música y SFX se pueden silenciar; ningún evento esencial se comunica solo por audio.

## Decisiones que faltan antes del arte final

1. Confirmar con la diseñadora si el acabado final será pictórico suave o ilustración de contorno limpio; mantener la misma composición y paleta.
2. Elegir una fuente con licencia de uso en Web y comprobar tildes, `¡`, `¿` y `ñ`.
3. Acordar un presupuesto de peso para la descarga Web y optimizar texturas y audio antes de exportar.
4. Definir quién entrega cada archivo y quién lo importa en Godot; mantener los dueños de `CONTRIBUTING.md`.

## Documentos de entrega

- [UX/UI](UX_UI.md): composición, navegación, estados, accesibilidad y sustitución del arte temporal.
- [Audio](AUDIO.md): música, efectos, mezcla y nombres de archivo.
- [Assets](ASSETS.md): nombres y tamaños de arte ya definidos para el equipo.
