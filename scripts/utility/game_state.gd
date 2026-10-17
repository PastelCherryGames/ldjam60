extends Node
#class_name GameState


@warning_ignore("unused_signal")
signal app_requested(app: E.App)


@export var app_names: Dictionary[E.App, String] = {}


func destroy_tween(tween: Tween) -> Tween:
	if tween != null: tween.kill()
	return null
