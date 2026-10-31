# Plan de la hackatón (6 horas)

Meta: un juego jugable de principio a fin. Menú → hub → 2 minijuegos garantizados (+1 opcional) → resultados.
**A las 4 h 30 se congelan las features.**

## Equipo y roles

| Persona | Responsabilidad |
| --- | --- |
| Dev 1 | Menú, hub, autoloads, `project.godot`; luego Ghost Whack e integración |
| Dev 2 | Pumpkin Catch; luego Haunted Maze (opcional) |
| Diseñador 1 | Estilo (con Diseñador 2) y arte de los minijuegos; video demo |
| Diseñador 2 | Estilo, UI (menú, hub, HUD), título y audio; retoques |

## Cronograma

| Tramo | Todo el equipo | Dev 1 | Dev 2 | Diseñador 1 | Diseñador 2 |
| --- | --- | --- | --- | --- | --- |
| 0:00–0:30 | Kickoff, setup, export de prueba | | | | |
| 0:30–1:00 | | Menú, hub, autoloads | Pumpkin Catch | Estilo | Estilo |
| 1:00–2:00 | | Menú, hub, autoloads | Pumpkin Catch | Arte minijuegos | UI: menú, hub, HUD |
| 2:00–3:00 | | Ghost Whack | Pumpkin Catch → Haunted Maze (2:30) | Arte minijuegos | UI |
| 3:00–4:30 | | Ghost Whack + integración | Haunted Maze (opcional) | Arte minijuegos | Título y audio |
| 4:30 | **Congelar features** | | | | |
| 4:30–5:30 | | Pulido y bugs | Solo bugs | Video demo | Retoques |
| 5:30–6:00 | Export y prueba final | | | | |

## Hitos

- **1:00**: export vacío probado en la plataforma final.
- **2:00**: hub navegable con un minijuego jugable.
- **4:30**: todo lo jugable en `main`; lo demás, `enabled = false`.
- **5:30**: build final generado.

## Acuerdos de los primeros 30 minutos

- Plataforma de entrega: Web o Windows.
- Estilo: pixel art o ilustrado (si es pixel art: tile de 16 o 32 px y filtro Nearest).
- Paleta: `shared/palette.gd` (5–8 colores).
- Fuente principal.

## Fuera de alcance

Guardado a disco, multijugador en red, opciones avanzadas, localización, logros.

## Riesgos

| Riesgo | Señal | Plan B |
| --- | --- | --- |
| Un minijuego no llega | No es jugable a las 4:00 | `enabled = false`, se presenta con 2 |
| Assets tarde | Sin arte a las 3:00 | Placeholders con la paleta |
| Export falla | Error en la hora 1 | Windows o video del editor |
| Git roto | `main` no abre | Revertir al último commit jugable |
| MCP caído | Errores de conexión repetidos | Seguir a mano; no más de 10 min arreglándolo |
