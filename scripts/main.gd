extends Control
class_name Main


@onready var start_screen: CustomTweener = %StartScreen


func _ready() -> void:
	start_screen.show()
	#await start_screen.toggle_finished
	remove_child(start_screen)
	start_screen.queue_free()
