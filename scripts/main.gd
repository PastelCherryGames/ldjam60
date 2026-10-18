extends Control
class_name Main


@onready var start_screen: CustomTweener = %StartScreen


func _ready() -> void:
	start_screen.show()
	await start_screen.toggle_finished
	await get_tree().create_timer(0.5).timeout
	GameState.app_requested.emit(E.App.EMAIL)
	remove_child(start_screen)
	start_screen.queue_free()
