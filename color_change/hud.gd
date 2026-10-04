extends CanvasLayer
## 顶部 HUD：显示当前选中的颜色与操作说明。

@onready var color_label: Label = $ColorLabel


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.color_changed.connect(_on_color_changed)
		_on_color_changed(player.selected_color, player.selected_color_name)


func _on_color_changed(new_color: Color, color_name: String) -> void:
	color_label.text = "当前颜色：%s　（1=绿　2=蓝　3=红）" % color_name
	color_label.modulate = new_color
