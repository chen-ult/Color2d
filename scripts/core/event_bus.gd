extends Node
## 事件总线：模块间通信的唯一桥梁。
## 用法：
##   EventBus.subscribe("color_applied", _on_color_applied)
##   EventBus.emit("color_applied", {"color": Color.RED})
## 约定：回调函数接收 1 个参数（payload，可为 null）。

var _subscribers: Dictionary = {}


func subscribe(event_name: String, callback: Callable) -> void:
	if not _subscribers.has(event_name):
		_subscribers[event_name] = []
	var list: Array = _subscribers[event_name]
	if callback not in list:
		list.append(callback)


func unsubscribe(event_name: String, callback: Callable) -> void:
	if _subscribers.has(event_name):
		var list: Array = _subscribers[event_name]
		list.erase(callback)


func emit(event_name: String, payload = null) -> void:
	if not _subscribers.has(event_name):
		return
	var list: Array = _subscribers[event_name]
	for cb in list.duplicate():
		var callable: Callable = cb
		if callable.get_argument_count() == 0:
			callable.call()
		else:
			callable.call(payload)
