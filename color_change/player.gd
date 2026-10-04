extends CharacterBody2D
## 玩家角色：WASD / 方向键移动，靠近白色物体按 E 上色，数字键 1/2/3 选择颜色。

signal color_changed(new_color: Color, color_name: String)

const SPEED := 260.0

# 1=绿 2=蓝 3=红，默认选中绿色
var selected_color := Color(0.25, 0.85, 0.35)
var selected_color_name := "绿"

@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	color_changed.emit(selected_color, selected_color_name)


func _physics_process(_delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1.0
	velocity = dir.normalized() * SPEED
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_select_color(Color(0.25, 0.85, 0.35), "绿")
			KEY_2:
				_select_color(Color(0.3, 0.55, 1.0), "蓝")
			KEY_3:
				_select_color(Color(1.0, 0.3, 0.3), "红")
			KEY_E:
				_interact()


func _select_color(c: Color, color_name: String) -> void:
	selected_color = c
	selected_color_name = color_name
	color_changed.emit(c, color_name)


func _interact() -> void:
	var target = _nearest_colorable()
	if target:
		target.apply_color(selected_color)


func _nearest_colorable():
	var best = null
	var best_d := INF
	for body in interaction_area.get_overlapping_bodies():
		if body.is_in_group("colorable"):
			var d := global_position.distance_squared_to(body.global_position)
			if d < best_d:
				best_d = d
				best = body
	return best
