extends PanelContainer
class_name CustomWindow


@export var own_app: E.App

@onready var hide_show_tweener: CustomTweener = %HideShowTweener
@onready var window_label: Label = %WindowLabel
@onready var close_button: BaseButton = %CloseButton


func _ready() -> void:
	GameState.app_requested.connect(_check_if_toggle_window)
	close_button.pressed.connect(toggle_window.bind(false))
	if GameState.app_names.keys().has(own_app):
		window_label.text = GameState.app_names[own_app]


func toggle_window(should_show: bool) -> void:
	hide_show_tweener.toggle(should_show)


func _check_if_toggle_window(requested_app: E.App) -> void:
	toggle_window(requested_app == own_app && hide_show_tweener.toggle_state == false)
