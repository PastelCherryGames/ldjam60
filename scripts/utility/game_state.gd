@tool
extends Node
#class_name GameState


@warning_ignore("unused_signal")
signal app_requested(app: E.App)
@warning_ignore("unused_signal")
signal blog_post_submitted(post_id: int)
signal blog_post_published(post_id: int)


@export var app_names: Dictionary[E.App, String] = {}
@export var emails: Array[EmailRes] = []:
	set(new_emails):
		if Engine.is_editor_hint():
			for index in new_emails.size():
				if new_emails[index] == null:
					new_emails[index] = EmailRes.new()
					var new_email_id: int = GameState.get_next_id(emails)
					new_emails[index].id = new_email_id
		emails = new_emails

@export_group('Scenes')
@export var inbox_entry_scene: PackedScene

@export_group('Assets')
@export var unread_email_icon: Texture2D
@export var read_email_icon: Texture2D


func _ready() -> void:
	blog_post_submitted.connect(_handle_submitted_blog_post)


func destroy_tween(tween: Tween) -> Tween:
	if tween != null: tween.kill()
	return null


func get_next_id(id_array: Array) -> int:
	var next_id := 0
	for entry in id_array: if entry.id == next_id: next_id += 1
	return next_id


func get_entry(id_array: Array, search_id: int) -> Resource:
	for entry in id_array:
		if entry.id == search_id: return entry
	return null


func _handle_submitted_blog_post(post_id: int) -> void:
	for email in emails:
		pass # check if email should be marked read
	
	blog_post_published.emit(post_id)
