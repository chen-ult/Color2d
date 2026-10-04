class_name ColorableSprite
extends Sprite2D
## 可上色物体（Sprite 版）：初始保持原色，被上色后用 modulate 染色。


func apply_color(c: Color) -> void:
	modulate = c
