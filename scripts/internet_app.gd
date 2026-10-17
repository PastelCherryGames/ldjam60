extends CustomWindow
class_name InternetApp


@onready var search_line_edit: LineEdit = %SearchLineEdit
@onready var search_button: BaseButton = %SearchButton
@onready var back_button: BaseButton = %BackButton
@onready var forward_button: BaseButton = %ForwardButton
@onready var search_result_label: RichTextLabel = %SearchResultLabel
@onready var notify_vbox: Container = %NotifyVBox

var no_results := false


func _ready() -> void:
	super()
	search_line_edit.max_length = GameState.get_longest_search_keyword_length()
	search_line_edit.text_submitted.connect(_search_internet)
	search_button.pressed.connect(_search_internet.bind(search_line_edit.text))
	back_button.pressed.connect(_move_through_history.bind(-1))
	forward_button.pressed.connect(_move_through_history.bind(1))
	_update_back_forward_buttons()


func toggle_window(should_show: bool) -> void:
	super(should_show)
	if should_show:
		pass


func _search_internet(search_text: String) -> void:
	no_results = false
	if GameState.search_history_position_offset < -1:
		GameState.search_history.resize(GameState.search_history.size() + (1+GameState.search_history_position_offset))
		GameState.search_history_position_offset = -1
	for child in notify_vbox.get_children(): child.hide()
	for search_result in GameState.search_results:
		if search_result.search_result_keywords.has(search_text.strip_edges().to_lower()):
			GameState.search_history.append(search_result.id)
			search_result_label.text = search_result.search_result_text
			if !search_result.visited:
				search_result.visited = true
				## check if info discovered, show notification
				GameState.search_result_discovered.emit(search_result.id)
			else:
				## show visited notification
				pass
			_update_back_forward_buttons()
			return
	no_results = true
	_update_back_forward_buttons()
	search_result_label.text = GameState.no_results_message


func _move_through_history(direction: int) -> void:
	if (
		(!no_results || (no_results && GameState.search_history.size() < 1))
		&& (
			(GameState.search_history_position_offset + direction) > -1
			|| (GameState.search_history_position_offset + direction) < (GameState.search_history.size() * -1)
		)
	): return
	
	if !no_results: GameState.search_history_position_offset += direction
	_update_back_forward_buttons()
	for child in notify_vbox.get_children(): child.hide()
	var history_result: SearchResultRes = GameState.get_entry(
		GameState.search_results,
		GameState.search_history[GameState.search_history_position_offset]
	)
	no_results = false
	search_result_label.text = history_result.search_result_text
	## show visited notification


func _update_back_forward_buttons() -> void:
	if no_results:
		GameState.search_history_position_offset = -1
		back_button.disabled = GameState.search_history.size() < 1
		forward_button.disabled = true
	else:
		back_button.disabled = GameState.search_history.size() <= 1 || (GameState.search_history.size() + GameState.search_history_position_offset < 1)
		forward_button.disabled = GameState.search_history_position_offset >= -1
