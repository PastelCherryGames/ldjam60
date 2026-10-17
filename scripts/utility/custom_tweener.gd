extends Node
class_name CustomTweener

signal toggle_started(is_focused: bool)
signal toggle_finished(is_focused: bool)
signal tweener_destroy()

enum Tween_Param_Type {NORMAL, SHADER, THEME_OVERRIDE}
enum UI_Signals {UNHANDLED, FOCUS, PRESS}
var toggle_state := false
@export var signal_trigger: UI_Signals = UI_Signals.FOCUS
@export var properties_to_tween: Array[CustomTweenRes] = []

@export_group('Transition Parameters')
@export var focus_time: float = 0.35
@export var unfocus_time: float = 0.35
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EaseType.EASE_IN_OUT

@export_group('Special Parameters')
@export var trigger_button: Control = null
@export var hide_show_node: Control = null
@export var set_params_on_start := true
@export var tween_in_out := false
@export var destroy_after_out := false
@export var node_to_destroy_after_out: Node = null
@export var hide_show_with_tween := false
@export var in_out_delay := 1.0
@export var no_change_while_tweening := false

var tween: Tween = null
var show_change := true
var paused_while_tweening := false

#var test_length := 0.0

func _ready() -> void:
	for index in properties_to_tween.size():
		if properties_to_tween[index].make_unique:
			properties_to_tween[index] = properties_to_tween[index].duplicate()
	
	if signal_trigger == UI_Signals.UNHANDLED && set_params_on_start:
		set_props(false)
	elif signal_trigger == UI_Signals.FOCUS:
		if trigger_button != null:
			trigger_button.focus_entered.connect(toggle.bind(true))
			trigger_button.focus_exited.connect(toggle.bind(false))
			trigger_button.mouse_entered.connect(toggle.bind(true))
			trigger_button.mouse_exited.connect(toggle.bind(false))
		else:
			self.focus_entered.connect(toggle.bind(true))
			self.focus_exited.connect(toggle.bind(false))
			self.mouse_entered.connect(toggle.bind(true))
			self.mouse_exited.connect(toggle.bind(false))
	elif signal_trigger == UI_Signals.PRESS && trigger_button != null:
		trigger_button.pressed.connect(toggle.bind(true))
	
	if hide_show_with_tween && hide_show_node != null && set_params_on_start:
		hide_show_node.hide()


#func _process(delta: float) -> void:
	#if self.name == 'HiddenHBox' && tween != null:
		#test_length += delta
		#print('tween')


func allow_change(change: bool) -> void:
	show_change = change


func toggle(should_focus: bool, override_show_change: bool = false) -> void:
	if (show_change || override_show_change) && !paused_while_tweening && should_focus != toggle_state:
		#if delay > 0.0: await get_tree().create_timer(delay).timeout
		if hide_show_with_tween && hide_show_node != null && should_focus:
			hide_show_node.visible = true
		toggle_state = should_focus
		#if no_change_while_tweening: paused_while_tweening = true
		if tween != null: tween.kill()
		tween = self.create_tween()
		tween.set_trans(transition_type)
		tween.set_ease(ease_type)
		tween.set_parallel()
		
		for prop in properties_to_tween:
			if !prop.enabled: continue
			var prop_path: String = prop.property
			if prop.param_type == Tween_Param_Type.SHADER: prop_path = "instance_shader_parameters/" + prop.property
			elif prop.param_type == Tween_Param_Type.THEME_OVERRIDE: prop_path = "theme_override_constants/" + prop.property
			tween.tween_property(get_node(prop.nodepath), prop_path, prop.values[should_focus], focus_time if should_focus else unfocus_time)
		toggle_started.emit(should_focus)
		
		if tween_in_out && should_focus:
			#if self.name == 'HiddenHBox':
				#print('1')
			tween.tween_callback(
				_handle_tween_finish_in_out_focus.bind(should_focus)
			).set_delay(focus_time + in_out_delay)
		elif !should_focus && destroy_after_out:
			#if self.name == 'HiddenHBox':
				#print('2')
			tween.tween_callback(
				_handle_tween_finish_destroy_unfocus.bind(should_focus)
			).set_delay(unfocus_time)
		else:
			#if self.name == 'HiddenHBox':
				#print('3')
				#print((focus_time if should_focus else unfocus_time))
			tween.tween_callback(
				_handle_tween_finish.bind(should_focus)
			).set_delay((focus_time if should_focus else unfocus_time))


func set_props(should_focus: bool) -> void:
	for prop in properties_to_tween:
		if !prop.enabled: continue
		if prop.param_type == Tween_Param_Type.SHADER:
			get_node(prop.nodepath).set_instance_shader_parameter(prop.property, prop.values[should_focus])
		elif prop.param_type == Tween_Param_Type.THEME_OVERRIDE:
			get_node(prop.nodepath).add_theme_constant_override(prop.property, prop.values[should_focus])
		else:
			if prop.property.contains(':'):
				var property_path = prop.property.split(':')
				get_node(prop.nodepath)[property_path[0]][property_path[1]] = prop.values[should_focus]
			else:
				get_node(prop.nodepath)[prop.property] = prop.values[should_focus]


func _handle_tween_finish_in_out_focus(should_focus: bool) -> void:
	toggle_finished.emit(should_focus)
	toggle(false)


func _handle_tween_finish_destroy_unfocus(should_focus: bool) -> void:
	if !destroy_after_out: return
	toggle_finished.emit(should_focus)
	tweener_destroy.emit()
	if node_to_destroy_after_out == null:
		self.queue_free()
	else:
		node_to_destroy_after_out.queue_free()


func _handle_tween_finish(should_focus: bool) -> void:
	#if self.name == 'HiddenHBox':
		#print(tween.get_total_elapsed_time())
		#print(test_length)
	if hide_show_with_tween && hide_show_node != null && !should_focus:
		hide_show_node.visible = false
	tween = GameState.destroy_tween(tween)
	toggle_finished.emit(should_focus)


func manual_end_tween() -> void:
	tween = GameState.destroy_tween(tween)
	toggle_state = !toggle_state
