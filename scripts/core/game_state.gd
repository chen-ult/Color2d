extends Node
## 运行时全局状态：当前关卡、进度、已解锁能力。

signal state_changed(key: String, value)

var current_room_id: String = ""
var unlocked_colors: Array[String] = ["red"]
var week_count: int = 1
var flags: Dictionary = {}


func set_flag(key: String, value) -> void:
	flags[key] = value
	state_changed.emit(key, value)
	EventBus.emit("game_state_changed", {"key": key, "value": value})


func get_flag(key: String, default = null):
	return flags.get(key, default)


## 把运行时状态打包成可存档的字典。
func to_dict() -> Dictionary:
	return {
		"current_room_id": current_room_id,
		"unlocked_colors": unlocked_colors,
		"week_count": week_count,
		"flags": flags,
	}


## 从存档字典还原运行时状态。
func from_dict(data: Dictionary) -> void:
	current_room_id = str(data.get("current_room_id", ""))
	week_count = int(data.get("week_count", 1))
	flags = data.get("flags", {}) as Dictionary

	unlocked_colors.clear()
	var loaded_colors = data.get("unlocked_colors", ["red"])
	if loaded_colors is Array:
		for c in loaded_colors:
			unlocked_colors.append(str(c))
	if unlocked_colors.is_empty():
		unlocked_colors.append("red")
