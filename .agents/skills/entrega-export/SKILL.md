---
name: entrega-export
description: Exporta Spooky World (Web o Windows) y corre el checklist de entrega final de la hackatón. Úsala para el export de prueba de la hora 1 y para la entrega desde las 5 h 30.
---

# Export y entrega

## Export de prueba (hora 1)

El objetivo es descubrir problemas de export **temprano**, con el proyecto casi vacío.

1. Editor → Project → Export → Add preset (**Web** o **Windows Desktop**).
2. Si faltan las plantillas: "Manage Export Templates" → Download (la misma versión exacta del editor).
3. Exporta a `build/web/index.html` o `build/windows/spooky_world.exe` (`build/` está en `.gitignore`).
4. Prueba:
   - **Web**: debe servirse por HTTP, no abriendo el archivo. Desde `build/web`: `python -m http.server 8000` y abre `http://localhost:8000`.
   - **Windows**: ejecuta el `.exe` en otra máquina si es posible.
5. Guarda el preset: `export_presets.cfg` **sí** se versiona (sin credenciales).

Notas para Web: usa el renderer GL Compatibility (ya está configurado). El audio arranca después del primer clic del usuario (lo exige el navegador). El botón "Salir" se oculta solo.

## Congelar features (4 h 30)

- Todo lo que no esté jugable: `enabled = false` en su `minigame_info.tres`.
- Merge final de todas las ramas a `main`.
- Desde aquí: solo bugs, balance de números `@export`, arte y audio.

## Checklist de entrega (5 h 30)

- [ ] El juego abre en el menú y llega al hub.
- [ ] Cada minijuego habilitado: cuenta regresiva → juego → termina solo → resultados → "Otra vez" y "Volver al hub" funcionan.
- [ ] `back` (Esc) en un minijuego vuelve al hub sin errores.
- [ ] Cero errores en rojo en el Debugger durante una partida completa.
- [ ] `godot --headless --path . -s res://tools/smoke_test.gd` → `SMOKE TEST OK`.
- [ ] Música y efectos con volumen equilibrado.
- [ ] Pantalla de título con "Spooky World" y créditos del equipo.
- [ ] Export final probado en una máquina distinta a la que lo generó.
- [ ] Video o GIF de 30 s para la presentación.
- [ ] Tag en git: `git tag v1.0-hackaton`.

## Plan B

| Problema | Qué hacer |
| --- | --- |
| El export Web falla | Entregar build de Windows |
| Ningún export funciona | Grabar un video jugando desde el editor |
| Un minijuego crashea | `enabled = false` y entregar con los demás |
