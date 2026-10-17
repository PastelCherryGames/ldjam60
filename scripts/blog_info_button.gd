extends Button
class_name BlogInfoButton


signal assigned_info_id_updated()


var assigned_info_id: int = -1


func _ready() -> void:
	self.pressed.connect(_info_button_pressed)


func _info_button_pressed() -> void:
	if GameState.selected_info > -1:
		self.assigned_info_id = GameState.selected_info
		GameState.selected_info = -1
		self.text = GameState.get_entry(GameState.infos, self.assigned_info_id).info_blurb
		self.theme_type_variation = 'SmallButtonEntryFilled'
		GameState.info_selected.emit()
		assigned_info_id_updated.emit()
	elif self.assigned_info_id > -1:
		self.assigned_info_id = -1
		self.text = ''
		self.theme_type_variation = 'SmallButtonEntryUnfilled'
		assigned_info_id_updated.emit()
