extends CustomWindow
class_name InternetApp


@onready var search_line_edit: LineEdit = %SearchLineEdit
@onready var search_button: BaseButton = %SearchButton
@onready var back_button: BaseButton = %BackButton
@onready var forward_button: BaseButton = %ForwardButton
@onready var search_result_label: RichTextLabel = %SearchResultLabel
@onready var notify_vbox: Container = %NotifyVBox
@onready var notify_info: Control = %NotifyInfoEntry
@onready var notify_source: Control = %NotifySourceEntry
@onready var notify_visited: Control = %NotifyVisitedEntry

var no_results := false


func _ready() -> void:
	super()
	notify_info.hide()
	notify_source.hide()
	notify_visited.hide()
	search_result_label.text = ''
	search_line_edit.max_length = GameState.get_longest_search_keyword_length(E.App.INTERNET)
	search_line_edit.text_submitted.connect(_search_internet.unbind(1))
	search_button.pressed.connect(_search_internet)
	back_button.pressed.connect(_move_through_history.bind(-1))
	forward_button.pressed.connect(_move_through_history.bind(1))
	_update_back_forward_buttons()


func toggle_window(should_show: bool) -> void:
	super(should_show)


func _search_internet() -> void:
	var search_text: String = search_line_edit.text
	no_results = false
	notify_info.hide()
	notify_source.hide()
	notify_visited.hide()
	var database: Array[SearchResultRes] = GameState.search_results
	var database_history: Array[int] = GameState.search_history
	var database_history_offset: int = GameState.search_history_position_offset
	if own_app == E.App.PORTAL:
		database = GameState.portal_search_results
		database_history = GameState.portal_search_history
		database_history_offset = GameState.portal_search_history_position_offset
	
	if database_history_offset < -1:
		database_history.resize(database_history.size() + (1+database_history_offset))
		database_history_offset = -1
		if own_app == E.App.PORTAL:
			GameState.portal_search_history_position_offset = -1
		else:
			GameState.search_history_position_offset = -1
	for child in notify_vbox.get_children(): child.hide()
	for search_result in database:
		if search_result.search_result_keywords.has(search_text.strip_edges().to_lower()):
			database_history.append(search_result.id)
			await get_tree().create_timer(GameState.UI_PAUSE_LENGTH).timeout
			search_result_label.text = search_result.search_result_text
			if !search_result.visited:
				search_result.visited = true
				## check if info discovered, show notification
				for info_id in search_result.discoverable_infos:
					var info: InfoRes = GameState.get_entry(GameState.infos, info_id)
					if info.discovered_index < 0:
						info.discovered_index = GameState.get_found_index(GameState.infos, 'discovered_index')
						notify_info.show()
					else:
						pass
						## if source already discovered, but doesn't have source, add source
						## and show notification
						#notify_source.show()
				GameState.search_result_discovered.emit(search_result.id)
			else:
				notify_visited.show()
			_update_back_forward_buttons()
			return
	no_results = true
	await get_tree().create_timer(GameState.UI_PAUSE_LENGTH).timeout
	_update_back_forward_buttons()
	if own_app == E.App.PORTAL:
		search_result_label.text = GameState.portal_no_results_message
	else:
		search_result_label.text = GameState.no_results_message


func _move_through_history(direction: int) -> void:
	var database: Array[SearchResultRes] = GameState.search_results
	var database_history: Array[int] = GameState.search_history
	var database_history_offset: int = GameState.search_history_position_offset
	if own_app == E.App.PORTAL:
		database = GameState.portal_search_results
		database_history = GameState.portal_search_history
		database_history_offset = GameState.portal_search_history_position_offset
	
	if (
		(!no_results || (no_results && database_history.size() < 1))
		&& (
			(database_history_offset + direction) > -1
			|| (database_history_offset + direction) < (database_history.size() * -1)
		)
	): return
	
	if !no_results:
		database_history_offset += direction
		if own_app == E.App.PORTAL:
			GameState.portal_search_history_position_offset += direction
		else:
			GameState.search_history_position_offset += direction
	_update_back_forward_buttons()
	for child in notify_vbox.get_children(): child.hide()
	var history_result: SearchResultRes = GameState.get_entry(
		database,
		database_history[database_history_offset]
	)
	no_results = false
	await get_tree().create_timer(GameState.UI_PAUSE_LENGTH).timeout
	search_result_label.text = history_result.search_result_text
	notify_info.hide()
	notify_source.hide()
	notify_visited.show()


func _update_back_forward_buttons() -> void:
	var database_history: Array[int] = GameState.search_history
	var database_history_offset: int = GameState.search_history_position_offset
	if own_app == E.App.PORTAL:
		database_history = GameState.portal_search_history
		database_history_offset = GameState.portal_search_history_position_offset
	
	if no_results:
		database_history_offset = -1
		if own_app == E.App.PORTAL:
			GameState.portal_search_history_position_offset = -1
		else:
			GameState.search_history_position_offset = -1
		back_button.disabled = database_history.size() < 1
		forward_button.disabled = true
	else:
		back_button.disabled = database_history.size() <= 1 || (database_history.size() + GameState.search_history_position_offset < 1)
		forward_button.disabled = database_history_offset >= -1
