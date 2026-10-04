class_name Player
extends CharacterBody2D

## 变色玩法：换色时发出，供 HUD 更新显示。
signal color_changed(new_color: Color, color_name: String)

## 角色控制器：横板卷轴平台跳跃。
## 左右移动 + 真实重力 + 起跳落地；保留变色玩法（1/2/3 选色，E 上色）。

enum State {
	IDLE,
	WALK,
	RUN,
	JUMP,
}

const STATE_NAMES: Array[String] = ["idle", "walk", "run", "jump"]

@export_group("Movement")
@export_range(0.0, 2000.0, 1.0) var walk_speed := 120.0
@export_range(0.0, 3000.0, 1.0) var run_speed := 220.0

@export_group("Jump")
@export_range(0.0, 3000.0, 1.0) var gravity := 1200.0
@export_range(0.0, 1000.0, 1.0) var jump_velocity := 320.0

@export_group("Visual")
@export_range(1.0, 8.0, 0.5) var pixel_scale := 1.0
@export var animation_frames: SpriteFrames

@export_group("Interact")
@export_range(8.0, 256.0, 1.0) var interact_range := 48.0
@export_range(1.0, 8.0, 0.5) var outline_width := 2.0
@export var outline_color := Color(1.0, 0.95, 0.4)

const OUTLINE_SHADER := preload("res://shaders/outline.gdshader")

var state: int = State.IDLE
var facing_right := true
var selected_color := Color(0.25, 0.85, 0.35)
var selected_color_name := "绿"

var _outline_material: ShaderMaterial
var _highlighted: Node = null
var _highlight_outline: Sprite2D = null

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	_register_input_actions()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(pixel_scale, pixel_scale)
	if animation_frames != null:
		sprite.sprite_frames = animation_frames
	_apply_animation()
	color_changed.emit(selected_color, selected_color_name)
	_outline_material = ShaderMaterial.new()
	_outline_material.shader = OUTLINE_SHADER
	_outline_material.set_shader_parameter("outline_width", outline_width)
	_outline_material.set_shader_parameter("outline_color", outline_color)


func _physics_process(delta: float) -> void:
	_handle_color_input()
	_update_highlight()

	var input_x := Input.get_axis("move_left", "move_right")
	var running := Input.is_action_pressed("run")

	# 重力（贴地时不叠加，避免落地抖动）。
	if not is_on_floor():
		velocity.y += gravity * delta

	# 水平移动。
	var speed := run_speed if running else walk_speed
	velocity.x = input_x * speed
	if input_x != 0.0:
		facing_right = input_x > 0.0

	# 起跳。
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity

	move_and_slide()

	# 状态判定（先看是否离地，再看水平输入）。
	if not is_on_floor():
		state = State.JUMP
	elif input_x != 0.0:
		state = State.RUN if running else State.WALK
	else:
		state = State.IDLE

	_apply_animation()


func _apply_animation() -> void:
	# 素材只有朝右的帧，朝左用 flip_h 镜像。
	sprite.play("%s_right" % STATE_NAMES[state])
	sprite.flip_h = not facing_right


func _handle_color_input() -> void:
	if Input.is_action_just_pressed("select_green"):
		_select_color(Color(0.25, 0.85, 0.35), "绿")
	elif Input.is_action_just_pressed("select_blue"):
		_select_color(Color(0.3, 0.55, 1.0), "蓝")
	elif Input.is_action_just_pressed("select_red"):
		_select_color(Color(1.0, 0.3, 0.3), "红")
	if Input.is_action_just_pressed("interact"):
		_interact()


func _select_color(c: Color, color_name: String) -> void:
	selected_color = c
	selected_color_name = color_name
	color_changed.emit(c, color_name)


func _interact() -> void:
	var target := _nearest_colorable()
	if target != null:
		target.call("apply_color", selected_color)


## 取圆形范围内（interact_range）最近、且能上色（有 apply_color）的物体。
func _nearest_colorable() -> Node:
	var best: Node = null
	var best_d := INF
	for obj in get_tree().get_nodes_in_group("colorable"):
		if not obj.has_method("apply_color"):
			continue
		var n := obj as Node2D
		if n == null:
			continue
		var dist := global_position.distance_to(n.global_position)
		if dist > interact_range:
			continue
		if dist < best_d:
			best_d = dist
			best = n
	return best


## 给当前最近的可上色物体加描边提示，目标变化时自动切换。
func _update_highlight() -> void:
	var target := _nearest_colorable()
	if target == _highlighted:
		return
	_clear_highlight()
	if target != null:
		_highlighted = target
		_add_outline(target)


func _add_outline(target: Node) -> void:
	var sprite_node := target as Sprite2D
	if sprite_node == null:
		return
	_highlight_outline = Sprite2D.new()
	_highlight_outline.texture = sprite_node.texture
	_highlight_outline.centered = sprite_node.centered
	_highlight_outline.material = _outline_material
	_highlight_outline.show_behind_parent = true
	sprite_node.add_child(_highlight_outline)


func _clear_highlight() -> void:
	if _highlight_outline != null:
		_highlight_outline.queue_free()
		_highlight_outline = null
	_highlighted = null


func _register_input_actions() -> void:
	_add_action("move_left", [KEY_A, KEY_LEFT])
	_add_action("move_right", [KEY_D, KEY_RIGHT])
	_add_action("run", [KEY_SHIFT])
	_add_action("jump", [KEY_SPACE])
	_add_action("select_green", [KEY_1])
	_add_action("select_blue", [KEY_2])
	_add_action("select_red", [KEY_3])
	_add_action("interact", [KEY_E])


func _add_action(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
