extends CustomWindow
class_name EmailApp


@onready var inbox_vbox: Container = %InboxVBox
@onready var details: Container = %Details
@onready var subject_label: Label = %SubjectLabel
@onready var from_label: Label = %FromLabel
@onready var to_label: Label = %ToLabel
@onready var body_label: RichTextLabel = %BodyLabel


func _ready() -> void:
	super()
	GameState.blog_post_published.connect(_refresh_emails.unbind(1))
	details.hide()
	_refresh_emails()


func toggle_window(should_show: bool) -> void:
	super(should_show)
	if should_show:
		details.hide()
		_refresh_emails()


func _refresh_emails() -> void:
	for child in inbox_vbox.get_children():
		inbox_vbox.remove_child(child)
		child.queue_free()
	for email in GameState.emails:
		if email.sent:
			var entry: InboxEntry = GameState.inbox_entry_scene.instantiate()
			entry.set_up_inbox_entry(email)
			entry.own_button.pressed.connect(_show_email_details.bind(email.id))
			inbox_vbox.add_child(entry)
			inbox_vbox.move_child(entry, 0)


func _show_email_details(email_id: int) -> void:
	var email = GameState.get_entry(GameState.emails, email_id)
	if email is not EmailRes: return
	await get_tree().create_timer(GameState.UI_PAUSE_LENGTH).timeout
	email.read = true
	subject_label.text = email.email_subject
	from_label.text = email.email_from
	to_label.text = email.email_to
	body_label.text = email.email_body
	details.show()
