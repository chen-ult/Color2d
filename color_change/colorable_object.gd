extends StaticBody2D
## 可上色物体：初始为白色，玩家靠近并按 E 后变成当前选中的颜色。

@onready var front: Polygon2D = $Front
@onready var top_face: Polygon2D = $Top


func apply_color(c: Color) -> void:
	front.color = c
	top_face.color = c.lightened(0.18)
