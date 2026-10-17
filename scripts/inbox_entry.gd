extends Container
class_name InboxEntry


@onready var hover_panel: Panel = %HoverPanel
#@onready var email_icon: TextureRect = %EmailIcon
@onready var alert_icon: Container = %AlertIcon
@onready var subject_label: Label = %SubjectLabel
@onready var from_label: Label = %FromLabel
@onready var own_button: BaseButton = %OwnButton


func _check_refs() -> void:
	if hover_panel == null: hover_panel = %HoverPanel
	#if email_icon == null: email_icon = %EmailIcon
	if alert_icon == null: alert_icon = %AlertIcon
	if subject_label == null: subject_label = %SubjectLabel
	if from_label == null: from_label = %FromLabel
	if own_button == null: own_button = %OwnButton


func set_up_inbox_entry(email: EmailRes) -> void:
	_check_refs()
	hover_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	own_button.pressed.connect(_mark_read)
	own_button.button_down.connect(_switch_entry_style_box.bind(true))
	own_button.button_up.connect(_switch_entry_style_box.bind(false))
	if email.read: _mark_read(false)
	subject_label.text = email.email_subject
	from_label.text = email.email_from


func _mark_read(delay: bool = true) -> void:
	if delay: await get_tree().create_timer(GameState.UI_PAUSE_LENGTH).timeout
	alert_icon.hide()
	#email_icon.texture = GameState.read_email_icon


func _switch_entry_style_box(is_pressed: bool) -> void:
	if is_pressed:
		hover_panel.add_theme_stylebox_override('panel', GameState.entry_press_style_box)
	else:
		hover_panel.add_theme_stylebox_override('panel', GameState.entry_hover_style_box)
