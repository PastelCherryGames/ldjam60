extends CustomWindow
class_name InternetApp


#@onready var inbox_vbox: Container = %InboxVBox


func _ready() -> void:
	super()


func toggle_window(should_show: bool) -> void:
	super(should_show)
	if should_show:
		pass
