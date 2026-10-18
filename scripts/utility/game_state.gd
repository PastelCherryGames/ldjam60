@tool
extends Node
#class_name GameState


@warning_ignore("unused_signal")
signal app_requested(app: E.App)
signal email_read(email_id: int)
signal search_result_discovered(result_id: int)
@warning_ignore("unused_signal")
signal info_selected()
signal blog_post_unlocked()
signal blog_post_submitted(post_id: int)
signal blog_post_published(post_id: int)


const UI_PAUSE_LENGTH: float = 0.075
const EMAIL_TO: String = 'Old Tech Enthusiast'

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
@export var portal_search_results: Array[SearchResultRes] = []:
	set(new_search_results):
		if Engine.is_editor_hint():
			for index in new_search_results.size():
				if new_search_results[index] == null:
					new_search_results[index] = SearchResultRes.new()
					var new_search_result_id: int = GameState.get_next_id(portal_search_results)
					new_search_results[index].id = new_search_result_id
		portal_search_results = new_search_results
@export var blog_posts: Array[BlogPostRes] = []:
	set(new_blog_posts):
		if Engine.is_editor_hint():
			for index in new_blog_posts.size():
				if new_blog_posts[index] == null:
					new_blog_posts[index] = BlogPostRes.new()
					var new_post_id: int = GameState.get_next_id(blog_posts)
					new_blog_posts[index].id = new_post_id
		blog_posts = new_blog_posts
@export var infos: Array[InfoRes] = []:
	set(new_infos):
		if Engine.is_editor_hint():
			for index in new_infos.size():
				if new_infos[index] == null:
					new_infos[index] = InfoRes.new()
					var new_info_id: int = GameState.get_next_id(infos)
					new_infos[index].id = new_info_id
		infos = new_infos

@export_group('No Results Messages')
@export_multiline var no_results_message: String = ''
@export_multiline var portal_no_results_message: String = ''

var search_history: Array[int] = []
var search_history_position_offset: int = -1
var portal_search_history: Array[int] = []
var portal_search_history_position_offset: int = -1

var selected_info: int = -1


@export_group('Scenes')
@export var inbox_entry_scene: PackedScene
@export var info_entry_scene: PackedScene
@export var blog_post_entry_scene: PackedScene
@export var info_button_scene: PackedScene

@export_group('Assets')
#@export var unread_email_icon: Texture2D
#@export var read_email_icon: Texture2D
@export var entry_hover_style_box: StyleBox
@export var entry_press_style_box: StyleBox
@export var unpublished_post_style_box: StyleBox
@export var published_post_style_box: StyleBox


func _ready() -> void:
	if Engine.is_editor_hint(): return
	email_read.connect(_check_if_unlock_blog_post.unbind(1))
	search_result_discovered.connect(_check_if_unlock_blog_post.unbind(1))
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


func get_found_index(index_array: Array, prop_name: String) -> int:
	var index_to_return: int = 0
	for entry in index_array:
		index_to_return = maxi(entry[prop_name], index_to_return)
	return index_to_return + 1


func sort_emails(a: EmailRes, b: EmailRes) -> bool:
	return a.sent_index < b.sent_index


func sort_blog_posts(a: BlogPostRes, b: BlogPostRes) -> bool:
	if a.published_index < 0 && b.published_index > -1: return true
	if (
		(a.published_index > -1 && b.published_index > -1)
		&& a.published_index > b.published_index
	): return true
	if (
		(a.published_index < 0 && b.published_index < 0)
		&& a.unlocked_index > b.unlocked_index
	): return true
	return false


func sort_infos(a: InfoRes, b: InfoRes) -> bool:
	return a.discovered_index < b.discovered_index


func _handle_submitted_blog_post(post_id: int) -> void:
	var published_post_count: int = 0
	for post in blog_posts:
		if post.published_index > -1:
			published_post_count += 1
	for email in emails:
		if email.sent_index > -1: continue
		var send_email := true
		if published_post_count < email.email_num_blog_posts:
			send_email = false
			continue
		for prereq in email.email_prereq_blog_posts:
			if get_entry(blog_posts, prereq).published_index < 0:
				send_email = false
		if send_email:
			email.sent_index = get_found_index(emails, 'sent_index')
	
	await get_tree().create_timer(GameState.UI_PAUSE_LENGTH).timeout
	blog_post_published.emit(post_id)


func _check_if_unlock_blog_post() -> void:
	var a_post_was_unlocked := false
	for post in blog_posts:
		if post.unlocked_index > -1: continue
		var unlock_post := true
		for email_id in post.email_prereqs:
			var email = get_entry(emails, email_id)
			if !email.read: unlock_post = false
		for info_id in post.info_prereqs:
			var info = get_entry(infos, info_id)
			if info.discovered_index < 0: unlock_post = false
		if unlock_post:
			a_post_was_unlocked = true
			post.unlocked_index = get_found_index(blog_posts, 'unlocked_index')
	
	await get_tree().create_timer(GameState.UI_PAUSE_LENGTH).timeout
	if a_post_was_unlocked: blog_post_unlocked.emit()



## DOUBLE CHECK THIS AND SET WHAT LENGTH SHOULD BE BEFORE SHIPPING
func get_longest_search_keyword_length(app: E.App) -> int:
	var longest: int = 20
	var database: Array[SearchResultRes] = search_results
	if app == E.App.PORTAL: database = portal_search_results
	for search_result in database:
		for keyword in search_result.search_result_keywords:
			if keyword.length() > longest:
				longest = keyword.length()
	#print(longest)
	return longest


## FOR DEBUG
func _check_if_search_keyword_exists(search_keyword: String, app: E.App) -> void:
	var ids := ''
	var database: Array[SearchResultRes] = search_results
	if app == E.App.PORTAL: database = portal_search_results
	for search_result in database:
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
