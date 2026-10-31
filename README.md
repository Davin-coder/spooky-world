# Spooky World

Colección de minijuegos de Halloween hecha en Godot 4 durante una hackatón de 6 horas por JamarTeam.

**Menú → Hub → Minijuego → Resultados → Hub**

| Minijuego | Cómo se juega | Estado |
| --- | --- | --- |
| Pumpkin Catch | Mueve la canasta (← → / A D), atrapa calabazas y evita bombas | Jugable con placeholders |
| Ghost Whack | Haz clic en los fantasmas blancos, no en los naranjas | Jugable con placeholders |
| Haunted Maze | Llega a la salida (flechas / WASD) recogiendo dulces | Opcional, jugable con placeholders |
| Última guardia | Sobrevive a zombis con pistola, recarga y esquiva | Sección Pixel art · jugable |

## Empezar

1. Instala **Godot 4.7.2** (estándar, no .NET). Todo el equipo debe usar la misma versión exacta.
2. Clona el repo y abre `project.godot` desde el Project Manager.
3. Espera a que termine la importación inicial (crea la carpeta `.godot/`, que no se versiona).
4. **F5** para jugar el flujo completo. **F6** sobre la escena de un minijuego para probarlo solo.

Controles: flechas o WASD para moverse, Espacio o clic para acción, **Esc** para volver.

En el hub elige **Pixel art · Acción** para jugar **Última guardia**: WASD/flechas para moverte, ratón para apuntar, clic para disparar, R para recargar, Espacio para esquivar y Esc para pausar. Partidas de 60 segundos con oleadas, cobertura, botiquines y resultados propios en pixel art.

## Estructura

```
autoload/      GameManager, SceneLoader, AudioManager
shared/        Contrato Minigame, MinigameInfo, Palette, HUD
scenes/        Menú, hub, resultados, host y minigames/<id>/
assets/        Arte, audio y fuentes (ver docs/ASSETS.md)
tools/         Pruebas de carga y flujo
docs/          Plan, arquitectura y spec de assets
.agents/skills Procedimientos para agentes de IA (y humanos)
```

Detalle en [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md).

## Documentos

- [`AGENTS.md`](AGENTS.md): contexto y reglas del proyecto (lo leen Codex y Claude; léelo tú también).
- [`docs/PLAN.md`](docs/PLAN.md): plan de la hackatón, cronograma y roles.
- [`docs/PLAN_MEJORAS.md`](docs/PLAN_MEJORAS.md): prioridades después del MVP, responsables y criterios de salida.
- [`docs/UX_UI.md`](docs/UX_UI.md): propuesta visual 2D, recorrido y sustitución del fondo temporal.
- [`docs/AUDIO.md`](docs/AUDIO.md): inventario y mezcla de música y efectos para Web.
- [`docs/PIXEL_ART.md`](docs/PIXEL_ART.md): contrato visual y sustitución de sprites de la sección arcade.
- [`docs/ZOMBIE_OUTBREAK.md`](docs/ZOMBIE_OUTBREAK.md): diseño, arquitectura, referencias y plan del shooter.
- [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md): cómo encajan las piezas.
- [`docs/ASSETS.md`](docs/ASSETS.md): especificación para el equipo de diseño.
- [`CONTRIBUTING.md`](CONTRIBUTING.md): Git y trabajo en equipo.

## Verificación

```bash
pip install "gdtoolkit==4.*"
gdlint $(git ls-files '*.gd')
gdformat --check $(git ls-files '*.gd')
godot --headless --path . -s res://tools/smoke_test.gd   # requiere haber abierto el proyecto una vez
godot --headless --path . res://tools/flow_test.tscn     # prueba menú → hub → partida → resultados
```

En Windows (PowerShell), con la ruta de tu Godot:

```powershell
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_console.exe" --headless --path . -s res://tools/smoke_test.gd
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2\Godot_console.exe" --headless --path . res://tools/flow_test.tscn
```

GitHub Actions ejecuta `gdlint` y `gdformat --check` en cada push a `main` o `develop` y en cada PR.

## Equipo

JamarTeam: 2 desarrolladores y 2 diseñadores.
