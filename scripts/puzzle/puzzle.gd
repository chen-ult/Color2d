class_name Puzzle
extends Node
## 谜题基类：关卡程序继承它写具体谜题。

enum State { INACTIVE, ACTIVE, SOLVED }

signal solved(puzzle_id: String)

@export var puzzle_id: String = "puzzle"

var state: int = State.INACTIVE


func activate() -> void:
	if state == State.INACTIVE:
		state = State.ACTIVE
		_on_activate()


func mark_solved() -> void:
	if state == State.SOLVED:
		return
	state = State.SOLVED
	solved.emit(puzzle_id)
	EventBus.emit("puzzle_solved", {"puzzle_id": puzzle_id})


func is_solved() -> bool:
	return state == State.SOLVED


func _on_activate() -> void:
	pass
