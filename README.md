# Spooky World

Colección de minijuegos de Halloween hecha en Godot 4 durante una hackatón de 6 horas por JamarTeam.

**Menú → Hub → Minijuego → Resultados → Hub**

| Minijuego | Cómo se juega | Estado |
| --- | --- | --- |
| Pumpkin Catch | Mueve la canasta (← → / A D), atrapa calabazas y evita bombas | Jugable con placeholders |
| Ghost Whack | Haz clic en los fantasmas blancos, no en los naranjas | Jugable con placeholders |
| Haunted Maze | Llega a la salida (flechas / WASD) recogiendo dulces | Opcional, jugable con placeholders |

## Empezar

1. Instala **Godot 4.7.2** (estándar, no .NET). Todo el equipo debe usar la misma versión exacta.
2. Clona el repo y abre `project.godot` desde el Project Manager.
3. Espera a que termine la importación inicial (crea la carpeta `.godot/`, que no se versiona).
4. **F5** para jugar el flujo completo. **F6** sobre la escena de un minijuego para probarlo solo.

Controles: flechas o WASD para moverse, Espacio o clic para acción, **Esc** para volver.

## Estructura

```
autoload/      GameManager, SceneLoader, AudioManager
shared/        Contrato Minigame, MinigameInfo, Palette, HUD
scenes/        Menú, hub, resultados, host y minigames/<id>/
assets/        Arte, audio y fuentes (ver docs/ASSETS.md)
tools/         Prueba de humo
docs/          Plan, arquitectura y spec de assets
.agents/skills Procedimientos para agentes de IA (y humanos)
```

Detalle en [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md).

## Documentos

- [`AGENTS.md`](AGENTS.md): contexto y reglas del proyecto (lo leen Codex y Claude; léelo tú también).
- [`docs/PLAN.md`](docs/PLAN.md): plan de la hackatón, cronograma y roles.
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
