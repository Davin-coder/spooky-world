---
name: editar-escenas-tscn
description: Cómo crear o modificar escenas .tscn y recursos .tres de Godot 4 sin romperlos, a mano o con el MCP de Godot. Úsala antes de tocar cualquier .tscn o .tres.
---

# Editar escenas `.tscn` y recursos `.tres`

Lo preferible es editar escenas **en el editor de Godot** (directamente o por el MCP).
Edita el texto a mano solo para cambios pequeños y siguiendo estas reglas.

## Antes de tocar una escena

1. ¿Es tuya? Revisa el dueño en `AGENTS.md`. Si no lo es, no la edites: pídeselo al dueño.
2. ¿El editor la tiene abierta? Ciérrala o recárgala después: el editor puede sobreescribir tus cambios al guardar.
3. Haz commit antes de un cambio grande.

## Formato (Godot 4, `format=3`)

```
[gd_scene format=3]

[ext_resource type="Script" path="res://scenes/minigames/x/x.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/minigames/x/item.tscn" id="2_item"]

[sub_resource type="CircleShape2D" id="CircleShape2D_item"]
radius = 22.0

[node name="X" type="Node2D"]
script = ExtResource("1_script")

[node name="SpawnTimer" type="Timer" parent="."]
unique_name_in_owner = true

[node name="Shape" type="CollisionShape2D" parent="Item"]
shape = SubResource("CircleShape2D_item")
```

Reglas:

- Orden: cabecera → `ext_resource` → `sub_resource` → nodos (raíz primero, padres antes que hijos).
- La raíz no tiene `parent`; sus hijos directos usan `parent="."`; los nietos, `parent="Hijo"` o `parent="Hijo/Nieto"`.
- Los `id` de `ext_resource` y `sub_resource` son únicos dentro del archivo; las referencias usan exactamente ese id.
- Al editar a mano se pueden omitir los `uid="uid://..."`: Godot los agrega al guardar. **Nunca inventes un uid.**
- Instanciar otra escena: `[node name="Hud" parent="." instance=ExtResource("2_hud")]`.
- Para que el script use `%Nombre`, el nodo necesita `unique_name_in_owner = true`.
- Colores como `Color(r, g, b, a)` con valores de 0 a 1.
- Rutas siempre `res://...` y en minúsculas (Linux y Web distinguen mayúsculas).

## Recurso de ficha (`minigame_info.tres`)

```
[gd_resource type="Resource" script_class="MinigameInfo" format=3]

[ext_resource type="Script" path="res://shared/minigame_info.gd" id="1_info"]

[resource]
script = ExtResource("1_info")
id = &"pumpkin_catch"
display_name = "Pumpkin Catch"
scene_path = "res://scenes/minigames/pumpkin_catch/pumpkin_catch.tscn"
order = 1
enabled = true
```

## Mover o renombrar archivos

- Hazlo **desde el editor** (FileSystem → Rename/Move): actualiza las referencias.
- Si lo haces por consola o MCP, busca la ruta vieja en todo el repo (`grep -r "res://ruta/vieja"`) y actualízala.

## Conflictos de Git en `.tscn`

No se mezclan a mano. Se conserva la versión del dueño (`git checkout --theirs` / `--ours`, según el caso) y el otro rehace su cambio en el editor.

## Verificar

- Abre la escena en el editor: sin "Missing dependencies" ni errores en la salida.
- Corre la escena (F6) o la prueba de humo `tools/smoke_test.gd`.
