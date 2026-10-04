extends Node
## 颜色系统：调色板 + 颜色语义表 + 当前选中色。

const RED := Color(0.85, 0.28, 0.28)
const BLUE := Color(0.30, 0.55, 1.00)
const GREEN := Color(0.25, 0.85, 0.35)
const BLACK := Color(0.10, 0.10, 0.13)
const WHITE := Color(1.00, 1.00, 1.00)

## 颜色 -> 语义（策划的核心规则表）
const SEMANTICS := {
	"red": "strength",
	"blue": "stability",
	"green": "grow",
	"black": "hide",
	"white": "reset",
}

## 调色板（顺序对应选色键 1~5）
const PALETTE := [
	{"name": "red", "color": RED},
	{"name": "blue", "color": BLUE},
	{"name": "green", "color": GREEN},
	{"name": "black", "color": BLACK},
	{"name": "white", "color": WHITE},
]

var current_color: Color = RED
var current_color_name: String = "red"

signal color_selected(color: Color, color_name: String)


func select_color(color: Color, color_name: String) -> void:
	current_color = color
	current_color_name = color_name
	color_selected.emit(color, color_name)
	EventBus.emit("color_selected", {"color": color, "color_name": color_name})


func select_color_by_index(index: int) -> void:
	if index < 0 or index >= PALETTE.size():
		return
	var entry: Dictionary = PALETTE[index]
	select_color(entry["color"], entry["name"])


func get_semantic(color_name: String) -> String:
	return str(SEMANTICS.get(color_name, ""))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				select_color_by_index(0)
			KEY_2:
				select_color_by_index(1)
			KEY_3:
				select_color_by_index(2)
			KEY_4:
				select_color_by_index(3)
			KEY_5:
				select_color_by_index(4)
