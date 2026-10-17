extends Container
class_name InfoEntry


@onready var hover_panel: Panel = %HoverPanel
@onready var blurb_label: Label = %BlurbLabel
@onready var link_hbox: Container = %LinkHBox
@onready var own_button: BaseButton = %OwnButton

var own_info_id: int = -1
var selected := false


func _check_refs() -> void:
	if hover_panel == null: hover_panel = %HoverPanel
	if blurb_label == null: blurb_label = %BlurbLabel
	if link_hbox == null: link_hbox = %LinkHBox
	if own_button == null: own_button = %OwnButton


func set_up_info_entry(info: InfoRes) -> void:
	_check_refs()
	own_info_id = info.id
	hover_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	own_button.pressed.connect(_select_own_info)
	own_button.button_down.connect(_switch_entry_style_box.bind(true))
	own_button.button_up.connect(_switch_entry_style_box.bind(false))
	GameState.info_selected.connect(_toggle_info)
	blurb_label.text = info.info_blurb
	_refresh_source_links()


func _select_own_info() -> void:
	if GameState.selected_info == own_info_id:
		GameState.selected_info = -1
	else:
		GameState.selected_info = own_info_id
		own_button.allow_change(false)
	GameState.info_selected.emit()


func _toggle_info() -> void:
	## toggle on
	if !selected && own_info_id == GameState.selected_info:
		selected = true
	## toggle off
	else:
		selected = false
		own_button.allow_change(true)
		own_button.toggle(false)


func _refresh_source_links() -> void:
	_check_refs()
	var info: InfoRes = GameState.get_entry(GameState.infos, own_info_id)
	if info == null: return
	if info.discovered_search_sources.size() + info.discovered_portal_sources.size() == link_hbox.get_child_count():
		return
	
	for child in link_hbox.get_children():
		link_hbox.remove_child(child)
		child.queue_free()
	var source_count: int = 0
	for source in info.discovered_search_sources:
		source_count += 1
		var new_source := LinkButton.new()
		new_source.text = 'Source ' + str(source_count)
		#new_source.pressed.connect
		link_hbox.add_child(new_source)
	for source in info.discovered_portal_sources:
		source_count += 1
		var new_source := LinkButton.new()
		new_source.text = 'Source ' + str(source_count)
		#new_source.pressed.connect
		link_hbox.add_child(new_source)


func _switch_entry_style_box(is_pressed: bool) -> void:
	if is_pressed:
		hover_panel.add_theme_stylebox_override('panel', GameState.entry_press_style_box)
	else:
		hover_panel.add_theme_stylebox_override('panel', GameState.entry_hover_style_box)
