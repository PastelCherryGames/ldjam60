extends PanelContainer
class_name TaskBar


@onready var email_button: BaseButton = %EmailButton
@onready var internet_button: BaseButton = %InternetButton
@onready var blog_button: BaseButton = %BlogButton
@onready var portal_button: BaseButton = %PortalButton
@onready var alert_icon: Container = %AlertIcon

var portal_activated := false


func _ready() -> void:
	portal_button.hide()
	email_button.pressed.connect(_request_app.bind(E.App.EMAIL))
	internet_button.pressed.connect(_request_app.bind(E.App.INTERNET))
	blog_button.pressed.connect(_request_app.bind(E.App.BLOG))
	portal_button.pressed.connect(_request_app.bind(E.App.PORTAL))
	GameState.blog_post_published.connect(_check_if_show_email_alert.unbind(1))
	GameState.email_read.connect(_check_if_show_email_alert.unbind(1))
	_check_if_show_email_alert()


func _request_app(app: E.App) -> void:
	GameState.app_requested.emit(app)


func _activate_portal_button() -> void:
	if portal_activated: return
	portal_activated = true
	portal_button.show()


func _check_if_show_email_alert() -> void:
	var show_alert_icon := false
	for email in GameState.emails:
		if !portal_activated && email.read && email.trigger_portal:
			_activate_portal_button()
		if email.sent_index > -1 && !email.read:
			show_alert_icon = true
	alert_icon.visible = show_alert_icon
