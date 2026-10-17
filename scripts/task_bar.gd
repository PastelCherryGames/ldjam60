extends PanelContainer
class_name TaskBar


@onready var email_button: BaseButton = %EmailButton
@onready var internet_button: BaseButton = %InternetButton
@onready var blog_button: BaseButton = %BlogButton
@onready var portal_button: BaseButton = %PortalButton


func _ready() -> void:
	portal_button.hide()
	email_button.pressed.connect(_request_app.bind(E.App.EMAIL))
	internet_button.pressed.connect(_request_app.bind(E.App.INTERNET))
	blog_button.pressed.connect(_request_app.bind(E.App.BLOG))


func _request_app(app: E.App) -> void:
	GameState.app_requested.emit(app)


func _activate_portal_button() -> void:
	portal_button.show()
	portal_button.pressed.connect(_request_app.bind(E.App.PORTAL))
