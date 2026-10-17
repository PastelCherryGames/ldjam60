extends Resource
class_name CustomTweenRes

@export var enabled := true
@export var nodepath: NodePath
## Make sure to also make resource local to scene if using this option.
@export var make_unique: bool = false
@export var param_type: CustomTweener.Tween_Param_Type = CustomTweener.Tween_Param_Type.NORMAL
@export var property: String
@export var values: Dictionary = {true: "", false: ""}
