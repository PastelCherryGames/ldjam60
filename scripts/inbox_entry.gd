extends Container
class_name InboxEntry


@onready var hover_panel: Panel = %HoverPanel
@onready var email_icon: TextureRect = %EmailIcon
@onready var subject_label: Label = %SubjectLabel
@onready var from_label: Label = %FromLabel
@onready var own_button: BaseButton = %OwnButton


func _check_refs() -> void:
	if hover_panel == null: hover_panel = %HoverPanel
	if email_icon == null: email_icon = %EmailIcon
	if subject_label == null: subject_label = %SubjectLabel
	if from_label == null: from_label = %FromLabel
	if own_button == null: own_button = %OwnButton


func set_up_inbox_entry(email: EmailRes) -> void:
	_check_refs()
	hover_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	own_button.pressed.connect(_mark_read)
	if email.read: _mark_read()
	subject_label.text = email.email_subject
	from_label.text = email.email_from


func _mark_read() -> void:
	email_icon.texture = GameState.read_email_icon
