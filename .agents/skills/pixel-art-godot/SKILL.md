---
name: pixel-art-godot
description: Crear o ampliar juegos y pantallas de la sección Pixel art de Spooky World, manteniendo resolución, paleta, sprites, input y resultados coherentes. No aplicar a las pantallas ilustradas.
---

# Pixel art en Spooky World

Consulta `docs/PIXEL_ART.md` para el contrato visual y `docs/ZOMBIE_OUTBREAK.md` para el juego existente. La sección se solicita expresamente por el usuario y convive con la colección ilustrada.

- La ficha `MinigameInfo.collection` debe ser `pixel_art`; GameManager conserva la categoría al volver al hub.
- Usa un `SubViewport` de 320×180 dentro de `SubViewportContainer`, escalado por 4 con filtro `NEAREST`. No cambies el filtro global del proyecto, porque afectaría a las ilustraciones.
- Todo lo que pertenece a la partida (escenario, actores, partículas, texto y pausa) se dibuja dentro del viewport lógico. No colocar un HUD suave de alta resolución encima del juego pixel.
- Convierte el ratón del viewport raíz a coordenadas lógicas: `mouse * Vector2(320, 180) / root_viewport_size`. La prueba debe cubrir esquinas y ventanas escaladas.
- Conserva los colores `Palette.PIXEL_*`, `PUMPKIN`, `SLIME`, `BONE` y `BLOOD`. Usa posiciones redondeadas al dibujar; mantén posiciones continuas en la simulación.
- Para sprites finales, conserva tamaño lógico, centro y transparencia; no aumentes resolución para simular más detalle. El contrato de archivos está en `docs/PIXEL_ART.md`.
- Las pantallas de resultados opcionales extienden `MinigameResults` y solo emiten `retry_requested` y `hub_requested`. La pantalla común sigue siendo quien conecta navegación.

El ejemplo actual usa PNG originales generados desde `OutbreakArt` y una fuente bitmap 5×7. `tools/build_outbreak_art.gd` crea archivos faltantes y conserva los existentes. No uses el generador para reemplazar una entrega de diseño.

Verifica el filtro, lectura del HUD, puntería, pausa, retorno a la sección y resultados con la exportación Web o un renderer gráfico. La prueba headless valida lógica, pero no demuestra nitidez visual ni reproducción en navegador.
