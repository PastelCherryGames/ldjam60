@tool
extends Node
#class_name GameState


@warning_ignore("unused_signal")
signal app_requested(app: E.App)
@warning_ignore("unused_signal")
signal search_result_discovered(result_id: int)
@warning_ignore("unused_signal")
signal blog_post_submitted(post_id: int)
signal blog_post_published(post_id: int)


const UI_PAUSE_LENGTH: float = 0.075

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
@export var search_results: Array[SearchResultRes] = []:
	set(new_search_results):
		if Engine.is_editor_hint():
			for index in new_search_results.size():
				if new_search_results[index] == null:
					new_search_results[index] = SearchResultRes.new()
					var new_search_result_id: int = GameState.get_next_id(search_results)
					new_search_results[index].id = new_search_result_id
		search_results = new_search_results
@export_multiline var no_results_message: String = ''
var search_history: Array[int] = []
var search_history_position_offset: int = -1

@export_group('Scenes')
@export var inbox_entry_scene: PackedScene

@export_group('Assets')
@export var unread_email_icon: Texture2D
@export var read_email_icon: Texture2D
@export var entry_hover_style_box: StyleBox
@export var entry_press_style_box: StyleBox


func _ready() -> void:
	if Engine.is_editor_hint(): return
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




## DOUBLE CHECK THIS AND SET WHAT LENGTH SHOULD BE BEFORE SHIPPING
func get_longest_search_keyword_length() -> int:
	var longest: int = 20
	for search_result in search_results:
		for keyword in search_result.search_result_keywords:
			if keyword.length() > longest:
				longest = keyword.length()
	#print(longest)
	return longest


## FOR DEBUG
func _check_if_search_keyword_exists(search_keyword: String) -> void:
	var ids := ''
	for search_result in search_results:
		if search_result.search_result_keywords.has(search_keyword):
			if ids.length() > 0: ids += ', '
			ids += str(search_result.id)
	if ids.length() > 0:
		print('FOUND "' + search_keyword + '": ' + ids)
	else: print('DID NOT FIND "' + search_keyword)


## FOR DEBUG
#func _check_if_duplicate_search_keyword() -> void:
	#var ids := ''
	#for search_result in search_results:
		#if search_result.search_result_keywords.has(search_keyword):
			#if ids.length() > 0: ids += ', '
			#ids += str(search_result.id)
	#if ids.length() > 0:
		#print('FOUND "' + search_keyword + '": ' + ids)
	#else: print('DID NOT FIND "' + search_keyword)
